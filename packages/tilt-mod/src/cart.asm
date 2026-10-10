// ============================================================================
// TILT-MOD cartridge: the STATMAT 2023 Tilt cartridge plus maze banks
//
// tilt-mod: banks 10+ hold the maze set (tools/mazes.py build): bank 10 the
// maze directory, banks 11+ the maze screens. See src/maze_loader.asm.
//
// Original notes:
// Builds a byte-identical Tilt.crt from
//   - the cartridge loader (bank 0, this file)
//   - the game RAM image build/tilt.prg, assembled from src/tilt.asm first
//   - the loading picture (src/bin/pic_*.bin) and its viewer (bank 9, this file)
//
// Magic Desk (CRT hardware type 19): 8K ROM at $8000-$9FFF (EXROM low, GAME
// high). Writing to $DE00 selects the bank (bits 0-6); bit 7 switches the
// cartridge off so that RAM shows at $8000 again.
//
//   bank 0     $8000-$8333  loader (below)
//              $8334-$9FFF  game image $0334-$1FFF
//   bank 1-7   $8000-$9FFF  game image $2000-$FFFF (bank n -> n * $2000)
//   bank 8     $8000-$9F3F  loading picture: hires bitmap
//   bank 9     $8000-$83E7  loading picture: screen RAM (colours)
//              $8800-$8B85  picture viewer
//
// Start-up: the KERNAL reset routine finds "CBM80" at $8004 and jumps through
// $8000 (cold_start). The loader initialises the machine, runs the picture
// viewer (until fire / a key / 10 seconds), copies banks 0-7 to RAM, switches
// the cartridge off and jumps to the game at $0460.
// ============================================================================

.const DE00_OFF = $80                       // Magic Desk: bit 7 = cartridge off

// the game image, assembled from src/tilt.asm (load address $0334)
.var game = LoadBinary("../build/tilt.prg")
.function game_byte(addr) { .return game.get(addr - $0334 + 2) }
.assert "game image starts at $0334", game.get(0) + 256 * game.get(1), $0334
.assert "game image ends at $FFFF", game.getSize(), $10000 - $0334 + 2

// tilt-mod: the maze set, made by tools/mazes.py build
.var maze_dir = LoadBinary("../build/maze_dir.bin")
.var maze_banks = LoadBinary("../build/maze_banks.bin")
.assert "maze directory is one bank", maze_dir.getSize(), $2000
.assert "at most 16 banks (128K)", 11 + maze_banks.getSize() / $2000 <= 16, true

.file [name="tilt-mod.crt", type="bin", segments="Crt"]
.segmentdef Crt
.segmentdef Bank0 [start=$8000, min=$8000, max=$9fff, fill, fillByte=$ff]
.segmentdef Bank8 [start=$8000, min=$8000, max=$9fff, fill, fillByte=$ff]
.segmentdef Bank9 [start=$8000, min=$8000, max=$9fff, fill, fillByte=$ff]

// ----------------------------------------------------------------------------
// CRT file: 64 byte header, then one CHIP packet (16 byte header + 8K) per bank
// (all numbers in the CRT headers are big-endian)
// ----------------------------------------------------------------------------
.segment Crt
    .text "C64 CARTRIDGE   "
    .byte $00, $00, $00, $40                // header length
    .byte $01, $00                          // CRT version 1.0
    .byte $00, 19                           // hardware type 19: Magic Desk
    .byte $00                               // EXROM line: active (low)
    .byte $01                               // GAME line: inactive (high) -> 8K mode
    .fill 6, $00                            // reserved
    .text "TILT"                            // cartridge name, padded to 32 bytes
    .fill 32 - 4, $00

