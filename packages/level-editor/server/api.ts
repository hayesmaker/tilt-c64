// Build API for the Tilt maze editor (plain Node, no dependencies). Used as
// middleware by the Vite dev server (vite.config.ts) and by server/index.ts.
//
//   GET  /api/original            the original maze set (tilt-mod/mazes/original.json)
//   POST /api/build               build tilt-mod with the posted maze set (JSON)
//   GET  /api/builds/<id>/<file>  tilt-mod.crt, mazes.json, build.log
//
// Every build runs in its own copy of the tilt-mod package (src, tools,
// build.sh), so the package itself is never changed.

import { execFile } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import type { IncomingMessage, ServerResponse } from 'node:http';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

export interface ApiOptions {
  /** packages/tilt-mod */
  modDir: string;
  original: string;
  kickass?: string;
  buildsDir?: string;
  keepBuilds?: number;
  timeoutMs?: number;
}

export interface BuildResult {
  id: string;
  ok: boolean;
  /** the first error line (mazes.py validation or KickAssembler) */
  error: string;
  log: string;
  ms: number;
  files: string[];
  crtBytes?: number;
}

const BUILD_FILES = new Set(['tilt-mod.crt', 'mazes.json', 'build.log']);
const MAX_BODY = 2 * 1024 * 1024;
type Next = (err?: unknown) => void;

function send(res: ServerResponse, code: number, body: unknown, type = 'application/json') {
  res.writeHead(code, { 'Content-Type': type, 'Cache-Control': 'no-store' });
  res.end(type === 'application/json' ? JSON.stringify(body) : (body as Buffer));
}

function readBody(req: IncomingMessage): Promise<string> {
  return new Promise((resolve, reject) => {
    let size = 0;
    const parts: Buffer[] = [];
    req.on('data', (d: Buffer) => {
      size += d.length;
      if (size > MAX_BODY) reject(new Error('request too large'));
      else parts.push(d);
    });
    req.on('end', () => resolve(Buffer.concat(parts).toString('utf8')));
    req.on('error', reject);
  });
}

/** The first line of the log that looks like an error. */
export function firstError(log: string): string {
  const lines = log.split('\n');
  const i = lines.findIndex((l) => /^Error:|ERROR IN ASSERTION|^need |: (screen|bad|needs|.*must)/.test(l.trim()));
  if (i < 0) return '';
  const at = lines[i + 1]?.trim().startsWith('at line') ? ' ' + lines[i + 1].trim() : '';
  return lines[i].trim() + at;
}

export function createApi(opt: ApiOptions) {
  const buildsDir = opt.buildsDir ?? join(tmpdir(), 'tilt-editor-builds');
  const keep = opt.keepBuilds ?? 20;
  const kickass = opt.kickass ?? process.env.KICKASS ?? '/opt/KickAss.jar';
  let queue: Promise<unknown> = Promise.resolve();

  function prune() {
    if (!existsSync(buildsDir)) return;
    const dirs = readdirSync(buildsDir)
      .map((n) => ({ n, t: statSync(join(buildsDir, n)).mtimeMs }))
      .sort((a, b) => b.t - a.t);
    for (const d of dirs.slice(keep)) rmSync(join(buildsDir, d.n), { recursive: true, force: true });
  }

  function build(mazes: string): Promise<BuildResult> {
    const id = Date.now().toString(36) + randomBytes(3).toString('hex');
    const dir = join(buildsDir, id);
    const t0 = Date.now();
    mkdirSync(dir, { recursive: true });
    for (const p of ['src', 'tools', 'build.sh', 'mazes']) cpSync(join(opt.modDir, p), join(dir, p), { recursive: true });
    writeFileSync(join(dir, 'mazes.json'), mazes);
    return new Promise((resolve) => {
      execFile('sh', ['build.sh', 'mazes.json'], { cwd: dir, timeout: opt.timeoutMs ?? 60000, env: { ...process.env, KICKASS: kickass } },
        (err, stdout, stderr) => {
          let log = stdout + stderr;
          for (const f of ['build/kickass.log', 'build/kickass_cart.log'])
            if (existsSync(join(dir, f)) && err) log += '\n' + readFileSync(join(dir, f), 'utf8');
          const crt = join(dir, 'build/tilt-mod.crt');
          const ok = !err && existsSync(crt);
          writeFileSync(join(dir, 'build.log'), log);
          if (ok) cpSync(crt, join(dir, 'tilt-mod.crt'));
          rmSync(join(dir, 'src'), { recursive: true, force: true });
          resolve({
            id, ok, log, ms: Date.now() - t0,
            error: ok ? '' : firstError(log) || (err?.message ?? 'build failed'),
            files: ok ? ['tilt-mod.crt', 'mazes.json', 'build.log'] : ['mazes.json', 'build.log'],
            crtBytes: ok ? statSync(crt).size : undefined,
          });
          prune();
        });
    });
  }

  return async (req: IncomingMessage, res: ServerResponse, next: Next) => {
    const url = new URL(req.url ?? '/', 'http://x');
    if (!url.pathname.startsWith('/api/')) return next();
    try {
      if (req.method === 'GET' && url.pathname === '/api/original')
        return send(res, 200, JSON.parse(readFileSync(opt.original, 'utf8')));
      if (req.method === 'POST' && url.pathname === '/api/build') {
        const body = await readBody(req);
        JSON.parse(body);                                       // must be JSON
        const job = queue.then(() => build(body));              // one build at a time
        queue = job.catch(() => undefined);
        return send(res, 200, await job);
      }
      const m = /^\/api\/builds\/([a-z0-9]+)\/([\w.-]+)$/.exec(url.pathname);
      if (req.method === 'GET' && m && BUILD_FILES.has(m[2])) {
        const f = join(buildsDir, m[1], m[2]);
        if (!existsSync(f)) return send(res, 404, { error: 'no such build file' });
        const type = m[2].endsWith('.json') ? 'application/json' : m[2].endsWith('.log') ? 'text/plain' : 'application/octet-stream';
        return send(res, 200, readFileSync(f), type);
      }
      send(res, 404, { error: 'unknown API call' });
    } catch (e) {
      send(res, 400, { error: String((e as Error).message ?? e) });
    }
  };
}