.macro chip_header(bank) {
    .text "CHIP"
    .byte $00, $00, $20, $10                // packet length $2010
    .byte $00, $00                          // chip type: ROM
    .byte >bank, <bank                      // bank number
    .byte $80, $00                          // load address $8000
    .byte $20, $00                          // ROM size $2000
}

    chip_header(0)
    .segmentout [segments="Bank0"]
    .for (var n = 1; n < 8; n++) {
        chip_header(n)
        .fill $2000, game_byte(n * $2000 + i)
    }
    chip_header(8)
    .segmentout [segments="Bank8"]
    chip_header(9)
    .segmentout [segments="Bank9"]
    // tilt-mod: maze directory and maze screens
    chip_header(10)
    .fill $2000, maze_dir.get(i)
    .for (var b = 0; b < maze_banks.getSize() / $2000; b++) {
        chip_header(11 + b)
        .fill $2000, maze_banks.get(b * $2000 + i)
    }

// ============================================================================
// Bank 0: loader
// ============================================================================
.segment Bank0
    .word cold_start                        // $8000 cold start vector
    .word warm_start                        // $8002 warm start vector (RESTORE)
    .byte $c3, $c2, $cd, '8', '0'           // $8004 "CBM80" signature
    .encoding "ascii"
    .text "[ STATMAT 2023 ]"                // $8009

// VIC-II register values written to $D000-$D02F by init_screen
vic_init_values:                            // $8019
    .fill 16, $00                           // sprite positions
    .byte $00                               // $D010 sprite X MSB
    .byte $0b                               // $D011 screen off, 25 rows
    .byte $00, $00, $00, $00                // $D012-$D015
    .byte $c8                               // $D016 40 columns, hires
    .byte $00                               // $D017
    .byte $15                               // $D018 screen $0400, upper case charset
    .byte $71                               // $D019 (acknowledges pending IRQs)
    .byte $f0                               // $D01A raster IRQ off
    .fill 5, $00                            // $D01B-$D01F
    .byte $00, $00                          // $D020/$D021 border, background black
    .byte $01, $02, $03, $f4                // $D022-$D025
    .byte $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7  // $D026-$D02D
    .byte $fc                               // $D02E
// the last table byte ($D02F, the C128 keypad register) doubles as a flag:
show_picture:                               // $8048
    .byte $01                               // <> 0: run the picture viewer in bank 9
stub_extra:                                 // $8049
    .byte $04                               // added to the length of start_stub
keep_cartridge:                             // $804A
    .byte $00                               // <> 0: leave bank 8 visible when the game starts

// ----------------------------------------------------------------------------
// Cold start: the usual KERNAL reset sequence, minus the cartridge check
// ----------------------------------------------------------------------------
cold_start:                                 // $804B
    ldx #$08
    stx $d016
    jsr $fda3                               // IOINIT: CIAs, SID, $00/$01
    lda #$00
    ldx #$18
!:  sta $d400,x                             // silence the SID
    dex
    bpl !-
    tay
!:  sta $0002,y                             // clear zero page, $0200 and $0300 pages
    sta $0200,y
    sta $0300,y
    iny
    bne !-
    ldx #$3c                                // tape buffer pointer = $033C
    ldy #$03
    stx $b2
    sty $b3
    ldx #$00                                // top of RAM = $A000 (RAMTAS without the test)
    ldy #$a0
    jsr $fd8c
    jsr $fd15                               // RESTOR: KERNAL vectors
    lda #$03
    sta $9a                                 // output device: screen
    lda #$00
    sta $99                                 // input device: keyboard
    jsr $e51b                               // init screen editor variables
    jsr $ff5e                               // wait for raster / set PAL-NTSC flag
    jsr $e453                               // BASIC vectors
    jsr $e3bf                               // BASIC RAM init
warm_start:                                 // $8090
    jsr init_screen
    lda show_picture
    beq copy_game
    ldx #viewer_stub_end - viewer_stub - 1
!:  lda viewer_stub,x                       // copy the 8 byte stub to $0100...
    sta $0100,x
    dex
    bpl !-
    jsr $0100                               // ...and show the picture (bank 9)
    jsr init_screen
    lda $dd00                               // VIC bank 0 again
    and #$fc
    ora #$03
    sta $dd00

copy_game:                                  // $80B3
    sei
    ldx #$34                                // bank 0 $8334-$83FF -> $0334-$03FF
!:  lda $8300,x
    sta $0300,x
    inx
    bne !-
    ldy #$00                                // copy_routine -> $0100 (256 bytes)
!:  lda copy_routine,y
    sta $0100,y
    dey
    bne !-
    lda #$33                                // RAM everywhere except the char ROM
    sta $01                                 // (ROML stays visible at $8000)
    lda #$00
    sta $fb                                 // bank being copied
    lda #$20
    sta $fc                                 // RAM page for bank 1
    jsr $0100                               // copy banks 0-7 to RAM
    lda #$3c                                // copy start_stub to $0100; carry is
    adc stub_extra                          // set here, so Y = $41
    tay
!:  lda start_stub,y
    sta $0100,y
    dey
    bpl !-
    jmp $0100

// ----------------------------------------------------------------------------
// Copied to $0100: select bank 9 and start the picture viewer there.
// The viewer ends with bank 0 selected and returns with RTS.
// ----------------------------------------------------------------------------
viewer_stub:                                // $80EB
.pseudopc $0100 {
    lda #$09
    sta $de00
    jmp viewer
}
viewer_stub_end:

// ----------------------------------------------------------------------------
// Copied to $0100: copy one cartridge bank ($8000-$9FFF) to RAM, page by page,
// then select the next bank, patch the destination pages and go again.
// For bank 0 the pages are $04,$04,$04,$04,$04,$05...$1F: the loader's own
// pages $8000-$83FF all go to $0400 and are then overwritten by $8400.
// For bank n the pages are patched to n*$20...n*$20+$1F ($FC counts up).
// ----------------------------------------------------------------------------
copy_routine:                               // $80F3
.pseudopc $0100 {
    ldy #$00
copy_page_loop:                             // $0102
    .for (var p = 0; p < 32; p++) {
        lda $8000 + p * $100,y
        sta max(p, 4) * $100,y              // high byte at $0107 + p * 6
    }
    dey
    beq copy_bank_done
    jmp copy_page_loop
copy_bank_done:
    lda #$37                                // ROML visible to change the bank
    sta $01
    inc $fb
    ldy $fb
    cpy #$08
    beq copy_all_done
    sty $de00                               // next bank
    lda #$33
    sta $01
    ldx #$07                                // patch the destination pages
!:  lda $fc
    sta $0100,x
    inc $fc
    txa
    clc
    adc #$06
    tax
    cmp #$c7
    bne !-
    jmp $0100
copy_all_done:
    lda #$00
    sta $de00
    rts
}

// The 256 byte copy above also takes the first 10 bytes of init_screen with it.
// ----------------------------------------------------------------------------
// Black colour RAM, VIC registers from vic_init_values
// ----------------------------------------------------------------------------
init_screen:                                // $81E9
    lda #$00
    tax
!:  sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $dae8,x
    inx
    bne !-
    ldx #$2f
!:  lda vic_init_values,x
    sta $d000,x
    dex
    bpl !-
    rts

// ----------------------------------------------------------------------------
// Copied to $0100 and run once all of the game is in RAM.
// ----------------------------------------------------------------------------
start_stub:                                 // $8207
.pseudopc $0100 {
    lda #$00
    sta $fb
    sta $fc
    lda keep_cartridge
    bne !keep+
    lda #DE00_OFF                           // switch the cartridge off
    .byte $2c                               // BIT abs: skips the next LDA
!keep:
    lda #$08
    sta $de00
    ldx #$fb                                // stack as after a normal BASIC start
    txs
    stx $cc                                 // cursor blink off
    lda $dd00                               // serial CLOCK/DATA out released
    and #$cf
    sta $dd00
!:  bit $dd00                               // wait until the serial bus is idle
    bvc !-                                  // (CLOCK and DATA in high)
    bpl !-
!:  bit $d011                               // wait for the bottom of the screen
    bpl !-
!:  bit $d011
    bmi !-
    jsr $fda3                               // IOINIT again
    lda $d011                               // screen on
    ora #$10
    sta $d011
    cli
    jmp $0460                               // game start (end of the original disk loader)
}
    .byte $ff                               // $8247 (also copied)

    .fill $830c - *, $ff
    .encoding "ascii"
    .text "832da99c4ed5269c5c8fd2aa53e3061b85bb19b6"   // $830C SHA-1 (of the original files?)

// bank 0 $8334-$9FFF: the game image $0334-$1FFF
    .fill $2000 - $0334, game_byte($0334 + i)

// ============================================================================
// Bank 8: loading picture, hires bitmap (shown with VIC bank 3: bitmap $E000)
// ============================================================================
.segment Bank8
    .import binary "bin/pic_bitmap.bin"

// ============================================================================
// Bank 9: loading picture screen RAM and the STATMAT picture viewer
// ============================================================================
.segment Bank9
    .import binary "bin/pic_screen.bin"     // $8000 screen RAM (copied to $D000)
    .fill $8400 - *, $ff                    // $8400 colour RAM (multicolour pictures only)
    .fill $8800 - *, $ff

// Viewer settings, copied to $02A7-$02B7
viewer_config:                              // $8800
    .byte $00                               // $02A7 border colour
    .byte $00                               // $02A8 background colour
    .byte $00                               // $02A9 <> 0: multicolour picture (with colour RAM)
    .byte $00                               // $02AA <> 0: play music
    .byte $0a, $00                          // $02AB/$02AC timeout in seconds (10)
    .byte $00                               // $02AD fake loading stripes (NMI): 0 off, 1, 2
    .byte $00, $00                          // $02AE/$02AF music: RAM address
    .byte $00                               // $02B0 music: length low byte
    .byte $00                               // $02B1 music: pages
    .byte $00                               // $02B2 music: tune number
    .byte $00, $00                          // $02B3/$02B4 music: init address
    .byte $00, $00                          // $02B5/$02B6 music: play address
    .byte $00                               // $02B7 <> 0: music on a CIA timer, not the raster IRQ

.label cfg_border       = $02a7
.label cfg_background   = $02a8
.label cfg_multicolour  = $02a9
.label cfg_music        = $02aa
.label cfg_timeout      = $02ab             // 16 bit
.label cfg_stripes      = $02ad
.label cfg_music_dest   = $02ae             // 16 bit
.label cfg_music_len    = $02b0
.label cfg_music_pages  = $02b1
.label cfg_music_tune   = $02b2
.label cfg_music_init   = $02b3             // 16 bit
.label cfg_music_play   = $02b5             // 16 bit
.label cfg_music_cia    = $02b7
.label stripe_counter   = $02b8             // 16 bit
.label frames_per_sec   = $02ba
.label frame_counter    = $02bb
.label timed_out        = $02bc
.label stripe_phase     = $02bd

viewer:                                     // $8811
    jsr irqs_off
    ldy #$11
    dey
!:  lda viewer_config,y
    sta cfg_border,y
    dey
    bpl !-
    ldy #$00                                // copy the bitmap copier to $0100 and run it
!:  lda bitmap_copier,y
    sta $0100,y
    iny
    cpy #bitmap_copier_end - bitmap_copier
    bne !-
    jsr $0100
    ldy #$00                                // raster IRQ handler -> $0400
!:  lda viewer_irq,y
    sta $0400,y
    iny
    cpy #viewer_irq_end - viewer_irq
    bne !-
    lda #<$0400
    sta $fffe
    lda #>$0400
    sta $ffff
    lda cfg_music
    beq no_music
    ldy #$00                                // NMI handler -> $0500
!:  lda viewer_nmi,y
    sta $0500,y
    iny
    cpy #viewer_nmi_end - viewer_nmi
    bne !-
    lda #<$0500
    sta $fffa
    lda #>$0500
    sta $fffb
    ldy #$00                                // music copier -> $0100, run it
!:  lda music_copier,y
    sta $0100,y
    iny
    cpy #music_copier_end - music_copier
    bne !-
    jsr $0100
no_music:
    // PAL or NTSC: the last raster line is $137 (PAL) or $105/$106 (NTSC)
!wait:
    lda $d012
!:  cmp $d012
    beq !-
    bmi !wait-
    and #$f0
    beq !ntsc+
    lda #50                                 // PAL: 50 frames per second
    .byte $2c                               // BIT abs: skips the next LDA
!ntsc:
    lda #60
    sta frames_per_sec
    sta frame_counter
    lda cfg_border
    sta $d020
    lda cfg_background
    sta $d021
    ldx #$00
    lda cfg_multicolour
    beq !copy_screen+
!:  lda $8400,x                             // colour RAM
    sta $d800,x
    lda $8500,x
    sta $d900,x
    lda $8600,x
    sta $da00,x
    lda $86e8,x
    sta $dae8,x
    inx
    bne !-
!copy_screen:
    lda #$33                                // screen RAM -> $D000 (RAM under the I/O)
    sta $01
!:  lda $8000,x
    sta $d000,x
    lda $8100,x
    sta $d100,x
    lda $8200,x
    sta $d200,x
    lda $82e8,x
    sta $d2e8,x
    inx
    bne !-
    ldy #$00                                // show routine -> $0100, run it
!:  lda show_picture_routine,y
    sta $0100,y
    iny
    cpy #show_picture_routine_end - show_picture_routine
    bne !-
    jmp $0100

// ----------------------------------------------------------------------------
// Copied to $0100: copy the bitmap from bank 8 to $E000-$FF40
// ----------------------------------------------------------------------------
bitmap_copier:                              // $88E9
.pseudopc $0100 {
    lda #$08
    sta $de00
    ldy #$00
!loop:
    .for (var p = 0; p < 31; p++) {
        lda $8000 + p * $100,y
        sta $e000 + p * $100,y
    }
    lda $9e41,y                             // the last 256 bytes, up to $9F40
    sta $fe41,y
    dey
    beq !+
    jmp !loop-
!:  lda #$09
    sta $de00
    rts
}
bitmap_copier_end:

// ----------------------------------------------------------------------------
// Copied to $0100: show the picture, wait for fire, a key or the timeout
// ----------------------------------------------------------------------------
show_picture_routine:                       // $89BC
.pseudopc $0100 {
    lda #$35                                // I/O, no ROMs
    sta $01
    lda $dd00                               // VIC bank 3 ($C000-$FFFF)
    and #$fc
    sta $dd00
    lda cfg_multicolour
    beq !+
    lda #$d8                                // multicolour
    .byte $2c                               // BIT abs: skips the next LDA
!:  lda #$c8                                // hires
    sta $d016
    lda #$48                                // screen $D000, bitmap $E000
    sta $d018
    lda #$3b                                // bitmap mode, screen on
    sta $d011
    ldx #$00
    stx timed_out
    lda cfg_stripes
    beq !no_stripes+
    stx $dd0f                               // CIA 2 timer B for the NMI stripes
    cmp #$01
    beq !+
    lda #$00
    sta $dd06
    lda #$01
    sta $dd07
    bne !start+
!:  lda #$40
    sta $dd06
    lda #$02
    sta $dd07
!start:
    lda #$83
    sta $dd0d
    lda #$11
    sta $dd0f
!no_stripes:
    lda cfg_music_cia
    beq !+
    ldx #$00                                // CIA 1 timer A IRQ for the music
    stx $dc0e
    lda #$83
    sta $dc0d
    inx
    stx $dc0e
!:  ldx #$00                                // raster IRQ at line 0
    stx $d012
    inx
    stx $d01a
    stx $d019
    cli
    clc
!wait_loop:
    .byte $24                               // BIT zp: hides the SEC
!fire_held:
    sec                                     // fire was pressed
    lda $dc00
    and #$10
    beq !fire_held-                         // wait until fire is released
    lda #$ff
    sta $dc02
    lda #$00
    sta $dc03
    sta $dc00                               // all keyboard columns
    .byte $24                               // BIT zp: hides the SEC
!key_held:
    sec                                     // a key was pressed
    lda $dc01
    eor #$ff
    bne !key_held-                          // wait until all keys are released
    lda #$7f
    sta $dc00
    bcs !done+
    lda timed_out
    beq !wait_loop-
!done:
    sei
    lda #$37
    sta $01
    ldx #$18
    lda #$00
!:  sta $d400,x
    dex
    bpl !-
    jsr $fda3                               // IOINIT
    jsr irqs_off
    lda #$00                                // bank 0 again: return to the loader
    sta $de00
    rts
}
show_picture_routine_end:

// ----------------------------------------------------------------------------
// Copied to $0400: raster IRQ (timeout counter, music) and CIA 1 IRQ (music)
// ----------------------------------------------------------------------------
viewer_irq:                                 // $8A77
.pseudopc $0400 {
    clc
    bcc irq_entry
play_music:                                 // $0403
    jmp (cfg_music_play)
irq_entry:
    pha
    txa
    pha
    tya
    pha
    lda $dc0d
    beq irq_raster
    lda cfg_music_cia
    bne irq_music
irq_exit:                                   // $0415
    pla
    tay
    pla
    tax
    pla
    rti
irq_raster:
    asl $d019
    dec frame_counter
    bne !music+
    lda cfg_timeout                         // one more second gone
    bne !lo+
    lda cfg_timeout + 1
    bne !hi+
    inc timed_out
    bne irq_exit
!hi:
    dec cfg_timeout + 1
!lo:
    dec cfg_timeout
    lda frames_per_sec
    sta frame_counter
!music:
    lda cfg_music
    beq irq_exit
    lda cfg_music_cia
    bne irq_exit
irq_music:                                  // $0448
    lda stripe_phase
    beq !+
    lda #$02
    dec stripe_phase
    beq !set+
!:  lda #$01
    inc stripe_phase
!set:
    sta $dd07
    jsr play_music
    clc
    bcc irq_exit
}
viewer_irq_end:

// ----------------------------------------------------------------------------
// Copied to $0500: NMI (CIA 2 timer B): border colour "loading stripes"
// ----------------------------------------------------------------------------
viewer_nmi:                                 // $8AD9
.pseudopc $0500 {
    pha
    txa
    pha
    tya
    pha
    lda cfg_stripes
    beq !exit+
    ldx stripe_counter
    stx $dd06
    cmp #$01
    beq !inc_border+
    inc stripe_counter
    bne !toggle+
    inc stripe_counter + 1
    lda stripe_counter + 1
    cmp #$08
    bcc !toggle+
    lda #$00
    sta stripe_counter + 1
    inc $d020
!toggle:
    lda $d020
    eor #$05
    sta $d020
    clc
    bcc !exit+
!inc_border:
    inc $d020
!exit:
    lda $dd0d
    pla
    tay
    pla
    tax
    pla
    rti
}
viewer_nmi_end:

// ----------------------------------------------------------------------------
// Copied to $0100: copy the music from bank 10 to RAM and initialise it
// (not used: this cartridge has no bank 10 and cfg_music is 0)
// ----------------------------------------------------------------------------
music_copier:                               // $8B1B
.pseudopc $0100 {
    clc
    bcc !+
music_init:                                 // $0103
    jmp (cfg_music_init)
!:  lda #$0a
    sta $de00
    lda #$00
    sta $fb
    lda #$80
    sta $fc
    lda cfg_music_dest
    sta $fd
    lda cfg_music_dest + 1
    sta $fe
    ldy #$00
    ldx cfg_music_pages
    beq !rest+
!:  lda ($fb),y
    sta ($fd),y
    iny
    bne !-
    inc $fc
    inc $fe
    dex
    bne !-
!rest:
    lda cfg_music_len
    beq !init+
!:  lda ($fb),y
    sta ($fd),y
    iny
    cpy cfg_music_len
    bne !-
!init:
    lda #$35
    sta $01
    ldx cfg_music_tune
    dex
    txa
    ldx #$00
    ldy #$00
    jsr music_init
    lda #$37
    sta $01
    lda #$09
    sta $de00
    rts
}
music_copier_end:

// ----------------------------------------------------------------------------
// Disable and acknowledge all CIA interrupts
// ----------------------------------------------------------------------------
irqs_off:                                   // $8B76
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    rts
