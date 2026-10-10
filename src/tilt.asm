// ============================================================================
// TILT (Commodore 64) - Codemasters, 1990
// Program by Steve Walters.
// Commented disassembly for KickAssembler 5.x
//
// This file assembles the game's RAM image, $0334-$FFFF, exactly as the
// STATMAT 2023 cartridge conversion (bin/Tilt.crt) copies it into memory
// before it jumps to $0460. src/cart.asm then packs the image, the cartridge
// loader and the loading picture into a byte-identical Tilt.crt.
//
// Build:   ./build.sh       (assembles src/tilt.asm, then src/cart.asm)
// ============================================================================


// ----------------------------------------------------------------------------
// Zero page
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Hardware registers, KERNAL and RAM outside the program image
// ----------------------------------------------------------------------------
.label CINV                           = $0314
.label CINV_HI                        = $0315
.label CBINV                          = $0316
.label CBINV_HI                       = $0317
.label NMINV                          = $0318
.label NMINV_HI                       = $0319
.label VIC_SPR0_X                     = $d000
.label VIC_SPR0_Y                     = $d001
.label VIC_SPR1_X                     = $d002
.label VIC_SPR1_Y                     = $d003
.label VIC_SPR2_X                     = $d004
.label VIC_SPR2_Y                     = $d005
.label VIC_SPR3_X                     = $d006
.label VIC_SPR3_Y                     = $d007
.label VIC_SPR4_X                     = $d008
.label VIC_SPR4_Y                     = $d009
.label VIC_SPR5_X                     = $d00a
.label VIC_SPR5_Y                     = $d00b
.label VIC_SPR6_X                     = $d00c
.label VIC_SPR6_Y                     = $d00d
.label VIC_SPR7_X                     = $d00e
.label VIC_SPR7_Y                     = $d00f
.label VIC_SPR_X_MSB                  = $d010
.label VIC_CTRL1                      = $d011
.label VIC_RASTER                     = $d012
.label VIC_SPR_ENABLE                 = $d015
.label VIC_CTRL2                      = $d016
.label VIC_SPR_EXPAND_Y               = $d017
.label VIC_MEMSETUP                   = $d018
.label VIC_IRQ_STATUS                 = $d019
.label VIC_IRQ_ENABLE                 = $d01a
.label VIC_SPR_PRIORITY               = $d01b
.label VIC_SPR_MULTICOLOR             = $d01c
.label VIC_SPR_EXPAND_X               = $d01d
.label VIC_SPR_BG_COLL                = $d01f
.label VIC_BORDER                     = $d020
.label VIC_BG0                        = $d021
.label VIC_BG1                        = $d022
.label VIC_BG2                        = $d023
.label VIC_SPR_MC0                    = $d025
.label VIC_SPR_MC1                    = $d026
.label VIC_SPR0_COL                   = $d027
.label VIC_SPR1_COL                   = $d028
.label VIC_SPR2_COL                   = $d029
.label VIC_SPR3_COL                   = $d02a
.label VIC_SPR4_COL                   = $d02b
.label VIC_SPR5_COL                   = $d02c
.label VIC_SPR6_COL                   = $d02d
.label VIC_SPR7_COL                   = $d02e
.label SID_V1_FREQ_LO                 = $d400
.label SID_V1_FREQ_HI                 = $d401
.label SID_V1_PW_LO                   = $d402
.label SID_V1_PW_HI                   = $d403
.label SID_V1_CTRL                    = $d404
.label SID_V1_AD                      = $d405
.label SID_V1_SR                      = $d406
.label SID_V2_FREQ_LO                 = $d407
.label SID_V2_FREQ_HI                 = $d408
.label SID_V2_PW_LO                   = $d409
.label SID_V2_PW_HI                   = $d40a
.label SID_V2_CTRL                    = $d40b
.label SID_V2_AD                      = $d40c
.label SID_V2_SR                      = $d40d
.label SID_V3_FREQ_LO                 = $d40e
.label SID_V3_FREQ_HI                 = $d40f
.label SID_V3_CTRL                    = $d412
.label SID_V3_AD                      = $d413
.label SID_V3_SR                      = $d414
.label SID_FC_HI                      = $d416
.label SID_RES_FILT                   = $d417
.label SID_MODE_VOL                   = $d418
.label SID_OSC3                       = $d41b
.label COLOR_RAM                      = $d800
.label CIA1_PRA                       = $dc00
.label CIA1_PRB                       = $dc01
.label CIA1_DDRA                      = $dc02
.label CIA1_CRA                       = $dc0e
.label CIA2_PRA                       = $dd00
.label KERNAL_IRQ                     = $ea31
.label KERNAL_IRQ_EXIT                = $ea81
.label SETLFS                         = $ffba
.label SETNAM                         = $ffbd
.label CHRIN                          = $ffcf
.label LOAD                           = $ffd5

// ---------------------------------------------------------------- program image

// ============================================================================
// tape_buffer  ($0334-$03ff)
// Cassette buffer area: leftovers, partly used as a work buffer
// ============================================================================
* = $0334 "tape_buffer"
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0334  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0344  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0354  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0364  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0374  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0384  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $0394  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03a4  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03b4  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03c4  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03d4  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03e4  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $03f4  

// ============================================================================
// screen  ($0400-$07ff)
// Screen RAM ($0400-$07E7) and sprite pointers ($07F8-$07FF).
// At start-up it still holds the original disk loader (typed into screen
// memory), which loaded "PIC" and "TILT". The cartridge enters at $0460,
// the loader's last two instructions.
// ============================================================================
* = $0400 "screen"
D0400:
    .byte $20                                   // $0400  
D0401:
    .byte $20,$20,$20,$20                       // $0401  
D0405:
    .byte $20,$20,$20,$20,$20,$20               // $0405  
D040b:
    .byte $20,$20,$20,$20,$20,$20               // $040b  
D0411:
    .byte $20,$20,$20,$20,$20,$20               // $0411  
D0417:
    .byte $20,$20,$20,$20,$20,$20               // $0417  
D041d:
    .byte $20                                   // $041d  
D041e:
    .byte $20                                   // $041e  
D041f:
    .byte $20,$20,$20                           // $041f  
D0422:
    .byte $20,$20,$20                           // $0422  
    lda #$00                                    // $0425  
    ldy #$01                                    // $0427  
    ldx #$08                                    // $0429  
    jsr SETLFS                                  // $042b  
    lda #$03                                    // $042e  
    ldx #$68                                    // $0430  
    ldy #$04                                    // $0432  
    jsr SETNAM                                  // $0434  
    ldx #$ff                                    // $0437  
    txs                                         // $0439  
    cld                                         // $043a  
    cli                                         // $043b  
    lda #$00                                    // $043c  
    jsr LOAD                                    // $043e  
    jsr L081f+1                                 // $0441  
    lda #$00                                    // $0444  
    ldy #$01                                    // $0446  
    ldx #$08                                    // $0448  
    jsr SETLFS                                  // $044a  
    lda #$04                                    // $044d  
L044f:
    ldx #$6b                                    // $044f  
L0451:
    ldy #$04                                    // $0451  
    jsr SETNAM                                  // $0453  
    ldx #$ff                                    // $0456  
    txs                                         // $0458  
    cld                                         // $0459  
    cli                                         // $045a  
    lda #$00                                    // $045b  
    jsr LOAD                                    // $045d  
cart_entry:
    lda #$0b                                    // $0460  
    sta VIC_CTRL1                               // $0462  
    jmp start                                   // $0465  
    .byte $50,$49,$43,$54,$49,$4c,$54,$57,$f1,$ca,$f1,$ed,$f6,$3e,$f1,$2f  // $0468  
    .byte $f3,$66                               // $0478  
D047a:
    .byte $fe,$a5,$f4,$ed,$f5,$a9,$00,$a8,$99,$02,$00,$99,$00,$02,$c0,$18  // $047a  
    .byte $90,$04,$c0,$1a,$90,$03,$99,$00,$03,$c8,$d0,$ec,$a2,$3c,$a0,$03  // $048a  
    .byte $86,$b2                               // $049a  
D049c:
    .byte $84,$b3,$a9,$08,$85                   // $049c  
D04a1:
    .byte $be                                   // $04a1  
D04a2:
    .byte $a0,$80,$ad,$00,$80,$aa,$49,$ff,$8d,$00,$80,$cd,$00,$80,$8e,$00  // $04a2  
    .byte $80,$d0,$02,$a0,$a0,$a2,$00,$84,$c2,$18,$20,$2d,$fe,$a9,$08,$8d  // $04b2  
    .byte $82,$02                               // $04c2  
D04c4:
    .byte $a9                                   // $04c4  
D04c5:
    .byte $04,$8d,$88,$02,$60,$6a,$fc,$cd,$fb,$31,$ea,$2c,$f9,$a9,$7f,$8d  // $04c5  
    .byte $0d,$dc,$8d,$0d,$dd,$8d,$00,$dc,$a9,$08,$8d,$0e,$dc,$8d,$0e,$dd  // $04d5  
    .byte $8d,$0f,$dc,$8d,$0f,$dd,$a2,$00,$20,$20,$20,$20,$20,$20,$20,$20  // $04e5  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $04f5  
D0500:
    .byte $20                                   // $0500  
D0501:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0501  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0511  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0521  
D052d:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $052d  
    .byte $20,$20,$20,$20,$20,$20,$20           // $053d  
D0544:
    .byte $20                                   // $0544  
D0545:
    .byte $20,$20,$20,$20,$20,$20,$20           // $0545  
D054c:
    .byte $20,$20                               // $054c  
D054e:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $054e  
D055a:
    .byte $20,$20,$20,$20,$20,$20,$20           // $055a  
D0561:
    .byte $20                                   // $0561  
D0562:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0562  
D056f:
    .byte $20,$20                               // $056f  
D0571:
    .byte $20,$20,$20,$20,$20,$20               // $0571  
D0577:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0577  
D0585:
    .byte $20,$20                               // $0585  
D0587:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0587  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0597  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05a7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05b7  
D05c7:
    .byte $20,$20,$20,$20,$20,$20               // $05c7  
D05cd:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05cd  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05dd  
    .byte $20                                   // $05ed  
D05ee:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $05ee  
D05fb:
    .byte $20,$20,$20,$20,$20                   // $05fb  
D0600:
    .byte $20                                   // $0600  
D0601:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0601  
D060f:
    .byte $20,$20                               // $060f  
D0611:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0611  
    .byte $20,$20,$20,$20                       // $0621  
D0625:
    .byte $20,$20                               // $0625  
D0627:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0627  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0637  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0647  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0657  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0667  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0677  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0687  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0697  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06a7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06b7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06c7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06d7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $06e7  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20   // $06f7  
D0700:
    .byte $20                                   // $0700  
D0701:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0701  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0711  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0721  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0731  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0741  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0751  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0761  
D0771:
    .byte $20                                   // $0771  
D0772:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0772  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $0782  
    .byte $20,$20                               // $0792  
D0794:
    .byte $20                                   // $0794  
D0795:
    .byte $20,$20,$20,$20,$20                   // $0795  
D079a:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $079a  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07aa  
    .byte $20,$20                               // $07ba  
D07bc:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07bc  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07cc  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07dc  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $07ec  
D07f8:
    .byte $20                                   // $07f8  
D07f9:
    .byte $20                                   // $07f9  
D07fa:
    .byte $20                                   // $07fa  
D07fb:
    .byte $20                                   // $07fb  
D07fc:
    .byte $20                                   // $07fc  
D07fd:
    .byte $20                                   // $07fd  
D07fe:
    .byte $20                                   // $07fe  
D07ff:
    .byte $20                                   // $07ff  

// ============================================================================
// basic  ($0800-$080c)
// BASIC line: 0 SYS2061
// ============================================================================
* = $0800 "basic"
    .byte $00,$0b,$08,$00,$00,$9e,$32,$30,$36,$31,$00,$00,$00  // $0800  

// ============================================================================
// main  ($080d-$8eff)
// The TILT program
// ============================================================================
* = $080d "main"
start:
    sei                                         // $080d  
    lda #$36                                    // $080e  
    sta $01                                     // $0810  
    lda VIC_CTRL1                               // $0812  
    and #$ef                                    // $0815  
    sta VIC_CTRL1                               // $0817  
    lda #$00                                    // $081a  
    sta VIC_BORDER                              // $081c  
L081f:
    sta VIC_BG0                                 // $081f  
    lda #$01                                    // $0822  
    sta $cef9                                   // $0824  
    jsr L0887                                   // $0827  
    cmp #$da                                    // $082a  
    bne L083b                                   // $082c  
    cpx #$3f                                    // $082e  
    bne L083b                                   // $0830  
    cpy #$37                                    // $0832  
    bne L083b                                   // $0834  
    lda #$00                                    // $0836  
    sta $cef9                                   // $0838  
L083b:
    ldx #$08                                    // $083b  
    ldy #$00                                    // $083d  
L083f:
    lda D2000,y                                 // $083f  
L0842:
    sta $a000,y                                 // $0842  
L0845:
    lda D7800,y                                 // $0845  
L0848:
    sta $a800,y                                 // $0848  
    iny                                         // $084b  
    bne L083f                                   // $084c  
    inc L083f+2                                 // $084e  
    inc L0842+2                                 // $0851  
    inc L0845+2                                 // $0854  
    inc L0848+2                                 // $0857  
    dex                                         // $085a  
    bne L083f                                   // $085b  
    ldy #$00                                    // $085d  
L085f:
    lda D1d00,y                                 // $085f  
    sta D2320,y                                 // $0862  
    iny                                         // $0865  
    cpy #$a0                                    // $0866  
    bcc L085f                                   // $0868  
    ldx #$fe                                    // $086a  
    sei                                         // $086c  
    txs                                         // $086d  
    cld                                         // $086e  
    lda #$0b                                    // $086f  
    sta VIC_CTRL1                               // $0871  
    lda #$c8                                    // $0874  
    sta VIC_CTRL2                               // $0876  
    lda #$15                                    // $0879  
    sta VIC_MEMSETUP                            // $087b  
    lda #$97                                    // $087e  
    sta CIA2_PRA                                // $0880  
    cld                                         // $0883  
    jmp L0980                                   // $0884  
L0887:
    lda #$09                                    // $0887  
    sta $fc                                     // $0889  
    lda #$00                                    // $088b  
    sta $fb                                     // $088d  
    sta $fd                                     // $088f  
    sta $fe                                     // $0891  
    ldy #$80                                    // $0893  
L0895:
    clc                                         // $0895  
    adc ($fb),y                                 // $0896  
    bcc L08a0                                   // $0898  
    inc $fd                                     // $089a  
    bne L08a0                                   // $089c  
    inc $fe                                     // $089e  
L08a0:
    iny                                         // $08a0  
    bne L0895                                   // $08a1  
    inc $fc                                     // $08a3  
    ldx $fc                                     // $08a5  
    cpx #$8e                                    // $08a7  
    bcc L0895                                   // $08a9  
    ldx $fd                                     // $08ab  
    ldy $fe                                     // $08ad  
    rts                                         // $08af  
    .byte $3c,$00,$93,$22,$43,$48,$41,$52,$33,$35,$2d,$34,$32,$2e,$4d,$4f  // $08b0  
    .byte $44,$22,$2c,$38,$2c,$31,$00,$e2,$08,$46,$00,$93,$22,$43,$48,$41  // $08c0  
    .byte $52,$31,$30,$30,$2d,$31,$31,$39,$2e,$4d,$4f,$44,$22,$2c,$38,$2c  // $08d0  
    .byte $31,$00,$f8,$08,$50,$00,$93,$22,$54,$41,$42,$4c,$45,$53,$2e,$4d  // $08e0  
    .byte $4f,$44,$22,$2c,$38,$2c,$31,$00,$0f,$09,$5a,$00,$93,$22,$53,$50  // $08f0  
    .byte $52,$49,$54,$45,$53,$2e,$4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$25  // $0900  
    .byte $09,$64,$00,$93,$22,$43,$4f,$53,$49,$4e,$45,$2e,$4d,$4f,$44,$22  // $0910  
    .byte $2c,$38,$2c,$31,$00,$39,$09,$6e,$00,$93,$22,$44,$45,$4d,$4f,$2e  // $0920  
    .byte $4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$4e,$09,$73,$00,$93,$22,$4d  // $0930  
    .byte $55,$53,$49,$43,$2e,$4d,$4f,$44,$22,$2c,$38,$2c,$31,$00,$54,$09  // $0940  
    .byte $78,$00,$80,$00,$00,$00,$42,$00,$84,$30,$00,$00,$00,$00,$00,$00  // $0950  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf  // $0960  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00  // $0970  
L0980:
    lda #$00                                    // $0980  
    beq L0986                                   // $0982  
    lda #$01                                    // $0984  
L0986:
    sta $ceff                                   // $0986  
    lda $cef9                                   // $0989  
    beq L0999                                   // $098c  
    ldx #$07                                    // $098e  
L0990:
    lda D09d0,x                                 // $0990  
    sta D7594,x                                 // $0993  
    dex                                         // $0996  
    bpl L0990                                   // $0997  
L0999:
    lda #$00                                    // $0999  
    sta $cefe                                   // $099b  
    lda #$00                                    // $099e  
    sta $cefb                                   // $09a0  
    sta $cefc                                   // $09a3  
    sta $cefd                                   // $09a6  
    lda #$01                                    // $09a9  
    sta $cefa                                   // $09ab  
    ldx #$2f                                    // $09ae  
L09b0:
    ldy #$07                                    // $09b0  
L09b2:
    lda D4c3e,y                                 // $09b2  
    sta D2780,x                                 // $09b5  
    dex                                         // $09b8  
    dey                                         // $09b9  
    bpl L09b2                                   // $09ba  
    txa                                         // $09bc  
    bpl L09b0                                   // $09bd  
    sei                                         // $09bf  
    ldy #$00                                    // $09c0  
L09c2:
    lda D7594,y                                 // $09c2  
    sta D2650,y                                 // $09c5  
    iny                                         // $09c8  
    cpy #$88                                    // $09c9  
    bcc L09c2                                   // $09cb  
    jmp L4029                                   // $09cd  
D09d0:
    .byte $00,$7e,$60,$60,$78,$60,$60,$7e       // $09d0  
L09d8:
    ldx #$01                                    // $09d8  
    sta $fb                                     // $09da  
    and #$80                                    // $09dc  
    sta $fd                                     // $09de  
    bpl L09eb                                   // $09e0  
    lda $fb                                     // $09e2  
    eor #$ff                                    // $09e4  
    clc                                         // $09e6  
    adc #$01                                    // $09e7  
    sta $fb                                     // $09e9  
L09eb:
    lda #$00                                    // $09eb  
L09ed:
    asl $fb                                     // $09ed  
    rol                                         // $09ef  
    dex                                         // $09f0  
    bpl L09ed                                   // $09f1  
    sta $fc                                     // $09f3  
    lda $fd                                     // $09f5  
    bpl L0a0a                                   // $09f7  
    lda $fb                                     // $09f9  
    eor #$ff                                    // $09fb  
    clc                                         // $09fd  
    adc #$01                                    // $09fe  
    sta $fb                                     // $0a00  
    lda $fc                                     // $0a02  
    eor #$ff                                    // $0a04  
    adc #$00                                    // $0a06  
    sta $fc                                     // $0a08  
L0a0a:
    rts                                         // $0a0a  
L0a0b:
    lda $cf00                                   // $0a0b  
    sec                                         // $0a0e  
    jsr L09d8                                   // $0a0f  
    lda $cf02                                   // $0a12  
    clc                                         // $0a15  
    adc $fb                                     // $0a16  
    sta $cf02                                   // $0a18  
    lda $cf03                                   // $0a1b  
    adc $fc                                     // $0a1e  
    sta $cf03                                   // $0a20  
    lda $fc                                     // $0a23  
    bcs L0a2d                                   // $0a25  
    bpl L0a34                                   // $0a27  
    ldx #$00                                    // $0a29  
    beq L0a31                                   // $0a2b  
L0a2d:
    bmi L0a34                                   // $0a2d  
    ldx #$01                                    // $0a2f  
L0a31:
    stx $cf04                                   // $0a31  
L0a34:
    lda $cf01                                   // $0a34  
    sec                                         // $0a37  
    jsr L09d8                                   // $0a38  
    lda $cf05                                   // $0a3b  
    clc                                         // $0a3e  
    adc $fb                                     // $0a3f  
    sta $cf05                                   // $0a41  
    lda $cf06                                   // $0a44  
    adc $fc                                     // $0a47  
    sta $cf06                                   // $0a49  
    rts                                         // $0a4c  
L0a4d:
    lda $cf07                                   // $0a4d  
    sta $cf25                                   // $0a50  
    lda $cf08                                   // $0a53  
    sta $cf26                                   // $0a56  
    lda $cf54                                   // $0a59  
    sta $fb                                     // $0a5c  
    ldy #$03                                    // $0a5e  
    ldx #$00                                    // $0a60  
L0a62:
    lsr                                         // $0a62  
    bcs L0a66                                   // $0a63  
    inx                                         // $0a65  
L0a66:
    dey                                         // $0a66  
    bpl L0a62                                   // $0a67  
    cpx #$02                                    // $0a69  
    bne L0a94                                   // $0a6b  
    lda #$00                                    // $0a6d  
    sta $cf1b                                   // $0a6f  
    lda $cf07                                   // $0a72  
    sta $cf1d                                   // $0a75  
    lda $cf08                                   // $0a78  
    sta $cf1e                                   // $0a7b  
    lda $cf1c                                   // $0a7e  
    bmi L0a94                                   // $0a81  
    clc                                         // $0a83  
    adc #$01                                    // $0a84  
    cmp #$05                                    // $0a86  
    bne L0a91                                   // $0a88  
    lda #$02                                    // $0a8a  
    sta $cfbd                                   // $0a8c  
    lda #$80                                    // $0a8f  
L0a91:
    sta $cf1c                                   // $0a91  
L0a94:
    cpx #$01                                    // $0a94  
    bne L0aa7                                   // $0a96  
    lda $cf1c                                   // $0a98  
    bpl L0abc                                   // $0a9b  
    inc $cf1b                                   // $0a9d  
    lda $cf1b                                   // $0aa0  
    cmp #$08                                    // $0aa3  
    beq L0abc                                   // $0aa5  
L0aa7:
    cpx #$00                                    // $0aa7  
    bne L0ac4                                   // $0aa9  
    lda $cf1b                                   // $0aab  
    beq L0abc                                   // $0aae  
    lda $cf1d                                   // $0ab0  
    sta $cf07                                   // $0ab3  
    lda $cf1e                                   // $0ab6  
    sta $cf08                                   // $0ab9  
L0abc:
    lda #$00                                    // $0abc  
    sta $cf1b                                   // $0abe  
    sta $cf1c                                   // $0ac1  
L0ac4:
    cpx #$00                                    // $0ac4  
    beq L0afa                                   // $0ac6  
    lda #$00                                    // $0ac8  
    sta $cf07                                   // $0aca  
    sta $cf08                                   // $0acd  
    lda $fb                                     // $0ad0  
    and #$04                                    // $0ad2  
    bne L0ada                                   // $0ad4  
    ldx #$ff                                    // $0ad6  
    bne L0ae2                                   // $0ad8  
L0ada:
    lda $fb                                     // $0ada  
    and #$08                                    // $0adc  
    bne L0ae5                                   // $0ade  
    ldx #$01                                    // $0ae0  
L0ae2:
    stx $cf07                                   // $0ae2  
L0ae5:
    lda $fb                                     // $0ae5  
    and #$01                                    // $0ae7  
    bne L0aef                                   // $0ae9  
    ldx #$ff                                    // $0aeb  
    bne L0af7                                   // $0aed  
L0aef:
    lda $fb                                     // $0aef  
    and #$02                                    // $0af1  
    bne L0afa                                   // $0af3  
    ldx #$01                                    // $0af5  
L0af7:
    stx $cf08                                   // $0af7  
L0afa:
    ldx $cf07                                   // $0afa  
    ldy $cf08                                   // $0afd  
    jsr L0b45                                   // $0b00  
    sta $fb                                     // $0b03  
    ldx $cf08                                   // $0b05  
    ldy $cf07                                   // $0b08  
    jsr L0b45                                   // $0b0b  
    sta $fc                                     // $0b0e  
    lda $cf07                                   // $0b10  
    cmp $cf25                                   // $0b13  
    bne L0b20                                   // $0b16  
    lda $cf08                                   // $0b18  
    cmp $cf26                                   // $0b1b  
    beq L0b23                                   // $0b1e  
L0b20:
    jsr L0bb1                                   // $0b20  
L0b23:
    lda $cf50                                   // $0b23  
    beq L0b44                                   // $0b26  
    lda $cf00                                   // $0b28  
    ldx $fb                                     // $0b2b  
    ldy $cf27                                   // $0b2d  
    jsr L0b64                                   // $0b30  
    sta $cf00                                   // $0b33  
    lda $cf01                                   // $0b36  
    ldx $fc                                     // $0b39  
    ldy $cf28                                   // $0b3b  
    jsr L0b64                                   // $0b3e  
    sta $cf01                                   // $0b41  
L0b44:
    rts                                         // $0b44  
L0b45:
    iny                                         // $0b45  
    cpy #$02                                    // $0b46  
    bne L0b4c                                   // $0b48  
    ldy #$00                                    // $0b4a  
L0b4c:
    tya                                         // $0b4c  
    asl                                         // $0b4d  
    asl                                         // $0b4e  
    stx $fd                                     // $0b4f  
    sec                                         // $0b51  
    adc $fd                                     // $0b52  
    sta $fd                                     // $0b54  
    lda $cfaf                                   // $0b56  
    asl                                         // $0b59  
    asl                                         // $0b5a  
    asl                                         // $0b5b  
    clc                                         // $0b5c  
    adc $fd                                     // $0b5d  
    tax                                         // $0b5f  
    lda D0b89,x                                 // $0b60  
    rts                                         // $0b63  
L0b64:
    stx $fd                                     // $0b64  
    sty $fe                                     // $0b66  
    clc                                         // $0b68  
    adc #$80                                    // $0b69  
    cmp $fd                                     // $0b6b  
    bcs L0b7a                                   // $0b6d  
    clc                                         // $0b6f  
    adc $fe                                     // $0b70  
    bcs L0b83                                   // $0b72  
    cmp $fd                                     // $0b74  
    bcs L0b83                                   // $0b76  
    bcc L0b85                                   // $0b78  
L0b7a:
    sec                                         // $0b7a  
    sbc $fe                                     // $0b7b  
    bcc L0b83                                   // $0b7d  
    cmp $fd                                     // $0b7f  
    bcs L0b85                                   // $0b81  
L0b83:
    lda $fd                                     // $0b83  
L0b85:
    sec                                         // $0b85  
    sbc #$80                                    // $0b86  
    rts                                         // $0b88  
D0b89:
    .byte $3c,$80,$c4,$00,$20,$80,$e0,$00,$36,$80,$ca,$00,$18,$80,$e8,$00  // $0b89  
    .byte $31,$80,$cf,$00,$10,$80,$f0,$00,$2b,$80,$d5,$00,$08,$80,$f8,$00  // $0b99  
    .byte $26,$80,$da,$00,$00,$80,$ff,$00       // $0ba9  
L0bb1:
    ldx $cfaf                                   // $0bb1  
    lda D0c2e,x                                 // $0bb4  
    sta $ff                                     // $0bb7  
    lda $cf00                                   // $0bb9  
    clc                                         // $0bbc  
    adc #$80                                    // $0bbd  
    sec                                         // $0bbf  
    sbc $fb                                     // $0bc0  
    bcs L0bc9                                   // $0bc2  
    eor #$ff                                    // $0bc4  
    clc                                         // $0bc6  
    adc #$01                                    // $0bc7  
L0bc9:
    sta $cf29                                   // $0bc9  
    lda $cf01                                   // $0bcc  
    clc                                         // $0bcf  
    adc #$80                                    // $0bd0  
    sec                                         // $0bd2  
    sbc $fc                                     // $0bd3  
    bcs L0bdc                                   // $0bd5  
    eor #$ff                                    // $0bd7  
    clc                                         // $0bd9  
    adc #$01                                    // $0bda  
L0bdc:
    sta $cf2a                                   // $0bdc  
    ldx $ff                                     // $0bdf  
    stx $cf27                                   // $0be1  
    stx $cf28                                   // $0be4  
    ldy #$00                                    // $0be7  
    lda $cf29                                   // $0be9  
    cmp $cf2a                                   // $0bec  
    bcc L0bf2                                   // $0bef  
    iny                                         // $0bf1  
L0bf2:
    lda #$00                                    // $0bf2  
    sta $fe                                     // $0bf4  
L0bf6:
    clc                                         // $0bf6  
    adc $cf29,y                                 // $0bf7  
    bcc L0bfe                                   // $0bfa  
    inc $fe                                     // $0bfc  
L0bfe:
    dex                                         // $0bfe  
    bne L0bf6                                   // $0bff  
    sta $fd                                     // $0c01  
    tya                                         // $0c03  
    eor #$01                                    // $0c04  
    tay                                         // $0c06  
    lda $cf29,y                                 // $0c07  
    beq L0c23                                   // $0c0a  
    ldx #$00                                    // $0c0c  
L0c0e:
    lda $fd                                     // $0c0e  
    sec                                         // $0c10  
    sbc $cf29,y                                 // $0c11  
    sta $fd                                     // $0c14  
    lda $fe                                     // $0c16  
    sbc #$00                                    // $0c18  
    sta $fe                                     // $0c1a  
    inx                                         // $0c1c  
    bcs L0c0e                                   // $0c1d  
    cpx $ff                                     // $0c1f  
    bcc L0c25                                   // $0c21  
L0c23:
    ldx $ff                                     // $0c23  
L0c25:
    tya                                         // $0c25  
    eor #$01                                    // $0c26  
    tay                                         // $0c28  
    txa                                         // $0c29  
    sta $cf27,y                                 // $0c2a  
    rts                                         // $0c2d  
D0c2e:
    .byte $05,$06,$06,$07,$07                   // $0c2e  
L0c33:
    lda $fc                                     // $0c33  
    cmp #$04                                    // $0c35  
    bne L0c46                                   // $0c37  
    ldx #$07                                    // $0c39  
    jsr L0cef                                   // $0c3b  
    ldx #$00                                    // $0c3e  
    jsr L0d09                                   // $0c40  
    clc                                         // $0c43  
    bcc L0c6e                                   // $0c44  
L0c46:
    bcs L0c5b                                   // $0c46  
    asl                                         // $0c48  
    sta $fe                                     // $0c49  
    tax                                         // $0c4b  
    dex                                         // $0c4c  
    jsr L0cef                                   // $0c4d  
    ldx #$00                                    // $0c50  
    jsr L0d09                                   // $0c52  
    jsr L0e2e                                   // $0c55  
    clc                                         // $0c58  
    bcc L0c6e                                   // $0c59  
L0c5b:
    asl                                         // $0c5b  
    sec                                         // $0c5c  
    sbc #$09                                    // $0c5d  
    sta $fe                                     // $0c5f  
    tax                                         // $0c61  
    inx                                         // $0c62  
    jsr L0d09                                   // $0c63  
    ldx #$07                                    // $0c66  
    jsr L0cef                                   // $0c68  
    jsr L0fea                                   // $0c6b  
L0c6e:
    lda $fb                                     // $0c6e  
    cmp #$04                                    // $0c70  
    bne L0c7d                                   // $0c72  
    jsr L0d23                                   // $0c74  
    jsr L0d34                                   // $0c77  
    clc                                         // $0c7a  
    bcc L0c95                                   // $0c7b  
L0c7d:
    bcs L0c8a                                   // $0c7d  
    sta $fe                                     // $0c7f  
    jsr L0d34                                   // $0c81  
    jsr L108e                                   // $0c84  
    clc                                         // $0c87  
    bcc L0c95                                   // $0c88  
L0c8a:
    sec                                         // $0c8a  
    sbc #$05                                    // $0c8b  
    sta $fe                                     // $0c8d  
    jsr L0d23                                   // $0c8f  
    jsr L1129                                   // $0c92  
L0c95:
    ldx #$07                                    // $0c95  
L0c97:
    lda D2030,x                                 // $0c97  
    eor D2050,x                                 // $0c9a  
    ora D2040,x                                 // $0c9d  
    sta D2088,x                                 // $0ca0  
    lda D2070,x                                 // $0ca3  
    eor D2050,x                                 // $0ca6  
    ora D2060,x                                 // $0ca9  
    sta D2090,x                                 // $0cac  
    lda D2070,x                                 // $0caf  
    eor D2010,x                                 // $0cb2  
    ora D2080,x                                 // $0cb5  
    sta D2098,x                                 // $0cb8  
    lda D2010,x                                 // $0cbb  
    eor D2030,x                                 // $0cbe  
    ora D2020,x                                 // $0cc1  
    sta D20a0,x                                 // $0cc4  
    lda D2008,x                                 // $0cc7  
    and D2018,x                                 // $0cca  
    sta D20a8,x                                 // $0ccd  
    lda D2028,x                                 // $0cd0  
    and D2038,x                                 // $0cd3  
    sta D20b0,x                                 // $0cd6  
    lda D2058,x                                 // $0cd9  
    and D2048,x                                 // $0cdc  
    sta D20b8,x                                 // $0cdf  
    lda D2078,x                                 // $0ce2  
    and D2068,x                                 // $0ce5  
    sta D20c0,x                                 // $0ce8  
    dex                                         // $0ceb  
    bpl L0c97                                   // $0cec  
    rts                                         // $0cee  
L0cef:
    lda #$00                                    // $0cef  
L0cf1:
    cpx #$00                                    // $0cf1  
    bmi L0d08                                   // $0cf3  
    sta D2080,x                                 // $0cf5  
    sta D2008,x                                 // $0cf8  
    sta D2010,x                                 // $0cfb  
    sta D2018,x                                 // $0cfe  
    sta D2020,x                                 // $0d01  
    dex                                         // $0d04  
    jmp L0cf1                                   // $0d05  
L0d08:
    rts                                         // $0d08  
L0d09:
    lda #$00                                    // $0d09  
L0d0b:
    cpx #$08                                    // $0d0b  
    bcs L0d22                                   // $0d0d  
    sta D2060,x                                 // $0d0f  
    sta D2058,x                                 // $0d12  
    sta D2050,x                                 // $0d15  
    sta D2048,x                                 // $0d18  
    sta D2040,x                                 // $0d1b  
    inx                                         // $0d1e  
    jmp L0d0b                                   // $0d1f  
L0d22:
    rts                                         // $0d22  
L0d23:
    ldx #$07                                    // $0d23  
    lda #$00                                    // $0d25  
L0d27:
    sta D2068,x                                 // $0d27  
    sta D2070,x                                 // $0d2a  
    sta D2078,x                                 // $0d2d  
    dex                                         // $0d30  
    bpl L0d27                                   // $0d31  
    rts                                         // $0d33  
L0d34:
    ldx #$07                                    // $0d34  
    lda #$00                                    // $0d36  
L0d38:
    sta D2028,x                                 // $0d38  
    sta D2030,x                                 // $0d3b  
    sta D2038,x                                 // $0d3e  
    dex                                         // $0d41  
    bpl L0d38                                   // $0d42  
    rts                                         // $0d44  
L0d45:
    ldx $cf07                                   // $0d45  
    lda $cf35                                   // $0d48  
    sta $cf23                                   // $0d4b  
    jsr L0dff                                   // $0d4e  
    sta $cf35                                   // $0d51  
    ldx $cf08                                   // $0d54  
    lda $cf36                                   // $0d57  
    sta $cf24                                   // $0d5a  
    jsr L0dff                                   // $0d5d  
    sta $cf36                                   // $0d60  
    lda $cf35                                   // $0d63  
    sec                                         // $0d66  
    sbc #$02                                    // $0d67  
    bcs L0d6d                                   // $0d69  
    lda #$00                                    // $0d6b  
L0d6d:
    ldx #$09                                    // $0d6d  
    sec                                         // $0d6f  
L0d70:
    dex                                         // $0d70  
    sbc #$1c                                    // $0d71  
    bcs L0d70                                   // $0d73  
    txa                                         // $0d75  
    bpl L0d7a                                   // $0d76  
    ldx #$00                                    // $0d78  
L0d7a:
    stx $cf37                                   // $0d7a  
    lda D0dbc,x                                 // $0d7d  
    sta $cf0e                                   // $0d80  
    lda $cf36                                   // $0d83  
    sec                                         // $0d86  
    sbc #$02                                    // $0d87  
    bcs L0d8d                                   // $0d89  
    lda #$00                                    // $0d8b  
L0d8d:
    ldx #$09                                    // $0d8d  
    sec                                         // $0d8f  
L0d90:
    dex                                         // $0d90  
    sbc #$1c                                    // $0d91  
    bcs L0d90                                   // $0d93  
    txa                                         // $0d95  
    bpl L0d9a                                   // $0d96  
    ldx #$00                                    // $0d98  
L0d9a:
    stx $cf38                                   // $0d9a  
    lda D0dc5,x                                 // $0d9d  
    sta $cf0f                                   // $0da0  
    rts                                         // $0da3  
L0da4:
    ldx $cf0a                                   // $0da4  
    lda D0dce,x                                 // $0da7  
    asl                                         // $0daa  
    asl                                         // $0dab  
    asl                                         // $0dac  
    ldx $cf09                                   // $0dad  
    clc                                         // $0db0  
    adc D0dce,x                                 // $0db1  
    tax                                         // $0db4  
    lda D0dd7,x                                 // $0db5  
    sta $cf6a                                   // $0db8  
    rts                                         // $0dbb  
D0dbc:
    .byte $07,$07,$06,$05,$04,$03,$02,$01,$00   // $0dbc  
D0dc5:
    .byte $02,$02,$01,$00,$07,$06,$05,$04,$03   // $0dc5  
D0dce:
    .byte $00,$01,$01,$02,$02,$02,$03,$03,$04   // $0dce  
D0dd7:
    .byte $bc,$bb,$b8,$bd,$be,$00,$00,$00,$bb,$bb,$b7,$bd,$bd,$00,$00,$00  // $0dd7  
    .byte $ba,$b9,$b6,$b9,$ba,$00,$00,$00,$bd,$bd,$b7,$bb,$bb,$00,$00,$00  // $0de7  
    .byte $be,$bd,$b8,$bb,$bc,$00,$00,$00       // $0df7  
L0dff:
    cpx #$00                                    // $0dff  
    bne L0e18                                   // $0e01  
    tay                                         // $0e03  
    bpl L0e0f                                   // $0e04  
    sec                                         // $0e06  
    sbc $cf57                                   // $0e07  
    bmi L0e0e                                   // $0e0a  
    lda #$80                                    // $0e0c  
L0e0e:
    rts                                         // $0e0e  
L0e0f:
    clc                                         // $0e0f  
    adc $cf57                                   // $0e10  
    bpl L0e17                                   // $0e13  
    lda #$80                                    // $0e15  
L0e17:
    rts                                         // $0e17  
L0e18:
    cpx #$ff                                    // $0e18  
    bne L0e25                                   // $0e1a  
    sec                                         // $0e1c  
    sbc $cf57                                   // $0e1d  
    bcs L0e24                                   // $0e20  
    lda #$00                                    // $0e22  
L0e24:
    rts                                         // $0e24  
L0e25:
    clc                                         // $0e25  
    adc $cf57                                   // $0e26  
    bcc L0e2d                                   // $0e29  
    lda #$ff                                    // $0e2b  
L0e2d:
    rts                                         // $0e2d  
L0e2e:
    ldy $fb                                     // $0e2e  
    cpy #$05                                    // $0e30  
    bcs L0e47                                   // $0e32  
    ldx $fe                                     // $0e34  
L0e36:
    lda #$55                                    // $0e36  
    sta D2008,x                                 // $0e38  
    lda #$00                                    // $0e3b  
    sta D2020,x                                 // $0e3d  
    inx                                         // $0e40  
    cpx #$08                                    // $0e41  
    bcc L0e36                                   // $0e43  
    bcs L0e7f                                   // $0e45  
L0e47:
    tya                                         // $0e47  
    sec                                         // $0e48  
    sbc #$05                                    // $0e49  
    asl                                         // $0e4b  
    asl                                         // $0e4c  
    asl                                         // $0e4d  
    asl                                         // $0e4e  
    sta $fd                                     // $0e4f  
    lda #$03                                    // $0e51  
    sec                                         // $0e53  
    sbc $fc                                     // $0e54  
    asl                                         // $0e56  
    asl                                         // $0e57  
    clc                                         // $0e58  
    adc $fd                                     // $0e59  
    sta $fd                                     // $0e5b  
    ldx #$00                                    // $0e5d  
L0e5f:
    ldy $fd                                     // $0e5f  
    lda D0f6a,y                                 // $0e61  
    sta D2020,x                                 // $0e64  
    sta D2021,x                                 // $0e67  
    lda D0ee0,y                                 // $0e6a  
    tay                                         // $0e6d  
    lda D0f60,y                                 // $0e6e  
    sta D2008,x                                 // $0e71  
    inx                                         // $0e74  
    sta D2008,x                                 // $0e75  
    inc $fd                                     // $0e78  
    inx                                         // $0e7a  
    cpx #$08                                    // $0e7b  
    bcc L0e5f                                   // $0e7d  
L0e7f:
    ldx $fe                                     // $0e7f  
    lda #$55                                    // $0e81  
L0e83:
    sta D2010,x                                 // $0e83  
    inx                                         // $0e86  
    cpx #$08                                    // $0e87  
    bne L0e83                                   // $0e89  
    ldy $fb                                     // $0e8b  
    cpy #$04                                    // $0e8d  
    bcc L0ea4                                   // $0e8f  
    ldx $fe                                     // $0e91  
L0e93:
    lda #$55                                    // $0e93  
    sta D2018,x                                 // $0e95  
    lda #$00                                    // $0e98  
    sta D2080,x                                 // $0e9a  
    inx                                         // $0e9d  
    cpx #$08                                    // $0e9e  
    bcc L0e93                                   // $0ea0  
    bcs L0edf                                   // $0ea2  
L0ea4:
    sty $fd                                     // $0ea4  
    lda #$03                                    // $0ea6  
    sec                                         // $0ea8  
    sbc $fd                                     // $0ea9  
    asl                                         // $0eab  
    asl                                         // $0eac  
    asl                                         // $0ead  
    asl                                         // $0eae  
    sta $fd                                     // $0eaf  
    lda #$03                                    // $0eb1  
    sec                                         // $0eb3  
    sbc $fc                                     // $0eb4  
    asl                                         // $0eb6  
    asl                                         // $0eb7  
    clc                                         // $0eb8  
    adc $fd                                     // $0eb9  
    sta $fd                                     // $0ebb  
    ldx #$00                                    // $0ebd  
L0ebf:
    ldy $fd                                     // $0ebf  
    lda D0faa,y                                 // $0ec1  
    sta D2080,x                                 // $0ec4  
    sta D2081,x                                 // $0ec7  
    lda D0ee0,y                                 // $0eca  
    tay                                         // $0ecd  
    lda D0f65,y                                 // $0ece  
    sta D2018,x                                 // $0ed1  
    inx                                         // $0ed4  
    sta D2018,x                                 // $0ed5  
    inc $fd                                     // $0ed8  
    inx                                         // $0eda  
    cpx #$08                                    // $0edb  
    bcc L0ebf                                   // $0edd  
L0edf:
    rts                                         // $0edf  
D0ee0:
    .byte $00,$00,$00,$03,$00,$00,$03,$04,$00,$03,$03,$04,$03,$03,$04,$04  // $0ee0  
    .byte $00,$00,$00,$02,$00,$00,$02,$03,$00,$02,$03,$04,$02,$03,$03,$04  // $0ef0  
    .byte $00,$00,$00,$01,$00,$00,$01,$03,$00,$01,$02,$03,$01,$02,$03,$04  // $0f00  
    .byte $00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$01,$03,$00,$01,$02,$03  // $0f10  
D0f20:
    .byte $00,$01,$01,$01,$01,$02,$02,$02,$01,$03,$03,$03,$02,$04,$04,$04  // $0f20  
    .byte $00,$00,$01,$01,$00,$01,$02,$02,$01,$02,$03,$03,$01,$03,$04,$04  // $0f30  
    .byte $00,$00,$00,$01,$00,$01,$01,$02,$00,$01,$02,$03,$01,$02,$03,$04  // $0f40  
    .byte $00,$00,$00,$00,$00,$00,$01,$01,$00,$01,$01,$02,$00,$01,$02,$03  // $0f50  
D0f60:
    .byte $00,$01,$05,$15,$55                   // $0f60  
D0f65:
    .byte $00,$40,$50,$54,$55                   // $0f65  
D0f6a:
    .byte $00,$00,$00,$40,$00,$00,$40,$40,$00,$40,$40,$40,$40,$40,$40,$40  // $0f6a  
    .byte $00,$00,$00,$50,$00,$00,$40,$10,$00,$40,$10,$10,$40,$10,$10,$10  // $0f7a  
    .byte $00,$00,$00,$54,$00,$00,$50,$04,$00,$50,$44,$14,$50,$44,$44,$14  // $0f8a  
    .byte $00,$00,$00,$55,$00,$00,$54,$01,$00,$54,$41,$15,$54,$51,$45,$15  // $0f9a  
D0faa:
    .byte $00,$00,$00,$01,$00,$00,$01,$01,$00,$01,$01,$01,$01,$01,$01,$01  // $0faa  
    .byte $00,$00,$00,$05,$00,$00,$01,$04,$00,$01,$04,$04,$01,$04,$04,$04  // $0fba  
    .byte $00,$00,$00,$15,$00,$00,$05,$10,$00,$05,$11,$14,$05,$11,$11,$14  // $0fca  
    .byte $00,$00,$00,$55,$00,$00,$15,$40,$00,$15,$41,$54,$15,$45,$51,$54  // $0fda  
L0fea:
    ldy $fb                                     // $0fea  
    cpy #$05                                    // $0fec  
    bcs L1001                                   // $0fee  
    ldx $fe                                     // $0ff0  
L0ff2:
    lda #$55                                    // $0ff2  
    sta D2058,x                                 // $0ff4  
    lda #$00                                    // $0ff7  
    sta D2040,x                                 // $0ff9  
    dex                                         // $0ffc  
    bpl L0ff2                                   // $0ffd  
    bmi L1035                                   // $0fff  
L1001:
    tya                                         // $1001  
    sec                                         // $1002  
    sbc #$05                                    // $1003  
    asl                                         // $1005  
    asl                                         // $1006  
    asl                                         // $1007  
    asl                                         // $1008  
    sta $fd                                     // $1009  
    lda $fe                                     // $100b  
    lsr                                         // $100d  
    asl                                         // $100e  
    asl                                         // $100f  
    clc                                         // $1010  
    adc $fd                                     // $1011  
    sta $fd                                     // $1013  
    ldx #$07                                    // $1015  
L1017:
    ldy $fd                                     // $1017  
    lda D0f6a,y                                 // $1019  
    sta D2040,x                                 // $101c  
    sta D203f,x                                 // $101f  
    lda D0ee0,y                                 // $1022  
    tay                                         // $1025  
    lda D0f60,y                                 // $1026  
    sta D2058,x                                 // $1029  
    dex                                         // $102c  
    sta D2058,x                                 // $102d  
    inc $fd                                     // $1030  
    dex                                         // $1032  
    bpl L1017                                   // $1033  
L1035:
    ldx $fe                                     // $1035  
    lda #$55                                    // $1037  
L1039:
    sta D2050,x                                 // $1039  
    dex                                         // $103c  
    bpl L1039                                   // $103d  
    ldy $fb                                     // $103f  
    cpy #$04                                    // $1041  
    bcc L1056                                   // $1043  
    ldx $fe                                     // $1045  
L1047:
    lda #$55                                    // $1047  
    sta D2048,x                                 // $1049  
    lda #$00                                    // $104c  
    sta D2060,x                                 // $104e  
    dex                                         // $1051  
    bpl L1047                                   // $1052  
    bmi L108d                                   // $1054  
L1056:
    sty $fd                                     // $1056  
    lda #$03                                    // $1058  
    sec                                         // $105a  
    sbc $fd                                     // $105b  
    asl                                         // $105d  
    asl                                         // $105e  
    asl                                         // $105f  
    asl                                         // $1060  
    sta $fd                                     // $1061  
    lda $fe                                     // $1063  
    lsr                                         // $1065  
    asl                                         // $1066  
    asl                                         // $1067  
    clc                                         // $1068  
    adc $fd                                     // $1069  
    sta $fd                                     // $106b  
    ldx #$07                                    // $106d  
L106f:
    ldy $fd                                     // $106f  
    lda D0faa,y                                 // $1071  
    sta D2060,x                                 // $1074  
    sta D205f,x                                 // $1077  
    lda D0ee0,y                                 // $107a  
    tay                                         // $107d  
    lda D0f65,y                                 // $107e  
    sta D2048,x                                 // $1081  
    dex                                         // $1084  
    sta D2048,x                                 // $1085  
    inc $fd                                     // $1088  
    dex                                         // $108a  
    bpl L106f                                   // $108b  
L108d:
    rts                                         // $108d  
L108e:
    ldy $fc                                     // $108e  
    cpy #$05                                    // $1090  
    bcs L10a3                                   // $1092  
    ldy $fe                                     // $1094  
    lda D1125,y                                 // $1096  
    ldx #$07                                    // $1099  
L109b:
    sta D2078,x                                 // $109b  
    dex                                         // $109e  
    bpl L109b                                   // $109f  
    bmi L10d2                                   // $10a1  
L10a3:
    tya                                         // $10a3  
    sec                                         // $10a4  
    sbc #$05                                    // $10a5  
    asl                                         // $10a7  
    asl                                         // $10a8  
    asl                                         // $10a9  
    asl                                         // $10aa  
    sta $fd                                     // $10ab  
    lda #$03                                    // $10ad  
    sec                                         // $10af  
    sbc $fe                                     // $10b0  
    asl                                         // $10b2  
    asl                                         // $10b3  
    clc                                         // $10b4  
    adc $fd                                     // $10b5  
    sta $fd                                     // $10b7  
    ldx #$00                                    // $10b9  
L10bb:
    ldy $fd                                     // $10bb  
    lda D0f20,y                                 // $10bd  
    tay                                         // $10c0  
    lda D0f60,y                                 // $10c1  
    sta D2078,x                                 // $10c4  
    inx                                         // $10c7  
    sta D2078,x                                 // $10c8  
    inc $fd                                     // $10cb  
    inx                                         // $10cd  
    cpx #$08                                    // $10ce  
    bcc L10bb                                   // $10d0  
L10d2:
    ldy $fe                                     // $10d2  
    lda D1125,y                                 // $10d4  
    ldx #$07                                    // $10d7  
L10d9:
    sta D2070,x                                 // $10d9  
    dex                                         // $10dc  
    bpl L10d9                                   // $10dd  
    ldy $fc                                     // $10df  
    cpy #$04                                    // $10e1  
    bcc L10f4                                   // $10e3  
    ldy $fe                                     // $10e5  
    lda D1125,y                                 // $10e7  
    ldx #$07                                    // $10ea  
L10ec:
    sta D2068,x                                 // $10ec  
    dex                                         // $10ef  
    bpl L10ec                                   // $10f0  
    bmi L1124                                   // $10f2  
L10f4:
    sty $fd                                     // $10f4  
    lda #$03                                    // $10f6  
    sec                                         // $10f8  
    sbc $fd                                     // $10f9  
    asl                                         // $10fb  
    asl                                         // $10fc  
    asl                                         // $10fd  
    asl                                         // $10fe  
    sta $fd                                     // $10ff  
    lda #$03                                    // $1101  
    sec                                         // $1103  
    sbc $fe                                     // $1104  
    asl                                         // $1106  
    asl                                         // $1107  
    clc                                         // $1108  
    adc $fd                                     // $1109  
    sta $fd                                     // $110b  
    ldx #$07                                    // $110d  
L110f:
    ldy $fd                                     // $110f  
    lda D0f20,y                                 // $1111  
    tay                                         // $1114  
    lda D0f60,y                                 // $1115  
    sta D2068,x                                 // $1118  
    dex                                         // $111b  
    sta D2068,x                                 // $111c  
    inc $fd                                     // $111f  
    dex                                         // $1121  
    bpl L110f                                   // $1122  
L1124:
    rts                                         // $1124  
D1125:
    .byte $55,$15,$05,$01                       // $1125  
L1129:
    ldy $fc                                     // $1129  
    cpy #$05                                    // $112b  
    bcs L113e                                   // $112d  
    ldy $fe                                     // $112f  
    lda D11ba,y                                 // $1131  
    ldx #$07                                    // $1134  
L1136:
    sta D2028,x                                 // $1136  
    dex                                         // $1139  
    bpl L1136                                   // $113a  
    bmi L116a                                   // $113c  
L113e:
    tya                                         // $113e  
    sec                                         // $113f  
    sbc #$05                                    // $1140  
    asl                                         // $1142  
    asl                                         // $1143  
    asl                                         // $1144  
    asl                                         // $1145  
    sta $fd                                     // $1146  
    lda $fe                                     // $1148  
    asl                                         // $114a  
    asl                                         // $114b  
    clc                                         // $114c  
    adc $fd                                     // $114d  
    sta $fd                                     // $114f  
    ldx #$00                                    // $1151  
L1153:
    ldy $fd                                     // $1153  
    lda D0f20,y                                 // $1155  
    tay                                         // $1158  
    lda D0f65,y                                 // $1159  
    sta D2028,x                                 // $115c  
    inx                                         // $115f  
    sta D2028,x                                 // $1160  
    inc $fd                                     // $1163  
    inx                                         // $1165  
    cpx #$08                                    // $1166  
    bcc L1153                                   // $1168  
L116a:
    ldy $fe                                     // $116a  
    lda D11ba,y                                 // $116c  
    ldx #$07                                    // $116f  
L1171:
    sta D2030,x                                 // $1171  
    dex                                         // $1174  
    bpl L1171                                   // $1175  
    ldy $fc                                     // $1177  
    cpy #$04                                    // $1179  
    bcc L118c                                   // $117b  
    ldy $fe                                     // $117d  
    lda D11ba,y                                 // $117f  
    ldx #$07                                    // $1182  
L1184:
    sta D2038,x                                 // $1184  
    dex                                         // $1187  
    bpl L1184                                   // $1188  
    bmi L11b9                                   // $118a  
L118c:
    sty $fd                                     // $118c  
    lda #$03                                    // $118e  
    sec                                         // $1190  
    sbc $fd                                     // $1191  
    asl                                         // $1193  
    asl                                         // $1194  
    asl                                         // $1195  
    asl                                         // $1196  
    sta $fd                                     // $1197  
    lda $fe                                     // $1199  
    asl                                         // $119b  
    asl                                         // $119c  
    clc                                         // $119d  
    adc $fd                                     // $119e  
    sta $fd                                     // $11a0  
    ldx #$07                                    // $11a2  
L11a4:
    ldy $fd                                     // $11a4  
    lda D0f20,y                                 // $11a6  
    tay                                         // $11a9  
    lda D0f65,y                                 // $11aa  
    sta D2038,x                                 // $11ad  
    dex                                         // $11b0  
    sta D2038,x                                 // $11b1  
    inc $fd                                     // $11b4  
    dex                                         // $11b6  
    bpl L11a4                                   // $11b7  
L11b9:
    rts                                         // $11b9  
D11ba:
    .byte $40,$50,$54,$55                       // $11ba  
L11be:
    lda $fb                                     // $11be  
    sec                                         // $11c0  
    sbc #$04                                    // $11c1  
    sta $fa                                     // $11c3  
    lda #$04                                    // $11c5  
    sec                                         // $11c7  
    sbc $fc                                     // $11c8  
    sta $ff                                     // $11ca  
    jsr L1292                                   // $11cc  
    lda $fb                                     // $11cf  
    sec                                         // $11d1  
    sbc $fc                                     // $11d2  
    bpl L11da                                   // $11d4  
    lda #$00                                    // $11d6  
    beq L11dc                                   // $11d8  
L11da:
    lda $fe                                     // $11da  
L11dc:
    clc                                         // $11dc  
    adc #$01                                    // $11dd  
    asl                                         // $11df  
    asl                                         // $11e0  
    asl                                         // $11e1  
    tax                                         // $11e2  
    dex                                         // $11e3  
    ldy #$07                                    // $11e4  
L11e6:
    lda D1e00,x                                 // $11e6  
    sta D2118,y                                 // $11e9  
    lda D1e48,x                                 // $11ec  
    sta D2120,y                                 // $11ef  
    dex                                         // $11f2  
    dey                                         // $11f3  
    bpl L11e6                                   // $11f4  
    lda $fc                                     // $11f6  
    sec                                         // $11f8  
    sbc $fb                                     // $11f9  
    bpl L1201                                   // $11fb  
    lda #$00                                    // $11fd  
    beq L1203                                   // $11ff  
L1201:
    lda $fe                                     // $1201  
L1203:
    asl                                         // $1203  
    asl                                         // $1204  
    asl                                         // $1205  
    tax                                         // $1206  
    pha                                         // $1207  
    ldy #$00                                    // $1208  
L120a:
    lda D1f68,x                                 // $120a  
    sta D2128,y                                 // $120d  
    inx                                         // $1210  
    iny                                         // $1211  
    cpy #$08                                    // $1212  
    bne L120a                                   // $1214  
    pla                                         // $1216  
    tax                                         // $1217  
    ldy #$07                                    // $1218  
L121a:
    lda D1ed8,x                                 // $121a  
    sta D2130,y                                 // $121d  
    inx                                         // $1220  
    dey                                         // $1221  
    bpl L121a                                   // $1222  
    lda $fb                                     // $1224  
    sec                                         // $1226  
    sbc #$04                                    // $1227  
    sta $fa                                     // $1229  
    lda $fc                                     // $122b  
    sec                                         // $122d  
    sbc #$04                                    // $122e  
    sta $ff                                     // $1230  
    jsr L1292                                   // $1232  
    lda $fb                                     // $1235  
    clc                                         // $1237  
    adc $fc                                     // $1238  
    sta $fd                                     // $123a  
    lda #$08                                    // $123c  
    sec                                         // $123e  
    sbc $fd                                     // $123f  
    bpl L1247                                   // $1241  
    lda #$00                                    // $1243  
    beq L1249                                   // $1245  
L1247:
    lda $fe                                     // $1247  
L1249:
    clc                                         // $1249  
    adc #$01                                    // $124a  
    asl                                         // $124c  
    asl                                         // $124d  
    asl                                         // $124e  
    tax                                         // $124f  
    dex                                         // $1250  
    ldy #$07                                    // $1251  
L1253:
    lda D1e90,x                                 // $1253  
    sta D2138,y                                 // $1256  
    lda D1ed8,x                                 // $1259  
    sta D2140,y                                 // $125c  
    dex                                         // $125f  
    dey                                         // $1260  
    bpl L1253                                   // $1261  
    lda $fd                                     // $1263  
    sec                                         // $1265  
    sbc #$08                                    // $1266  
    bpl L126e                                   // $1268  
    lda #$00                                    // $126a  
    beq L1270                                   // $126c  
L126e:
    lda $fe                                     // $126e  
L1270:
    asl                                         // $1270  
    asl                                         // $1271  
    asl                                         // $1272  
    tax                                         // $1273  
    pha                                         // $1274  
    ldy #$00                                    // $1275  
L1277:
    lda D1f20,x                                 // $1277  
    sta D2148,y                                 // $127a  
    inx                                         // $127d  
    iny                                         // $127e  
    cpy #$08                                    // $127f  
    bne L1277                                   // $1281  
    pla                                         // $1283  
    tax                                         // $1284  
    ldy #$07                                    // $1285  
L1287:
    lda D1e48,x                                 // $1287  
    sta D2150,y                                 // $128a  
    inx                                         // $128d  
    dey                                         // $128e  
    bpl L1287                                   // $128f  
    rts                                         // $1291  
L1292:
    lda $fa                                     // $1292  
    clc                                         // $1294  
    adc $ff                                     // $1295  
    bpl L129e                                   // $1297  
    eor #$ff                                    // $1299  
    clc                                         // $129b  
    adc #$01                                    // $129c  
L129e:
    sta $fe                                     // $129e  
    lda $fa                                     // $12a0  
    bpl L12a9                                   // $12a2  
    eor #$ff                                    // $12a4  
    clc                                         // $12a6  
    adc #$01                                    // $12a7  
L12a9:
    sta $fa                                     // $12a9  
    lda $ff                                     // $12ab  
    bpl L12b4                                   // $12ad  
    eor #$ff                                    // $12af  
    clc                                         // $12b1  
    adc #$01                                    // $12b2  
L12b4:
    sec                                         // $12b4  
    sbc $fa                                     // $12b5  
    bpl L12be                                   // $12b7  
    eor #$ff                                    // $12b9  
    clc                                         // $12bb  
    adc #$01                                    // $12bc  
L12be:
    clc                                         // $12be  
    adc $fe                                     // $12bf  
    sta $fe                                     // $12c1  
    rts                                         // $12c3  
L12c4:
    ldx #$07                                    // $12c4  
L12c6:
    lda D2118,x                                 // $12c6  
    lsr                                         // $12c9  
    ora D2118,x                                 // $12ca  
    tay                                         // $12cd  
    and D2010,x                                 // $12ce  
    sta D2158,x                                 // $12d1  
    tya                                         // $12d4  
    and D2030,x                                 // $12d5  
    sta D2170,x                                 // $12d8  
    lda D2120,x                                 // $12db  
    tay                                         // $12de  
    and D2010,x                                 // $12df  
    sta D2160,x                                 // $12e2  
    tya                                         // $12e5  
    and D2030,x                                 // $12e6  
    sta D2168,x                                 // $12e9  
    dex                                         // $12ec  
    bpl L12c6                                   // $12ed  
    ldx #$07                                    // $12ef  
L12f1:
    lda D2148,x                                 // $12f1  
    lsr                                         // $12f4  
    ora D2148,x                                 // $12f5  
    tay                                         // $12f8  
    and D2030,x                                 // $12f9  
    sta D2178,x                                 // $12fc  
    tya                                         // $12ff  
    and D2050,x                                 // $1300  
    sta D2188,x                                 // $1303  
    lda D2150,x                                 // $1306  
    tay                                         // $1309  
    and D2030,x                                 // $130a  
    sta D2180,x                                 // $130d  
    tya                                         // $1310  
    and D2050,x                                 // $1311  
    sta D2190,x                                 // $1314  
    dex                                         // $1317  
    bpl L12f1                                   // $1318  
    ldx #$07                                    // $131a  
L131c:
    lda D2128,x                                 // $131c  
    lsr                                         // $131f  
    ora D2128,x                                 // $1320  
    tay                                         // $1323  
    and D2050,x                                 // $1324  
    sta D21a0,x                                 // $1327  
    tya                                         // $132a  
    and D2070,x                                 // $132b  
    sta D21a8,x                                 // $132e  
    lda D2130,x                                 // $1331  
    tay                                         // $1334  
    and D2050,x                                 // $1335  
    sta D2198,x                                 // $1338  
    tya                                         // $133b  
    and D2070,x                                 // $133c  
    sta D21b0,x                                 // $133f  
    dex                                         // $1342  
    bpl L131c                                   // $1343  
    ldx #$07                                    // $1345  
L1347:
    lda D2138,x                                 // $1347  
    lsr                                         // $134a  
    ora D2138,x                                 // $134b  
    tay                                         // $134e  
    and D2070,x                                 // $134f  
    sta D21c0,x                                 // $1352  
    tya                                         // $1355  
    and D2010,x                                 // $1356  
    sta D21d0,x                                 // $1359  
    lda D2140,x                                 // $135c  
    tay                                         // $135f  
    and D2070,x                                 // $1360  
    sta D21b8,x                                 // $1363  
    tya                                         // $1366  
    and D2010,x                                 // $1367  
    sta D21c8,x                                 // $136a  
    dex                                         // $136d  
    bpl L1347                                   // $136e  
    rts                                         // $1370  
L1371:
    ldx #$07                                    // $1371  
L1373:
    lda D2130,x                                 // $1373  
    tay                                         // $1376  
    ora D2050,x                                 // $1377  
    sta D20c8,x                                 // $137a  
    tya                                         // $137d  
    ora D2070,x                                 // $137e  
    sta D20d0,x                                 // $1381  
    dex                                         // $1384  
    bpl L1373                                   // $1385  
    ldx #$07                                    // $1387  
L1389:
    lda D2140,x                                 // $1389  
    tay                                         // $138c  
    ora D2070,x                                 // $138d  
    sta D20d8,x                                 // $1390  
    tya                                         // $1393  
    ora D2010,x                                 // $1394  
    sta D20e0,x                                 // $1397  
    dex                                         // $139a  
    bpl L1389                                   // $139b  
    ldx #$07                                    // $139d  
L139f:
    lda D2120,x                                 // $139f  
    tay                                         // $13a2  
    ora D2010,x                                 // $13a3  
    sta D20e8,x                                 // $13a6  
    tya                                         // $13a9  
    ora D2030,x                                 // $13aa  
    sta D20f0,x                                 // $13ad  
    dex                                         // $13b0  
    bpl L139f                                   // $13b1  
    ldx #$07                                    // $13b3  
L13b5:
    lda D2150,x                                 // $13b5  
    tay                                         // $13b8  
    ora D2030,x                                 // $13b9  
    sta D20f8,x                                 // $13bc  
    tya                                         // $13bf  
    ora D2050,x                                 // $13c0  
    sta D2108,x                                 // $13c3  
    dex                                         // $13c6  
    bpl L13b5                                   // $13c7  
    rts                                         // $13c9  
L13ca:
    ldx #$07                                    // $13ca  
L13cc:
    lda D2038,x                                 // $13cc  
    and D2170,x                                 // $13cf  
    sta D21d8,x                                 // $13d2  
    lda D2048,x                                 // $13d5  
    and D2130,x                                 // $13d8  
    sta D21e0,x                                 // $13db  
    lda D2030,x                                 // $13de  
    and D21a0,x                                 // $13e1  
    sta D21e8,x                                 // $13e4  
    lda D2038,x                                 // $13e7  
    and D2120,x                                 // $13ea  
    sta D21f0,x                                 // $13ed  
    lda D2048,x                                 // $13f0  
    and D21a0,x                                 // $13f3  
    sta D21f8,x                                 // $13f6  
    lda D2050,x                                 // $13f9  
    and D2170,x                                 // $13fc  
    sta D2200,x                                 // $13ff  
    lda D2018,x                                 // $1402  
    and D2140,x                                 // $1405  
    sta D2208,x                                 // $1408  
    lda D2030,x                                 // $140b  
    and D21d0,x                                 // $140e  
    sta D2210,x                                 // $1411  
    lda D2028,x                                 // $1414  
    and D2178,x                                 // $1417  
    sta D2218,x                                 // $141a  
    lda D2018,x                                 // $141d  
    and D21d0,x                                 // $1420  
    sta D2220,x                                 // $1423  
    lda D2010,x                                 // $1426  
    and D2178,x                                 // $1429  
    sta D2228,x                                 // $142c  
    lda D2028,x                                 // $142f  
    and D2150,x                                 // $1432  
    sta D2230,x                                 // $1435  
    dex                                         // $1438  
    bpl L13cc                                   // $1439  
    ldx #$07                                    // $143b  
L143d:
    lda D2070,x                                 // $143d  
    and D2158,x                                 // $1440  
    sta D2238,x                                 // $1443  
    lda D2008,x                                 // $1446  
    and D2120,x                                 // $1449  
    sta D2240,x                                 // $144c  
    lda D2078,x                                 // $144f  
    and D21a8,x                                 // $1452  
    sta D2248,x                                 // $1455  
    lda D2010,x                                 // $1458  
    and D21a8,x                                 // $145b  
    sta D2250,x                                 // $145e  
    lda D2008,x                                 // $1461  
    and D2158,x                                 // $1464  
    sta D2258,x                                 // $1467  
    lda D2078,x                                 // $146a  
    and D2130,x                                 // $146d  
    sta D2260,x                                 // $1470  
    lda D2068,x                                 // $1473  
    and D21c0,x                                 // $1476  
    sta D2268,x                                 // $1479  
    lda D2070,x                                 // $147c  
    and D2188,x                                 // $147f  
    sta D2270,x                                 // $1482  
    lda D2058,x                                 // $1485  
    and D2150,x                                 // $1488  
    sta D2278,x                                 // $148b  
    lda D2068,x                                 // $148e  
    and D2140,x                                 // $1491  
    sta D2280,x                                 // $1494  
    lda D2050,x                                 // $1497  
    and D21c0,x                                 // $149a  
    sta D2288,x                                 // $149d  
    lda D2058,x                                 // $14a0  
    and D2188,x                                 // $14a3  
    sta D2290,x                                 // $14a6  
    dex                                         // $14a9  
    bpl L143d                                   // $14aa  
    rts                                         // $14ac  
L14ad:
    ldx #$07                                    // $14ad  
L14af:
    lda D2140,x                                 // $14af  
    and D2158,x                                 // $14b2  
    sta D2298,x                                 // $14b5  
    lda D2120,x                                 // $14b8  
    and D21d0,x                                 // $14bb  
    sta D22a0,x                                 // $14be  
    lda D2120,x                                 // $14c1  
    and D2178,x                                 // $14c4  
    sta D22a8,x                                 // $14c7  
    lda D2150,x                                 // $14ca  
    and D2170,x                                 // $14cd  
    sta D22b0,x                                 // $14d0  
    lda D2188,x                                 // $14d3  
    and D2130,x                                 // $14d6  
    sta D22b8,x                                 // $14d9  
    lda D21a0,x                                 // $14dc  
    and D2150,x                                 // $14df  
    sta D22c0,x                                 // $14e2  
    lda D21a8,x                                 // $14e5  
    and D2140,x                                 // $14e8  
    sta D22c8,x                                 // $14eb  
    lda D21c0,x                                 // $14ee  
    and D2130,x                                 // $14f1  
    sta D22d0,x                                 // $14f4  
    dex                                         // $14f7  
    bpl L14af                                   // $14f8  
    rts                                         // $14fa  
L14fb:
    ldx #$07                                    // $14fb  
L14fd:
    lda D2148,x                                 // $14fd  
    sta $fb                                     // $1500  
    lsr                                         // $1502  
    ora $fb                                     // $1503  
    eor #$ff                                    // $1505  
    and D2130,x                                 // $1507  
    ora $fb                                     // $150a  
    sta D22d8,x                                 // $150c  
    lda D2128,x                                 // $150f  
    sta $fb                                     // $1512  
    lsr                                         // $1514  
    ora $fb                                     // $1515  
    eor #$ff                                    // $1517  
    and D2150,x                                 // $1519  
    ora $fb                                     // $151c  
    sta D22e0,x                                 // $151e  
    lda D2128,x                                 // $1521  
    sta $fb                                     // $1524  
    lsr                                         // $1526  
    ora $fb                                     // $1527  
    eor #$ff                                    // $1529  
    and D2140,x                                 // $152b  
    ora $fb                                     // $152e  
    sta D22e8,x                                 // $1530  
    lda D2138,x                                 // $1533  
    sta $fb                                     // $1536  
    lsr                                         // $1538  
    ora $fb                                     // $1539  
    eor #$ff                                    // $153b  
    and D2130,x                                 // $153d  
    ora $fb                                     // $1540  
    sta D22f0,x                                 // $1542  
    dex                                         // $1545  
    bpl L14fd                                   // $1546  
    ldx #$07                                    // $1548  
L154a:
    lda D2118,x                                 // $154a  
    sta $fb                                     // $154d  
    lsr                                         // $154f  
    ora $fb                                     // $1550  
    eor #$ff                                    // $1552  
    and D2140,x                                 // $1554  
    ora $fb                                     // $1557  
    sta D22f8,x                                 // $1559  
    lda D2138,x                                 // $155c  
    sta $fb                                     // $155f  
    lsr                                         // $1561  
    ora $fb                                     // $1562  
    eor #$ff                                    // $1564  
    and D2120,x                                 // $1566  
    ora $fb                                     // $1569  
    sta D2300,x                                 // $156b  
    lda D2148,x                                 // $156e  
    sta $fb                                     // $1571  
    lsr                                         // $1573  
    ora $fb                                     // $1574  
    eor #$ff                                    // $1576  
    and D2120,x                                 // $1578  
    ora $fb                                     // $157b  
    sta D2308,x                                 // $157d  
    lda D2118,x                                 // $1580  
    sta $fb                                     // $1583  
    lsr                                         // $1585  
    ora $fb                                     // $1586  
    eor #$ff                                    // $1588  
    and D2150,x                                 // $158a  
    ora $fb                                     // $158d  
    sta D2310,x                                 // $158f  
    dex                                         // $1592  
    bpl L154a                                   // $1593  
    rts                                         // $1595  
L1596:
    ldx #$1f                                    // $1596  
    stx SID_MODE_VOL                            // $1598  
    lda #$00                                    // $159b  
    sta SID_V3_FREQ_LO                          // $159d  
    lda #$08                                    // $15a0  
    sta SID_V3_FREQ_HI                          // $15a2  
    lda $cf00                                   // $15a5  
    bpl L15af                                   // $15a8  
    eor #$ff                                    // $15aa  
    clc                                         // $15ac  
    adc #$01                                    // $15ad  
L15af:
    sta $fb                                     // $15af  
    lda $cf01                                   // $15b1  
    bpl L15bb                                   // $15b4  
    eor #$ff                                    // $15b6  
    clc                                         // $15b8  
    adc #$01                                    // $15b9  
L15bb:
    clc                                         // $15bb  
    adc $fb                                     // $15bc  
    ror                                         // $15be  
    lsr                                         // $15bf  
    ldx $cf4d                                   // $15c0  
    beq L15c7                                   // $15c3  
    lda #$00                                    // $15c5  
L15c7:
    sta $fc                                     // $15c7  
    lsr                                         // $15c9  
    cmp #$10                                    // $15ca  
    bcc L15d0                                   // $15cc  
    lda #$0f                                    // $15ce  
L15d0:
    sta $cf10                                   // $15d0  
    asl                                         // $15d3  
    asl                                         // $15d4  
    asl                                         // $15d5  
    asl                                         // $15d6  
    sta SID_V3_SR                               // $15d7  
    lda $cf11                                   // $15da  
    cmp $cf10                                   // $15dd  
    bcs L15e7                                   // $15e0  
    lda #$80                                    // $15e2  
    sta SID_V3_CTRL                             // $15e4  
L15e7:
    lda #$81                                    // $15e7  
    sta SID_V3_CTRL                             // $15e9  
    lda $cf10                                   // $15ec  
    sta $cf11                                   // $15ef  
    ldy #$ff                                    // $15f2  
    lda $fc                                     // $15f4  
    cmp #$02                                    // $15f6  
    bcs L15ff                                   // $15f8  
    lda #$00                                    // $15fa  
    sta $cf13                                   // $15fc  
L15ff:
    cmp #$1b                                    // $15ff  
    bcc L1605                                   // $1601  
    lda #$1b                                    // $1603  
L1605:
    ldx $cf12                                   // $1605  
    bne L1620                                   // $1608  
    clc                                         // $160a  
    adc $cf13                                   // $160b  
    cmp #$1c                                    // $160e  
    bcc L1636                                   // $1610  
    eor #$ff                                    // $1612  
    clc                                         // $1614  
    adc #$38                                    // $1615  
    ldx #$01                                    // $1617  
    stx $cf12                                   // $1619  
    ldy #$1c                                    // $161c  
    bne L1636                                   // $161e  
L1620:
    sta $fb                                     // $1620  
    lda $cf13                                   // $1622  
    sec                                         // $1625  
    sbc $fb                                     // $1626  
    bcs L1636                                   // $1628  
    eor #$ff                                    // $162a  
    clc                                         // $162c  
    adc #$01                                    // $162d  
    ldx #$00                                    // $162f  
    stx $cf12                                   // $1631  
    ldy #$00                                    // $1634  
L1636:
    sta $cf13                                   // $1636  
    cpy #$ff                                    // $1639  
    beq L163e                                   // $163b  
    tya                                         // $163d  
L163e:
    lsr $fc                                     // $163e  
    clc                                         // $1640  
    adc $fc                                     // $1641  
    sta SID_FC_HI                               // $1643  
    rts                                         // $1646  
L1647:
    lda $cf03                                   // $1647  
    clc                                         // $164a  
    adc $cf09                                   // $164b  
    sta $fb                                     // $164e  
    lda $cf04                                   // $1650  
    adc #$00                                    // $1653  
    sta $fc                                     // $1655  
    lda $fb                                     // $1657  
    sec                                         // $1659  
    sbc #$04                                    // $165a  
    sta $fb                                     // $165c  
    lda $fc                                     // $165e  
    sbc #$00                                    // $1660  
    sta $fc                                     // $1662  
    lda $fb                                     // $1664  
    sta VIC_SPR4_X                              // $1666  
    lda VIC_SPR_X_MSB                           // $1669  
    ldx $fc                                     // $166c  
    beq L1674                                   // $166e  
    ora #$10                                    // $1670  
    bne L1676                                   // $1672  
L1674:
    and #$ef                                    // $1674  
L1676:
    sta VIC_SPR_X_MSB                           // $1676  
    lda $cf06                                   // $1679  
    clc                                         // $167c  
    adc $cf0a                                   // $167d  
    sec                                         // $1680  
    sbc #$04                                    // $1681  
    sta VIC_SPR4_Y                              // $1683  
    rts                                         // $1686  
L1687:
    cpy #$05                                    // $1687  
    bcc L1691                                   // $1689  
    ldx #$04                                    // $168b  
    ldy #$04                                    // $168d  
    bpl L16c0                                   // $168f  
L1691:
    stx $fb                                     // $1691  
    cpx #$05                                    // $1693  
    bcc L169d                                   // $1695  
    lda #$08                                    // $1697  
    sec                                         // $1699  
    sbc $fb                                     // $169a  
    tax                                         // $169c  
L169d:
    tya                                         // $169d  
    asl                                         // $169e  
    asl                                         // $169f  
    sty $fc                                     // $16a0  
    clc                                         // $16a2  
    adc $fc                                     // $16a3  
    stx $fc                                     // $16a5  
    clc                                         // $16a7  
    adc $fc                                     // $16a8  
    asl                                         // $16aa  
    tax                                         // $16ab  
    lda D16c2,x                                 // $16ac  
    tay                                         // $16af  
    lda D16c1,x                                 // $16b0  
    tax                                         // $16b3  
    lda $fb                                     // $16b4  
    cmp #$05                                    // $16b6  
    bcc L16c0                                   // $16b8  
    stx $fc                                     // $16ba  
    tya                                         // $16bc  
    tax                                         // $16bd  
    ldy $fc                                     // $16be  
L16c0:
    rts                                         // $16c0  
D16c1:
    .byte $04                                   // $16c1  
D16c2:
    .byte $00,$03,$00,$02,$00,$01,$00,$00,$00,$04,$00,$03,$00,$02,$01,$01  // $16c2  
    .byte $01,$01,$01,$04,$00,$03,$01,$02,$01,$02,$02,$02,$02,$04,$00,$03  // $16d2  
    .byte $01,$03,$02,$03,$02,$03,$03,$04,$00,$04,$01,$04,$02,$04,$03,$04  // $16e2  
    .byte $04                                   // $16f2  
L16f3:
    ldx $cf09                                   // $16f3  
    ldy $cf0a                                   // $16f6  
    jsr L1687                                   // $16f9  
    stx $fb                                     // $16fc  
    tya                                         // $16fe  
    sec                                         // $16ff  
    sbc $fb                                     // $1700  
    ldy #$01                                    // $1702  
    bcs L170d                                   // $1704  
    ldy #$ff                                    // $1706  
    eor #$ff                                    // $1708  
    clc                                         // $170a  
    adc #$01                                    // $170b  
L170d:
    sty $cf20                                   // $170d  
    tax                                         // $1710  
    lda D173f,x                                 // $1711  
    sta $fc                                     // $1714  
    ldx #$00                                    // $1716  
    asl $fb                                     // $1718  
L171a:
    ldy $fb                                     // $171a  
    tya                                         // $171c  
    clc                                         // $171d  
    adc $cf20                                   // $171e  
    sta $fb                                     // $1721  
    lda D1736,y                                 // $1723  
    ldy $fc                                     // $1726  
L1728:
    sta D079a,x                                 // $1728  
    inx                                         // $172b  
    cpx #$23                                    // $172c  
    beq L1735                                   // $172e  
    dey                                         // $1730  
    bne L1728                                   // $1731  
    beq L171a                                   // $1733  
L1735:
    rts                                         // $1735  
D1736:
    .byte $a0,$6a,$69,$68,$67,$66,$65,$64,$00   // $1736  
D173f:
    .byte $ff,$0c,$07,$05,$04                   // $173f  
L1744:
    ldx $cf09                                   // $1744  
    lda #$08                                    // $1747  
    sec                                         // $1749  
    sbc $cf0a                                   // $174a  
    tay                                         // $174d  
    jsr L1687                                   // $174e  
    stx $fb                                     // $1751  
    tya                                         // $1753  
    sec                                         // $1754  
    sbc $fb                                     // $1755  
    ldy #$01                                    // $1757  
    bcs L1762                                   // $1759  
    ldy #$ff                                    // $175b  
    eor #$ff                                    // $175d  
    clc                                         // $175f  
    adc #$01                                    // $1760  
L1762:
    sty $cf20                                   // $1762  
    tax                                         // $1765  
    lda D173f,x                                 // $1766  
    sta $fc                                     // $1769  
    ldx #$00                                    // $176b  
    asl $fb                                     // $176d  
L176f:
    ldy $fb                                     // $176f  
    tya                                         // $1771  
    clc                                         // $1772  
    adc $cf20                                   // $1773  
    sta $fb                                     // $1776  
    lda D178b,y                                 // $1778  
    ldy $fc                                     // $177b  
L177d:
    sta D047a,x                                 // $177d  
    inx                                         // $1780  
    cpx #$23                                    // $1781  
    beq L178a                                   // $1783  
    dey                                         // $1785  
    bne L177d                                   // $1786  
    beq L176f                                   // $1788  
L178a:
    rts                                         // $178a  
D178b:
    .byte $a0,$71,$70,$6f,$6e,$6d,$6c,$6b,$00   // $178b  
L1794:
    lda #$08                                    // $1794  
    sec                                         // $1796  
    sbc $cf09                                   // $1797  
    tay                                         // $179a  
    ldx $cf0a                                   // $179b  
    jsr L1687                                   // $179e  
    txa                                         // $17a1  
    nop                                         // $17a2  
    tax                                         // $17a3  
    tya                                         // $17a4  
    nop                                         // $17a5  
    tay                                         // $17a6  
    stx $fb                                     // $17a7  
    tya                                         // $17a9  
    sec                                         // $17aa  
    sbc $fb                                     // $17ab  
    ldy #$01                                    // $17ad  
    bcs L17b8                                   // $17af  
    ldy #$ff                                    // $17b1  
    eor #$ff                                    // $17b3  
    clc                                         // $17b5  
    adc #$01                                    // $17b6  
L17b8:
    sty $cf20                                   // $17b8  
    tax                                         // $17bb  
    lda D17fc,x                                 // $17bc  
    sta $cf21                                   // $17bf  
    lda #<D04a1                                 // $17c2  
    sta $fd                                     // $17c4  
    lda #>D04a1                                 // $17c6  
    sta $fe                                     // $17c8  
    lda #$13                                    // $17ca  
    sta $fc                                     // $17cc  
L17ce:
    ldy $fb                                     // $17ce  
    tya                                         // $17d0  
    clc                                         // $17d1  
    adc $cf20                                   // $17d2  
    sta $fb                                     // $17d5  
    lda D1801,y                                 // $17d7  
    sta $cf22                                   // $17da  
    ldy #$00                                    // $17dd  
    ldx $cf21                                   // $17df  
L17e2:
    lda $cf22                                   // $17e2  
    sta ($fd),y                                 // $17e5  
    dec $fc                                     // $17e7  
    beq L17fb                                   // $17e9  
    lda $fd                                     // $17eb  
    clc                                         // $17ed  
    adc #$28                                    // $17ee  
    sta $fd                                     // $17f0  
    bcc L17f6                                   // $17f2  
    inc $fe                                     // $17f4  
L17f6:
    dex                                         // $17f6  
    bne L17e2                                   // $17f7  
    beq L17ce                                   // $17f9  
L17fb:
    rts                                         // $17fb  
D17fc:
    .byte $ff,$0a,$07,$05,$04                   // $17fc  
D1801:
    .byte $a0,$74,$73,$72,$00                   // $1801  
L1806:
    ldx $cf0a                                   // $1806  
    ldy $cf09                                   // $1809  
    jsr L1687                                   // $180c  
    txa                                         // $180f  
    nop                                         // $1810  
    tax                                         // $1811  
    tya                                         // $1812  
    nop                                         // $1813  
    tay                                         // $1814  
    stx $fb                                     // $1815  
    tya                                         // $1817  
    sec                                         // $1818  
    sbc $fb                                     // $1819  
    ldy #$01                                    // $181b  
    bcs L1826                                   // $181d  
    ldy #$ff                                    // $181f  
    eor #$ff                                    // $1821  
    clc                                         // $1823  
    adc #$01                                    // $1824  
L1826:
    sty $cf20                                   // $1826  
    tax                                         // $1829  
    lda D17fc,x                                 // $182a  
    sta $cf21                                   // $182d  
    lda #<D04c5                                 // $1830  
    sta $fd                                     // $1832  
    lda #>D04c5                                 // $1834  
    sta $fe                                     // $1836  
    lda #$13                                    // $1838  
    sta $fc                                     // $183a  
L183c:
    ldy $fb                                     // $183c  
    tya                                         // $183e  
    clc                                         // $183f  
    adc $cf20                                   // $1840  
    sta $fb                                     // $1843  
    lda D186a,y                                 // $1845  
    sta $cf22                                   // $1848  
    ldy #$00                                    // $184b  
    ldx $cf21                                   // $184d  
L1850:
    lda $cf22                                   // $1850  
    sta ($fd),y                                 // $1853  
    dec $fc                                     // $1855  
    beq L1869                                   // $1857  
    lda $fd                                     // $1859  
    clc                                         // $185b  
    adc #$28                                    // $185c  
    sta $fd                                     // $185e  
    bcc L1864                                   // $1860  
    inc $fe                                     // $1862  
L1864:
    dex                                         // $1864  
    bne L1850                                   // $1865  
    beq L183c                                   // $1867  
L1869:
    rts                                         // $1869  
D186a:
    .byte $a0,$77,$76,$75,$00                   // $186a  
L186f:
    sta $fb                                     // $186f  
    lda #$00                                    // $1871  
    asl $fb                                     // $1873  
    rol                                         // $1875  
    asl $fb                                     // $1876  
    rol                                         // $1878  
    asl $fb                                     // $1879  
    rol                                         // $187b  
    clc                                         // $187c  
    adc #$20                                    // $187d  
    sta $fc                                     // $187f  
    rts                                         // $1881  
L1882:
    sta $fd                                     // $1882  
    lda #$00                                    // $1884  
    asl $fd                                     // $1886  
    rol                                         // $1888  
    asl $fd                                     // $1889  
    rol                                         // $188b  
    asl $fd                                     // $188c  
    rol                                         // $188e  
    clc                                         // $188f  
    adc #$20                                    // $1890  
    sta $fe                                     // $1892  
    rts                                         // $1894  
L1895:
    lda D047a                                   // $1895  
    jsr L186f                                   // $1898  
    lda D04a1                                   // $189b  
    jsr L1882                                   // $189e  
    ldy #$07                                    // $18a1  
L18a3:
    lda ($fb),y                                 // $18a3  
    and ($fd),y                                 // $18a5  
    sta $fa                                     // $18a7  
    eor #$ff                                    // $18a9  
    sta $ff                                     // $18ab  
    lsr                                         // $18ad  
    and $ff                                     // $18ae  
    and #$55                                    // $18b0  
    ora $fa                                     // $18b2  
    sta D23c0,y                                 // $18b4  
    dey                                         // $18b7  
    bpl L18a3                                   // $18b8  
    lda D049c                                   // $18ba  
    jsr L186f                                   // $18bd  
    lda D04c5                                   // $18c0  
    jsr L1882                                   // $18c3  
    ldy #$07                                    // $18c6  
L18c8:
    lda ($fb),y                                 // $18c8  
    and ($fd),y                                 // $18ca  
    sta $fa                                     // $18cc  
    eor #$ff                                    // $18ce  
    sta $ff                                     // $18d0  
    lsr                                         // $18d2  
    and $ff                                     // $18d3  
    and #$55                                    // $18d5  
    ora $fa                                     // $18d7  
    sta D23c8,y                                 // $18d9  
    dey                                         // $18dc  
    bpl L18c8                                   // $18dd  
    lda D0795                                   // $18df  
    jsr L186f                                   // $18e2  
    lda D07bc                                   // $18e5  
    jsr L1882                                   // $18e8  
    ldy #$07                                    // $18eb  
L18ed:
    lda ($fb),y                                 // $18ed  
    and ($fd),y                                 // $18ef  
    sta $fa                                     // $18f1  
    eor #$ff                                    // $18f3  
    sta $ff                                     // $18f5  
    lsr                                         // $18f7  
    and $ff                                     // $18f8  
    and #$55                                    // $18fa  
    ora $fa                                     // $18fc  
    sta D23d0,y                                 // $18fe  
    dey                                         // $1901  
    bpl L18ed                                   // $1902  
    lda D0771                                   // $1904  
    jsr L186f                                   // $1907  
    lda D079a                                   // $190a  
    jsr L1882                                   // $190d  
    ldy #$07                                    // $1910  
L1912:
    lda ($fb),y                                 // $1912  
    and ($fd),y                                 // $1914  
    sta $fa                                     // $1916  
    eor #$ff                                    // $1918  
    sta $ff                                     // $191a  
    lsr                                         // $191c  
    and $ff                                     // $191d  
    and #$55                                    // $191f  
    ora $fa                                     // $1921  
    sta D23d8,y                                 // $1923  
    dey                                         // $1926  
    bpl L1912                                   // $1927  
    rts                                         // $1929  
L192a:
    ldx #$06                                    // $192a  
L192c:
    lda D2128,x                                 // $192c  
    ora D2148,x                                 // $192f  
    and #$3c                                    // $1932  
    sta $fb                                     // $1934  
    lda D2000,x                                 // $1936  
    and #$c3                                    // $1939  
    ora $fb                                     // $193b  
    sta D23e0,x                                 // $193d  
    inx                                         // $1940  
    cpx #$08                                    // $1941  
    bne L192c                                   // $1943  
    ldx #$01                                    // $1945  
L1947:
    lda D2118,x                                 // $1947  
    ora D2138,x                                 // $194a  
    and #$3c                                    // $194d  
    sta $fb                                     // $194f  
    lda D2000,x                                 // $1951  
    and #$c3                                    // $1954  
    ora $fb                                     // $1956  
    sta D23f0,x                                 // $1958  
    dex                                         // $195b  
    bpl L1947                                   // $195c  
    ldx #$02                                    // $195e  
L1960:
    lda D2128,x                                 // $1960  
    ora D2138,x                                 // $1963  
    and #$c0                                    // $1966  
    sta $fb                                     // $1968  
    lda D2000,x                                 // $196a  
    and #$3f                                    // $196d  
    ora $fb                                     // $196f  
    sta D2400,x                                 // $1971  
    lda D2148,x                                 // $1974  
    ora D2118,x                                 // $1977  
    and #$03                                    // $197a  
    sta $fb                                     // $197c  
    lda D2000,x                                 // $197e  
    and #$fc                                    // $1981  
    ora $fb                                     // $1983  
    sta D2410,x                                 // $1985  
    inx                                         // $1988  
    cpx #$06                                    // $1989  
    bne L1960                                   // $198b  
    rts                                         // $198d  
L198e:
    ldx #$07                                    // $198e  
L1990:
    lda D2150,x                                 // $1990  
    ora D2130,x                                 // $1993  
    sta D23e8,x                                 // $1996  
    lda D2120,x                                 // $1999  
    ora D2140,x                                 // $199c  
    sta D23f8,x                                 // $199f  
    lda D2130,x                                 // $19a2  
    ora D2140,x                                 // $19a5  
    sta D2408,x                                 // $19a8  
    lda D2150,x                                 // $19ab  
    ora D2120,x                                 // $19ae  
    sta D2418,x                                 // $19b1  
    dex                                         // $19b4  
    bpl L1990                                   // $19b5  
    rts                                         // $19b7  
L19b8:
    lda $cf1b                                   // $19b8  
    bne L19f2                                   // $19bb  
    lda $cf07                                   // $19bd  
    cmp $cf2b                                   // $19c0  
    bne L19cd                                   // $19c3  
    lda $cf08                                   // $19c5  
    cmp $cf2c                                   // $19c8  
    beq L19e6                                   // $19cb  
L19cd:
    lda #$01                                    // $19cd  
    sta $cf15                                   // $19cf  
    lda #$10                                    // $19d2  
    sta SID_V2_CTRL                             // $19d4  
    lda #$e0                                    // $19d7  
    sta SID_V2_SR                               // $19d9  
    lda #$00                                    // $19dc  
    sta SID_V2_AD                               // $19de  
    lda #$11                                    // $19e1  
    sta SID_V2_CTRL                             // $19e3  
L19e6:
    lda $cf07                                   // $19e6  
    sta $cf2b                                   // $19e9  
    lda $cf08                                   // $19ec  
    sta $cf2c                                   // $19ef  
L19f2:
    lda $cf35                                   // $19f2  
    cmp $cf23                                   // $19f5  
    bne L1a1f                                   // $19f8  
    lda $cf36                                   // $19fa  
    cmp $cf24                                   // $19fd  
    bne L1a1f                                   // $1a00  
    lda $cf15                                   // $1a02  
    beq L1a1f                                   // $1a05  
    cmp #$80                                    // $1a07  
    bne L1a12                                   // $1a09  
    lda #$81                                    // $1a0b  
    sta $cf15                                   // $1a0d  
    bne L1a1f                                   // $1a10  
L1a12:
    cmp #$80                                    // $1a12  
    bcs L1a1f                                   // $1a14  
    lda #$8a                                    // $1a16  
    sec                                         // $1a18  
    sbc $cf15                                   // $1a19  
    sta $cf15                                   // $1a1c  
L1a1f:
    lda $cf15                                   // $1a1f  
    beq L1a3c                                   // $1a22  
    cmp #$80                                    // $1a24  
    bne L1a3f                                   // $1a26  
    lda $cf16                                   // $1a28  
    eor #$01                                    // $1a2b  
    sta $cf16                                   // $1a2d  
    ldx #$0f                                    // $1a30  
    and #$01                                    // $1a32  
    beq L1a38                                   // $1a34  
    ldx #$10                                    // $1a36  
L1a38:
    txa                                         // $1a38  
    jsr L1a6c                                   // $1a39  
L1a3c:
    clc                                         // $1a3c  
    bcc L1a6b                                   // $1a3d  
L1a3f:
    tax                                         // $1a3f  
    bmi L1a52                                   // $1a40  
    clc                                         // $1a42  
    adc #$07                                    // $1a43  
    jsr L1a6c                                   // $1a45  
    inx                                         // $1a48  
    cpx #$0a                                    // $1a49  
    bcc L1a4f                                   // $1a4b  
    ldx #$80                                    // $1a4d  
L1a4f:
    clc                                         // $1a4f  
    bcc L1a68                                   // $1a50  
L1a52:
    lda #$90                                    // $1a52  
    sec                                         // $1a54  
    sbc $cf15                                   // $1a55  
    jsr L1a6c                                   // $1a58  
    inx                                         // $1a5b  
    cpx #$90                                    // $1a5c  
    bcc L1a68                                   // $1a5e  
    ldx #$00                                    // $1a60  
    stx SID_V2_FREQ_HI                          // $1a62  
    stx SID_V2_FREQ_LO                          // $1a65  
L1a68:
    stx $cf15                                   // $1a68  
L1a6b:
    rts                                         // $1a6b  
L1a6c:
    clc                                         // $1a6c  
    adc $cfaf                                   // $1a6d  
    clc                                         // $1a70  
    adc #$01                                    // $1a71  
    ldy $cfa1                                   // $1a73  
    beq L1a7b                                   // $1a76  
    clc                                         // $1a78  
    adc #$02                                    // $1a79  
L1a7b:
    sta SID_V2_FREQ_HI                          // $1a7b  
    ldy #$00                                    // $1a7e  
    sty SID_V2_FREQ_LO                          // $1a80  
    rts                                         // $1a83  
L1a84:
    dec $ceff                                   // $1a84  
    bne L1ab5                                   // $1a87  
    ldx #$1e                                    // $1a89  
    stx $ceff                                   // $1a8b  
    lda #<D0400                                 // $1a8e  
    sta $fb                                     // $1a90  
    sta $fd                                     // $1a92  
    lda #>D0400                                 // $1a94  
    sta $fc                                     // $1a96  
    lda $cefe                                   // $1a98  
    asl                                         // $1a9b  
    asl                                         // $1a9c  
    clc                                         // $1a9d  
    adc #$a0                                    // $1a9e  
    sta $fe                                     // $1aa0  
    ldy #$00                                    // $1aa2  
L1aa4:
    lda ($fb),y                                 // $1aa4  
    sta ($fd),y                                 // $1aa6  
    iny                                         // $1aa8  
    bne L1aa4                                   // $1aa9  
    inc $fe                                     // $1aab  
    inc $fc                                     // $1aad  
    lda $fc                                     // $1aaf  
    cmp #$08                                    // $1ab1  
    bne L1aa4                                   // $1ab3  
L1ab5:
    rts                                         // $1ab5  
L1ab6:
    lda #$ff                                    // $1ab6  
    sta CIA1_DDRA                               // $1ab8  
    lda #$00                                    // $1abb  
    sta $ff                                     // $1abd  
    sec                                         // $1abf  
    lda #$7f                                    // $1ac0  
    sta CIA1_PRA                                // $1ac2  
    lda CIA1_PRB                                // $1ac5  
    and #$10                                    // $1ac8  
    bne L1acd                                   // $1aca  
    clc                                         // $1acc  
L1acd:
    rol $ff                                     // $1acd  
    sec                                         // $1acf  
    lda #$fe                                    // $1ad0  
    sta CIA1_PRA                                // $1ad2  
    lda CIA1_PRB                                // $1ad5  
    and #$02                                    // $1ad8  
    beq L1ae8                                   // $1ada  
    lda #$fd                                    // $1adc  
    sta CIA1_PRA                                // $1ade  
    lda CIA1_PRB                                // $1ae1  
    and #$04                                    // $1ae4  
    bne L1ae9                                   // $1ae6  
L1ae8:
    clc                                         // $1ae8  
L1ae9:
    rol $ff                                     // $1ae9  
    sec                                         // $1aeb  
    lda #$bf                                    // $1aec  
    sta CIA1_PRA                                // $1aee  
    lda CIA1_PRB                                // $1af1  
    and #$04                                    // $1af4  
    beq L1b04                                   // $1af6  
    lda #$7f                                    // $1af8  
    sta CIA1_PRA                                // $1afa  
    lda CIA1_PRB                                // $1afd  
    and #$80                                    // $1b00  
    bne L1b05                                   // $1b02  
L1b04:
    clc                                         // $1b04  
L1b05:
    rol $ff                                     // $1b05  
    sec                                         // $1b07  
    lda #$bf                                    // $1b08  
    sta CIA1_PRA                                // $1b0a  
    lda CIA1_PRB                                // $1b0d  
    and #$10                                    // $1b10  
    beq L1b20                                   // $1b12  
    lda #$fd                                    // $1b14  
    sta CIA1_PRA                                // $1b16  
    lda CIA1_PRB                                // $1b19  
    and #$80                                    // $1b1c  
    bne L1b21                                   // $1b1e  
L1b20:
    clc                                         // $1b20  
L1b21:
    rol $ff                                     // $1b21  
    sec                                         // $1b23  
    lda #$bf                                    // $1b24  
    sta CIA1_PRA                                // $1b26  
    lda CIA1_PRB                                // $1b29  
    tax                                         // $1b2c  
    and #$02                                    // $1b2d  
    beq L1b46                                   // $1b2f  
    txa                                         // $1b31  
    and #$14                                    // $1b32  
    eor #$14                                    // $1b34  
    bne L1b47                                   // $1b36  
    lda #$7f                                    // $1b38  
    sta CIA1_PRA                                // $1b3a  
    lda CIA1_PRB                                // $1b3d  
    and #$44                                    // $1b40  
    eor #$44                                    // $1b42  
    beq L1b47                                   // $1b44  
L1b46:
    clc                                         // $1b46  
L1b47:
    rol $ff                                     // $1b47  
    ldx $ff                                     // $1b49  
    txa                                         // $1b4b  
    and #$03                                    // $1b4c  
    bne L1b54                                   // $1b4e  
    txa                                         // $1b50  
    ora #$03                                    // $1b51  
    tax                                         // $1b53  
L1b54:
    txa                                         // $1b54  
    and #$0c                                    // $1b55  
    bne L1b5d                                   // $1b57  
    txa                                         // $1b59  
    ora #$0c                                    // $1b5a  
    tax                                         // $1b5c  
L1b5d:
    stx $ff                                     // $1b5d  
    ldx #$ff                                    // $1b5f  
    lda #$00                                    // $1b61  
    sta CIA1_DDRA                               // $1b63  
    lda CIA1_PRA                                // $1b66  
    stx CIA1_DDRA                               // $1b69  
    and $ff                                     // $1b6c  
    rts                                         // $1b6e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b6f  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b7f  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b8f  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1b9f  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1baf  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bbf  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bcf  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bdf  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1bef  
    .byte $ff                                   // $1bff  
D1c00:
    .byte $1d,$1e,$1f,$19,$1f,$0f,$1f,$17,$1f,$1d,$1f,$1e,$1f,$1d,$1f,$1b  // $1c00  
    .byte $1f,$17,$1f,$1b,$1f,$1a,$1f,$0f,$1f,$0f,$1f,$17,$1f,$1b,$1f,$17  // $1c10  
    .byte $1f,$1b,$1f,$17,$1f,$19,$1f,$0f,$1f,$17,$1f,$0f,$1f,$1f,$1f,$1f  // $1c20  
    .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f  // $1c30  
    .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f  // $1c40  
    .byte $19,$1d,$1f,$0f,$1f,$17,$1f,$1b,$1f,$17,$1f,$1d,$1f,$1e,$35,$00  // $1c50  
    .byte $68,$77,$02,$53,$43,$4c,$43,$00,$73,$77,$0c,$53,$41,$44,$43,$20  // $1c60  
    .byte $23,$31,$00,$7f,$77,$16,$53,$53,$54,$41,$20,$53,$2b,$31,$00,$8a  // $1c70  
D1c80:
    .byte $1e,$6f,$0d,$10,$2a,$10,$31,$0a,$15,$0a,$08,$0a,$09,$0a,$09,$0a  // $1c80  
    .byte $1c,$0a,$09,$0a,$12,$0a,$05,$0a,$10,$0a,$16,$0a,$1a,$0a,$09,$0a  // $1c90  
    .byte $1c,$0a,$09,$0a,$10,$0a,$14,$0a,$12,$0a,$12,$0a,$00,$00,$00,$00  // $1ca0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$04,$08,$09,$01,$0a,$01,$12,$01  // $1cb0  
    .byte $01,$07,$01,$01,$11,$07,$00,$08,$32,$0b,$25,$04,$1b,$09,$2d,$02  // $1cc0  
    .byte $1a,$01,$1f,$39,$17,$09,$14,$0e,$15,$09,$1e,$0b,$05,$00,$53,$42  // $1cd0  
    .byte $4e,$45,$20,$2a,$2b,$32,$2b,$24,$32,$43,$00,$f7,$77,$66,$53,$4c  // $1ce0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1cf0  
D1d00:
    .byte $ee,$bb,$ee,$bb,$ee,$bb,$ee,$55,$ee,$bb,$ee,$bb,$ee,$bb,$55,$55  // $1d00  
    .byte $ee,$bb,$ee,$bb,$ee,$55,$55,$55,$ee,$bb,$ee,$bb,$55,$55,$55,$55  // $1d10  
    .byte $ee,$bb,$ee,$55,$55,$55,$55,$55,$ee,$bb,$55,$55,$55,$55,$55,$55  // $1d20  
    .byte $ee,$55,$55,$55,$55,$55,$55,$55,$55,$bb,$ee,$bb,$ee,$bb,$ee,$bb  // $1d30  
    .byte $55,$55,$ee,$bb,$ee,$bb,$ee,$bb,$55,$55,$55,$bb,$ee,$bb,$ee,$bb  // $1d40  
    .byte $55,$55,$55,$55,$ee,$bb,$ee,$bb,$55,$55,$55,$55,$55,$bb,$ee,$bb  // $1d50  
    .byte $55,$55,$55,$55,$55,$55,$ee,$bb,$55,$55,$55,$55,$55,$55,$55,$bb  // $1d60  
    .byte $6e,$7b,$6e,$7b,$6e,$7b,$6e,$7b,$5e,$5b,$5e,$5b,$5e,$5b,$5e,$5b  // $1d70  
    .byte $56,$57,$56,$57,$56,$57,$56,$57,$ed,$b9,$ed,$b9,$ed,$b9,$ed,$b9  // $1d80  
    .byte $e5,$b5,$e5,$b5,$e5,$b5,$e5,$b5,$d5,$95,$d5,$95,$d5,$95,$d5,$95  // $1d90  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1da0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1db0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1dc0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1dd0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1de0  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1df0  
D1e00:
    .byte $c0,$80,$e0,$b0,$ec,$b8,$ee,$bb,$c0,$90,$e0,$b4,$ec,$b9,$ee,$bb  // $1e00  
    .byte $d0,$90,$e4,$b4,$ed,$b9,$ee,$bb,$d0,$94,$e4,$b5,$ed,$b9,$ee,$bb  // $1e10  
    .byte $d4,$94,$e5,$b5,$ed,$b9,$ee,$bb,$d4,$95,$e5,$b5,$ed,$b9,$ee,$bb  // $1e20  
    .byte $d5,$95,$e5,$b5,$ed,$b9,$ee,$bb,$d5,$95,$e5,$b5,$ed,$b9,$ee,$bb  // $1e30  
    .byte $d5,$95,$e5,$b5,$ed,$b9,$ee,$bb       // $1e40  
D1e48:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40  // $1e48  
    .byte $00,$00,$00,$00,$00,$00,$40,$40,$00,$00,$00,$00,$00,$40,$40,$50  // $1e58  
    .byte $00,$00,$00,$00,$40,$40,$50,$50,$00,$00,$00,$40,$40,$50,$50,$54  // $1e68  
    .byte $00,$00,$40,$40,$50,$50,$54,$54,$00,$40,$40,$50,$50,$54,$54,$55  // $1e78  
    .byte $40,$40,$50,$50,$54,$54,$55,$55       // $1e88  
D1e90:
    .byte $02,$03,$0e,$0b,$2e,$3b,$ee,$bb,$02,$07,$0e,$1b,$2e,$7b,$ee,$bb  // $1e90  
    .byte $06,$07,$1e,$1b,$6e,$7b,$ee,$bb,$06,$17,$1e,$5b,$6e,$7b,$ee,$bb  // $1ea0  
    .byte $16,$17,$5e,$5b,$6e,$7b,$ee,$bb,$16,$57,$5e,$5b,$6e,$7b,$ee,$bb  // $1eb0  
    .byte $56,$57,$5e,$5b,$6e,$7b,$ee,$bb,$56,$57,$5e,$5b,$6e,$7b,$ee,$bb  // $1ec0  
    .byte $56,$57,$5e,$5b,$6e,$7b,$ee,$bb       // $1ed0  
D1ed8:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01  // $1ed8  
    .byte $00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$01,$01,$05  // $1ee8  
    .byte $00,$00,$00,$00,$01,$01,$05,$05,$00,$00,$00,$01,$01,$05,$05,$15  // $1ef8  
    .byte $00,$00,$01,$01,$05,$05,$15,$15,$00,$01,$01,$05,$05,$15,$15,$55  // $1f08  
    .byte $01,$01,$05,$05,$15,$15,$55,$55       // $1f18  
D1f20:
    .byte $ee,$bb,$ec,$b8,$e0,$b0,$c0,$80,$ee,$bb,$ed,$b8,$e4,$b0,$d0,$80  // $1f20  
    .byte $ee,$bb,$ed,$b9,$e4,$b4,$d0,$90,$ee,$bb,$ed,$b9,$e5,$b4,$d4,$90  // $1f30  
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d4,$94,$ee,$bb,$ed,$b9,$e5,$b5,$d5,$94  // $1f40  
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d5,$95,$ee,$bb,$ed,$b9,$e5,$b5,$d5,$95  // $1f50  
    .byte $ee,$bb,$ed,$b9,$e5,$b5,$d5,$95       // $1f60  
D1f68:
    .byte $ee,$bb,$2e,$3b,$0e,$0b,$02,$03,$ee,$bb,$6e,$3b,$1e,$0b,$06,$03  // $1f68  
    .byte $ee,$bb,$6e,$7b,$1e,$1b,$06,$07,$ee,$bb,$6e,$7b,$5e,$1b,$16,$07  // $1f78  
    .byte $ee,$bb,$6e,$7b,$5e,$5b,$16,$17,$ee,$bb,$6e,$7b,$5e,$5b,$56,$17  // $1f88  
    .byte $ee,$bb,$6e,$7b,$5e,$5b,$56,$57,$ee,$bb,$6e,$7b,$5e,$5b,$56,$57  // $1f98  
    .byte $ee,$bb,$6e,$7b,$5e,$5b,$56,$57,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fa8  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fb8  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fc8  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fd8  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $1fe8  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff           // $1ff8  
D1fff:
    .byte $ff                                   // $1fff  
D2000:
    .byte $ca,$cb,$cc,$cd,$ce,$e6,$e7,$e8       // $2000  
D2008:
    .byte $e9,$ea,$eb,$b4,$cf,$d0,$d1,$d2       // $2008  
D2010:
    .byte $d3,$20,$20,$20,$20,$20,$20,$b4       // $2010  
D2018:
    .byte $d4,$d5,$d6,$d7,$d8,$ee,$ef,$b4       // $2018  
D2020:
    .byte $d9                                   // $2020  
D2021:
    .byte $da,$f0,$f1,$f2,$f3,$f4,$f5           // $2021  
D2028:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2028  
D2030:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2030  
D2038:
    .byte $20,$20,$20,$20,$20,$20,$20           // $2038  
D203f:
    .byte $20                                   // $203f  
D2040:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2040  
D2048:
    .byte $20,$20,$20,$20,$20,$20,$20           // $2048  
D204f:
    .byte $20                                   // $204f  
D2050:
    .byte $b0,$a1,$a2,$a2,$a2,$a2,$a2,$a2       // $2050  
D2058:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2           // $2058  
D205f:
    .byte $a2                                   // $205f  
D2060:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2       // $2060  
D2068:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2       // $2068  
D2070:
    .byte $a2,$a2,$a2,$a2,$a2,$a3,$a4,$a0       // $2070  
D2078:
    .byte $af,$78,$a0,$a0,$a0,$a0,$a0,$a0       // $2078  
D2080:
    .byte $a0                                   // $2080  
D2081:
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0           // $2081  
D2088:
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0       // $2088  
D2090:
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0       // $2090  
D2098:
    .byte $a0,$a0,$a0,$a0,$a0,$79,$a5,$a0       // $2098  
D20a0:
    .byte $ae,$a0,$6c,$8d,$8c,$8c,$8d,$8c       // $20a0  
D20a8:
    .byte $8c,$8d,$8c,$8c,$8d,$8c,$8c,$8d       // $20a8  
D20b0:
    .byte $8c,$8c,$8d,$8d,$8e,$8e,$8e,$8e       // $20b0  
D20b8:
    .byte $8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e       // $20b8  
D20c0:
    .byte $8e,$8e,$8e,$8e,$6c,$a0,$a6,$a0       // $20c0  
D20c8:
    .byte $ae,$a0,$96,$00,$11,$12,$00,$11       // $20c8  
D20d0:
    .byte $12,$00,$11,$12,$00,$11,$12,$00       // $20d0  
D20d8:
    .byte $11,$12,$00,$00,$11,$0a,$0a,$0a       // $20d8  
D20e0:
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a       // $20e0  
D20e8:
    .byte $0a,$0a,$0a,$12,$8f,$a0,$a6,$a0       // $20e8  
D20f0:
    .byte $ae,$a0,$96,$00,$14,$13,$00,$14       // $20f0  
D20f8:
    .byte $13,$00,$14,$13,$00,$14,$13,$00       // $20f8  
D2100:
    .byte $14,$13,$00,$00,$06,$20,$20,$20       // $2100  
D2108:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$0e,$8f,$a0,$a6,$a0  // $2108  
D2118:
    .byte $ae,$a0,$96,$00,$00,$00,$00,$00       // $2118  
D2120:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $2120  
D2128:
    .byte $00,$00,$00,$00,$06,$20,$10,$01       // $2128  
D2130:
    .byte $02,$02,$02,$02,$02,$02,$02,$02       // $2130  
D2138:
    .byte $03,$04,$20,$0e,$8f,$a0,$a6,$a0       // $2138  
D2140:
    .byte $ae,$74,$97,$11,$0a,$0a,$0a,$0a       // $2140  
D2148:
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a       // $2148  
D2150:
    .byte $0a,$0a,$12,$00,$06,$20,$0f,$00       // $2150  
D2158:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $2158  
D2160:
    .byte $00,$05,$20,$0e,$8f,$77,$a6,$a0       // $2160  
D2168:
    .byte $ae,$74,$97,$06,$20,$20,$20,$20       // $2168  
D2170:
    .byte $20,$20,$20,$20,$20,$20,$20,$b3       // $2170  
D2178:
    .byte $b3,$b3,$0e,$00,$06,$20,$0e,$00       // $2178  
D2180:
    .byte $11,$12,$00,$11,$12,$00,$11,$12       // $2180  
D2188:
    .byte $00,$06,$20,$0e,$8f,$77,$a6,$a0       // $2188  
D2190:
    .byte $ae,$74,$97,$06,$20,$10,$01,$02       // $2190  
D2198:
    .byte $02,$02,$02,$02,$02,$02,$02,$02       // $2198  
D21a0:
    .byte $02,$02,$13,$00,$06,$20,$0e,$00       // $21a0  
D21a8:
    .byte $14,$13,$00,$14,$13,$00,$14,$13       // $21a8  
D21b0:
    .byte $00,$06,$20,$0e,$8f,$77,$a6,$a0       // $21b0  
D21b8:
    .byte $ae,$74,$97,$06,$20,$0f,$00,$00       // $21b8  
D21c0:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $21c0  
D21c8:
    .byte $00,$00,$00,$00,$06,$20,$0e,$00       // $21c8  
D21d0:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $21d0  
D21d8:
    .byte $00,$07,$20,$0e,$8f,$77,$a6,$a0       // $21d8  
D21e0:
    .byte $ae,$73,$97,$06,$20,$0e,$00,$11       // $21e0  
D21e8:
    .byte $12,$00,$11,$12,$00,$11,$12,$00       // $21e8  
D21f0:
    .byte $11,$12,$00,$00,$06,$20,$0e,$00       // $21f0  
D21f8:
    .byte $11,$0a,$0a,$0a,$0a,$0a,$0a,$0a       // $21f8  
D2200:
    .byte $09,$08,$20,$0e,$8f,$76,$a6,$a0       // $2200  
D2208:
    .byte $ae,$73,$95,$06,$20,$0e,$00,$14       // $2208  
D2210:
    .byte $13,$00,$14,$13,$00,$14,$13,$00       // $2210  
D2218:
    .byte $14,$13,$00,$00,$06,$20,$0e,$00       // $2218  
D2220:
    .byte $06,$20,$20,$20,$20,$20,$20,$20       // $2220  
D2228:
    .byte $20,$20,$20,$0e,$91,$76,$a6,$a0       // $2228  
D2230:
    .byte $ae,$73,$95,$06,$20,$0d,$00,$00       // $2230  
D2238:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $2238  
D2240:
    .byte $00,$00,$00,$00,$07,$20,$0e,$00       // $2240  
D2248:
    .byte $06,$20,$10,$01,$02,$02,$02,$02       // $2248  
D2250:
    .byte $02,$02,$02,$13,$91,$76,$a6,$a0       // $2250  
D2258:
    .byte $ae,$73,$95,$06,$20,$0c,$0b,$0a       // $2258  
D2260:
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a       // $2260  
D2268:
    .byte $0a,$0a,$0a,$09,$08,$20,$0e,$00       // $2268  
D2270:
    .byte $06,$20,$0f,$00,$00,$00,$00,$00       // $2270  
D2278:
    .byte $00,$00,$00,$00,$90,$76,$a6,$a0       // $2278  
D2280:
    .byte $ae,$72,$95,$06,$20,$20,$20,$20       // $2280  
D2288:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2288  
D2290:
    .byte $20,$20,$20,$20,$20,$20,$0e,$00       // $2290  
D2298:
    .byte $06,$20,$0e,$00,$11,$12,$00,$11       // $2298  
D22a0:
    .byte $12,$00,$11,$12,$91,$75,$a6,$a0       // $22a0  
D22a8:
    .byte $ae,$72,$95,$14,$02,$02,$02,$02       // $22a8  
D22b0:
    .byte $02,$02,$02,$02,$02,$02,$02,$02       // $22b0  
D22b8:
    .byte $02,$02,$02,$02,$02,$02,$13,$00       // $22b8  
D22c0:
    .byte $06,$20,$0e,$00,$14,$13,$00,$14       // $22c0  
D22c8:
    .byte $13,$00,$14,$13,$91,$75,$a6,$a0       // $22c8  
D22d0:
    .byte $ae,$72,$96,$00,$00,$00,$00,$00       // $22d0  
D22d8:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $22d8  
D22e0:
    .byte $00,$00,$00,$00,$00,$00,$00,$00       // $22e0  
D22e8:
    .byte $07,$20,$0e,$00,$00,$00,$00,$00       // $22e8  
D22f0:
    .byte $00,$00,$00,$00,$90,$75,$a6,$a0       // $22f0  
D22f8:
    .byte $ae,$72,$95,$11,$0a,$0a,$0a,$0a       // $22f8  
D2300:
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a       // $2300  
D2308:
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$09       // $2308  
D2310:
    .byte $08,$20,$0e,$00,$11,$12,$00,$11       // $2310  
D2318:
    .byte $12,$00,$11,$12,$91,$75,$a6,$a0       // $2318  
D2320:
    .byte $ae,$00,$95,$06,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $2320  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$0e,$00,$14,$13,$00,$14  // $2330  
    .byte $13,$00,$14,$13,$91,$00,$a6,$a0,$ae,$00,$95,$14,$02,$02,$02,$02  // $2340  
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02  // $2350  
    .byte $02,$02,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90,$00,$a6,$a0  // $2360  
    .byte $ae,$00,$00,$94,$94,$94,$94,$94,$94,$94,$94,$94,$94,$94,$94,$94  // $2370  
    .byte $94,$94,$94,$92,$92,$92,$92,$92,$92,$92,$92,$93,$93,$93,$93,$93  // $2380  
    .byte $93,$93,$93,$93,$00,$00,$a6,$a0,$ad,$7b,$00,$00,$00,$00,$00,$00  // $2390  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $23a0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7a,$a7,$a0  // $23b0  
D23c0:
    .byte $ac,$ab,$aa,$aa,$aa,$aa,$aa,$aa       // $23c0  
D23c8:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $23c8  
D23d0:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $23d0  
D23d8:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $23d8  
D23e0:
    .byte $aa,$aa,$aa,$aa,$aa,$a9,$a8,$a0       // $23e0  
D23e8:
    .byte $00,$ff,$00,$ff,$ff,$00,$ef,$ff       // $23e8  
D23f0:
    .byte $00,$00,$00,$00,$ff,$00,$00,$ff       // $23f0  
D23f8:
    .byte $c7,$dd,$dc,$a7,$a7,$d5,$de,$b8       // $23f8  
D2400:
    .byte $ca,$cb,$cc,$cd,$ce,$e6,$e7,$e8       // $2400  
D2408:
    .byte $e9,$ea,$eb,$b4,$cf,$d0,$d1,$d2       // $2408  
D2410:
    .byte $d3,$20,$20,$20,$20,$20,$20,$b4       // $2410  
D2418:
    .byte $d4,$d5,$d6,$d7,$d8,$ee,$ef,$b4       // $2418  
D2420:
    .byte $d9,$da,$f0,$f1,$f2,$f3,$f4,$f5       // $2420  
D2428:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2428  
D2430:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2430  
D2438:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2438  
D2440:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2440  
D2448:
    .byte $20,$20,$20,$20,$20,$20,$20,$20       // $2448  
D2450:
    .byte $b0,$a1,$a2,$a2,$a2,$a2,$a2,$a2       // $2450  
D2458:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2       // $2458  
D2460:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2           // $2460  
D2467:
    .byte $a2                                   // $2467  
D2468:
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2       // $2468  
D2470:
    .byte $a2,$a2,$a2,$a2,$a2,$a3,$a4           // $2470  
D2477:
    .byte $a0                                   // $2477  
D2478:
    .byte $af,$78,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0  // $2478  
D2488:
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0       // $2488  
D2490:
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0       // $2490  
D2498:
    .byte $a0,$a0,$a0,$a0,$a0,$79,$a5,$a0       // $2498  
D24a0:
    .byte $ae,$a0,$6c,$8d,$8c,$8c,$8d,$8c       // $24a0  
D24a8:
    .byte $8c,$8d,$8c,$8c,$8d,$8c,$8c,$8d,$8c,$8c,$8d,$8d,$8e,$8e,$8e,$8e  // $24a8  
D24b8:
    .byte $8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e       // $24b8  
D24c0:
    .byte $8e,$8e,$8e,$8e,$6c,$a0,$a6,$a0       // $24c0  
D24c8:
    .byte $ae,$a0,$96,$00,$11,$12,$00,$11       // $24c8  
D24d0:
    .byte $12,$00,$11,$12,$00,$11,$12,$00,$11,$12,$00,$00,$11,$0a,$0a,$0a  // $24d0  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$12,$8f,$a0,$a6,$a0  // $24e0  
    .byte $ae,$a0,$96,$00,$14,$13,$00,$14,$13,$00,$14,$13,$00,$14,$13,$00  // $24f0  
D2500:
    .byte $14,$13,$00,$00,$06,$20,$20,$20       // $2500  
D2508:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$0e,$8f,$a0,$a6,$a0  // $2508  
    .byte $ae,$a0,$96,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2518  
    .byte $00,$00,$00,$00,$06,$20,$10,$01,$02,$02,$02,$02,$02,$02,$02,$02  // $2528  
    .byte $03,$04,$20,$0e,$8f,$a0,$a6,$a0,$ae,$74,$97,$11,$0a,$0a,$0a,$0a  // $2538  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$19,$84,$00,$00,$00,$00,$06,$20,$0f,$00  // $2548  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$20,$0e,$8f,$77,$a6,$a0  // $2558  
    .byte $ae,$74,$97,$1e,$b1,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$26  // $2568  
    .byte $25,$00,$00,$00,$06,$20,$0e,$00,$11,$0a,$12,$00,$00,$11,$12,$00  // $2578  
D2588:
    .byte $00,$06,$20,$0e,$8f,$77,$a6,$a0       // $2588  
D2590:
    .byte $ae,$74,$96,$89,$24,$20,$b1,$4a       // $2590  
D2598:
    .byte $01,$02,$02,$02,$02,$2b,$2c,$20       // $2598  
D25a0:
    .byte $26,$25,$00,$00,$06,$20,$0e,$00       // $25a0  
D25a8:
    .byte $06,$b3,$0e,$00,$00,$14,$13,$00,$00,$06,$20,$0e,$8f,$77,$a6,$a0  // $25a8  
    .byte $ae,$74,$96,$00,$23,$24,$20,$4c,$25,$00,$00,$00,$00,$7c,$23,$24  // $25b8  
    .byte $20,$26,$25,$00,$06,$20,$0e,$00,$06,$b3,$0e,$00,$00,$00,$00,$00  // $25c8  
    .byte $00,$06,$20,$0e,$8f,$77,$a6,$a0,$ae,$73,$96,$00,$00,$23,$24,$20  // $25d8  
    .byte $26,$25,$00,$00,$29,$7d,$25,$23       // $25e8  
D25f0:
    .byte $24,$20,$26,$25,$07,$20,$0e,$00,$06,$b3,$0e,$00,$00,$11,$12,$00  // $25f0  
    .byte $00,$06,$20,$0e,$8f,$76,$a6,$a0,$ae,$73,$96,$00,$00,$00,$23,$24  // $2600  
    .byte $20,$26,$25,$82,$83,$20,$81,$80,$23,$24,$20,$3c,$3d,$20,$0e,$00  // $2610  
D2620:
    .byte $06,$20,$0e,$00,$00,$14,$13,$00,$00,$06,$20,$0e,$91,$76,$a6,$a0  // $2620  
    .byte $ae,$73,$96,$00,$00,$00,$00,$23,$24,$20,$26,$25,$23,$7f,$27,$5b  // $2630  
    .byte $5c,$23,$24,$20,$b1,$20,$0e,$00,$06,$20,$0d,$00,$00,$00,$00,$00  // $2640  
D2650:
    .byte $00,$07,$20,$0e,$91,$76,$a6,$a0,$ae,$73,$95,$11,$19,$84,$00,$00  // $2650  
    .byte $23,$24,$20,$26,$25,$7e,$61,$2a,$26,$5d,$23,$24,$20,$20,$0e,$00  // $2660  
    .byte $06,$20,$0c,$0b,$0a,$0a,$0a,$0a,$09,$08,$20,$0e,$91,$76,$a6,$a0  // $2670  
    .byte $ae,$72,$95,$06,$20,$26,$25,$00,$00,$23,$24,$20,$26,$25,$62,$24  // $2680  
    .byte $28,$5e,$00,$23,$24,$b1,$0e,$00,$06,$20,$20,$20,$20,$20,$20,$20  // $2690  
    .byte $20,$20,$20,$0e,$91,$75,$a6,$a0,$ae,$72,$95,$06,$20,$20,$26,$25  // $26a0  
    .byte $00,$00,$23,$24,$20,$26,$25,$5f,$60,$00,$00,$00,$88,$1d,$13,$00  // $26b0  
    .byte $14,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$13,$91,$75,$a6,$a0  // $26c0  
    .byte $ae,$72,$95,$06,$20,$20,$20,$26,$25,$00,$00,$23,$24,$20,$26,$25  // $26d0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $26e0  
    .byte $00,$00,$00,$00,$90,$75,$a6,$a0,$ae,$72,$95,$06,$20,$20,$20,$20  // $26f0  
    .byte $26,$85,$00,$00,$23,$24,$20,$33,$34,$0a,$0a,$0a,$0a,$0a,$0a,$0a  // $2700  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$12,$91,$75,$a6,$a0  // $2710  
    .byte $ae,$00,$95,$06,$20,$20,$20,$20,$20,$1a,$00,$00,$00,$23,$24,$20  // $2720  
D2730:
    .byte $20                                   // $2730  
D2731:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $2731  
    .byte $20,$20,$0e,$91,$00,$a6,$a0,$ae,$00,$95,$14,$02,$02,$02,$02,$02  // $2741  
    .byte $13,$00,$00,$00,$00,$88,$1d,$02,$02,$02,$02,$02,$02,$02,$02  // $2751  
D2760:
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$13,$91,$00,$a6,$a0  // $2760  
D2770:
    .byte $ae                                   // $2770  
D2771:
    .byte $00,$00,$94,$94,$94,$94,$94           // $2771  
D2778:
    .byte $94,$94,$93,$93,$93,$93,$93,$94       // $2778  
D2780:
    .byte $94                                   // $2780  
D2781:
    .byte $94,$94,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92  // $2781  
    .byte $92,$92,$92,$00,$00,$a6,$a0,$ad,$7b,$00,$00,$00,$00,$00,$00,$00  // $2791  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $27a1  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7a,$a7,$a0  // $27b1  
D27c0:
    .byte $ac,$ab,$aa,$aa,$aa,$aa,$aa,$aa       // $27c0  
D27c8:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $27c8  
D27d0:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $27d0  
D27d8:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa       // $27d8  
D27e0:
    .byte $aa,$aa,$aa,$aa,$aa,$a9,$a8           // $27e0  
D27e7:
    .byte $a0,$00,$ff,$00,$ff,$ff,$00,$ef,$ff,$00,$00,$00,$00,$ff,$00,$00  // $27e7  
    .byte $ff,$c7,$a0,$dc,$a7,$a7,$db,$de,$b8   // $27f7  
D2800:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2800  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$00,$3e,$00,$00,$3e  // $2810  
    .byte $00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2820  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$94  // $2830  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2840  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04  // $2850  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2860  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2870  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2880  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c  // $2890  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $28a0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$98  // $28b0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $28c0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$0c  // $28d0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $28e0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $28f0  
D2900:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2900  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$00,$1c  // $2910  
    .byte $00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2920  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$84  // $2930  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2940  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$3c,$00,$00,$3c  // $2950  
    .byte $00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2960  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$94  // $2970  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2980  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$00,$3e,$00,$00,$3e  // $2990  
    .byte $00,$00,$3e,$00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $29a0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $29b0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $29c0  
    .byte $00,$00,$00,$00,$00,$00,$3c,$00,$00,$7e,$00,$00,$7e,$00,$00,$7e  // $29d0  
    .byte $00,$00,$7e,$00,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $29e0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$98  // $29f0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2a00  
    .byte $00,$00,$00,$00,$00,$00,$1c,$00,$00,$3e,$00,$00,$7f,$00,$00,$7f  // $2a10  
    .byte $00,$00,$7f,$00,$00,$3e,$00,$00,$1c,$00,$00,$00,$00,$00,$00,$00  // $2a20  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2a30  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2a40  
    .byte $00,$00,$00,$3c,$00,$00,$7e,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff  // $2a50  
    .byte $00,$00,$ff,$00,$00,$7e,$00,$00,$3c,$00,$00,$00,$00,$00,$00,$00  // $2a60  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$84  // $2a70  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2a80  
    .byte $00,$00,$00,$1c,$00,$00,$7f,$00,$00,$7f,$00,$00,$ff,$80,$00,$ff  // $2a90  
    .byte $80,$00,$ff,$80,$00,$7f,$00,$00,$7f,$00,$00,$1c,$00,$00,$00,$00  // $2aa0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2ab0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2ac0  
    .byte $3c,$00,$00,$ff,$00,$00,$ff,$00,$01,$ff,$80,$01,$ff,$80,$01,$ff  // $2ad0  
    .byte $80,$01,$ff,$80,$00,$ff,$00,$00,$ff,$00,$00,$3c,$00,$00,$00,$00  // $2ae0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90  // $2af0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2b00  
    .byte $1c,$00,$00,$7f,$00,$00,$ff,$80,$00,$ff,$80,$01,$ff,$c0,$01,$ff  // $2b10  
    .byte $c0,$01,$ff,$c0,$00,$ff,$80,$00,$ff,$80,$00,$7f,$00,$00,$1c,$00  // $2b20  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2b30  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$00,$00  // $2b40  
    .byte $ff,$00,$01,$ff,$80,$01,$ff,$80,$03,$ff,$c0,$03,$ff,$c0,$03,$ff  // $2b50  
    .byte $c0,$03,$ff,$c0,$01,$ff,$80,$01,$ff,$80,$00,$ff,$00,$00,$3c,$00  // $2b60  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10  // $2b70  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$00,$00  // $2b80  
    .byte $ff,$80,$01,$ff,$c0,$01,$ff,$c0,$03,$ff,$e0,$03,$ff,$e0,$03,$ff  // $2b90  
    .byte $e0,$03,$ff,$e0,$03,$ff,$e0,$01,$ff,$c0,$01,$ff,$c0,$00,$ff,$80  // $2ba0  
    .byte $00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2bb0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$00,$00,$ff,$00,$01  // $2bc0  
    .byte $ff,$80,$03,$ff,$c0,$03,$ff,$c0,$07,$ff,$e0,$07,$ff,$e0,$07,$ff  // $2bd0  
    .byte $e0,$07,$ff,$e0,$03,$ff,$c0,$03,$ff,$c0,$01,$ff,$80,$00,$ff,$00  // $2be0  
    .byte $00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90  // $2bf0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$00,$00,$ff,$80,$01  // $2c00  
    .byte $ff,$c0,$03,$ff,$e0,$03,$ff,$e0,$07,$ff,$f0,$07,$ff,$f0,$07,$ff  // $2c10  
    .byte $f0,$07,$ff,$f0,$07,$ff,$f0,$03,$ff,$e0,$03,$ff,$e0,$01,$ff,$c0  // $2c20  
    .byte $00,$ff,$80,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2c30  
    .byte $00,$00,$00,$00,$00,$00,$00,$3c,$00,$00,$ff,$00,$03,$ff,$c0,$03  // $2c40  
    .byte $ff,$c0,$07,$ff,$e0,$07,$ff,$e0,$0f,$ff,$f0,$0f,$ff,$f0,$0f,$ff  // $2c50  
    .byte $f0,$0f,$ff,$f0,$07,$ff,$e0,$07,$ff,$e0,$03,$ff,$c0,$03,$ff,$c0  // $2c60  
    .byte $00,$ff,$00,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90  // $2c70  
    .byte $00,$00,$00,$00,$00,$00,$00,$3e,$00,$00,$ff,$80,$03,$ff,$e0,$03  // $2c80  
    .byte $ff,$e0,$07,$ff,$f0,$07,$ff,$f0,$0f,$ff,$f8,$0f,$ff,$f8,$0f,$ff  // $2c90  
    .byte $f8,$0f,$ff,$f8,$0f,$ff,$f8,$07,$ff,$f0,$07,$ff,$f0,$03,$ff,$e0  // $2ca0  
    .byte $03,$ff,$e0,$00,$ff,$80,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$00  // $2cb0  
    .byte $00,$00,$00,$00,$7e,$00,$01,$ff,$80,$07,$ff,$e0,$07,$ff,$e0,$0f  // $2cc0  
    .byte $ff,$f0,$0f,$ff,$f0,$1f,$ff,$f8,$1f,$ff,$f8,$1f,$ff,$f8,$1f,$ff  // $2cd0  
    .byte $f8,$1f,$ff,$f8,$1f,$ff,$f8,$0f,$ff,$f0,$0f,$ff,$f0,$07,$ff,$e0  // $2ce0  
    .byte $07,$ff,$e0,$01,$ff,$80,$00,$7e,$00,$00,$00,$00,$00,$00,$00,$14  // $2cf0  
    .byte $00,$00,$00,$00,$3e,$00,$00,$ff,$80,$03,$ff,$e0,$07,$ff,$f0,$07  // $2d00  
    .byte $ff,$f0,$0f,$ff,$f8,$0f,$ff,$f8,$1f,$ff,$fc,$1f,$ff,$fc,$1f,$ff  // $2d10  
    .byte $fc,$1f,$ff,$fc,$1f,$ff,$fc,$0f,$ff,$f8,$0f,$ff,$f8,$07,$ff,$f0  // $2d20  
    .byte $07,$ff,$f0,$03,$ff,$e0,$00,$ff,$80,$00,$3e,$00,$00,$00,$00,$00  // $2d30  
    .byte $00,$7e,$00,$01,$ff,$80,$07,$ff,$e0,$0f,$ff,$f0,$0f,$ff,$f0,$1f  // $2d40  
    .byte $ff,$f8,$1f,$ff,$f8,$3f,$ff,$fc,$3f,$ff,$fc,$3f,$ff,$fc,$3f,$ff  // $2d50  
    .byte $fc,$3f,$ff,$fc,$3f,$ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8,$0f,$ff,$f0  // $2d60  
    .byte $0f,$ff,$f0,$07,$ff,$e0,$01,$ff,$80,$00,$7e,$00,$00,$00,$00,$14  // $2d70  
    .byte $00,$7f,$00,$01,$ff,$c0,$07,$ff,$f0,$0f,$ff,$f8,$0f,$ff,$f8,$1f  // $2d80  
    .byte $ff,$fc,$1f,$ff,$fc,$3f,$ff,$fe,$3f,$ff,$fe,$3f,$ff,$fe,$3f,$ff  // $2d90  
    .byte $fe,$3f,$ff,$fe,$3f,$ff,$fe,$3f,$ff,$fe,$1f,$ff,$fc,$1f,$ff,$fc  // $2da0  
    .byte $0f,$ff,$f8,$0f,$ff,$f8,$07,$ff,$f0,$01,$ff,$c0,$00,$7f,$00,$00  // $2db0  
    .byte $00,$00,$00,$00,$7f,$00,$01,$ff,$c0,$07,$ff,$f0,$0f,$ff,$f8,$0f  // $2dc0  
    .byte $ff,$f8,$1f,$ff,$fc,$1f,$ff,$fc,$3f,$ff,$fe,$3f,$ff,$fe,$3f,$ff  // $2dd0  
    .byte $fe,$3f,$ff,$fe,$3f,$ff,$fe,$1f,$ff,$fc,$1f,$ff,$fc,$0f,$ff,$f8  // $2de0  
    .byte $0f,$ff,$f8,$07,$ff,$f0,$01,$ff,$c0,$00,$7f,$00,$00,$00,$00,$00  // $2df0  
    .byte $00,$00,$00,$00,$00,$00,$00,$3e,$00,$01,$ff,$c0,$07,$ff,$f0,$0f  // $2e00  
    .byte $ff,$f8,$1f,$ff,$fc,$1f,$ff,$fc,$3f,$ff,$fe,$3f,$ff,$fe,$3f,$ff  // $2e10  
    .byte $fe,$3f,$ff,$fe,$3f,$ff,$fe,$1f,$ff,$fc,$1f,$ff,$fc,$0f,$ff,$f8  // $2e20  
    .byte $07,$ff,$f0,$01,$ff,$c0,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$10  // $2e30  
    .byte $00,$3e,$00,$00,$ff,$80,$03,$ff,$e0,$07,$ff,$f0,$07,$ff,$f0,$0f  // $2e40  
    .byte $ff,$f8,$0f,$ff,$f8,$1f,$ff,$fc,$1f,$ff,$fc,$1f,$ff,$fc,$1f,$ff  // $2e50  
    .byte $fc,$1f,$ff,$fc,$1f,$ff,$fc,$1f,$ff,$fc,$0f,$ff,$f8,$0f,$ff,$f8  // $2e60  
    .byte $07,$ff,$f0,$07,$ff,$f0,$03,$ff,$e0,$00,$ff,$80,$00,$3e,$00,$00  // $2e70  
    .byte $00,$3e,$00,$00,$ff,$80,$01,$ff,$c0,$03,$ff,$e0,$03,$ff,$e0,$07  // $2e80  
    .byte $ff,$f0,$07,$ff,$f0,$07,$ff,$f0,$0f,$ff,$f8,$0f,$ff,$f8,$0f,$ff  // $2e90  
    .byte $f8,$0f,$ff,$f8,$0f,$ff,$f8,$07,$ff,$f0,$07,$ff,$f0,$07,$ff,$f0  // $2ea0  
    .byte $03,$ff,$e0,$03,$ff,$e0,$01,$ff,$c0,$00,$ff,$80,$00,$3e,$00,$d0  // $2eb0  
    .byte $00,$0f,$00,$00,$7f,$c0,$01,$ff,$f0,$03,$ff,$f8,$07,$ff,$f8,$0f  // $2ec0  
    .byte $ff,$fc,$0f,$ff,$fc,$1f,$ff,$fe,$1f,$ff,$fe,$1f,$ff,$fe,$3f,$ff  // $2ed0  
    .byte $fe,$3f,$ff,$fc,$3f,$ff,$fc,$3f,$ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8  // $2ee0  
    .byte $0f,$ff,$f0,$0f,$ff,$e0,$07,$ff,$c0,$01,$ff,$00,$00,$78,$00,$00  // $2ef0  
    .byte $00,$00,$00,$00,$0f,$c0,$00,$3f,$f0,$00,$ff,$f8,$01,$ff,$f8,$03  // $2f00  
    .byte $ff,$fc,$07,$ff,$fc,$07,$ff,$fc,$0f,$ff,$fc,$0f,$ff,$fc,$1f,$ff  // $2f10  
    .byte $fc,$1f,$ff,$f8,$1f,$ff,$f8,$1f,$ff,$f0,$1f,$ff,$f0,$1f,$ff,$e0  // $2f20  
    .byte $0f,$ff,$c0,$0f,$ff,$80,$07,$fe,$00,$01,$f8,$00,$00,$00,$00,$d0  // $2f30  
    .byte $00,$78,$00,$01,$ff,$00,$07,$ff,$c0,$0f,$ff,$e0,$0f,$ff,$f0,$1f  // $2f40  
    .byte $ff,$f8,$1f,$ff,$f8,$3f,$ff,$fc,$3f,$ff,$fc,$3f,$ff,$fc,$3f,$ff  // $2f50  
    .byte $fe,$1f,$ff,$fe,$1f,$ff,$fe,$1f,$ff,$fe,$0f,$ff,$fc,$0f,$ff,$fc  // $2f60  
    .byte $07,$ff,$f8,$03,$ff,$f8,$01,$ff,$f0,$00,$7f,$c0,$00,$0f,$00,$00  // $2f70  
    .byte $00,$00,$00,$01,$f8,$00,$07,$fe,$00,$0f,$ff,$80,$0f,$ff,$c0,$1f  // $2f80  
    .byte $ff,$e0,$1f,$ff,$f0,$1f,$ff,$f0,$1f,$ff,$f8,$1f,$ff,$f8,$1f,$ff  // $2f90  
    .byte $fc,$0f,$ff,$fc,$0f,$ff,$fc,$07,$ff,$fc,$07,$ff,$fc,$03,$ff,$fc  // $2fa0  
    .byte $01,$ff,$f8,$00,$ff,$f8,$00,$3f,$f0,$00,$0f,$c0,$00,$00,$00,$10  // $2fb0  
    .byte $00,$00,$00,$00,$00,$00,$00,$3e,$00,$01,$ff,$c0,$07,$c1,$f0,$0e  // $2fc0  
    .byte $00,$38,$18,$00,$0c,$10,$00,$04,$20,$00,$02,$20,$00,$02,$00,$00  // $2fd0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2fe0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $2ff0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3000  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3010  
    .byte $00,$20,$00,$02,$20,$00,$02,$10,$00,$04,$18,$00,$0c,$0e,$00,$38  // $3020  
    .byte $07,$c1,$f0,$01,$ff,$c0,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$df  // $3030  
    .byte $00,$30,$00,$00,$c0,$00,$01,$80,$00,$03,$00,$00,$03,$00,$00,$06  // $3040  
    .byte $00,$00,$06,$00,$00,$06,$00,$00,$0c,$00,$00,$0c,$00,$00,$0c,$00  // $3050  
    .byte $00,$0c,$00,$00,$0c,$00,$00,$06,$00,$00,$06,$00,$00,$06,$00,$00  // $3060  
    .byte $03,$00,$00,$03,$00,$00,$01,$80,$00,$00,$c0,$00,$00,$30,$00,$82  // $3070  
    .byte $00,$06,$00,$00,$01,$80,$00,$00,$c0,$00,$00,$60,$00,$00,$60,$00  // $3080  
    .byte $00,$30,$00,$00,$30,$00,$00,$30,$00,$00,$18,$00,$00,$18,$00,$00  // $3090  
    .byte $18,$00,$00,$18,$00,$00,$18,$00,$00,$30,$00,$00,$30,$00,$00,$30  // $30a0  
    .byte $00,$00,$60,$00,$00,$60,$00,$00,$c0,$00,$01,$80,$00,$06,$00,$df  // $30b0  
    .byte $00,$00,$00,$00,$0f,$c0,$00,$3c,$30,$00,$f0,$00,$01,$c0,$00,$03  // $30c0  
    .byte $80,$00,$07,$00,$00,$06,$00,$00,$0c,$00,$00,$0c,$00,$00,$18,$00  // $30d0  
    .byte $00,$18,$00,$00,$10,$00,$00,$10,$00,$00,$10,$00,$00,$10,$00,$00  // $30e0  
    .byte $08,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82  // $30f0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$08,$00  // $3100  
    .byte $00,$04,$00,$00,$04,$00,$00,$04,$00,$00,$04,$00,$00,$0c,$00,$00  // $3110  
    .byte $0c,$00,$00,$18,$00,$00,$18,$00,$00,$30,$00,$00,$70,$00,$00,$e0  // $3120  
    .byte $00,$01,$c0,$00,$07,$80,$06,$1e,$00,$01,$f8,$00,$00,$00,$00,$df  // $3130  
    .byte $00,$00,$00,$01,$f8,$00,$06,$1e,$00,$00,$07,$80,$00,$01,$c0,$00  // $3140  
    .byte $00,$e0,$00,$00,$70,$00,$00,$30,$00,$00,$18,$00,$00,$18,$00,$00  // $3150  
    .byte $0c,$00,$00,$0c,$00,$00,$04,$00,$00,$04,$00,$00,$04,$00,$00,$04  // $3160  
    .byte $00,$00,$08,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82  // $3170  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$08,$00,$00,$10  // $3180  
    .byte $00,$00,$10,$00,$00,$10,$00,$00,$10,$00,$00,$18,$00,$00,$18,$00  // $3190  
    .byte $00,$0c,$00,$00,$0c,$00,$00,$06,$00,$00,$07,$00,$00,$03,$80,$00  // $31a0  
    .byte $01,$c0,$00,$00,$f0,$00,$00,$3c,$30,$00,$0f,$c0,$00,$00,$00,$df  // $31b0  
D31c0:
    .byte $00,$00,$00,$00,$00,$00,$00,$cf,$ff   // $31c0  
D31c9:
    .byte $00,$00,$cf                           // $31c9  
D31cc:
    .byte $cd,$00,$cd,$00,$00,$00,$00,$00,$00,$ff,$6c,$00,$00,$00,$00,$00  // $31cc  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$00,$cf  // $31dc  
    .byte $01,$00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $31ec  
    .byte $00,$00,$89,$80                       // $31fc  
D3200:
    .byte $ff,$ff,$92,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3200  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3210  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3220  
    .byte $ff,$ff,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$30,$ff,$ff,$ff,$df  // $3230  
    .byte $03,$fa,$80,$3f,$fa,$a8,$7f,$fa,$a8,$ff,$fa,$aa,$ff,$fa,$aa,$ff  // $3240  
    .byte $fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$fd,$55  // $3250  
    .byte $6a,$d7,$fa,$96,$ff,$fa,$aa,$7f,$fa,$a9,$ff,$fa,$aa,$ff,$d6,$aa  // $3260  
    .byte $aa,$97,$ff,$55,$57,$ff,$55,$57,$fc,$2a,$af,$fc,$02,$af,$c0,$82  // $3270  
    .byte $03,$ff,$80,$3f,$ff,$a8,$7f,$ff,$a8,$bf,$ff,$aa,$bf,$ff,$aa,$bf  // $3280  
    .byte $ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bd,$55  // $3290  
    .byte $6a,$97,$ff,$96,$bf,$ff,$aa,$7f,$fe,$a9,$ab,$fe,$aa,$aa,$96,$aa  // $32a0  
    .byte $aa,$96,$aa,$55,$57,$ea,$55,$57,$fc,$2a,$ff,$fc,$02,$ff,$c0,$df  // $32b0  
    .byte $03,$ff,$c0,$2f,$ff,$f8,$6f,$ff,$f8,$af,$ff,$fa,$af,$ff,$fa,$af  // $32c0  
    .byte $ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$ad,$55  // $32d0  
    .byte $7a,$97,$ff,$d6,$af,$ff,$fa,$6b,$ff,$e9,$aa,$ff,$aa,$aa,$96,$aa  // $32e0  
    .byte $aa,$96,$aa,$55,$57,$aa,$55,$57,$e8,$2f,$ff,$f8,$03,$ff,$c0,$82  // $32f0  
    .byte $02,$ff,$c0,$2a,$ff,$fc,$6a,$ff,$fc,$aa,$ff,$fe,$aa,$ff,$fe,$aa  // $3300  
    .byte $ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$a9,$55  // $3310  
    .byte $7e,$96,$ff,$d6,$aa,$ff,$fe,$6a,$bf,$fd,$aa,$bf,$ea,$aa,$96,$aa  // $3320  
    .byte $aa,$96,$aa,$55,$56,$aa,$55,$56,$a8,$3f,$ff,$a8,$03,$ff,$80,$df  // $3330  
    .byte $03,$fa,$80,$3f,$fa,$a8,$3f,$fa,$a9,$ff,$fa,$aa,$ff,$fa,$aa,$ff  // $3340  
    .byte $fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$ff,$fa,$aa,$fd,$55  // $3350  
    .byte $6a,$d7,$fa,$96,$ff,$fa,$aa,$7f,$fa,$a9,$ff,$fa,$aa,$ff,$d6,$aa  // $3360  
    .byte $aa,$97,$ff,$aa,$95,$55,$2a,$95,$55,$2a,$af,$fc,$02,$af,$c0,$82  // $3370  
    .byte $03,$ff,$80,$3f,$ff,$a8,$3f,$ff,$a9,$bf,$ff,$aa,$bf,$ff,$aa,$bf  // $3380  
    .byte $ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bf,$ff,$aa,$bd,$55  // $3390  
    .byte $6a,$97,$ff,$96,$bf,$ff,$aa,$7f,$fe,$a9,$ab,$fe,$aa,$aa,$96,$aa  // $33a0  
    .byte $aa,$96,$aa,$aa,$95,$55,$2a,$95,$55,$2a,$ff,$fc,$02,$ff,$c0,$df  // $33b0  
    .byte $03,$ff,$c0,$2f,$ff,$f8,$2f,$ff,$f9,$af,$ff,$fa,$af,$ff,$fa,$af  // $33c0  
    .byte $ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$af,$ff,$fa,$ad,$55  // $33d0  
    .byte $7a,$97,$ff,$d6,$af,$ff,$fa,$6b,$ff,$e9,$aa,$ff,$aa,$aa,$96,$aa  // $33e0  
    .byte $aa,$96,$aa,$aa,$d5,$55,$2b,$d5,$55,$2f,$ff,$f8,$03,$ff,$c0,$82  // $33f0  
    .byte $02,$ff,$c0,$2a,$ff,$fc,$2a,$ff,$fd,$aa,$ff,$fe,$aa,$ff,$fe,$aa  // $3400  
    .byte $ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$aa,$ff,$fe,$a9,$55  // $3410  
    .byte $7e,$96,$ff,$d6,$aa,$ff,$fe,$6a,$bf,$fd,$aa,$bf,$ea,$aa,$96,$aa  // $3420  
    .byte $aa,$96,$aa,$ab,$d5,$55,$3f,$d5,$55,$3f,$ff,$a8,$03,$ff,$80,$df  // $3430  
    .byte $00,$00,$00,$00,$00,$00,$14,$00,$00,$14,$00,$00,$15,$00,$00,$05  // $3440  
    .byte $00,$00,$05,$4a,$00,$01,$6a,$80,$01,$5a,$b0,$00,$5a,$b0,$00,$5a  // $3450  
    .byte $b0,$02,$aa,$f0,$02,$aa,$f0,$02,$ab,$f0,$03,$af,$c0,$00,$ff,$c0  // $3460  
    .byte $00,$3f,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82  // $3470  
    .byte $00,$14,$00,$00,$14,$00,$00,$14,$00,$00,$14,$00,$00,$14,$00,$00  // $3480  
    .byte $14,$00,$00,$14,$00,$00,$96,$00,$02,$96,$80,$02,$96,$80,$02,$96  // $3490  
    .byte $80,$02,$aa,$80,$02,$aa,$80,$03,$aa,$c0,$03,$ff,$c0,$03,$ff,$c0  // $34a0  
    .byte $00,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$df  // $34b0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$14,$00,$00,$14,$00,$00,$54,$00  // $34c0  
    .byte $00,$50,$00,$a1,$50,$02,$a9,$40,$0e,$a5,$40,$0e,$a5,$00,$0e,$a5  // $34d0  
    .byte $00,$0f,$aa,$80,$0f,$aa,$80,$0f,$ea,$80,$03,$fa,$c0,$03,$ff,$00  // $34e0  
    .byte $00,$fc,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82  // $34f0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3500  
    .byte $00,$00,$00,$2b,$c0,$00,$aa,$f0,$00,$aa,$f0,$55,$5a,$f0,$55,$5a  // $3510  
    .byte $f0,$55,$5a,$f0,$00,$aa,$f0,$00,$aa,$f0,$00,$2b,$c0,$00,$00,$00  // $3520  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$df  // $3530  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3540  
    .byte $00,$00,$00,$aa,$00,$02,$aa,$80,$02,$aa,$80,$02,$96,$80,$02,$96  // $3550  
    .byte $80,$02,$96,$80,$02,$aa,$80,$02,$aa,$80,$00,$aa,$00,$00,$00,$00  // $3560  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82  // $3570  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3580  
    .byte $00,$00,$03,$e8,$00,$0f,$aa,$00,$0f,$aa,$00,$0f,$a5,$55,$0f,$a5  // $3590  
    .byte $55,$0f,$a5,$55,$0f,$aa,$00,$0f,$aa,$00,$03,$e8,$00,$00,$00,$00  // $35a0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$df  // $35b0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$3f,$00,$00  // $35c0  
    .byte $ff,$c0,$03,$af,$c0,$02,$ab,$f0,$02,$aa,$f0,$02,$aa,$f0,$00,$5a  // $35d0  
    .byte $b0,$00,$5a,$b0,$01,$5a,$b0,$01,$6a,$80,$05,$4a,$00,$05,$00,$00  // $35e0  
    .byte $15,$00,$00,$14,$00,$00,$14,$00,$00,$00,$00,$00,$00,$00,$00,$8a  // $35f0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$00,$03  // $3600  
    .byte $ff,$c0,$03,$ff,$c0,$03,$aa,$c0,$02,$aa,$80,$02,$aa,$80,$02,$96  // $3610  
    .byte $80,$02,$96,$80,$02,$96,$80,$00,$96,$00,$00,$14,$00,$00,$14,$00  // $3620  
    .byte $00,$14,$00,$00,$14,$00,$00,$14,$00,$00,$14,$00,$00,$14,$00,$df  // $3630  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$00,$fc,$00,$03  // $3640  
    .byte $ff,$00,$03,$fa,$c0,$0f,$ea,$80,$0f,$aa,$80,$0f,$aa,$80,$0e,$a5  // $3650  
    .byte $00,$0e,$a5,$00,$0e,$a5,$40,$02,$a9,$40,$00,$a1,$50,$00,$00,$50  // $3660  
    .byte $00,$00,$54,$00,$00,$14,$00,$00,$14,$00,$00,$00,$00,$00,$00,$82  // $3670  
    .byte $ff,$ff,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea  // $3680  
    .byte $aa,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea,$aa,$c0,$ea,$aa  // $3690  
    .byte $c0,$ea,$aa,$c0,$ea,$aa,$c0,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00  // $36a0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$df  // $36b0  
    .byte $00,$00,$00,$00,$00,$00,$aa,$aa,$aa,$aa,$aa,$aa,$00,$00,$00,$00  // $36c0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $36d0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $36e0  
    .byte $00,$00,$00,$aa,$aa,$aa,$aa,$aa,$aa,$00,$00,$00,$00,$00,$00,$82  // $36f0  
D3700:
    .byte $ff,$ff,$82,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3700  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3710  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3720  
    .byte $ff,$ff,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$b0,$ff,$ff,$ff,$df  // $3730  
D3740:
    .byte $00,$00,$00,$00,$00,$00,$00,$cf,$ff,$00,$00,$cf,$cd,$00,$cd,$00  // $3740  
    .byte $00,$00,$00,$00,$00,$ff,$6c,$00,$00   // $3750  
D3759:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3759  
    .byte $ff,$00,$cf,$01,$00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $3769  
    .byte $00,$00,$00,$00,$00,$8b,$82           // $3779  
D3780:
    .byte $ff,$ff,$82,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3780  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3790  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $37a0  
    .byte $ff,$ff,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$30,$ff,$ff,$ff,$df  // $37b0  
    .byte $00,$00,$00,$00,$00,$00,$00,$cf,$ff,$00,$00,$cf,$cd,$00,$cd,$00  // $37c0  
    .byte $00,$00,$00,$00,$00,$ff,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $37d0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$00,$cf,$01,$00,$cf,$00  // $37e0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$8b,$ff  // $37f0  
D3800:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fd,$fd,$fc,$fc,$fb  // $3800  
    .byte $fb,$fa,$f9,$f9,$f8,$f7,$f6,$f5,$f4,$f4,$f3,$f2,$f1,$ef,$ee,$ed  // $3810  
    .byte $ec,$eb,$ea,$e8,$e7,$e6,$e4,$e3,$e1,$e0,$de,$dd,$db,$d9,$d8,$d6  // $3820  
    .byte $d4,$d3,$d1,$cf,$cd,$cb,$c9,$c7,$c5,$c3,$c1,$bf,$bd,$bb,$b9,$b7  // $3830  
    .byte $b5,$b2,$b0,$ae,$ab,$a9,$a7,$a4,$a2,$9f,$9d,$9b,$98,$95,$93,$90  // $3840  
    .byte $8e,$8b,$88,$86,$83,$80,$7e,$7b,$78,$75,$73,$70,$6d,$6a,$67,$64  // $3850  
    .byte $61,$5f,$5c,$59,$56,$53,$50,$4d,$4a,$47,$44,$41,$3e,$3b,$38,$35  // $3860  
    .byte $31,$2e,$2b,$28,$25,$22,$1f,$1c,$19,$15,$12,$0f,$0c,$09,$06,$03  // $3870  
D3880:
    .byte $ff                                   // $3880  
D3881:
    .byte $ff                                   // $3881  
D3882:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3882  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $3892  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $38a2  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $38b2  
L38c0:
    ldx #$00                                    // $38c0  
L38c2:
    lda D2008,x                                 // $38c2  
    asl                                         // $38c5  
    ora #$55                                    // $38c6  
    sta D2508,x                                 // $38c8  
    inx                                         // $38cb  
    bpl L38c2                                   // $38cc  
    rts                                         // $38ce  
L38cf:
    lda #$00                                    // $38cf  
    bcc L38d5                                   // $38d1  
    lda #$78                                    // $38d3  
L38d5:
    sta $cf3a                                   // $38d5  
    bcc L38fa                                   // $38d8  
    lda $cf3b                                   // $38da  
    cmp #$04                                    // $38dd  
    bcc L38e3                                   // $38df  
    lda #$04                                    // $38e1  
L38e3:
    asl                                         // $38e3  
    asl                                         // $38e4  
    clc                                         // $38e5  
    adc $cf2d                                   // $38e6  
    tax                                         // $38e9  
    lda D3979,x                                 // $38ea  
    sta $cf9b                                   // $38ed  
    lda #$00                                    // $38f0  
    sta $cf32                                   // $38f2  
    sta $cf2f                                   // $38f5  
    beq L3910                                   // $38f8  
L38fa:
    lda $cf2e                                   // $38fa  
    cmp $cf2f                                   // $38fd  
    sta $cf2f                                   // $3900  
    beq L3938                                   // $3903  
    asl                                         // $3905  
    sta $fb                                     // $3906  
    asl                                         // $3908  
    asl                                         // $3909  
    clc                                         // $390a  
    adc $fb                                     // $390b  
    sta $cf32                                   // $390d  
L3910:
    lda #$08                                    // $3910  
    sta $cf30                                   // $3912  
    ldx $cf2d                                   // $3915  
    lda D398d,x                                 // $3918  
    sta $cf31                                   // $391b  
    lda $cf9b                                   // $391e  
    sta $fa                                     // $3921  
L3923:
    ror $fa                                     // $3923  
    bcc L392a                                   // $3925  
    jsr L3939                                   // $3927  
L392a:
    lda $cf31                                   // $392a  
    clc                                         // $392d  
    adc #$03                                    // $392e  
    sta $cf31                                   // $3930  
    dec $cf30                                   // $3933  
    bne L3923                                   // $3936  
L3938:
    rts                                         // $3938  
L3939:
    ldx $cf31                                   // $3939  
    lda D3991,x                                 // $393c  
    sta $fd                                     // $393f  
    inx                                         // $3941  
    lda D3991,x                                 // $3942  
    clc                                         // $3945  
    adc $cf3a                                   // $3946  
    sta $fe                                     // $3949  
    inx                                         // $394b  
    lda D3991,x                                 // $394c  
    ldy #$08                                    // $394f  
    cmp #$02                                    // $3951  
    bcc L3957                                   // $3953  
    ldy #$09                                    // $3955  
L3957:
    sty $fc                                     // $3957  
    asl                                         // $3959  
    asl                                         // $395a  
    asl                                         // $395b  
    asl                                         // $395c  
    sta $fb                                     // $395d  
    asl                                         // $395f  
    asl                                         // $3960  
    clc                                         // $3961  
    adc $cf32                                   // $3962  
    tax                                         // $3965  
L3966:
    ldy $fb                                     // $3966  
    lda D39f1,y                                 // $3968  
    tay                                         // $396b  
    lda D3a31,x                                 // $396c  
    sta ($fd),y                                 // $396f  
    inx                                         // $3971  
    inc $fb                                     // $3972  
    dec $fc                                     // $3974  
    bpl L3966                                   // $3976  
    rts                                         // $3978  
D3979:
    .byte $ff,$ff,$ff,$ff,$fe,$fe,$ef,$fb,$de,$de,$ed,$bb,$d6,$dc,$cd,$3b  // $3979  
    .byte $56,$9c,$cc,$39                       // $3989  
D398d:
    .byte $00,$18,$30,$48                       // $398d  
D3991:
    .byte $02,$07,$00,$0a,$07,$00,$fd,$05,$00,$e2,$04,$00,$cc,$05,$01,$63  // $3991  
    .byte $06,$00,$47,$05,$00,$4e,$05,$00,$13,$07,$00,$0c,$07,$00,$10,$06  // $39a1  
    .byte $02,$49,$05,$00,$7c,$05,$01,$e3,$04,$00,$b1,$05,$01,$d0,$05,$01  // $39b1  
    .byte $79,$06,$01,$10,$07,$00,$65,$06,$02,$6f,$05,$02,$d3,$04,$00,$dc  // $39c1  
    .byte $04,$00,$a6,$05,$03,$70,$06,$00,$0e,$06,$02,$14,$06,$01,$d5,$04  // $39d1  
    .byte $00,$e5,$04,$00,$b1,$05,$01,$9d,$06,$03,$0d,$07,$00,$f6,$05,$00  // $39e1  
D39f1:
    .byte $00,$01,$02,$28,$29,$2a,$50,$51,$52,$00,$00,$00,$00,$00,$00,$00  // $39f1  
    .byte $00,$01,$02,$28,$29,$2a,$50,$51,$52,$00,$00,$00,$00,$00,$00,$00  // $3a01  
    .byte $02,$29,$2a,$2b,$50,$51,$52,$53,$79,$7a,$00,$00,$00,$00,$00,$00  // $3a11  
    .byte $01,$28,$29,$2a,$50,$51,$52,$53,$79,$7a,$00,$00,$00,$00,$00,$00  // $3a21  
D3a31:
    .byte $12,$00,$11,$0e,$00,$06,$13,$7c,$14,$ff,$12,$00,$11,$0d,$7c,$07  // $3a31  
    .byte $02,$02,$02,$ff,$12,$00,$11,$0d,$7c,$07,$02,$02,$02,$ff,$12,$7c  // $3a41  
    .byte $11,$0c,$17,$08,$02,$02,$02,$ff,$12,$7c,$11,$0c,$17,$08,$02,$02  // $3a51  
    .byte $02,$ff,$0a,$0a,$0a,$20,$20,$20,$02,$02,$02,$ff,$ff,$ff,$ff,$ff  // $3a61  
    .byte $14,$02,$13,$00,$00,$82,$11,$0a,$12,$ff,$14,$03,$0e,$00,$82,$0e  // $3a71  
    .byte $11,$09,$0e,$ff,$14,$03,$0e,$00,$82,$0e,$11,$09,$0e,$ff,$14,$04  // $3a81  
    .byte $0e,$82,$16,$0e,$11,$08,$0e,$ff,$14,$04,$0e,$82,$16,$0e,$11,$08  // $3a91  
    .byte $0e,$ff,$06,$20,$0e,$06,$20,$0e,$06,$20,$0e,$ff,$ff,$ff,$ff,$ff  // $3aa1  
    .byte $5d,$28,$5e,$7c,$5f,$60,$29,$7d,$98,$83,$5d,$28,$5e,$7c,$5f,$60  // $3ab1  
    .byte $29,$7d,$62,$24,$5d,$37,$5e,$7c,$23,$24,$29,$7d,$23,$24,$5d,$50  // $3ac1  
    .byte $5e,$7c,$23,$24,$52,$7d,$23,$24,$25,$20,$1a,$7c,$23,$24,$4e,$7d  // $3ad1  
    .byte $23,$24,$25,$20,$26,$25,$23,$24,$20,$26,$23,$24,$ff,$ff,$ff,$ff  // $3ae1  
    .byte $61,$7c,$62,$24,$7d,$25,$5f,$60,$81,$99,$61,$7c,$62,$24,$7d,$25  // $3af1  
    .byte $5f,$60,$28,$5e,$61,$7c,$62,$2d,$7d,$25,$28,$27,$28,$27,$61,$7c  // $3b01  
    .byte $62,$3e,$7d,$3f,$28,$27,$28,$27,$29,$7c,$1f,$20,$7d,$3d,$28,$27  // $3b11  
    .byte $28,$27,$29,$29,$2a,$20,$2a,$20,$28,$27,$28,$27  // $3b21  
L3b2d:
    lda $cf54                                   // $3b2d  
    and #$10                                    // $3b30  
    beq L3b39                                   // $3b32  
    lda #$00                                    // $3b34  
    sta $cf34                                   // $3b36  
L3b39:
    lda $cf33                                   // $3b39  
    bne L3b52                                   // $3b3c  
    lda $cf54                                   // $3b3e  
    and #$10                                    // $3b41  
    bne L3b9a                                   // $3b43  
    lda $cf34                                   // $3b45  
    bne L3b9a                                   // $3b48  
    lda #$01                                    // $3b4a  
    sta $cf34                                   // $3b4c  
    sta $cf33                                   // $3b4f  
L3b52:
    inc $cf33                                   // $3b52  
    cmp #$0b                                    // $3b55  
    bcs L3b5e                                   // $3b57  
    lsr                                         // $3b59  
    sta $cf2e                                   // $3b5a  
    rts                                         // $3b5d  
L3b5e:
    cmp #$0b                                    // $3b5e  
    bne L3b6c                                   // $3b60  
    ldx $cf9b                                   // $3b62  
    beq L3b6b                                   // $3b65  
    sec                                         // $3b67  
    jsr L3ba5                                   // $3b68  
L3b6b:
    rts                                         // $3b6b  
L3b6c:
    ldx $cfaf                                   // $3b6c  
    cmp D3b9b,x                                 // $3b6f  
    bcs L3b75                                   // $3b72  
    rts                                         // $3b74  
L3b75:
    sta $fb                                     // $3b75  
    ldx $cfaf                                   // $3b77  
    lda D3ba0,x                                 // $3b7a  
    sec                                         // $3b7d  
    sbc $fb                                     // $3b7e  
    beq L3b89                                   // $3b80  
    lsr                                         // $3b82  
    sta $cf2e                                   // $3b83  
    jmp L3b9a                                   // $3b86  
L3b89:
    ldx $cf9b                                   // $3b89  
    beq L3b92                                   // $3b8c  
    clc                                         // $3b8e  
    jsr L3ba5                                   // $3b8f  
L3b92:
    lda #$00                                    // $3b92  
    sta $cf2e                                   // $3b94  
    sta $cf33                                   // $3b97  
L3b9a:
    rts                                         // $3b9a  
D3b9b:
    .byte $1a,$19,$18,$17,$16                   // $3b9b  
D3ba0:
    .byte $24,$23,$22,$21,$20                   // $3ba0  
L3ba5:
    lda #$0f                                    // $3ba5  
    bcc L3bab                                   // $3ba7  
    lda #$ff                                    // $3ba9  
L3bab:
    sta SID_V3_FREQ_HI                          // $3bab  
    lda #$80                                    // $3bae  
    sta SID_V3_CTRL                             // $3bb0  
    lda #$00                                    // $3bb3  
    sta SID_V3_FREQ_LO                          // $3bb5  
    sta SID_V3_AD                               // $3bb8  
    lda #$f0                                    // $3bbb  
    sta SID_V3_SR                               // $3bbd  
    lda #$0f                                    // $3bc0  
    sta $cf11                                   // $3bc2  
    lda #$2f                                    // $3bc5  
    sta SID_MODE_VOL                            // $3bc7  
    lda #$6e                                    // $3bca  
    sta SID_FC_HI                               // $3bcc  
    lda #$81                                    // $3bcf  
    sta SID_V3_CTRL                             // $3bd1  
    rts                                         // $3bd4  
L3bd5:
    lda #$00                                    // $3bd5  
    sta $fc                                     // $3bd7  
    lda $cf06                                   // $3bd9  
    sec                                         // $3bdc  
    sbc #$2e                                    // $3bdd  
    bcs L3be3                                   // $3bdf  
    lda #$00                                    // $3be1  
L3be3:
    lsr                                         // $3be3  
    lsr                                         // $3be4  
    lsr                                         // $3be5  
    cmp #$04                                    // $3be6  
    bcs L3bec                                   // $3be8  
    lda #$04                                    // $3bea  
L3bec:
    cmp #$16                                    // $3bec  
    bcc L3bf2                                   // $3bee  
    lda #$16                                    // $3bf0  
L3bf2:
    asl                                         // $3bf2  
    asl                                         // $3bf3  
    asl                                         // $3bf4  
    sta $fb                                     // $3bf5  
    asl                                         // $3bf7  
    rol $fc                                     // $3bf8  
    asl                                         // $3bfa  
    rol $fc                                     // $3bfb  
    clc                                         // $3bfd  
    adc $fb                                     // $3bfe  
    sta $fb                                     // $3c00  
    bcc L3c06                                   // $3c02  
    inc $fc                                     // $3c04  
L3c06:
    lda $cf04                                   // $3c06  
    lsr                                         // $3c09  
    lda $cf03                                   // $3c0a  
    ror                                         // $3c0d  
    sec                                         // $3c0e  
    sbc #$08                                    // $3c0f  
    bcs L3c15                                   // $3c11  
    lda #$00                                    // $3c13  
L3c15:
    lsr                                         // $3c15  
    lsr                                         // $3c16  
    cmp #$03                                    // $3c17  
    bcs L3c1d                                   // $3c19  
    lda #$03                                    // $3c1b  
L3c1d:
    cmp #$25                                    // $3c1d  
    bcc L3c23                                   // $3c1f  
    lda #$25                                    // $3c21  
L3c23:
    clc                                         // $3c23  
    adc $fb                                     // $3c24  
    sta $fb                                     // $3c26  
    lda $fc                                     // $3c28  
    adc #$04                                    // $3c2a  
    sta $fc                                     // $3c2c  
    lda $fb                                     // $3c2e  
    sec                                         // $3c30  
    sbc #$29                                    // $3c31  
    sta $fb                                     // $3c33  
    lda $fc                                     // $3c35  
    sbc #$00                                    // $3c37  
    sta $fc                                     // $3c39  
    lda $cf08                                   // $3c3b  
    clc                                         // $3c3e  
    adc #$01                                    // $3c3f  
    sta $fd                                     // $3c41  
    asl                                         // $3c43  
    clc                                         // $3c44  
    adc $fd                                     // $3c45  
    sec                                         // $3c47  
    adc $cf07                                   // $3c48  
    tax                                         // $3c4b  
    lda D3cb8,x                                 // $3c4c  
    sta $cf39                                   // $3c4f  
    txa                                         // $3c52  
    asl                                         // $3c53  
    sta $fd                                     // $3c54  
    asl                                         // $3c56  
    clc                                         // $3c57  
    adc $fd                                     // $3c58  
    tax                                         // $3c5a  
    lda $fb                                     // $3c5b  
    sta $fd                                     // $3c5d  
    lda $fc                                     // $3c5f  
    clc                                         // $3c61  
    adc #$78                                    // $3c62  
    sta $fe                                     // $3c64  
L3c66:
    lda D3cc1,x                                 // $3c66  
    tay                                         // $3c69  
    lda ($fd),y                                 // $3c6a  
    cmp #$20                                    // $3c6c  
    beq L3c74                                   // $3c6e  
    cmp #$b3                                    // $3c70  
    bne L3c77                                   // $3c72  
L3c74:
    jsr L3c7e                                   // $3c74  
L3c77:
    inx                                         // $3c77  
    dec $cf39                                   // $3c78  
    bne L3c66                                   // $3c7b  
    rts                                         // $3c7d  
L3c7e:
    stx $fa                                     // $3c7e  
    ldx $cf55                                   // $3c80  
    tya                                         // $3c83  
    clc                                         // $3c84  
    adc $fb                                     // $3c85  
    sta D7800,x                                 // $3c87  
    lda $fc                                     // $3c8a  
    adc #$00                                    // $3c8c  
    sta D7900,x                                 // $3c8e  
    lda #$63                                    // $3c91  
    sta ($fd),y                                 // $3c93  
    txa                                         // $3c95  
    sec                                         // $3c96  
    sbc #$02                                    // $3c97  
    bcc L3cb2                                   // $3c99  
    tax                                         // $3c9b  
    lda D7800,x                                 // $3c9c  
    sta $f8                                     // $3c9f  
    lda D7900,x                                 // $3ca1  
    sta $f9                                     // $3ca4  
    ldy #$00                                    // $3ca6  
    lda ($f8),y                                 // $3ca8  
    cmp #$20                                    // $3caa  
    bne L3cb2                                   // $3cac  
    lda #$63                                    // $3cae  
    sta ($f8),y                                 // $3cb0  
L3cb2:
    inc $cf55                                   // $3cb2  
    ldx $fa                                     // $3cb5  
    rts                                         // $3cb7  
D3cb8:
    .byte $06,$06,$06,$06,$01,$06,$06,$06,$06   // $3cb8  
D3cc1:
    .byte $02,$29,$2a,$50,$51,$52,$28,$29,$2a,$50,$51,$52,$00,$28,$29,$50  // $3cc1  
    .byte $51,$52,$01,$02,$29,$2a,$51,$52,$29,$29,$29,$29,$29,$29,$00,$01  // $3cd1  
    .byte $28,$29,$50,$51,$00,$01,$02,$29,$2a,$52,$00,$01,$02,$28,$29,$2a  // $3ce1  
    .byte $00,$01,$02,$28,$29,$50               // $3cf1  
L3cf7:
    stx $fb                                     // $3cf7  
    sty $fc                                     // $3cf9  
    lda #$00                                    // $3cfb  
    sta $fd                                     // $3cfd  
    ldy #$08                                    // $3cff  
L3d01:
    lsr $fb                                     // $3d01  
    bcc L3d08                                   // $3d03  
    clc                                         // $3d05  
    adc $fc                                     // $3d06  
L3d08:
    ror                                         // $3d08  
    ror $fd                                     // $3d09  
    dey                                         // $3d0b  
    bne L3d01                                   // $3d0c  
    tay                                         // $3d0e  
    ldx $fd                                     // $3d0f  
    rts                                         // $3d11  
L3d12:
    lda $cf07                                   // $3d12  
    bne L3d2c                                   // $3d15  
    lda #$01                                    // $3d17  
    ldx $cf36                                   // $3d19  
    bpl L3d20                                   // $3d1c  
    eor #$01                                    // $3d1e  
L3d20:
    ldx $cf06                                   // $3d20  
    cpx #$a0                                    // $3d23  
    bcs L3d29                                   // $3d25  
    eor #$01                                    // $3d27  
L3d29:
    jmp L3da1                                   // $3d29  
L3d2c:
    lda $cf08                                   // $3d2c  
    bne L3d4b                                   // $3d2f  
    lda #$01                                    // $3d31  
    ldx $cf35                                   // $3d33  
    bpl L3d3a                                   // $3d36  
    eor #$01                                    // $3d38  
L3d3a:
    ldx $cf04                                   // $3d3a  
    bne L3d48                                   // $3d3d  
    ldx $cf03                                   // $3d3f  
    cpx #$a0                                    // $3d42  
    bcs L3d48                                   // $3d44  
    eor #$01                                    // $3d46  
L3d48:
    jmp L3da1                                   // $3d48  
L3d4b:
    lda $cf07                                   // $3d4b  
    cmp $cf08                                   // $3d4e  
    bne L3d7c                                   // $3d51  
    ldy #$00                                    // $3d53  
    lda $cf35                                   // $3d55  
    clc                                         // $3d58  
    adc $cf36                                   // $3d59  
    bcs L3d62                                   // $3d5c  
    tya                                         // $3d5e  
    eor #$01                                    // $3d5f  
    tay                                         // $3d61  
L3d62:
    lda $cf04                                   // $3d62  
    ror                                         // $3d65  
    lda $cf03                                   // $3d66  
    ror                                         // $3d69  
    clc                                         // $3d6a  
    adc $cf06                                   // $3d6b  
    bcs L3d78                                   // $3d6e  
    cmp #$e6                                    // $3d70  
    bcs L3d78                                   // $3d72  
    tya                                         // $3d74  
    eor #$01                                    // $3d75  
    tay                                         // $3d77  
L3d78:
    tya                                         // $3d78  
    jmp L3da1                                   // $3d79  
L3d7c:
    ldy #$00                                    // $3d7c  
    lda $cf35                                   // $3d7e  
    cmp $cf36                                   // $3d81  
    bcs L3d8a                                   // $3d84  
    tya                                         // $3d86  
    eor #$01                                    // $3d87  
    tay                                         // $3d89  
L3d8a:
    lda $cf04                                   // $3d8a  
    ror                                         // $3d8d  
    lda $cf03                                   // $3d8e  
    ror                                         // $3d91  
    sec                                         // $3d92  
    sbc $cf06                                   // $3d93  
    bcs L3da0                                   // $3d96  
    cmp #$b4                                    // $3d98  
    bcs L3da0                                   // $3d9a  
    tya                                         // $3d9c  
    eor #$01                                    // $3d9d  
    tay                                         // $3d9f  
L3da0:
    tya                                         // $3da0  
L3da1:
    sta $fb                                     // $3da1  
    lda $cfa2                                   // $3da3  
    asl                                         // $3da6  
    clc                                         // $3da7  
    adc #$a7                                    // $3da8  
    clc                                         // $3daa  
    adc $fb                                     // $3dab  
    cmp D07fb                                   // $3dad  
    beq L3db7                                   // $3db0  
    ldx #$01                                    // $3db2  
    stx $cfa7                                   // $3db4  
L3db7:
    sta D07fb                                   // $3db7  
    sta D07fc                                   // $3dba  
    rts                                         // $3dbd  
L3dbe:
    lda $cf3d                                   // $3dbe  
    sta $cf3e                                   // $3dc1  
    lda #$7f                                    // $3dc4  
    sec                                         // $3dc6  
    sbc $cf3e                                   // $3dc7  
    sta $cf40                                   // $3dca  
    lda $cf3c                                   // $3dcd  
    sta $cf3f                                   // $3dd0  
    lda #$7f                                    // $3dd3  
    sec                                         // $3dd5  
    sbc $cf3f                                   // $3dd6  
    sta $cf41                                   // $3dd9  
    lda $cf00                                   // $3ddc  
    bpl L3de6                                   // $3ddf  
    eor #$ff                                    // $3de1  
    clc                                         // $3de3  
    adc #$01                                    // $3de4  
L3de6:
    tax                                         // $3de6  
    lda $cf3e                                   // $3de7  
    tay                                         // $3dea  
    jsr L3cf7                                   // $3deb  
    tya                                         // $3dee  
    ldx #$01                                    // $3def  
L3df1:
    lsr                                         // $3df1  
    dex                                         // $3df2  
    bne L3df1                                   // $3df3  
    sta $fb                                     // $3df5  
    lda $cf00                                   // $3df7  
    ldx $cf42                                   // $3dfa  
    eor D4019,x                                 // $3dfd  
    bpl L3e0b                                   // $3e00  
    lda $fb                                     // $3e02  
    eor #$ff                                    // $3e04  
    clc                                         // $3e06  
    adc #$01                                    // $3e07  
    sta $fb                                     // $3e09  
L3e0b:
    lda $cf3c                                   // $3e0b  
    clc                                         // $3e0e  
    adc $fb                                     // $3e0f  
    bpl L3e25                                   // $3e11  
    ldx $fb                                     // $3e13  
    bpl L3e1b                                   // $3e15  
    lda #$ff                                    // $3e17  
    bne L3e25                                   // $3e19  
L3e1b:
    ldy $cf93                                   // $3e1b  
    cpy #$01                                    // $3e1e  
    bne L3e25                                   // $3e20  
    inc $cf93                                   // $3e22  
L3e25:
    sta $cf3c                                   // $3e25  
    lda $cf01                                   // $3e28  
    bpl L3e32                                   // $3e2b  
    eor #$ff                                    // $3e2d  
    clc                                         // $3e2f  
    adc #$01                                    // $3e30  
L3e32:
    tax                                         // $3e32  
    lda $cf3f                                   // $3e33  
    tay                                         // $3e36  
    jsr L3cf7                                   // $3e37  
    tya                                         // $3e3a  
    ldx #$01                                    // $3e3b  
L3e3d:
    lsr                                         // $3e3d  
    dex                                         // $3e3e  
    bne L3e3d                                   // $3e3f  
    sta $fb                                     // $3e41  
    lda $cf01                                   // $3e43  
    ldx $cf43                                   // $3e46  
    eor D4019,x                                 // $3e49  
    bpl L3e57                                   // $3e4c  
    lda $fb                                     // $3e4e  
    eor #$ff                                    // $3e50  
    clc                                         // $3e52  
    adc #$01                                    // $3e53  
    sta $fb                                     // $3e55  
L3e57:
    lda $cf3d                                   // $3e57  
    clc                                         // $3e5a  
    adc $fb                                     // $3e5b  
    bpl L3e71                                   // $3e5d  
    ldx $fb                                     // $3e5f  
    bpl L3e67                                   // $3e61  
    lda #$ff                                    // $3e63  
    bne L3e71                                   // $3e65  
L3e67:
    ldy $cf93                                   // $3e67  
    cpy #$01                                    // $3e6a  
    bne L3e71                                   // $3e6c  
    inc $cf93                                   // $3e6e  
L3e71:
    sta $cf3d                                   // $3e71  
    lda $cf08                                   // $3e74  
    bne L3e8a                                   // $3e77  
    lda $cf42                                   // $3e79  
    cmp #$02                                    // $3e7c  
    bcc L3e8a                                   // $3e7e  
    lda #$50                                    // $3e80  
    cmp $cf3d                                   // $3e82  
    bcc L3e8a                                   // $3e85  
    sta $cf3d                                   // $3e87  
L3e8a:
    lda $cf07                                   // $3e8a  
    bne L3ea0                                   // $3e8d  
    lda $cf43                                   // $3e8f  
    cmp #$02                                    // $3e92  
    bcc L3ea0                                   // $3e94  
    lda #$50                                    // $3e96  
    cmp $cf3c                                   // $3e98  
    bcc L3ea0                                   // $3e9b  
    sta $cf3c                                   // $3e9d  
L3ea0:
    ldy #$00                                    // $3ea0  
    lda $cf3c                                   // $3ea2  
    cmp $cf40                                   // $3ea5  
    bcc L3eae                                   // $3ea8  
    cmp #$ff                                    // $3eaa  
    bne L3eaf                                   // $3eac  
L3eae:
    iny                                         // $3eae  
L3eaf:
    lda $cf3d                                   // $3eaf  
    cmp $cf41                                   // $3eb2  
    bcc L3ebb                                   // $3eb5  
    cmp #$ff                                    // $3eb7  
    bne L3ebd                                   // $3eb9  
L3ebb:
    iny                                         // $3ebb  
    iny                                         // $3ebc  
L3ebd:
    tya                                         // $3ebd  
    and #$01                                    // $3ebe  
    beq L3ecd                                   // $3ec0  
    lda $cf40                                   // $3ec2  
    asl                                         // $3ec5  
    sec                                         // $3ec6  
    sbc $cf3c                                   // $3ec7  
    sta $cf3c                                   // $3eca  
L3ecd:
    tya                                         // $3ecd  
    and #$02                                    // $3ece  
    beq L3edd                                   // $3ed0  
    lda $cf41                                   // $3ed2  
    asl                                         // $3ed5  
    sec                                         // $3ed6  
    sbc $cf3d                                   // $3ed7  
    sta $cf3d                                   // $3eda  
L3edd:
    tya                                         // $3edd  
    beq L3ef2                                   // $3ede  
    ldx $cf42                                   // $3ee0  
    lda D4025,x                                 // $3ee3  
    sta $cf42                                   // $3ee6  
    ldx $cf43                                   // $3ee9  
    lda D4025,x                                 // $3eec  
    sta $cf43                                   // $3eef  
L3ef2:
    lda $cf3c                                   // $3ef2  
    bpl L3f0d                                   // $3ef5  
    eor #$ff                                    // $3ef7  
    cmp $cf40                                   // $3ef9  
    bcs L3f01                                   // $3efc  
    lda $cf40                                   // $3efe  
L3f01:
    sta $cf3c                                   // $3f01  
    ldx $cf42                                   // $3f04  
    lda D4021,x                                 // $3f07  
    sta $cf42                                   // $3f0a  
L3f0d:
    lda $cf3d                                   // $3f0d  
    bpl L3f28                                   // $3f10  
    eor #$ff                                    // $3f12  
    cmp $cf41                                   // $3f14  
    bcs L3f1c                                   // $3f17  
    lda $cf41                                   // $3f19  
L3f1c:
    sta $cf3d                                   // $3f1c  
    ldx $cf43                                   // $3f1f  
    lda D4021,x                                 // $3f22  
    sta $cf43                                   // $3f25  
L3f28:
    lda VIC_SPR_ENABLE                          // $3f28  
    and #$fd                                    // $3f2b  
    ldx $cf42                                   // $3f2d  
    cpx #$02                                    // $3f30  
    bcs L3f3d                                   // $3f32  
    ldx $cf43                                   // $3f34  
    cpx #$02                                    // $3f37  
    bcs L3f3d                                   // $3f39  
    ora #$02                                    // $3f3b  
L3f3d:
    sta VIC_SPR_ENABLE                          // $3f3d  
    and #$02                                    // $3f40  
    bne L3f51                                   // $3f42  
    ldy $cf93                                   // $3f44  
    cpy #$02                                    // $3f47  
    bne L3f56                                   // $3f49  
    jsr L67b0                                   // $3f4b  
    jmp L3f56                                   // $3f4e  
L3f51:
    ldy #$01                                    // $3f51  
    sty $cf93                                   // $3f53  
L3f56:
    ldx $cf3c                                   // $3f56  
    lda D3800,x                                 // $3f59  
    tay                                         // $3f5c  
    lda $cf74                                   // $3f5d  
    beq L3f6a                                   // $3f60  
    lda $cf07                                   // $3f62  
    and $cf08                                   // $3f65  
    bne L3f6e                                   // $3f68  
L3f6a:
    lda #$03                                    // $3f6a  
    bne L3f70                                   // $3f6c  
L3f6e:
    lda #$02                                    // $3f6e  
L3f70:
    clc                                         // $3f70  
    adc $cfa2                                   // $3f71  
    tax                                         // $3f74  
    sta $fe                                     // $3f75  
    jsr L3cf7                                   // $3f77  
    sty $fb                                     // $3f7a  
    lda #$00                                    // $3f7c  
    sta $fc                                     // $3f7e  
    ldx $cf42                                   // $3f80  
    lda D401d,x                                 // $3f83  
    bne L3f99                                   // $3f86  
    lda $fb                                     // $3f88  
    eor #$ff                                    // $3f8a  
    clc                                         // $3f8c  
    adc #$01                                    // $3f8d  
    sta $fb                                     // $3f8f  
    lda $fc                                     // $3f91  
    eor #$ff                                    // $3f93  
    adc #$00                                    // $3f95  
    sta $fc                                     // $3f97  
L3f99:
    lda $cf03                                   // $3f99  
    clc                                         // $3f9c  
    adc $fb                                     // $3f9d  
    sta VIC_SPR1_X                              // $3f9f  
    lda $cf04                                   // $3fa2  
    adc $fc                                     // $3fa5  
    bne L3fb1                                   // $3fa7  
    lda VIC_SPR_X_MSB                           // $3fa9  
    and #$fd                                    // $3fac  
    clc                                         // $3fae  
    bcc L3fb6                                   // $3faf  
L3fb1:
    lda VIC_SPR_X_MSB                           // $3fb1  
    ora #$02                                    // $3fb4  
L3fb6:
    sta VIC_SPR_X_MSB                           // $3fb6  
    ldx $cf3d                                   // $3fb9  
    lda D3800,x                                 // $3fbc  
    tay                                         // $3fbf  
    ldx $fe                                     // $3fc0  
    jsr L3cf7                                   // $3fc2  
    sty $fb                                     // $3fc5  
    ldx $cf43                                   // $3fc7  
    lda D401d,x                                 // $3fca  
    bne L3fd8                                   // $3fcd  
    lda $fb                                     // $3fcf  
    eor #$ff                                    // $3fd1  
    clc                                         // $3fd3  
    adc #$01                                    // $3fd4  
    sta $fb                                     // $3fd6  
L3fd8:
    lda $cf06                                   // $3fd8  
    clc                                         // $3fdb  
    adc $fb                                     // $3fdc  
    sta VIC_SPR1_Y                              // $3fde  
    jsr L3fed                                   // $3fe1  
    lda $cf74                                   // $3fe4  
    beq L3fec                                   // $3fe7  
    jsr L6ec9                                   // $3fe9  
L3fec:
    rts                                         // $3fec  
L3fed:
    lda $cf07                                   // $3fed  
    and $cf08                                   // $3ff0  
    beq L4018                                   // $3ff3  
    lda #$02                                    // $3ff5  
    ldx $cf3c                                   // $3ff7  
    cpx $cf3d                                   // $3ffa  
    bcs L400d                                   // $3ffd  
    clc                                         // $3fff  
    adc $cf3c                                   // $4000  
    bpl L4007                                   // $4003  
    lda #$7f                                    // $4005  
L4007:
    sta $cf3c                                   // $4007  
    clc                                         // $400a  
    bcc L4018                                   // $400b  
L400d:
    clc                                         // $400d  
    adc $cf3d                                   // $400e  
    bpl L4015                                   // $4011  
    lda #$7f                                    // $4013  
L4015:
    sta $cf3d                                   // $4015  
L4018:
    rts                                         // $4018  
D4019:
    .byte $00,$80,$00,$80                       // $4019  
D401d:
    .byte $00,$01,$01,$00                       // $401d  
D4021:
    .byte $01,$00,$03,$02                       // $4021  
D4025:
    .byte $03,$02,$01,$00                       // $4025  
L4029:
    jsr L7078                                   // $4029  
L402c:
    jsr L44b5                                   // $402c  
L402f:
    jsr L556b                                   // $402f  
    jsr L4524                                   // $4032  
    jsr L493b                                   // $4035  
L4038:
    jsr L4597                                   // $4038  
    lda $cf87                                   // $403b  
    bne L402f                                   // $403e  
    lda $cfb4                                   // $4040  
    beq L4038                                   // $4043  
    jmp L402c                                   // $4045  
L4048:
    lda $cf2d                                   // $4048  
    asl                                         // $404b  
    asl                                         // $404c  
    clc                                         // $404d  
    adc #$a0                                    // $404e  
    sta $fc                                     // $4050  
    lda #$00                                    // $4052  
    sta $fb                                     // $4054  
    sta $fd                                     // $4056  
    lda #$7c                                    // $4058  
    sta $fe                                     // $405a  
    ldx #$04                                    // $405c  
    ldy #$00                                    // $405e  
L4060:
    lda ($fb),y                                 // $4060  
    sta ($fd),y                                 // $4062  
    iny                                         // $4064  
    bne L4060                                   // $4065  
    inc $fc                                     // $4067  
    inc $fe                                     // $4069  
    dex                                         // $406b  
    bne L4060                                   // $406c  
    lda #$78                                    // $406e  
    sta D7c79                                   // $4070  
    lda #$79                                    // $4073  
    sta D7c9d                                   // $4075  
    lda #$7a                                    // $4078  
    sta D7fbd                                   // $407a  
    lda #$7b                                    // $407d  
    sta D7f99                                   // $407f  
    jsr L4086                                   // $4082  
    rts                                         // $4085  
L4086:
    ldx #$17                                    // $4086  
    lda #<D7c50                                 // $4088  
    sta $fb                                     // $408a  
    lda #>D7c50                                 // $408c  
    sta $fc                                     // $408e  
L4090:
    ldy #$00                                    // $4090  
    lda #$ae                                    // $4092  
    sta ($fb),y                                 // $4094  
    ldy #$26                                    // $4096  
    lda #$a6                                    // $4098  
    sta ($fb),y                                 // $409a  
    ldy #$27                                    // $409c  
    lda #$a0                                    // $409e  
    sta ($fb),y                                 // $40a0  
    lda $fb                                     // $40a2  
    clc                                         // $40a4  
    adc #$28                                    // $40a5  
    sta $fb                                     // $40a7  
    bcc L40ad                                   // $40a9  
    inc $fc                                     // $40ab  
L40ad:
    dex                                         // $40ad  
    bne L4090                                   // $40ae  
    ldx #$26                                    // $40b0  
L40b2:
    lda #$a2                                    // $40b2  
    sta D7c50,x                                 // $40b4  
    lda #$aa                                    // $40b7  
    sta D7fc0,x                                 // $40b9  
    dex                                         // $40bc  
    bpl L40b2                                   // $40bd  
    lda #$a1                                    // $40bf  
    sta D7c51                                   // $40c1  
    lda #$a3                                    // $40c4  
    sta D7c75                                   // $40c6  
    lda #$a4                                    // $40c9  
    sta D7c76                                   // $40cb  
    lda #$a5                                    // $40ce  
    sta D7c9e                                   // $40d0  
    lda #$a7                                    // $40d3  
    sta D7fbe                                   // $40d5  
    lda #$a8                                    // $40d8  
    sta D7fe6                                   // $40da  
    lda #$a9                                    // $40dd  
    sta D7fe5                                   // $40df  
    lda #$ab                                    // $40e2  
    sta D7fc1                                   // $40e4  
    lda #$ac                                    // $40e7  
    sta D7fc0                                   // $40e9  
    lda #$ad                                    // $40ec  
    sta D7f98                                   // $40ee  
    lda #$af                                    // $40f1  
    sta D7c78                                   // $40f3  
    lda #$b0                                    // $40f6  
    sta D7c50                                   // $40f8  
    rts                                         // $40fb  
L40fc:
    lda #<D7be8                                 // $40fc  
    sta $fb                                     // $40fe  
    sta $fd                                     // $4100  
    lda #>D7be8                                 // $4102  
    sta $fc                                     // $4104  
    lda #$03                                    // $4106  
    sta $fe                                     // $4108  
    ldx #$04                                    // $410a  
    ldy #$68                                    // $410c  
L410e:
    lda ($fb),y                                 // $410e  
    sta ($fd),y                                 // $4110  
    iny                                         // $4112  
    bne L410e                                   // $4113  
    inc $fc                                     // $4115  
    inc $fe                                     // $4117  
    dex                                         // $4119  
    bne L410e                                   // $411a  
    lda #<D7800                                 // $411c  
    sta $fb                                     // $411e  
    sta $fd                                     // $4120  
    lda #>D7800                                 // $4122  
    sta $fc                                     // $4124  
    lda #$d8                                    // $4126  
    sta $fe                                     // $4128  
    ldx #$04                                    // $412a  
    ldy #$50                                    // $412c  
L412e:
    lda ($fb),y                                 // $412e  
    sta ($fd),y                                 // $4130  
    iny                                         // $4132  
    bne L412e                                   // $4133  
    inc $fc                                     // $4135  
    inc $fe                                     // $4137  
    dex                                         // $4139  
    bne L412e                                   // $413a  
    rts                                         // $413c  
L413d:
    lda #<D7800                                 // $413d  
    sta $fb                                     // $413f  
    lda #>D7800                                 // $4141  
    sta $fc                                     // $4143  
    ldx $cf2d                                   // $4145  
    lda D4195,x                                 // $4148  
    ldx #$04                                    // $414b  
    ldy #$00                                    // $414d  
L414f:
    sta ($fb),y                                 // $414f  
    iny                                         // $4151  
    bne L414f                                   // $4152  
    inc $fc                                     // $4154  
    dex                                         // $4156  
    bne L414f                                   // $4157  
    jsr L415d                                   // $4159  
    rts                                         // $415c  
L415d:
    ldx $cf2d                                   // $415d  
    lda D4199,x                                 // $4160  
    sta $fd                                     // $4163  
    ldx #$17                                    // $4165  
    lda #<D7850                                 // $4167  
    sta $fb                                     // $4169  
    lda #>D7850                                 // $416b  
    sta $fc                                     // $416d  
L416f:
    lda $fd                                     // $416f  
    ldy #$00                                    // $4171  
    sta ($fb),y                                 // $4173  
    ldy #$26                                    // $4175  
    sta ($fb),y                                 // $4177  
    lda $fb                                     // $4179  
    clc                                         // $417b  
    adc #$28                                    // $417c  
    sta $fb                                     // $417e  
    bcc L4184                                   // $4180  
    inc $fc                                     // $4182  
L4184:
    dex                                         // $4184  
    bne L416f                                   // $4185  
    ldx #$26                                    // $4187  
    lda $fd                                     // $4189  
L418b:
    sta D7850,x                                 // $418b  
    sta D7bc0,x                                 // $418e  
    dex                                         // $4191  
    bpl L418b                                   // $4192  
    rts                                         // $4194  
D4195:
    .byte $0e,$0a,$0c,$0d                       // $4195  
D4199:
    .byte $0e,$0a,$0c,$0d                       // $4199  
L419d:
    lda #$08                                    // $419d  
    sta $cf30                                   // $419f  
    ldx $cf2d                                   // $41a2  
    lda D398d,x                                 // $41a5  
    sta $cf31                                   // $41a8  
    lda #$00                                    // $41ab  
    sta $cf32                                   // $41ad  
L41b0:
    ldx $cf31                                   // $41b0  
    lda D3991,x                                 // $41b3  
    sta $fd                                     // $41b6  
    inx                                         // $41b8  
    lda D3991,x                                 // $41b9  
    clc                                         // $41bc  
    adc #$74                                    // $41bd  
    sta $fe                                     // $41bf  
    inx                                         // $41c1  
    lda D3991,x                                 // $41c2  
    sta $fb                                     // $41c5  
    asl                                         // $41c7  
    clc                                         // $41c8  
    adc $fb                                     // $41c9  
    sta $fb                                     // $41cb  
    lda #$02                                    // $41cd  
    sta $fc                                     // $41cf  
L41d1:
    ldy $fb                                     // $41d1  
    lda D41f0,y                                 // $41d3  
    tay                                         // $41d6  
    lda #$0f                                    // $41d7  
    sta ($fd),y                                 // $41d9  
    inc $fb                                     // $41db  
    dec $fc                                     // $41dd  
    bpl L41d1                                   // $41df  
    lda $cf31                                   // $41e1  
    clc                                         // $41e4  
    adc #$03                                    // $41e5  
    sta $cf31                                   // $41e7  
    dec $cf30                                   // $41ea  
    bne L41b0                                   // $41ed  
    rts                                         // $41ef  
D41f0:
    .byte $01,$29,$51,$28,$29,$2a,$2a,$51,$52,$29,$51,$52  // $41f0  
L41fc:
    jsr L4048                                   // $41fc  
    sec                                         // $41ff  
    jsr L38cf                                   // $4200  
    jsr L67e1                                   // $4203  
    jsr L413d                                   // $4206  
    jsr L419d                                   // $4209  
    lda #$00                                    // $420c  
    sta $cf53                                   // $420e  
    lda #$01                                    // $4211  
    sta $cf65                                   // $4213  
    ldx $cf2d                                   // $4216  
    lda #$40                                    // $4219  
    clc                                         // $421b  
    adc D4d6f,x                                 // $421c  
    dex                                         // $421f  
    sec                                         // $4220  
    sbc D4d6f,x                                 // $4221  
    sta $cf95                                   // $4224  
    lda #$00                                    // $4227  
    sta $cf5e                                   // $4229  
    lda #$01                                    // $422c  
    sta $cf5f                                   // $422e  
    lda #$02                                    // $4231  
    sta $cf60                                   // $4233  
    lda #$01                                    // $4236  
    sta $cf61                                   // $4238  
    lda #$60                                    // $423b  
    sta $cf64                                   // $423d  
    lda $cf0e                                   // $4240  
    sta $cf62                                   // $4243  
    lda #$00                                    // $4246  
    sta $cf63                                   // $4248  
    lda #$00                                    // $424b  
    sta $cf44                                   // $424d  
    lda #$01                                    // $4250  
    sta $cf45                                   // $4252  
L4255:
    jsr L4309                                   // $4255  
    lda $cf44                                   // $4258  
    cmp #$28                                    // $425b  
    bcc L4255                                   // $425d  
    jsr L4263                                   // $425f  
    rts                                         // $4262  
L4263:
    lda #$00                                    // $4263  
    sta $cf85                                   // $4265  
    sta $cf66                                   // $4268  
    lda #$08                                    // $426b  
    sta SID_V1_CTRL                             // $426d  
    sta SID_V2_CTRL                             // $4270  
L4273:
    lda #$00                                    // $4273  
    sta $cf45                                   // $4275  
    jsr L433c                                   // $4278  
    ldx $cf66                                   // $427b  
    lda D42a8,x                                 // $427e  
    sta $cf60                                   // $4281  
    lda $cf65                                   // $4284  
    beq L428f                                   // $4287  
    jsr L42af                                   // $4289  
    jmp L4292                                   // $428c  
L428f:
    jsr L42dd                                   // $428f  
L4292:
    inc $cf66                                   // $4292  
    lda $cf66                                   // $4295  
    cmp #$06                                    // $4298  
    bcc L4273                                   // $429a  
    jsr L433c                                   // $429c  
    lda #$00                                    // $429f  
    sta $cf45                                   // $42a1  
    jsr L4c8e                                   // $42a4  
    rts                                         // $42a7  
D42a8:
    .byte $04,$07,$0c,$13,$1c,$27,$ff           // $42a8  
L42af:
    lda #$80                                    // $42af  
    sta $cf5e                                   // $42b1  
    lda #$00                                    // $42b4  
    sta $cf5f                                   // $42b6  
    lda #$01                                    // $42b9  
    sta $cf61                                   // $42bb  
    lda #$80                                    // $42be  
    sta $cf64                                   // $42c0  
    lda #$00                                    // $42c3  
    sta $cf63                                   // $42c5  
    lda #$01                                    // $42c8  
    sta $cf45                                   // $42ca  
L42cd:
    jsr L4309                                   // $42cd  
    lda $cf44                                   // $42d0  
    cmp #$28                                    // $42d3  
    bcc L42cd                                   // $42d5  
    lda $cf5f                                   // $42d7  
    beq L42cd                                   // $42da  
    rts                                         // $42dc  
L42dd:
    lda #$80                                    // $42dd  
    sta $cf5e                                   // $42df  
    lda #$01                                    // $42e2  
    sta $cf5f                                   // $42e4  
    lda #$00                                    // $42e7  
    sta $cf61                                   // $42e9  
    lda #$80                                    // $42ec  
    sta $cf64                                   // $42ee  
    lda #$00                                    // $42f1  
    sta $cf63                                   // $42f3  
    lda #$01                                    // $42f6  
    sta $cf45                                   // $42f8  
L42fb:
    jsr L4309                                   // $42fb  
    lda $cf44                                   // $42fe  
    bpl L42fb                                   // $4301  
    lda $cf5f                                   // $4303  
    bne L42fb                                   // $4306  
    rts                                         // $4308  
L4309:
    lda $cf45                                   // $4309  
    cmp #$02                                    // $430c  
    bcc L433b                                   // $430e  
    ldx #$06                                    // $4310  
L4312:
    ldy #$66                                    // $4312  
L4314:
    dey                                         // $4314  
    beq L431a                                   // $4315  
    jmp L4314                                   // $4317  
L431a:
    dex                                         // $431a  
    bne L4312                                   // $431b  
    jsr L4465                                   // $431d  
    lda $cf45                                   // $4320  
    cmp #$02                                    // $4323  
    bne L4330                                   // $4325  
    jsr L48c3                                   // $4327  
    dec $cf44                                   // $432a  
    jmp L4336                                   // $432d  
L4330:
    jsr L4419                                   // $4330  
    inc $cf44                                   // $4333  
L4336:
    lda #$01                                    // $4336  
    sta $cf45                                   // $4338  
L433b:
    rts                                         // $433b  
L433c:
    lda #$07                                    // $433c  
    ldx #$09                                    // $433e  
    ldy #$10                                    // $4340  
    sty SID_V2_CTRL                             // $4342  
    sty SID_V1_CTRL                             // $4345  
    sta SID_V2_FREQ_HI                          // $4348  
    sta SID_V1_FREQ_HI                          // $434b  
    stx SID_V2_AD                               // $434e  
    stx SID_V1_AD                               // $4351  
    lda #$00                                    // $4354  
    sta SID_V2_FREQ_LO                          // $4356  
    sta SID_V1_FREQ_LO                          // $4359  
    sta SID_V2_SR                               // $435c  
    sta SID_V1_SR                               // $435f  
    lda #$11                                    // $4362  
    sta SID_V2_CTRL                             // $4364  
    sta SID_V1_CTRL                             // $4367  
    rts                                         // $436a  
L436b:
    lda $cf45                                   // $436b  
    bne L4373                                   // $436e  
    jmp L43e4                                   // $4370  
L4373:
    jsr L6629                                   // $4373  
    lda $cf62                                   // $4376  
    sta $cf0e                                   // $4379  
    jsr L43e5                                   // $437c  
    lda #$00                                    // $437f  
    sta $fb                                     // $4381  
    lda $cf5e                                   // $4383  
    ldx #$05                                    // $4386  
L4388:
    lsr                                         // $4388  
    ror $fb                                     // $4389  
    dex                                         // $438b  
    bne L4388                                   // $438c  
    sta $fc                                     // $438e  
    lda $cf5f                                   // $4390  
    bne L43bf                                   // $4393  
    lda $cf63                                   // $4395  
    clc                                         // $4398  
    adc $fb                                     // $4399  
    sta $cf63                                   // $439b  
    lda $cf62                                   // $439e  
    adc $fc                                     // $43a1  
    cmp #$08                                    // $43a3  
    bcc L43b6                                   // $43a5  
    sec                                         // $43a7  
    sbc #$08                                    // $43a8  
    ldx $cf45                                   // $43aa  
    cpx #$01                                    // $43ad  
    bne L43b6                                   // $43af  
    ldx #$02                                    // $43b1  
    stx $cf45                                   // $43b3  
L43b6:
    sta $cf62                                   // $43b6  
    jsr L4ce9                                   // $43b9  
    jmp L43e4                                   // $43bc  
L43bf:
    lda $cf63                                   // $43bf  
    sec                                         // $43c2  
    sbc $fb                                     // $43c3  
    sta $cf63                                   // $43c5  
    lda $cf62                                   // $43c8  
    sbc $fc                                     // $43cb  
    bcs L43de                                   // $43cd  
    clc                                         // $43cf  
    adc #$08                                    // $43d0  
    ldx $cf45                                   // $43d2  
    cpx #$01                                    // $43d5  
    bne L43de                                   // $43d7  
    ldx #$03                                    // $43d9  
    stx $cf45                                   // $43db  
L43de:
    sta $cf62                                   // $43de  
    jsr L4d2a                                   // $43e1  
L43e4:
    rts                                         // $43e4  
L43e5:
    lda $cf5f                                   // $43e5  
    eor $cf61                                   // $43e8  
    bne L4402                                   // $43eb  
    lda $cf5e                                   // $43ed  
    clc                                         // $43f0  
    adc $cf60                                   // $43f1  
    cmp $cf64                                   // $43f4  
    bcc L43fc                                   // $43f7  
    lda $cf64                                   // $43f9  
L43fc:
    sta $cf5e                                   // $43fc  
    jmp L4418                                   // $43ff  
L4402:
    lda $cf5e                                   // $4402  
    sec                                         // $4405  
    sbc $cf60                                   // $4406  
    bcs L4415                                   // $4409  
    lda $cf5f                                   // $440b  
    eor #$01                                    // $440e  
    sta $cf5f                                   // $4410  
    lda #$00                                    // $4413  
L4415:
    sta $cf5e                                   // $4415  
L4418:
    rts                                         // $4418  
L4419:
    ldx #$50                                    // $4419  
L441b:
    lda D0401,x                                 // $441b  
    sta D0400,x                                 // $441e  
    lda $d801,x                                 // $4421  
    sta COLOR_RAM,x                             // $4424  
    inx                                         // $4427  
    bne L441b                                   // $4428  
L442a:
    lda D0501,x                                 // $442a  
    sta D0500,x                                 // $442d  
    lda $d901,x                                 // $4430  
    sta $d900,x                                 // $4433  
    inx                                         // $4436  
    bne L442a                                   // $4437  
L4439:
    lda D0601,x                                 // $4439  
    sta D0600,x                                 // $443c  
    lda $da01,x                                 // $443f  
    sta $da00,x                                 // $4442  
    inx                                         // $4445  
    bne L4439                                   // $4446  
L4448:
    lda D0701,x                                 // $4448  
    sta D0700,x                                 // $444b  
    lda $db01,x                                 // $444e  
    sta $db00,x                                 // $4451  
    inx                                         // $4454  
    cpx #$e8                                    // $4455  
    bne L4448                                   // $4457  
    lda #$27                                    // $4459  
    sta L4498+1                                 // $445b  
    sta L449d+1                                 // $445e  
    jsr L4492                                   // $4461  
    rts                                         // $4464  
L4465:
    ldx $cf44                                   // $4465  
    lda $cf45                                   // $4468  
    sec                                         // $446b  
    sbc #$02                                    // $446c  
    eor $cf65                                   // $446e  
    beq L4475                                   // $4471  
    ldx #<D7c27                                 // $4473  
L4475:
    stx $fb                                     // $4475  
    stx $fd                                     // $4477  
    lda #>D7c27                                 // $4479  
    sta $fc                                     // $447b  
    lda #$78                                    // $447d  
    sta $fe                                     // $447f  
    lda #$04                                    // $4481  
    sta L4498+2                                 // $4483  
    sta L4902+2                                 // $4486  
    lda #$d8                                    // $4489  
    sta L449d+2                                 // $448b  
    sta L4907+2                                 // $448e  
    rts                                         // $4491  
L4492:
    ldx #$17                                    // $4492  
    ldy #$50                                    // $4494  
L4496:
    lda ($fb),y                                 // $4496  
L4498:
    sta $ffff,y                                 // $4498  
    lda ($fd),y                                 // $449b  
L449d:
    sta $ffff,y                                 // $449d  
    tya                                         // $44a0  
    clc                                         // $44a1  
    adc #$28                                    // $44a2  
    tay                                         // $44a4  
    bcc L44b1                                   // $44a5  
    inc $fc                                     // $44a7  
    inc $fe                                     // $44a9  
    inc L4498+2                                 // $44ab  
    inc L449d+2                                 // $44ae  
L44b1:
    dex                                         // $44b1  
    bne L4496                                   // $44b2  
    rts                                         // $44b4  
L44b5:
    lda #$01                                    // $44b5  
    sta $cfb8                                   // $44b7  
    sed                                         // $44ba  
    lda $cefb                                   // $44bb  
    sec                                         // $44be  
    sbc $cf47                                   // $44bf  
    lda $cefc                                   // $44c2  
    sbc $cf48                                   // $44c5  
    lda $cefd                                   // $44c8  
    sbc $cf49                                   // $44cb  
    cld                                         // $44ce  
    bcc L44de                                   // $44cf  
    lda $cfb4                                   // $44d1  
    beq L44db                                   // $44d4  
    lda #$1e                                    // $44d6  
    jsr L4664                                   // $44d8  
L44db:
    jmp L451e                                   // $44db  
L44de:
    lda $cf47                                   // $44de  
    sta $cefb                                   // $44e1  
    lda $cf48                                   // $44e4  
    sta $cefc                                   // $44e7  
    lda $cf49                                   // $44ea  
    sta $cefd                                   // $44ed  
    jsr L466d                                   // $44f0  
    lda #$f0                                    // $44f3  
    sta SID_V2_SR                               // $44f5  
    lda #$11                                    // $44f8  
    sta SID_V2_CTRL                             // $44fa  
    lda #$01                                    // $44fd  
    sta $cf5a                                   // $44ff  
    sta $cf75                                   // $4502  
L4505:
    lda $cf5a                                   // $4505  
    bne L4505                                   // $4508  
    lda #$00                                    // $450a  
    sta $cf75                                   // $450c  
    sta $cf7a                                   // $450f  
    sta SID_V2_CTRL                             // $4512  
    clc                                         // $4515  
    jsr L3ba5                                   // $4516  
    lda #$1e                                    // $4519  
    jsr L4664                                   // $451b  
L451e:
    lda #$00                                    // $451e  
    lda $cfb8                                   // $4520  
    rts                                         // $4523  
L4524:
    ldx #$00                                    // $4524  
    ldy #$00                                    // $4526  
    lda $cf87                                   // $4528  
    ora $cf89                                   // $452b  
    beq L4534                                   // $452e  
    ldx #$07                                    // $4530  
    ldy #$02                                    // $4532  
L4534:
    stx $cf3b                                   // $4534  
    sty $cf2d                                   // $4537  
    lda #$00                                    // $453a  
    sta $cf47                                   // $453c  
    sta $cf48                                   // $453f  
    sta $cf49                                   // $4542  
    ldx $cf3b                                   // $4545  
    cpx #$04                                    // $4548  
    bcc L454e                                   // $454a  
    ldx #$04                                    // $454c  
L454e:
    stx $cfaf                                   // $454e  
    lda D4560,x                                 // $4551  
    sta $cf57                                   // $4554  
    jsr L4c8e                                   // $4557  
    lda #$b8                                    // $455a  
    sta $cf6a                                   // $455c  
    rts                                         // $455f  
D4560:
    .byte $07,$08,$08,$09,$09                   // $4560  
L4565:
    lda $cf2d                                   // $4565  
    asl                                         // $4568  
    clc                                         // $4569  
    adc $cf2d                                   // $456a  
    tax                                         // $456d  
    lda D458b,x                                 // $456e  
    sta $cf03                                   // $4571  
    inx                                         // $4574  
    lda D458b,x                                 // $4575  
    sta $cf04                                   // $4578  
    inx                                         // $457b  
    lda D458b,x                                 // $457c  
    sta $cf06                                   // $457f  
    lda #$80                                    // $4582  
    sta $cf02                                   // $4584  
    sta $cf05                                   // $4587  
    rts                                         // $458a  
D458b:
    .byte $36,$00,$d0,$22,$01,$d0,$20,$01,$62,$34,$00,$62  // $458b  
L4597:
    lda #$01                                    // $4597  
    sta $cfb5                                   // $4599  
    sta $cfbf                                   // $459c  
    lda VIC_SPR_ENABLE                          // $459f  
    and #$e1                                    // $45a2  
    sta VIC_SPR_ENABLE                          // $45a4  
    ldx $cf3b                                   // $45a7  
    cpx #$04                                    // $45aa  
    bcc L45b0                                   // $45ac  
    ldx #$04                                    // $45ae  
L45b0:
    stx $cfaf                                   // $45b0  
    lda D4560,x                                 // $45b3  
    sta $cf57                                   // $45b6  
    lda $cf3b                                   // $45b9  
    sec                                         // $45bc  
    sbc #$03                                    // $45bd  
    bcc L45c5                                   // $45bf  
    cmp #$01                                    // $45c1  
    bcs L45ca                                   // $45c3  
L45c5:
    lda #$01                                    // $45c5  
    jmp L45d0                                   // $45c7  
L45ca:
    cmp #$06                                    // $45ca  
    bcc L45d0                                   // $45cc  
    lda #$06                                    // $45ce  
L45d0:
    sta $cfa2                                   // $45d0  
    jsr L4048                                   // $45d3  
    jsr L4565                                   // $45d6  
    jsr L6ff6                                   // $45d9  
    jsr L50a5                                   // $45dc  
    lda $cf79                                   // $45df  
    beq L45fa                                   // $45e2  
    lda #$00                                    // $45e4  
    sta $cf79                                   // $45e6  
    lda $cfa2                                   // $45e9  
    cmp #$01                                    // $45ec  
    beq L45fa                                   // $45ee  
    lda $cf3b                                   // $45f0  
    cmp #$0a                                    // $45f3  
    bcs L45fa                                   // $45f5  
    jsr L51f1                                   // $45f7  
L45fa:
    jsr L5124                                   // $45fa  
    lda VIC_SPR_ENABLE                          // $45fd  
    and #$fe                                    // $4600  
    sta VIC_SPR_ENABLE                          // $4602  
    lda VIC_SPR_BG_COLL                         // $4605  
    lda #$00                                    // $4608  
    sta $cf73                                   // $460a  
    sta $cf55                                   // $460d  
    sta $cf93                                   // $4610  
    jsr L6ec9                                   // $4613  
    lda #$dd                                    // $4616  
    sta D07f9                                   // $4618  
    lda #$03                                    // $461b  
    sta $cf9a                                   // $461d  
    lda #$01                                    // $4620  
    sta $cf74                                   // $4622  
    sta $cfa3                                   // $4625  
    sta $cf53                                   // $4628  
    sta $cf52                                   // $462b  
    sta $cf50                                   // $462e  
    sta $cf51                                   // $4631  
    lda #$00                                    // $4634  
    sta $cf4d                                   // $4636  
    sta $cf4e                                   // $4639  
    lda #$01                                    // $463c  
    sta $cf8d                                   // $463e  
L4641:
    lda #$01                                    // $4641  
    jsr L4664                                   // $4643  
    jsr L6321                                   // $4646  
    clc                                         // $4649  
    jsr L38cf                                   // $464a  
    lda $cf4d                                   // $464d  
    ora $cf4e                                   // $4650  
    beq L4641                                   // $4653  
    lda $cf4d                                   // $4655  
    beq L4660                                   // $4658  
    jsr L4678                                   // $465a  
    jmp L4663                                   // $465d  
L4660:
    jsr L46ec                                   // $4660  
L4663:
    rts                                         // $4663  
L4664:
    sta $cf1a                                   // $4664  
L4667:
    lda $cf1a                                   // $4667  
    bne L4667                                   // $466a  
    rts                                         // $466c  
L466d:
    ldx #$14                                    // $466d  
    lda #$00                                    // $466f  
L4671:
    sta SID_V1_FREQ_LO,x                        // $4671  
    dex                                         // $4674  
    bpl L4671                                   // $4675  
    rts                                         // $4677  
L4678:
    lda $cf87                                   // $4678  
    beq L4685                                   // $467b  
    sec                                         // $467d  
    jsr L6864                                   // $467e  
    sec                                         // $4681  
    jsr L6920                                   // $4682  
L4685:
    jsr L4dcc                                   // $4685  
    lda #$00                                    // $4688  
    sta $cfa3                                   // $468a  
    lda #$0a                                    // $468d  
    jsr L4664                                   // $468f  
    jsr L4a12                                   // $4692  
    jsr L47a5                                   // $4695  
    lda $cf87                                   // $4698  
    beq L46a5                                   // $469b  
    lda #$32                                    // $469d  
    jsr L4664                                   // $469f  
    jmp L46eb                                   // $46a2  
L46a5:
    inc $cf2d                                   // $46a5  
    jsr L63d1                                   // $46a8  
    jsr L6539                                   // $46ab  
    lda $cf2d                                   // $46ae  
    cmp #$04                                    // $46b1  
    bcs L46bb                                   // $46b3  
    jsr L41fc                                   // $46b5  
    jmp L46e8                                   // $46b8  
L46bb:
    jsr L483c                                   // $46bb  
    lda #$00                                    // $46be  
    sta $cf82                                   // $46c0  
    sta $cf7a                                   // $46c3  
    lda #$14                                    // $46c6  
    jsr L4664                                   // $46c8  
    lda #$00                                    // $46cb  
    sta $cf2d                                   // $46cd  
    lda #$00                                    // $46d0  
    sta $cfa9                                   // $46d2  
    lda #$01                                    // $46d5  
    sta $cfb3                                   // $46d7  
    sta $cfa8                                   // $46da  
    sta $cf5c                                   // $46dd  
    sta $cf79                                   // $46e0  
L46e3:
    lda $cfa8                                   // $46e3  
    bne L46e3                                   // $46e6  
L46e8:
    jsr L65a7                                   // $46e8  
L46eb:
    rts                                         // $46eb  
L46ec:
    jsr L6d91                                   // $46ec  
    jsr L466d                                   // $46ef  
    lda #$d0                                    // $46f2  
    sta SID_V2_SR                               // $46f4  
    lda #$15                                    // $46f7  
    sta SID_V2_CTRL                             // $46f9  
    lda #$00                                    // $46fc  
    sta $cf17                                   // $46fe  
    lda #$01                                    // $4701  
    sta $cf18                                   // $4703  
L4706:
    lda $cf18                                   // $4706  
    bne L4706                                   // $4709  
    jsr L466d                                   // $470b  
    lda #$e0                                    // $470e  
    sta SID_V2_SR                               // $4710  
    lda #$11                                    // $4713  
    sta SID_V2_CTRL                             // $4715  
    lda #$01                                    // $4718  
    sta VIC_BG2                                 // $471a  
    lda #$14                                    // $471d  
    jsr L4664                                   // $471f  
    lda VIC_SPR_ENABLE                          // $4722  
    and #$e1                                    // $4725  
    sta VIC_SPR_ENABLE                          // $4727  
    lda $cfb4                                   // $472a  
    bne L4766                                   // $472d  
    lda #$01                                    // $472f  
    sta $cf53                                   // $4731  
    sta $cf51                                   // $4734  
    lda #$1e                                    // $4737  
    sta $cf54                                   // $4739  
L473c:
    lda #$01                                    // $473c  
    jsr L4664                                   // $473e  
    jsr L6321                                   // $4741  
    clc                                         // $4744  
    jsr L38cf                                   // $4745  
    lda $cf09                                   // $4748  
    cmp #$04                                    // $474b  
    bne L473c                                   // $474d  
    lda $cf0a                                   // $474f  
    cmp #$08                                    // $4752  
    bne L473c                                   // $4754  
    lda $cf33                                   // $4756  
    bne L473c                                   // $4759  
    sec                                         // $475b  
    jsr L6864                                   // $475c  
    sec                                         // $475f  
    jsr L6920                                   // $4760  
    jmp L477d                                   // $4763  
L4766:
    lda #$01                                    // $4766  
    sta $cf51                                   // $4768  
L476b:
    clc                                         // $476b  
    jsr L38cf                                   // $476c  
    lda #$01                                    // $476f  
    jsr L4664                                   // $4771  
    lda $cf33                                   // $4774  
    bne L476b                                   // $4777  
    clc                                         // $4779  
    jsr L38cf                                   // $477a  
L477d:
    lda $cf87                                   // $477d  
    bne L47a4                                   // $4780  
    jsr L73f7                                   // $4782  
    jsr L742a                                   // $4785  
    jsr L7535                                   // $4788  
    lda #$00                                    // $478b  
    jsr L755d                                   // $478d  
    ldx #$01                                    // $4790  
    lda $cfb4                                   // $4792  
    beq L4799                                   // $4795  
    ldx #$0f                                    // $4797  
L4799:
    stx VIC_BG2                                 // $4799  
    lda #$14                                    // $479c  
    jsr L5fa7                                   // $479e  
    jsr L47a5                                   // $47a1  
L47a4:
    rts                                         // $47a4  
L47a5:
    jsr L47f1                                   // $47a5  
    jsr L6cfa                                   // $47a8  
    lda #$01                                    // $47ab  
    sta $cf7a                                   // $47ad  
    sta $cfa5                                   // $47b0  
    sta $cf9c                                   // $47b3  
    jsr L466d                                   // $47b6  
    lda #$00                                    // $47b9  
    sta SID_RES_FILT                            // $47bb  
    lda #$d0                                    // $47be  
    sta SID_V3_SR                               // $47c0  
    lda #$11                                    // $47c3  
    sta SID_V3_CTRL                             // $47c5  
L47c8:
    lda $cf9c                                   // $47c8  
    ora $cfa0                                   // $47cb  
    ora $cfa8                                   // $47ce  
    bne L47c8                                   // $47d1  
    lda #$19                                    // $47d3  
    jsr L4664                                   // $47d5  
    lda #$00                                    // $47d8  
    sta $cfa5                                   // $47da  
    sta $cf7a                                   // $47dd  
    jsr L751f                                   // $47e0  
    lda #$00                                    // $47e3  
    jsr L755d                                   // $47e5  
    jsr L466d                                   // $47e8  
    lda #$44                                    // $47eb  
    sta SID_RES_FILT                            // $47ed  
    rts                                         // $47f0  
L47f1:
    ldx #$07                                    // $47f1  
    lda $cf4d                                   // $47f3  
    beq L47fa                                   // $47f6  
    ldx #$0f                                    // $47f8  
L47fa:
    ldy #$07                                    // $47fa  
L47fc:
    lda D4807,x                                 // $47fc  
    sta D2590,y                                 // $47ff  
    dex                                         // $4802  
    dey                                         // $4803  
    bpl L47fc                                   // $4804  
    rts                                         // $4806  
D4807:
    .byte $fc,$86,$c3,$61,$80,$c3,$61,$3f,$fc,$86,$c3,$61,$80,$c3,$61,$3f  // $4807  
L4817:
    lda #$1e                                    // $4817  
    sta $cf54                                   // $4819  
    lda #$01                                    // $481c  
    sta $cf51                                   // $481e  
    sta $cf53                                   // $4821  
    sta $cf15                                   // $4824  
L4827:
    jsr L6321                                   // $4827  
    clc                                         // $482a  
    jsr L38cf                                   // $482b  
    lda #$01                                    // $482e  
    jsr L4664                                   // $4830  
    lda $cf33                                   // $4833  
    ora $cf15                                   // $4836  
    bne L4827                                   // $4839  
    rts                                         // $483b  
L483c:
    lda #$00                                    // $483c  
    sta $cf53                                   // $483e  
    lda #$00                                    // $4841  
    sta $cf65                                   // $4843  
    lda #$02                                    // $4846  
    sta $cf2d                                   // $4848  
L484b:
    lda $cf2d                                   // $484b  
    bne L4853                                   // $484e  
    inc $cf3b                                   // $4850  
L4853:
    jsr L4048                                   // $4853  
    sec                                         // $4856  
    jsr L38cf                                   // $4857  
    jsr L67e1                                   // $485a  
    jsr L413d                                   // $485d  
    jsr L419d                                   // $4860  
    ldx $cf2d                                   // $4863  
    lda #$40                                    // $4866  
    sec                                         // $4868  
    sbc D4d6f,x                                 // $4869  
    inx                                         // $486c  
    clc                                         // $486d  
    adc D4d6f,x                                 // $486e  
    sta $cf95                                   // $4871  
    lda #$00                                    // $4874  
    sta $cf5e                                   // $4876  
    lda #$00                                    // $4879  
    sta $cf5f                                   // $487b  
    lda #$05                                    // $487e  
    sta $cf60                                   // $4880  
    lda #$00                                    // $4883  
    sta $cf61                                   // $4885  
    lda #$80                                    // $4888  
    sta $cf64                                   // $488a  
    lda $cf0e                                   // $488d  
    sta $cf62                                   // $4890  
    lda #$00                                    // $4893  
    sta $cf63                                   // $4895  
    lda #$27                                    // $4898  
    sta $cf44                                   // $489a  
    lda #$01                                    // $489d  
    sta $cf45                                   // $489f  
L48a2:
    jsr L4309                                   // $48a2  
    lda $cf44                                   // $48a5  
    bpl L48a2                                   // $48a8  
    lda #$00                                    // $48aa  
    sta $cf45                                   // $48ac  
    ldx $cf2d                                   // $48af  
    beq L48b7                                   // $48b2  
    jsr L4c8e                                   // $48b4  
L48b7:
    dec $cf2d                                   // $48b7  
    bpl L484b                                   // $48ba  
    inc $cf2d                                   // $48bc  
    jsr L4263                                   // $48bf  
    rts                                         // $48c2  
L48c3:
    lda #$00                                    // $48c3  
    sta L4902+1                                 // $48c5  
    sta L4907+1                                 // $48c8  
    ldy #$50                                    // $48cb  
    sty L48f1+1                                 // $48cd  
    sty L48f7+1                                 // $48d0  
    lda #$51                                    // $48d3  
    sta L48f4+1                                 // $48d5  
    sta L48fa+1                                 // $48d8  
    lda #$04                                    // $48db  
    sta L48f1+2                                 // $48dd  
    sta L48f4+2                                 // $48e0  
    lda #$d8                                    // $48e3  
    sta L48f7+2                                 // $48e5  
    sta L48fa+2                                 // $48e8  
    lda #$17                                    // $48eb  
    sta $ff                                     // $48ed  
L48ef:
    ldx #$26                                    // $48ef  
L48f1:
    lda L044f+1,x                               // $48f1  
L48f4:
    sta L0451,x                                 // $48f4  
L48f7:
    lda $d850,x                                 // $48f7  
L48fa:
    sta $d851,x                                 // $48fa  
    dex                                         // $48fd  
    bpl L48f1                                   // $48fe  
    lda ($fb),y                                 // $4900  
L4902:
    sta $ffff,y                                 // $4902  
    lda ($fd),y                                 // $4905  
L4907:
    sta $ffff,y                                 // $4907  
    tya                                         // $490a  
    clc                                         // $490b  
    adc #$28                                    // $490c  
    tay                                         // $490e  
    sta L48f1+1                                 // $490f  
    sta L48f7+1                                 // $4912  
    bcc L492d                                   // $4915  
    inc L48f1+2                                 // $4917  
    inc L48f4+2                                 // $491a  
    inc L48f7+2                                 // $491d  
    inc L48fa+2                                 // $4920  
    inc $fc                                     // $4923  
    inc $fe                                     // $4925  
    inc L4902+2                                 // $4927  
    inc L4907+2                                 // $492a  
L492d:
    clc                                         // $492d  
    adc #$01                                    // $492e  
    sta L48f4+1                                 // $4930  
    sta L48fa+1                                 // $4933  
    dec $ff                                     // $4936  
    bne L48ef                                   // $4938  
    rts                                         // $493a  
L493b:
    jsr L4048                                   // $493b  
    sec                                         // $493e  
    jsr L38cf                                   // $493f  
    jsr L67e1                                   // $4942  
    jsr L413d                                   // $4945  
    jsr L419d                                   // $4948  
    lda #$08                                    // $494b  
    sta $cfb0                                   // $494d  
    lda #$01                                    // $4950  
    jsr L4664                                   // $4952  
    jsr L768c                                   // $4955  
    lda #$00                                    // $4958  
    sta VIC_SPR_ENABLE                          // $495a  
    sta VIC_SPR_EXPAND_Y                        // $495d  
    sta VIC_SPR_EXPAND_X                        // $4960  
    ldx $cf87                                   // $4963  
    bne L496b                                   // $4966  
    sta VIC_SPR_MULTICOLOR                      // $4968  
L496b:
    lda #$00                                    // $496b  
    sta VIC_SPR1_COL                            // $496d  
    lda #$01                                    // $4970  
    sta VIC_SPR3_COL                            // $4972  
    lda #$00                                    // $4975  
    sta VIC_SPR4_COL                            // $4977  
    lda #$0f                                    // $497a  
    sta VIC_SPR6_COL                            // $497c  
    lda #$00                                    // $497f  
    sta VIC_SPR7_COL                            // $4981  
    lda #$00                                    // $4984  
    sta $cf76                                   // $4986  
    lda #$00                                    // $4989  
    sta $cf53                                   // $498b  
    lda #$1d                                    // $498e  
    sta $cf54                                   // $4990  
    lda #$80                                    // $4993  
    sta $cf35                                   // $4995  
    sta $cf23                                   // $4998  
    lda #$ff                                    // $499b  
    sta $cf36                                   // $499d  
    sta $cf24                                   // $49a0  
    lda #$00                                    // $49a3  
    sta $cf07                                   // $49a5  
    sta $cf08                                   // $49a8  
    sta $cf2b                                   // $49ab  
    sta $cf2c                                   // $49ae  
    sta $cf0b                                   // $49b1  
    sta $cf0c                                   // $49b4  
    lda #$01                                    // $49b7  
    sta $cf53                                   // $49b9  
    lda #$01                                    // $49bc  
    jsr L4664                                   // $49be  
    lda #$00                                    // $49c1  
    sta SID_V2_CTRL                             // $49c3  
    lda VIC_SPR_ENABLE                          // $49c6  
    ora #$c0                                    // $49c9  
    ldx $cf87                                   // $49cb  
    beq L49d2                                   // $49ce  
    ora #$a0                                    // $49d0  
L49d2:
    sta VIC_SPR_ENABLE                          // $49d2  
    lda #$c0                                    // $49d5  
    sta VIC_SPR_PRIORITY                        // $49d7  
    lda #$00                                    // $49da  
    sta VIC_BG1                                 // $49dc  
    lda #$0f                                    // $49df  
    sta VIC_BG2                                 // $49e1  
    jsr L72ff                                   // $49e4  
    jsr L72a3                                   // $49e7  
    jsr L532e                                   // $49ea  
    jsr L40fc                                   // $49ed  
    jsr L6321                                   // $49f0  
    jsr L6321                                   // $49f3  
    lda #$18                                    // $49f6  
    sta $cfb0                                   // $49f8  
    jsr L5f61                                   // $49fb  
    lda #$01                                    // $49fe  
    sta $cfb3                                   // $4a00  
    sta $cf59                                   // $4a03  
    sta $cf5c                                   // $4a06  
    lda #$07                                    // $4a09  
    sta $cfbc                                   // $4a0b  
    jsr L4817                                   // $4a0e  
    rts                                         // $4a11  
L4a12:
    lda #$01                                    // $4a12  
    sta $cfa1                                   // $4a14  
    lda #$02                                    // $4a17  
    sta $cfa4                                   // $4a19  
    lda #$00                                    // $4a1c  
    sta $cf52                                   // $4a1e  
    lda #$01                                    // $4a21  
    sta $cf53                                   // $4a23  
    lda #$0e                                    // $4a26  
    sta $cf57                                   // $4a28  
    lda #$1d                                    // $4a2b  
    sta $cf54                                   // $4a2d  
    jsr L466d                                   // $4a30  
    lda #$e0                                    // $4a33  
    sta SID_V2_SR                               // $4a35  
    lda #$11                                    // $4a38  
    sta SID_V2_CTRL                             // $4a3a  
L4a3d:
    lda #$01                                    // $4a3d  
    jsr L4664                                   // $4a3f  
    jsr L6321                                   // $4a42  
    ldx $cf07                                   // $4a45  
    inx                                         // $4a48  
    lda D4a9c,x                                 // $4a49  
    cmp $cf09                                   // $4a4c  
    bne L4a3d                                   // $4a4f  
    ldx $cf08                                   // $4a51  
    inx                                         // $4a54  
    lda D4a9c,x                                 // $4a55  
    cmp $cf0a                                   // $4a58  
    bne L4a3d                                   // $4a5b  
    lda $cf54                                   // $4a5d  
    cmp #$1e                                    // $4a60  
    bne L4a6d                                   // $4a62  
    dec $cfa4                                   // $4a64  
    beq L4a75                                   // $4a67  
    lda #$1d                                    // $4a69  
    bne L4a6f                                   // $4a6b  
L4a6d:
    lda #$1e                                    // $4a6d  
L4a6f:
    sta $cf54                                   // $4a6f  
    jmp L4a3d                                   // $4a72  
L4a75:
    sec                                         // $4a75  
    jsr L6864                                   // $4a76  
    sec                                         // $4a79  
    jsr L6920                                   // $4a7a  
    jsr L73f7                                   // $4a7d  
    jsr L742a                                   // $4a80  
    jsr L72ff                                   // $4a83  
    jsr L72a3                                   // $4a86  
    jsr L7549                                   // $4a89  
    lda #$00                                    // $4a8c  
    jsr L755d                                   // $4a8e  
    lda #$19                                    // $4a91  
    jsr L4664                                   // $4a93  
    lda #$00                                    // $4a96  
    sta $cfa1                                   // $4a98  
    rts                                         // $4a9b  
D4a9c:
    .byte $08,$04,$00                           // $4a9c  
L4a9f:
    stx $fb                                     // $4a9f  
    sed                                         // $4aa1  
    clc                                         // $4aa2  
    adc $cf47                                   // $4aa3  
    sta $cf47                                   // $4aa6  
    lda $cf48                                   // $4aa9  
    adc $fb                                     // $4aac  
    sta $cf48                                   // $4aae  
    bcc L4ab4                                   // $4ab1  
    nop                                         // $4ab3  
L4ab4:
    lda $cf49                                   // $4ab4  
    adc #$00                                    // $4ab7  
    sta $cf49                                   // $4ab9  
    cld                                         // $4abc  
    lda $cf49                                   // $4abd  
    lsr                                         // $4ac0  
    lsr                                         // $4ac1  
    lsr                                         // $4ac2  
    lsr                                         // $4ac3  
    ldx #$00                                    // $4ac4  
    jsr L4b00                                   // $4ac6  
    lda $cf49                                   // $4ac9  
    and #$0f                                    // $4acc  
    ldx #$08                                    // $4ace  
    jsr L4b00                                   // $4ad0  
    lda $cf48                                   // $4ad3  
    lsr                                         // $4ad6  
    lsr                                         // $4ad7  
    lsr                                         // $4ad8  
    lsr                                         // $4ad9  
    ldx #$10                                    // $4ada  
    jsr L4b00                                   // $4adc  
    lda $cf48                                   // $4adf  
    and #$0f                                    // $4ae2  
    ldx #$18                                    // $4ae4  
    jsr L4b00                                   // $4ae6  
    lda $cf47                                   // $4ae9  
    lsr                                         // $4aec  
    lsr                                         // $4aed  
    lsr                                         // $4aee  
    lsr                                         // $4aef  
    ldx #$20                                    // $4af0  
    jsr L4b00                                   // $4af2  
    lda $cf47                                   // $4af5  
    and #$0f                                    // $4af8  
    ldx #$28                                    // $4afa  
    jsr L4b00                                   // $4afc  
    rts                                         // $4aff  
L4b00:
    asl                                         // $4b00  
    asl                                         // $4b01  
    asl                                         // $4b02  
    tay                                         // $4b03  
    lda #$07                                    // $4b04  
    sta $fb                                     // $4b06  
L4b08:
    lda D4c3e,y                                 // $4b08  
    sta D2730,x                                 // $4b0b  
    iny                                         // $4b0e  
    inx                                         // $4b0f  
    dec $fb                                     // $4b10  
    bpl L4b08                                   // $4b12  
    rts                                         // $4b14  
L4b15:
    lda $cf59                                   // $4b15  
    beq L4b59                                   // $4b18  
    lda $cf5d                                   // $4b1a  
    bne L4b59                                   // $4b1d  
    ldx #$00                                    // $4b1f  
L4b21:
    lda D2731,x                                 // $4b21  
    sta D2730,x                                 // $4b24  
    inx                                         // $4b27  
    cpx #$2f                                    // $4b28  
    bne L4b21                                   // $4b2a  
    lda #$00                                    // $4b2c  
    ldx $cf59                                   // $4b2e  
    dex                                         // $4b31  
    beq L4b38                                   // $4b32  
    dex                                         // $4b34  
    lda D4c3e,x                                 // $4b35  
L4b38:
    sta $fb                                     // $4b38  
    ldx #$07                                    // $4b3a  
L4b3c:
    lda $fb                                     // $4b3c  
    sta D2730,x                                 // $4b3e  
    txa                                         // $4b41  
    clc                                         // $4b42  
    adc #$08                                    // $4b43  
    tax                                         // $4b45  
    cmp #$30                                    // $4b46  
    bcc L4b3c                                   // $4b48  
    inc $cf59                                   // $4b4a  
    lda $cf59                                   // $4b4d  
    cmp #$0a                                    // $4b50  
    bcc L4b59                                   // $4b52  
    lda #$00                                    // $4b54  
    sta $cf59                                   // $4b56  
L4b59:
    rts                                         // $4b59  
L4b5a:
    lda $cf5a                                   // $4b5a  
    beq L4ba1                                   // $4b5d  
    lda $cf5d                                   // $4b5f  
    bne L4ba1                                   // $4b62  
    ldx #$00                                    // $4b64  
L4b66:
    lda D2781,x                                 // $4b66  
    sta D2780,x                                 // $4b69  
    inx                                         // $4b6c  
    cpx #$2f                                    // $4b6d  
    bne L4b66                                   // $4b6f  
    ldy $cf5a                                   // $4b71  
    dey                                         // $4b74  
    sty $fa                                     // $4b75  
    dey                                         // $4b77  
    ldx #$07                                    // $4b78  
L4b7a:
    lda $fa                                     // $4b7a  
    beq L4b81                                   // $4b7c  
    lda D2730,y                                 // $4b7e  
L4b81:
    sta D2780,x                                 // $4b81  
    tya                                         // $4b84  
    clc                                         // $4b85  
    adc #$08                                    // $4b86  
    tay                                         // $4b88  
    txa                                         // $4b89  
    clc                                         // $4b8a  
    adc #$08                                    // $4b8b  
    tax                                         // $4b8d  
    cmp #$30                                    // $4b8e  
    bcc L4b7a                                   // $4b90  
    inc $cf5a                                   // $4b92  
    lda $cf5a                                   // $4b95  
    cmp #$0a                                    // $4b98  
    bcc L4ba1                                   // $4b9a  
    lda #$00                                    // $4b9c  
    sta $cf5a                                   // $4b9e  
L4ba1:
    rts                                         // $4ba1  
L4ba2:
    lda $cf5c                                   // $4ba2  
    beq L4bac                                   // $4ba5  
    lda $cf5d                                   // $4ba7  
    beq L4baf                                   // $4baa  
L4bac:
    jmp L4c3d                                   // $4bac  
L4baf:
    lda $cf5c                                   // $4baf  
    cmp #$01                                    // $4bb2  
    bne L4c04                                   // $4bb4  
    ldx #$07                                    // $4bb6  
    lda #$00                                    // $4bb8  
L4bba:
    sta D27c8,x                                 // $4bba  
    dex                                         // $4bbd  
    bpl L4bba                                   // $4bbe  
    lda $cf3b                                   // $4bc0  
    clc                                         // $4bc3  
    adc #$01                                    // $4bc4  
    ldx #$ff                                    // $4bc6  
L4bc8:
    inx                                         // $4bc8  
    sec                                         // $4bc9  
    sbc #$0a                                    // $4bca  
    bcs L4bc8                                   // $4bcc  
    clc                                         // $4bce  
    adc #$0a                                    // $4bcf  
    sta $fb                                     // $4bd1  
    ldy #$07                                    // $4bd3  
    txa                                         // $4bd5  
    beq L4bec                                   // $4bd6  
    asl                                         // $4bd8  
    asl                                         // $4bd9  
    asl                                         // $4bda  
    ora #$07                                    // $4bdb  
    tax                                         // $4bdd  
    ldy #$07                                    // $4bde  
L4be0:
    lda D4c3e,x                                 // $4be0  
    sta D27c0,y                                 // $4be3  
    dex                                         // $4be6  
    dey                                         // $4be7  
    bpl L4be0                                   // $4be8  
    ldy #$0f                                    // $4bea  
L4bec:
    lda $fb                                     // $4bec  
    asl                                         // $4bee  
    asl                                         // $4bef  
    asl                                         // $4bf0  
    ora #$07                                    // $4bf1  
    tax                                         // $4bf3  
    lda #$07                                    // $4bf4  
    sta $fc                                     // $4bf6  
L4bf8:
    lda D4c3e,x                                 // $4bf8  
    sta D27c0,y                                 // $4bfb  
    dex                                         // $4bfe  
    dey                                         // $4bff  
    dec $fc                                     // $4c00  
    bpl L4bf8                                   // $4c02  
L4c04:
    ldx #$00                                    // $4c04  
L4c06:
    lda D2771,x                                 // $4c06  
    sta D2770,x                                 // $4c09  
    inx                                         // $4c0c  
    cpx #$0f                                    // $4c0d  
    bne L4c06                                   // $4c0f  
    ldy $cf5c                                   // $4c11  
    dey                                         // $4c14  
    sty $fa                                     // $4c15  
    dey                                         // $4c17  
    ldx #$07                                    // $4c18  
    lda $fa                                     // $4c1a  
    beq L4c21                                   // $4c1c  
    lda D27c0,y                                 // $4c1e  
L4c21:
    sta D2770,x                                 // $4c21  
    lda $fa                                     // $4c24  
    beq L4c2b                                   // $4c26  
    lda D27c8,y                                 // $4c28  
L4c2b:
    sta D2778,x                                 // $4c2b  
    inc $cf5c                                   // $4c2e  
    lda $cf5c                                   // $4c31  
    cmp #$0a                                    // $4c34  
    bcc L4c3d                                   // $4c36  
    lda #$00                                    // $4c38  
    sta $cf5c                                   // $4c3a  
L4c3d:
    rts                                         // $4c3d  
D4c3e:
    .byte $3c,$66,$66,$66,$66,$66,$66,$3c,$18,$18,$78,$18,$18,$18,$18,$7e  // $4c3e  
    .byte $3c,$66,$66,$0c,$18,$30,$60,$7e,$7e,$06,$0c,$1c,$06,$06,$66,$3c  // $4c4e  
    .byte $60,$60,$60,$6c,$6c,$7e,$0c,$0c,$7e,$60,$60,$7c,$06,$06,$66,$3c  // $4c5e  
    .byte $3c,$66,$60,$7c,$66,$66,$66,$3c,$7e,$66,$06,$0c,$18,$18,$18,$18  // $4c6e  
    .byte $3c,$66,$66,$3c,$66,$66,$66,$3c,$3c,$66,$66,$66,$3e,$06,$66,$3c  // $4c7e  
L4c8e:
    ldx $cf2d                                   // $4c8e  
    lda D4d6f,x                                 // $4c91  
    sta $cf67                                   // $4c94  
    lda D4d73,x                                 // $4c97  
    sta $cf69                                   // $4c9a  
    lda #$00                                    // $4c9d  
    sta $cf68                                   // $4c9f  
    lda #$04                                    // $4ca2  
    sta $cf0e                                   // $4ca4  
    rts                                         // $4ca7  
L4ca8:
    lda $cf67                                   // $4ca8  
    clc                                         // $4cab  
    adc $cf37                                   // $4cac  
    sec                                         // $4caf  
    sbc #$04                                    // $4cb0  
    sta $cfab                                   // $4cb2  
    sta VIC_SPR7_X                              // $4cb5  
    sta VIC_SPR6_X                              // $4cb8  
    lda $cf69                                   // $4cbb  
    clc                                         // $4cbe  
    adc $cf38                                   // $4cbf  
    sec                                         // $4cc2  
    sbc #$04                                    // $4cc3  
    sta $cfac                                   // $4cc5  
    sta VIC_SPR7_Y                              // $4cc8  
    sta VIC_SPR6_Y                              // $4ccb  
    lda VIC_SPR_X_MSB                           // $4cce  
    and #$3f                                    // $4cd1  
    ldx $cf68                                   // $4cd3  
    beq L4cda                                   // $4cd6  
    ora #$c0                                    // $4cd8  
L4cda:
    sta VIC_SPR_X_MSB                           // $4cda  
    lda $cf6a                                   // $4cdd  
    sta D07ff                                   // $4ce0  
    ldx #$de                                    // $4ce3  
    stx D07fe                                   // $4ce5  
    rts                                         // $4ce8  
L4ce9:
    lda $cf62                                   // $4ce9  
    sec                                         // $4cec  
    sbc $cf0e                                   // $4ced  
    bcs L4cf4                                   // $4cf0  
    adc #$08                                    // $4cf2  
L4cf4:
    clc                                         // $4cf4  
    adc $cf67                                   // $4cf5  
    sta $cf67                                   // $4cf8  
    bcc L4d00                                   // $4cfb  
    inc $cf68                                   // $4cfd  
L4d00:
    lda $cf68                                   // $4d00  
    cmp #$01                                    // $4d03  
    bne L4d29                                   // $4d05  
    lda $cf67                                   // $4d07  
    cmp #$48                                    // $4d0a  
    bcc L4d29                                   // $4d0c  
    lda $cf67                                   // $4d0e  
    sec                                         // $4d11  
    sbc $cf95                                   // $4d12  
    sta $cf67                                   // $4d15  
    lda $cf68                                   // $4d18  
    sbc #$01                                    // $4d1b  
    sta $cf68                                   // $4d1d  
    ldx $cf2d                                   // $4d20  
    lda D4d73,x                                 // $4d23  
    sta $cf69                                   // $4d26  
L4d29:
    rts                                         // $4d29  
L4d2a:
    lda $cf0e                                   // $4d2a  
    sec                                         // $4d2d  
    sbc $cf62                                   // $4d2e  
    bcs L4d35                                   // $4d31  
    adc #$08                                    // $4d33  
L4d35:
    sta $ff                                     // $4d35  
    lda $cf67                                   // $4d37  
    sec                                         // $4d3a  
    sbc $ff                                     // $4d3b  
    sta $cf67                                   // $4d3d  
    bcs L4d45                                   // $4d40  
    dec $cf68                                   // $4d42  
L4d45:
    lda $cf68                                   // $4d45  
    bmi L4d53                                   // $4d48  
    bne L4d6e                                   // $4d4a  
    lda $cf67                                   // $4d4c  
    cmp #$10                                    // $4d4f  
    bcs L4d6e                                   // $4d51  
L4d53:
    lda $cf67                                   // $4d53  
    clc                                         // $4d56  
    adc $cf95                                   // $4d57  
    sta $cf67                                   // $4d5a  
    lda $cf68                                   // $4d5d  
    adc #$01                                    // $4d60  
    sta $cf68                                   // $4d62  
    ldx $cf2d                                   // $4d65  
    lda D4d73,x                                 // $4d68  
    sta $cf69                                   // $4d6b  
L4d6e:
    rts                                         // $4d6e  
D4d6f:
    .byte $9c,$dc,$f4,$dc                       // $4d6f  
D4d73:
    .byte $78,$7f,$b0,$98                       // $4d73  
L4d77:
    lda $cf00                                   // $4d77  
    ldx $cfab                                   // $4d7a  
    ldy $cf03                                   // $4d7d  
    jsr L4d96                                   // $4d80  
    sta $cf00                                   // $4d83  
    lda $cf01                                   // $4d86  
    ldx $cfac                                   // $4d89  
    ldy $cf06                                   // $4d8c  
    jsr L4d96                                   // $4d8f  
    sta $cf01                                   // $4d92  
    rts                                         // $4d95  
L4d96:
    sta $fa                                     // $4d96  
    sty $ff                                     // $4d98  
    txa                                         // $4d9a  
    sec                                         // $4d9b  
    sbc $ff                                     // $4d9c  
    sta $ff                                     // $4d9e  
    lda $fa                                     // $4da0  
    bpl L4da9                                   // $4da2  
    eor #$ff                                    // $4da4  
    clc                                         // $4da6  
    adc #$01                                    // $4da7  
L4da9:
    tax                                         // $4da9  
    ldy #$e6                                    // $4daa  
    jsr L3cf7                                   // $4dac  
    tya                                         // $4daf  
    ldx $fa                                     // $4db0  
    bpl L4db9                                   // $4db2  
    eor #$ff                                    // $4db4  
    clc                                         // $4db6  
    adc #$01                                    // $4db7  
L4db9:
    sta $fa                                     // $4db9  
    clv                                         // $4dbb  
    lda $fa                                     // $4dbc  
    clc                                         // $4dbe  
    adc $ff                                     // $4dbf  
    bvc L4dcb                                   // $4dc1  
    bmi L4dc9                                   // $4dc3  
    lda #$80                                    // $4dc5  
    bne L4dcb                                   // $4dc7  
L4dc9:
    lda #$7f                                    // $4dc9  
L4dcb:
    rts                                         // $4dcb  
L4dcc:
    jsr L466d                                   // $4dcc  
    lda VIC_SPR_ENABLE                          // $4dcf  
    and #$e9                                    // $4dd2  
    sta VIC_SPR_ENABLE                          // $4dd4  
    ldx #$14                                    // $4dd7  
    stx $cf6d                                   // $4dd9  
    ldx #$0f                                    // $4ddc  
    stx $cf6e                                   // $4dde  
L4de1:
    lda #$01                                    // $4de1  
    jsr L4664                                   // $4de3  
    clc                                         // $4de6  
    jsr L38cf                                   // $4de7  
    jsr L4d77                                   // $4dea  
    lda $cf6e                                   // $4ded  
    bne L4df8                                   // $4df0  
    jsr L4e25                                   // $4df2  
    jmp L4e00                                   // $4df5  
L4df8:
    dec $cf6e                                   // $4df8  
    bne L4e00                                   // $4dfb  
    jsr L4e5e                                   // $4dfd  
L4e00:
    dec $cf6d                                   // $4e00  
    bne L4de1                                   // $4e03  
    ldx #$0c                                    // $4e05  
    stx $cf6d                                   // $4e07  
    dec D07fb                                   // $4e0a  
    lda D07fb                                   // $4e0d  
    cmp #$a0                                    // $4e10  
    bne L4de1                                   // $4e12  
    lda #$00                                    // $4e14  
    sta $cf00                                   // $4e16  
    sta $cf01                                   // $4e19  
    lda VIC_SPR_ENABLE                          // $4e1c  
    and #$f7                                    // $4e1f  
    sta VIC_SPR_ENABLE                          // $4e21  
    rts                                         // $4e24  
L4e25:
    ldx #$fa                                    // $4e25  
    ldy $cf71                                   // $4e27  
    jsr L3cf7                                   // $4e2a  
    sty $ff                                     // $4e2d  
    ldx #$fa                                    // $4e2f  
    ldy $cf72                                   // $4e31  
    jsr L3cf7                                   // $4e34  
    txa                                         // $4e37  
    clc                                         // $4e38  
    adc $ff                                     // $4e39  
    sta $cf71                                   // $4e3b  
    tya                                         // $4e3e  
    adc #$00                                    // $4e3f  
    sta $cf72                                   // $4e41  
    lda $cf6f                                   // $4e44  
    sec                                         // $4e47  
    sbc $cf71                                   // $4e48  
    sta $cf6f                                   // $4e4b  
    sta SID_V2_FREQ_LO                          // $4e4e  
    lda $cf70                                   // $4e51  
    sbc $cf72                                   // $4e54  
    sta $cf70                                   // $4e57  
    sta SID_V2_FREQ_HI                          // $4e5a  
    rts                                         // $4e5d  
L4e5e:
    lda #$00                                    // $4e5e  
    sta $cf71                                   // $4e60  
    sta $cf6f                                   // $4e63  
    lda #$e6                                    // $4e66  
    sta $cf70                                   // $4e68  
    lda #$05                                    // $4e6b  
    sta $cf72                                   // $4e6d  
    lda $cfa2                                   // $4e70  
    lsr                                         // $4e73  
    lsr                                         // $4e74  
    clc                                         // $4e75  
    adc #$09                                    // $4e76  
    cmp #$0f                                    // $4e78  
    bcc L4e7e                                   // $4e7a  
    lda #$0f                                    // $4e7c  
L4e7e:
    clc                                         // $4e7e  
    adc #$a0                                    // $4e7f  
    sta SID_V2_AD                               // $4e81  
    lda #$11                                    // $4e84  
    sta SID_V2_CTRL                             // $4e86  
    rts                                         // $4e89  
L4e8a:
    lda $cf06                                   // $4e8a  
    sec                                         // $4e8d  
    sbc $cf69                                   // $4e8e  
    bcs L4e98                                   // $4e91  
    eor #$ff                                    // $4e93  
    clc                                         // $4e95  
    adc #$01                                    // $4e96  
L4e98:
    sta $ff                                     // $4e98  
    ldy #$00                                    // $4e9a  
    lda D4ed7,y                                 // $4e9c  
    cmp $ff                                     // $4e9f  
    bcc L4ed5                                   // $4ea1  
    lda $cf03                                   // $4ea3  
    sec                                         // $4ea6  
    sbc $cf67                                   // $4ea7  
    sta $fb                                     // $4eaa  
    lda $cf04                                   // $4eac  
    sbc $cf68                                   // $4eaf  
    sta $fc                                     // $4eb2  
    bcs L4ec7                                   // $4eb4  
    lda $fb                                     // $4eb6  
    eor #$ff                                    // $4eb8  
    clc                                         // $4eba  
    adc #$01                                    // $4ebb  
    sta $fb                                     // $4ebd  
    lda $fc                                     // $4ebf  
    eor #$ff                                    // $4ec1  
    adc #$00                                    // $4ec3  
    sta $fc                                     // $4ec5  
L4ec7:
    lda $fc                                     // $4ec7  
    bne L4ed5                                   // $4ec9  
    ldy $ff                                     // $4ecb  
    lda D4ed7,y                                 // $4ecd  
    cmp $fb                                     // $4ed0  
    jmp L4ed6                                   // $4ed2  
L4ed5:
    clc                                         // $4ed5  
L4ed6:
    rts                                         // $4ed6  
D4ed7:
    .byte $0e,$0e,$0e,$0e,$0d,$0d,$0d,$0c,$0c,$0b,$0a,$09,$08,$06,$03  // $4ed7  
L4ee6:
    ldx #$07                                    // $4ee6  
    lda $cf35                                   // $4ee8  
    sec                                         // $4eeb  
    sbc #$80                                    // $4eec  
    bpl L4ef2                                   // $4eee  
    eor #$ff                                    // $4ef0  
L4ef2:
    sta $fb                                     // $4ef2  
    lda $cf36                                   // $4ef4  
    sec                                         // $4ef7  
    sbc #$80                                    // $4ef8  
    bpl L4efe                                   // $4efa  
    eor #$ff                                    // $4efc  
L4efe:
    sta $fc                                     // $4efe  
    lda $fc                                     // $4f00  
    sec                                         // $4f02  
    sbc $fb                                     // $4f03  
    bcs L4f0c                                   // $4f05  
    eor #$ff                                    // $4f07  
    clc                                         // $4f09  
    adc #$01                                    // $4f0a  
L4f0c:
    clc                                         // $4f0c  
    adc $fb                                     // $4f0d  
    bcs L4f1b                                   // $4f0f  
    adc $fc                                     // $4f11  
    bcs L4f1b                                   // $4f13  
    lsr                                         // $4f15  
    lsr                                         // $4f16  
    lsr                                         // $4f17  
    lsr                                         // $4f18  
    lsr                                         // $4f19  
    tax                                         // $4f1a  
L4f1b:
    inx                                         // $4f1b  
    cpx #$02                                    // $4f1c  
    bcs L4f22                                   // $4f1e  
    ldx #$02                                    // $4f20  
L4f22:
    stx $ff                                     // $4f22  
    lsr $fb                                     // $4f24  
    lsr $fc                                     // $4f26  
    ldx $cfa2                                   // $4f28  
    cpx #$02                                    // $4f2b  
    bcs L4f33                                   // $4f2d  
    lsr $fb                                     // $4f2f  
    lsr $fc                                     // $4f31  
L4f33:
    lda #$7f                                    // $4f33  
    sec                                         // $4f35  
    sbc $fb                                     // $4f36  
    sta $cf3c                                   // $4f38  
    lda #$7f                                    // $4f3b  
    sec                                         // $4f3d  
    sbc $fc                                     // $4f3e  
    sta $cf3d                                   // $4f40  
    ldx #$00                                    // $4f43  
    lda $cf35                                   // $4f45  
    bpl L4f4b                                   // $4f48  
    inx                                         // $4f4a  
L4f4b:
    stx $cf42                                   // $4f4b  
    ldx #$00                                    // $4f4e  
    lda $cf36                                   // $4f50  
    bpl L4f56                                   // $4f53  
    inx                                         // $4f55  
L4f56:
    stx $cf43                                   // $4f56  
    rts                                         // $4f59  
L4f5a:
    ldx $cf35                                   // $4f5a  
    ldy $cf36                                   // $4f5d  
    cpx #$80                                    // $4f60  
    bne L4f6f                                   // $4f62  
    lda #$00                                    // $4f64  
    cpy #$00                                    // $4f66  
    bpl L4f6c                                   // $4f68  
    lda #$01                                    // $4f6a  
L4f6c:
    jmp L4f94                                   // $4f6c  
L4f6f:
    cpy #$80                                    // $4f6f  
    bne L4f7e                                   // $4f71  
    lda #$02                                    // $4f73  
    cpx #$00                                    // $4f75  
    bpl L4f7b                                   // $4f77  
    lda #$03                                    // $4f79  
L4f7b:
    jmp L4f94                                   // $4f7b  
L4f7e:
    txa                                         // $4f7e  
    bpl L4f8c                                   // $4f7f  
    lda #$06                                    // $4f81  
    cpy #$00                                    // $4f83  
    bpl L4f89                                   // $4f85  
    lda #$05                                    // $4f87  
L4f89:
    jmp L4f94                                   // $4f89  
L4f8c:
    lda #$04                                    // $4f8c  
    cpy #$00                                    // $4f8e  
    bpl L4f94                                   // $4f90  
    lda #$07                                    // $4f92  
L4f94:
    tax                                         // $4f94  
    ldy $ff                                     // $4f95  
    and #$01                                    // $4f97  
    beq L4f9d                                   // $4f99  
    ldy #$02                                    // $4f9b  
L4f9d:
    sty $fa                                     // $4f9d  
    cpx #$02                                    // $4f9f  
    bcs L4fb5                                   // $4fa1  
    lda $ff                                     // $4fa3  
    jsr L5022                                   // $4fa5  
    lda #$0b                                    // $4fa8  
    sec                                         // $4faa  
    sbc $fa                                     // $4fab  
    tay                                         // $4fad  
    ldx #$09                                    // $4fae  
    lda #$a0                                    // $4fb0  
    jmp L4ff8                                   // $4fb2  
L4fb5:
    cpx #$04                                    // $4fb5  
    bcs L4fcb                                   // $4fb7  
    lda $ff                                     // $4fb9  
    jsr L5033                                   // $4fbb  
    lda #$0d                                    // $4fbe  
    sec                                         // $4fc0  
    sbc $fa                                     // $4fc1  
    tax                                         // $4fc3  
    ldy #$06                                    // $4fc4  
    lda #$a5                                    // $4fc6  
    jmp L4ff8                                   // $4fc8  
L4fcb:
    cpx #$06                                    // $4fcb  
    bcs L4fe5                                   // $4fcd  
    lda $ff                                     // $4fcf  
    jsr L5044                                   // $4fd1  
    lda #$0d                                    // $4fd4  
    sec                                         // $4fd6  
    sbc $fa                                     // $4fd7  
    tax                                         // $4fd9  
    lda #$0b                                    // $4fda  
    sec                                         // $4fdc  
    sbc $fa                                     // $4fdd  
    tay                                         // $4fdf  
    lda #$a5                                    // $4fe0  
    jmp L4ff8                                   // $4fe2  
L4fe5:
    lda $ff                                     // $4fe5  
    jsr L506e                                   // $4fe7  
    lda #$03                                    // $4fea  
    clc                                         // $4fec  
    adc $fa                                     // $4fed  
    tax                                         // $4fef  
    lda #$0b                                    // $4ff0  
    sec                                         // $4ff2  
    sbc $fa                                     // $4ff3  
    tay                                         // $4ff5  
    lda #$a5                                    // $4ff6  
L4ff8:
    sta D07f9                                   // $4ff8  
    txa                                         // $4ffb  
    clc                                         // $4ffc  
    adc VIC_SPR1_X                              // $4ffd  
    sta VIC_SPR0_X                              // $5000  
    lda VIC_SPR_X_MSB                           // $5003  
    bcs L5013                                   // $5006  
    and #$fe                                    // $5008  
    tax                                         // $500a  
    lda VIC_SPR_X_MSB                           // $500b  
    and #$02                                    // $500e  
    beq L5016                                   // $5010  
    txa                                         // $5012  
L5013:
    ora #$01                                    // $5013  
    tax                                         // $5015  
L5016:
    stx VIC_SPR_X_MSB                           // $5016  
    tya                                         // $5019  
    clc                                         // $501a  
    adc VIC_SPR1_Y                              // $501b  
    sta VIC_SPR0_Y                              // $501e  
    rts                                         // $5021  
L5022:
    tay                                         // $5022  
    beq L5032                                   // $5023  
    ldx #$00                                    // $5025  
    lda #$38                                    // $5027  
L5029:
    sta D31c0,x                                 // $5029  
    inx                                         // $502c  
    inx                                         // $502d  
    inx                                         // $502e  
    dey                                         // $502f  
    bne L5029                                   // $5030  
L5032:
    rts                                         // $5032  
L5033:
    tay                                         // $5033  
    beq L5043                                   // $5034  
    lda #$00                                    // $5036  
L5038:
    sec                                         // $5038  
    ror                                         // $5039  
    dey                                         // $503a  
    bne L5038                                   // $503b  
    sta D31c9                                   // $503d  
    sta D31cc                                   // $5040  
L5043:
    rts                                         // $5043  
L5044:
    tay                                         // $5044  
    beq L506d                                   // $5045  
    ldx #$00                                    // $5047  
    dey                                         // $5049  
    bne L5050                                   // $504a  
    lda #$80                                    // $504c  
    bne L506a                                   // $504e  
L5050:
    lda #$c0                                    // $5050  
    sta D31c0,x                                 // $5052  
    sta $fb                                     // $5055  
    lda #$e0                                    // $5057  
L5059:
    inx                                         // $5059  
    inx                                         // $505a  
    inx                                         // $505b  
    dey                                         // $505c  
    beq L5068                                   // $505d  
    sta D31c0,x                                 // $505f  
    lsr                                         // $5062  
    lsr $fb                                     // $5063  
    jmp L5059                                   // $5065  
L5068:
    lda $fb                                     // $5068  
L506a:
    sta D31c0,x                                 // $506a  
L506d:
    rts                                         // $506d  
L506e:
    tay                                         // $506e  
    beq L5097                                   // $506f  
    ldx #$00                                    // $5071  
    dey                                         // $5073  
    bne L507a                                   // $5074  
    lda #$01                                    // $5076  
    bne L5094                                   // $5078  
L507a:
    lda #$03                                    // $507a  
    sta D31c0,x                                 // $507c  
    sta $fb                                     // $507f  
    lda #$07                                    // $5081  
L5083:
    inx                                         // $5083  
    inx                                         // $5084  
    inx                                         // $5085  
    dey                                         // $5086  
    beq L5092                                   // $5087  
    sta D31c0,x                                 // $5089  
    asl                                         // $508c  
    asl $fb                                     // $508d  
    jmp L5083                                   // $508f  
L5092:
    lda $fb                                     // $5092  
L5094:
    sta D31c0,x                                 // $5094  
L5097:
    rts                                         // $5097  
L5098:
    ldx #$15                                    // $5098  
    lda #$00                                    // $509a  
L509c:
    sta D31c0,x                                 // $509c  
    dex                                         // $509f  
    dex                                         // $50a0  
    dex                                         // $50a1  
    bpl L509c                                   // $50a2  
    rts                                         // $50a4  
L50a5:
    lda #$01                                    // $50a5  
    jsr L4664                                   // $50a7  
    lda VIC_SPR_ENABLE                          // $50aa  
    and #$e0                                    // $50ad  
    sta VIC_SPR_ENABLE                          // $50af  
    lda #$dc                                    // $50b2  
    sta D07fa                                   // $50b4  
    lda #$0c                                    // $50b7  
    sta VIC_SPR2_COL                            // $50b9  
    lda #$00                                    // $50bc  
    sta VIC_SPR1_COL                            // $50be  
    lda VIC_SPR_PRIORITY                        // $50c1  
    ora #$14                                    // $50c4  
    sta VIC_SPR_PRIORITY                        // $50c6  
    lda VIC_SPR_X_MSB                           // $50c9  
    and #$fe                                    // $50cc  
    sta VIC_SPR_X_MSB                           // $50ce  
    lda #$c7                                    // $50d1  
    sta D07f8                                   // $50d3  
    lda #$05                                    // $50d6  
    sta VIC_SPR0_COL                            // $50d8  
    lda #$00                                    // $50db  
    sta $cf73                                   // $50dd  
    sta $cf74                                   // $50e0  
    sta $cf53                                   // $50e3  
    sta $cf50                                   // $50e6  
    sta $cf51                                   // $50e9  
    sta $cf52                                   // $50ec  
    jsr L4ee6                                   // $50ef  
    jsr L3dbe                                   // $50f2  
    lda VIC_SPR_ENABLE                          // $50f5  
    and #$fd                                    // $50f8  
    sta VIC_SPR_ENABLE                          // $50fa  
    jsr L4f5a                                   // $50fd  
    jsr L5098                                   // $5100  
    jsr L3d12                                   // $5103  
    jsr L1647                                   // $5106  
    jsr L6d91                                   // $5109  
    lda #$02                                    // $510c  
    jsr L4664                                   // $510e  
    lda VIC_SPR_ENABLE                          // $5111  
    ora #$1f                                    // $5114  
    sta VIC_SPR_ENABLE                          // $5116  
    rts                                         // $5119  
L511a:
    jsr L4ee6                                   // $511a  
    jsr L5098                                   // $511d  
    jsr L4f5a                                   // $5120  
    rts                                         // $5123  
L5124:
    jsr L51ab                                   // $5124  
    lda #$01                                    // $5127  
    sta $cf75                                   // $5129  
    lda #$0f                                    // $512c  
    jsr L4664                                   // $512e  
    lda #$00                                    // $5131  
    sta $ff                                     // $5133  
L5135:
    lda #$03                                    // $5135  
    jsr L4664                                   // $5137  
    jsr L5098                                   // $513a  
    jsr L4f5a                                   // $513d  
    inc $ff                                     // $5140  
    lda $ff                                     // $5142  
    cmp #$09                                    // $5144  
    bcc L5135                                   // $5146  
    lda #$00                                    // $5148  
    sta $cf75                                   // $514a  
    sta SID_V2_FREQ_HI                          // $514d  
    sec                                         // $5150  
    jsr L3ba5                                   // $5151  
    lda #$01                                    // $5154  
    sta $cf53                                   // $5156  
    sta $cf52                                   // $5159  
    sta $cf73                                   // $515c  
L515f:
    lda #$01                                    // $515f  
    jsr L4664                                   // $5161  
    jsr L6321                                   // $5164  
    lda $cf15                                   // $5167  
    bne L515f                                   // $516a  
    lda $cf54                                   // $516c  
    and #$10                                    // $516f  
    bne L515f                                   // $5171  
    lda #$00                                    // $5173  
    sta $cf73                                   // $5175  
    sta $cf53                                   // $5178  
    sta $cf52                                   // $517b  
    jsr L51ab                                   // $517e  
    lda #$01                                    // $5181  
    sta $cf75                                   // $5183  
    lda #$08                                    // $5186  
    sta $ff                                     // $5188  
L518a:
    lda #$03                                    // $518a  
    jsr L4664                                   // $518c  
    jsr L5098                                   // $518f  
    jsr L4f5a                                   // $5192  
    dec $ff                                     // $5195  
    bpl L518a                                   // $5197  
    lda #$0f                                    // $5199  
    jsr L4664                                   // $519b  
    lda #$00                                    // $519e  
    sta $cf75                                   // $51a0  
    sta SID_V2_CTRL                             // $51a3  
    clc                                         // $51a6  
    jsr L3ba5                                   // $51a7  
    rts                                         // $51aa  
L51ab:
    lda #$00                                    // $51ab  
    sta SID_V2_CTRL                             // $51ad  
    sta SID_V2_FREQ_HI                          // $51b0  
    sta SID_V2_FREQ_LO                          // $51b3  
    sta SID_V2_AD                               // $51b6  
    lda #$f0                                    // $51b9  
    sta SID_V2_SR                               // $51bb  
    lda #$11                                    // $51be  
    sta SID_V2_CTRL                             // $51c0  
    rts                                         // $51c3  
L51c4:
    ldx $cf75                                   // $51c4  
    beq L51f0                                   // $51c7  
    dex                                         // $51c9  
    bne L51e1                                   // $51ca  
    ldx #$03                                    // $51cc  
    lda #$0f                                    // $51ce  
    ldy $cf5a                                   // $51d0  
    bne L51de                                   // $51d3  
    lda #$08                                    // $51d5  
    ldy $cf84                                   // $51d7  
    beq L51de                                   // $51da  
    lda #$09                                    // $51dc  
L51de:
    sta SID_V2_FREQ_HI                          // $51de  
L51e1:
    stx $cf75                                   // $51e1  
    cpx #$01                                    // $51e4  
    bne L51f0                                   // $51e6  
    lda #$00                                    // $51e8  
    sta SID_V2_FREQ_HI                          // $51ea  
    sta SID_V2_FREQ_LO                          // $51ed  
L51f0:
    rts                                         // $51f0  
L51f1:
    jsr L466d                                   // $51f1  
    lda VIC_SPR_ENABLE                          // $51f4  
    and #$f9                                    // $51f7  
    sta VIC_SPR_ENABLE                          // $51f9  
    lda D07fb                                   // $51fc  
    sta $cf30                                   // $51ff  
    sec                                         // $5202  
    sbc #$02                                    // $5203  
    sta D07fb                                   // $5205  
    sta D07fc                                   // $5208  
    lda #$14                                    // $520b  
    jsr L4664                                   // $520d  
    ldx #$00                                    // $5210  
    stx $cfae                                   // $5212  
    stx $cfad                                   // $5215  
    lda $cf30                                   // $5218  
    sta $fe                                     // $521b  
    lda #$00                                    // $521d  
    lsr $fe                                     // $521f  
    ror                                         // $5221  
    lsr $fe                                     // $5222  
    ror                                         // $5224  
    sta $fd                                     // $5225  
    sec                                         // $5227  
    sbc #$80                                    // $5228  
    sta $fb                                     // $522a  
    lda $fe                                     // $522c  
    sbc #$00                                    // $522e  
    sta $fc                                     // $5230  
    lda #$c8                                    // $5232  
    sta D07fb                                   // $5234  
    sta D07fc                                   // $5237  
    lda #$01                                    // $523a  
    sta $cf7a                                   // $523c  
    lda #$80                                    // $523f  
    sta SID_V3_CTRL                             // $5241  
    lda #$ff                                    // $5244  
    sta SID_V3_FREQ_HI                          // $5246  
    lda #$00                                    // $5249  
    sta $fa                                     // $524b  
    lda #$00                                    // $524d  
    sta $cf31                                   // $524f  
L5252:
    dec $fa                                     // $5252  
L5254:
    ldy #$3e                                    // $5254  
L5256:
    lda ($fb),y                                 // $5256  
    eor ($fd),y                                 // $5258  
    sta $ff                                     // $525a  
    beq L5276                                   // $525c  
    ldx #$08                                    // $525e  
L5260:
    lda $ff                                     // $5260  
    rol                                         // $5262  
    bcc L5271                                   // $5263  
    tya                                         // $5265  
    ldy #$14                                    // $5266  
L5268:
    dey                                         // $5268  
    bne L5268                                   // $5269  
    tay                                         // $526b  
    lda SID_OSC3                                // $526c  
    cmp $fa                                     // $526f  
L5271:
    rol $ff                                     // $5271  
    dex                                         // $5273  
    bne L5260                                   // $5274  
L5276:
    lda ($fb),y                                 // $5276  
    ora $ff                                     // $5278  
    sta D3200,y                                 // $527a  
    dey                                         // $527d  
    bpl L5256                                   // $527e  
    lda $fa                                     // $5280  
    bne L5292                                   // $5282  
    lda $cf30                                   // $5284  
    sta D07fb                                   // $5287  
    sta D07fc                                   // $528a  
    lda #$00                                    // $528d  
    sta $cf7a                                   // $528f  
L5292:
    jsr L7001                                   // $5292  
    bcs L52a5                                   // $5295  
    dec $cf31                                   // $5297  
    bpl L5254                                   // $529a  
    lda #$01                                    // $529c  
    sta $cf31                                   // $529e  
    lda $fa                                     // $52a1  
    bne L5252                                   // $52a3  
L52a5:
    lda VIC_SPR_ENABLE                          // $52a5  
    ora #$06                                    // $52a8  
    sta VIC_SPR_ENABLE                          // $52aa  
    lda #$01                                    // $52ad  
    sta VIC_SPR3_COL                            // $52af  
    lda #$14                                    // $52b2  
    jsr L4664                                   // $52b4  
    rts                                         // $52b7  
L52b8:
    ldy #$07                                    // $52b8  
L52ba:
    lda D2128,y                                 // $52ba  
    sta $fa                                     // $52bd  
    lsr                                         // $52bf  
    ora $fa                                     // $52c0  
    eor #$ff                                    // $52c2  
    tax                                         // $52c4  
    and D2050,y                                 // $52c5  
    ora $fa                                     // $52c8  
    sta D2420,y                                 // $52ca  
    txa                                         // $52cd  
    and D2070,y                                 // $52ce  
    ora $fa                                     // $52d1  
    sta D2428,y                                 // $52d3  
    lda D2138,y                                 // $52d6  
    sta $fa                                     // $52d9  
    lsr                                         // $52db  
    ora $fa                                     // $52dc  
    eor #$ff                                    // $52de  
    tax                                         // $52e0  
    and D2070,y                                 // $52e1  
    ora $fa                                     // $52e4  
    sta D2430,y                                 // $52e6  
    txa                                         // $52e9  
    and D2010,y                                 // $52ea  
    ora $fa                                     // $52ed  
    sta D2438,y                                 // $52ef  
    lda D2118,y                                 // $52f2  
    sta $fa                                     // $52f5  
    lsr                                         // $52f7  
    ora $fa                                     // $52f8  
    eor #$ff                                    // $52fa  
    tax                                         // $52fc  
    and D2010,y                                 // $52fd  
    ora $fa                                     // $5300  
    sta D2440,y                                 // $5302  
    txa                                         // $5305  
    and D2030,y                                 // $5306  
    ora $fa                                     // $5309  
    sta D2448,y                                 // $530b  
    lda D2148,y                                 // $530e  
    sta $fa                                     // $5311  
    lsr                                         // $5313  
    ora $fa                                     // $5314  
    eor #$ff                                    // $5316  
    tax                                         // $5318  
    and D2030,y                                 // $5319  
    ora $fa                                     // $531c  
    sta D2450,y                                 // $531e  
    txa                                         // $5321  
    and D2050,y                                 // $5322  
    ora $fa                                     // $5325  
    sta D2458,y                                 // $5327  
    dey                                         // $532a  
    bpl L52ba                                   // $532b  
    rts                                         // $532d  
L532e:
    lda #$01                                    // $532e  
    sta $cf91                                   // $5330  
    lda #$00                                    // $5333  
    sta $cf92                                   // $5335  
    ldx #$5f                                    // $5338  
L533a:
    ldy #$07                                    // $533a  
L533c:
    lda D2000,y                                 // $533c  
    sta D2460,x                                 // $533f  
    dex                                         // $5342  
    dey                                         // $5343  
    bpl L533c                                   // $5344  
    txa                                         // $5346  
    bpl L533a                                   // $5347  
    rts                                         // $5349  
L534a:
    lda $cf91                                   // $534a  
    ldx $cf09                                   // $534d  
    cpx #$04                                    // $5350  
    bne L536e                                   // $5352  
    ldx $cf0a                                   // $5354  
    cpx #$08                                    // $5357  
    bne L536e                                   // $5359  
    ldx $cf07                                   // $535b  
    bne L536e                                   // $535e  
    and #$01                                    // $5360  
    bne L53a0                                   // $5362  
    ldy #$01                                    // $5364  
    lda $cf91                                   // $5366  
    ora #$01                                    // $5369  
    jmp L5379                                   // $536b  
L536e:
    and #$01                                    // $536e  
    beq L53a0                                   // $5370  
    ldy #$00                                    // $5372  
    lda $cf91                                   // $5374  
    and #$fe                                    // $5377  
L5379:
    sta $cf91                                   // $5379  
    ldx #$01                                    // $537c  
L537e:
    lda #$55                                    // $537e  
    cpy #$00                                    // $5380  
    bne L5387                                   // $5382  
    lda D2000,x                                 // $5384  
L5387:
    sta D2460,x                                 // $5387  
    sta D2468,x                                 // $538a  
    sta D2470,x                                 // $538d  
    dex                                         // $5390  
    bpl L537e                                   // $5391  
    ldx #$00                                    // $5393  
    tya                                         // $5395  
    beq L539a                                   // $5396  
    ldx #$6c                                    // $5398  
L539a:
    stx D04a2                                   // $539a  
    stx D04c4                                   // $539d  
L53a0:
    rts                                         // $53a0  
L53a1:
    lda $cf91                                   // $53a1  
    ldx $cf09                                   // $53a4  
    cpx #$04                                    // $53a7  
    bne L53c3                                   // $53a9  
    ldx $cf0a                                   // $53ab  
    bne L53c3                                   // $53ae  
    ldx $cf07                                   // $53b0  
    bne L53c3                                   // $53b3  
    and #$04                                    // $53b5  
    bne L53f7                                   // $53b7  
    ldy #$01                                    // $53b9  
    lda $cf91                                   // $53bb  
    ora #$04                                    // $53be  
    jmp L53ce                                   // $53c0  
L53c3:
    and #$04                                    // $53c3  
    beq L53f7                                   // $53c5  
    ldy #$00                                    // $53c7  
    lda $cf91                                   // $53c9  
    and #$fb                                    // $53cc  
L53ce:
    sta $cf91                                   // $53ce  
    ldx #$06                                    // $53d1  
L53d3:
    lda #$55                                    // $53d3  
    cpy #$00                                    // $53d5  
    bne L53dc                                   // $53d7  
    lda D2000,x                                 // $53d9  
L53dc:
    sta D2490,x                                 // $53dc  
    sta D2498,x                                 // $53df  
    sta D24a0,x                                 // $53e2  
    inx                                         // $53e5  
    cpx #$08                                    // $53e6  
    bcc L53d3                                   // $53e8  
    ldx #$00                                    // $53ea  
    tya                                         // $53ec  
    beq L53f1                                   // $53ed  
    ldx #$65                                    // $53ef  
L53f1:
    stx D0772                                   // $53f1  
    stx D0794                                   // $53f4  
L53f7:
    rts                                         // $53f7  
L53f8:
    lda $cf91                                   // $53f8  
    ldx $cf0a                                   // $53fb  
    cpx #$04                                    // $53fe  
    bne L541c                                   // $5400  
    ldx $cf09                                   // $5402  
    cpx #$08                                    // $5405  
    bne L541c                                   // $5407  
    ldx $cf08                                   // $5409  
    bne L541c                                   // $540c  
    and #$08                                    // $540e  
    bne L544b                                   // $5410  
    ldy #$01                                    // $5412  
    lda $cf91                                   // $5414  
    ora #$08                                    // $5417  
    jmp L5427                                   // $5419  
L541c:
    and #$08                                    // $541c  
    beq L544b                                   // $541e  
    ldy #$00                                    // $5420  
    lda $cf91                                   // $5422  
    and #$f7                                    // $5425  
L5427:
    sta $cf91                                   // $5427  
    ldx #$00                                    // $542a  
    tya                                         // $542c  
    beq L5431                                   // $542d  
    ldx #$72                                    // $542f  
L5431:
    stx D04a2                                   // $5431  
    stx D0772                                   // $5434  
    ldx #$00                                    // $5437  
L5439:
    lda D544c,y                                 // $5439  
    sta D24a8,x                                 // $543c  
    inx                                         // $543f  
    lda D544e,y                                 // $5440  
    sta D24a8,x                                 // $5443  
    inx                                         // $5446  
    cpx #$18                                    // $5447  
    bcc L5439                                   // $5449  
L544b:
    rts                                         // $544b  
D544c:
    .byte $ee,$6e                               // $544c  
D544e:
    .byte $bb,$7b                               // $544e  
L5450:
    lda $cf91                                   // $5450  
    ldx $cf0a                                   // $5453  
    cpx #$04                                    // $5456  
    bne L5472                                   // $5458  
    ldx $cf09                                   // $545a  
    bne L5472                                   // $545d  
    ldx $cf08                                   // $545f  
    bne L5472                                   // $5462  
    and #$02                                    // $5464  
    bne L54a1                                   // $5466  
    ldy #$01                                    // $5468  
    lda $cf91                                   // $546a  
    ora #$02                                    // $546d  
    jmp L547d                                   // $546f  
L5472:
    and #$02                                    // $5472  
    beq L54a1                                   // $5474  
    ldy #$00                                    // $5476  
    lda $cf91                                   // $5478  
    and #$fd                                    // $547b  
L547d:
    sta $cf91                                   // $547d  
    ldx #$00                                    // $5480  
    tya                                         // $5482  
    beq L5487                                   // $5483  
    ldx #$75                                    // $5485  
L5487:
    stx D04c4                                   // $5487  
    stx D0794                                   // $548a  
    ldx #$00                                    // $548d  
L548f:
    lda D54a2,y                                 // $548f  
    sta D2478,x                                 // $5492  
    inx                                         // $5495  
    lda D54a4,y                                 // $5496  
    sta D2478,x                                 // $5499  
    inx                                         // $549c  
    cpx #$18                                    // $549d  
    bcc L548f                                   // $549f  
L54a1:
    rts                                         // $54a1  
D54a2:
    .byte $ee,$ed                               // $54a2  
D54a4:
    .byte $bb,$b9                               // $54a4  
L54a6:
    lda $cf91                                   // $54a6  
    ldx $cf0a                                   // $54a9  
    cpx #$04                                    // $54ac  
    bne L54c3                                   // $54ae  
    ldx $cf08                                   // $54b0  
    bne L54c3                                   // $54b3  
    ora #$20                                    // $54b5  
    sta $cf91                                   // $54b7  
    ldx $cf09                                   // $54ba  
    lda D54f6,x                                 // $54bd  
    jmp L54d1                                   // $54c0  
L54c3:
    and #$20                                    // $54c3  
    beq L54f5                                   // $54c5  
    lda $cf91                                   // $54c7  
    and #$df                                    // $54ca  
    sta $cf91                                   // $54cc  
    lda #$00                                    // $54cf  
L54d1:
    ldx #$00                                    // $54d1  
    ldy #$00                                    // $54d3  
    cmp #$01                                    // $54d5  
    beq L54dd                                   // $54d7  
    ldx #$bb                                    // $54d9  
    ldy #$ee                                    // $54db  
L54dd:
    stx D2477                                   // $54dd  
    sty D2490                                   // $54e0  
    ldx #$00                                    // $54e3  
    ldy #$00                                    // $54e5  
    cmp #$02                                    // $54e7  
    beq L54ef                                   // $54e9  
    ldx #$bb                                    // $54eb  
    ldy #$ee                                    // $54ed  
L54ef:
    stx D2467                                   // $54ef  
    sty D24a0                                   // $54f2  
L54f5:
    rts                                         // $54f5  
D54f6:
    .byte $02,$02,$02,$00,$00,$00,$01,$01,$01   // $54f6  
L54ff:
    lda $cf91                                   // $54ff  
    ldx $cf09                                   // $5502  
    cpx #$04                                    // $5505  
    bne L551d                                   // $5507  
    ldx $cf07                                   // $5509  
    bne L551d                                   // $550c  
    ora #$10                                    // $550e  
    sta $cf91                                   // $5510  
    ldx $cf0a                                   // $5513  
    lda D54f6,x                                 // $5516  
    tay                                         // $5519  
    jmp L552b                                   // $551a  
L551d:
    and #$10                                    // $551d  
    beq L555e                                   // $551f  
    lda $cf91                                   // $5521  
    and #$ef                                    // $5524  
    sta $cf91                                   // $5526  
    ldy #$00                                    // $5529  
L552b:
    cpy $cf92                                   // $552b  
    beq L555e                                   // $552e  
    sty $cf92                                   // $5530  
    ldx #$00                                    // $5533  
L5535:
    lda D2000,x                                 // $5535  
    and D5562,y                                 // $5538  
    sta D24b8,x                                 // $553b  
    lda D2000,x                                 // $553e  
    and D555f,y                                 // $5541  
    sta D2478,x                                 // $5544  
    lda D2000,x                                 // $5547  
    and D5568,y                                 // $554a  
    sta D24a8,x                                 // $554d  
    lda D2000,x                                 // $5550  
    and D5565,y                                 // $5553  
    sta D2488,x                                 // $5556  
    inx                                         // $5559  
    cpx #$08                                    // $555a  
    bcc L5535                                   // $555c  
L555e:
    rts                                         // $555e  
D555f:
    .byte $ff,$ff,$3f                           // $555f  
D5562:
    .byte $ff,$ff,$fc                           // $5562  
D5565:
    .byte $ff,$3f,$ff                           // $5565  
D5568:
    .byte $ff,$fc,$ff                           // $5568  
L556b:
    lda $cf5a                                   // $556b  
    ora $cf5c                                   // $556e  
    ora $cf59                                   // $5571  
    bne L556b                                   // $5574  
    jsr L466d                                   // $5576  
    lda #$0c                                    // $5579  
    sta SID_V1_FREQ_HI                          // $557b  
    lda #$08                                    // $557e  
    sta SID_V1_AD                               // $5580  
    lda #$21                                    // $5583  
    sta SID_V1_CTRL                             // $5585  
    lda #$ff                                    // $5588  
    sta D8000                                   // $558a  
    lda #$00                                    // $558d  
    sta D866d                                   // $558f  
    sta $cfc8                                   // $5592  
    sta $cfca                                   // $5595  
    sta $cfcb                                   // $5598  
    lda #$00                                    // $559b  
    sta $cfb1                                   // $559d  
    sta $cfb2                                   // $55a0  
    sta $cfb4                                   // $55a3  
    sta $cfb5                                   // $55a6  
    sta $cfbf                                   // $55a9  
    sta $cf8d                                   // $55ac  
    sta $cf88                                   // $55af  
    sta $cf89                                   // $55b2  
    sta $cf8f                                   // $55b5  
    lda #$27                                    // $55b8  
    sta $cf90                                   // $55ba  
    lda #$0b                                    // $55bd  
    sta $cfbe                                   // $55bf  
    jsr L5754                                   // $55c2  
    jsr L5779                                   // $55c5  
    lda #$08                                    // $55c8  
    sta $cfb0                                   // $55ca  
    lda #$01                                    // $55cd  
    jsr L4664                                   // $55cf  
    lda #$01                                    // $55d2  
    sta $cf76                                   // $55d4  
    lda #$00                                    // $55d7  
    sta $cf87                                   // $55d9  
    sta $cf36                                   // $55dc  
    sta $cf0c                                   // $55df  
    lda #$0f                                    // $55e2  
    sta $cf78                                   // $55e4  
    lda #$04                                    // $55e7  
    sta $cf0e                                   // $55e9  
    lda #$08                                    // $55ec  
    sta $cf38                                   // $55ee  
    lda #$00                                    // $55f1  
    sta $cf77                                   // $55f3  
    lda #$01                                    // $55f6  
    jsr L4664                                   // $55f8  
    lda #$00                                    // $55fb  
    sta VIC_SPR_ENABLE                          // $55fd  
    sta VIC_SPR_MULTICOLOR                      // $5600  
    sta VIC_SPR_EXPAND_Y                        // $5603  
    sta VIC_SPR_EXPAND_X                        // $5606  
    lda #$07                                    // $5609  
    sta VIC_BG1                                 // $560b  
    lda #$0e                                    // $560e  
    sta VIC_BG2                                 // $5610  
    jsr L768c                                   // $5613  
    jsr L761c                                   // $5616  
    jsr L74c4                                   // $5619  
    jsr L56d7                                   // $561c  
    jsr L40fc                                   // $561f  
L5622:
    lda #$01                                    // $5622  
    jsr L4664                                   // $5624  
    jsr L56fd                                   // $5627  
    jsr L5ee3                                   // $562a  
    jsr L5e1a                                   // $562d  
    lda #$18                                    // $5630  
    sta $cfb0                                   // $5632  
    inc $cfca                                   // $5635  
    bne L563d                                   // $5638  
    inc $cfcb                                   // $563a  
L563d:
    lda $cfbe                                   // $563d  
    beq L5648                                   // $5640  
    dec $cfbe                                   // $5642  
    jmp L5622                                   // $5645  
L5648:
    jsr L1ab6                                   // $5648  
    and #$10                                    // $564b  
    beq L566d                                   // $564d  
    lda #$fe                                    // $564f  
    sta CIA1_PRA                                // $5651  
    lda CIA1_PRB                                // $5654  
    cmp #$f7                                    // $5657  
    beq L566a                                   // $5659  
    lda $cfca                                   // $565b  
    cmp #$03                                    // $565e  
    lda $cfcb                                   // $5660  
    sbc #$0f                                    // $5663  
    bcs L566a                                   // $5665  
    jmp L5622                                   // $5667  
L566a:
    jsr L6664                                   // $566a  
L566d:
    jsr L466d                                   // $566d  
    lda #$00                                    // $5670  
    sta $cfb8                                   // $5672  
    lda #$08                                    // $5675  
    sta $cfb0                                   // $5677  
    lda #$1f                                    // $567a  
    sta SID_MODE_VOL                            // $567c  
    lda #$44                                    // $567f  
    sta SID_RES_FILT                            // $5681  
    rts                                         // $5684  
L5685:
    jsr L5e02                                   // $5685  
    lda $cf78                                   // $5688  
    beq L5692                                   // $568b  
    dec $cf78                                   // $568d  
    bne L56bd                                   // $5690  
L5692:
    ldy #$00                                    // $5692  
    lda $cf36                                   // $5694  
    ldx $cf77                                   // $5697  
    bne L56a9                                   // $569a  
    clc                                         // $569c  
    adc #$07                                    // $569d  
    bcc L56b4                                   // $569f  
    ldx #$01                                    // $56a1  
    ldy #$0c                                    // $56a3  
    lda #$ff                                    // $56a5  
    bne L56b4                                   // $56a7  
L56a9:
    sec                                         // $56a9  
    sbc #$07                                    // $56aa  
    bcs L56b4                                   // $56ac  
    ldx #$00                                    // $56ae  
    ldy #$0c                                    // $56b0  
    lda #$00                                    // $56b2  
L56b4:
    sta $cf36                                   // $56b4  
    stx $cf77                                   // $56b7  
    sty $cf78                                   // $56ba  
L56bd:
    lda $cf36                                   // $56bd  
    ldx #$09                                    // $56c0  
L56c2:
    dex                                         // $56c2  
    sec                                         // $56c3  
    sbc #$1c                                    // $56c4  
    bcs L56c2                                   // $56c6  
    txa                                         // $56c8  
    bpl L56cd                                   // $56c9  
    ldx #$00                                    // $56cb  
L56cd:
    stx $cf38                                   // $56cd  
    lda D0dc5,x                                 // $56d0  
    sta $cf0f                                   // $56d3  
    rts                                         // $56d6  
L56d7:
    lda #$05                                    // $56d7  
    sta $fa                                     // $56d9  
    ldx #$2f                                    // $56db  
L56dd:
    ldy $fa                                     // $56dd  
    lda D56f7,y                                 // $56df  
    sta $ff                                     // $56e2  
    ldy #$07                                    // $56e4  
L56e6:
    lda D2000,y                                 // $56e6  
    and $ff                                     // $56e9  
    sta D21b0,x                                 // $56eb  
    dex                                         // $56ee  
    dey                                         // $56ef  
    bpl L56e6                                   // $56f0  
    dec $fa                                     // $56f2  
    bpl L56dd                                   // $56f4  
    rts                                         // $56f6  
D56f7:
    .byte $3f,$0f,$03,$fc,$f0,$c0               // $56f7  
L56fd:
    lda $cf38                                   // $56fd  
    sta $cf0a                                   // $5700  
    cmp $cf0c                                   // $5703  
    beq L5708                                   // $5706  
L5708:
    jsr L59fb                                   // $5708  
    jsr L5a76                                   // $570b  
    jsr L5a59                                   // $570e  
    jsr L5a38                                   // $5711  
    jsr L5a1a                                   // $5714  
    jsr L58e8                                   // $5717  
    jsr L5920                                   // $571a  
    jsr L5b0a                                   // $571d  
    jsr L5b85                                   // $5720  
    jsr L5bc8                                   // $5723  
    jsr L5c04                                   // $5726  
    jsr L5c40                                   // $5729  
    jsr L5c7c                                   // $572c  
    jsr L5c98                                   // $572f  
    jsr L5d59                                   // $5732  
    jsr L5cc5                                   // $5735  
    jsr L5d8c                                   // $5738  
    jsr L5cdf                                   // $573b  
    jsr L5d1d                                   // $573e  
    jsr L5dc1                                   // $5741  
    jsr L5dd4                                   // $5744  
    jsr L5df5                                   // $5747  
    jsr L5ab3                                   // $574a  
    lda $cf0a                                   // $574d  
    sta $cf0c                                   // $5750  
    rts                                         // $5753  
L5754:
    lda #<D7c00                                 // $5754  
    sta $fb                                     // $5756  
    sta $fd                                     // $5758  
    lda #>D7c00                                 // $575a  
    sta $fc                                     // $575c  
    lda #$78                                    // $575e  
    sta $fe                                     // $5760  
    ldx #$04                                    // $5762  
    ldy #$00                                    // $5764  
L5766:
    lda #$20                                    // $5766  
    sta ($fb),y                                 // $5768  
    lda #$0e                                    // $576a  
    sta ($fd),y                                 // $576c  
    iny                                         // $576e  
    bne L5766                                   // $576f  
    inc $fc                                     // $5771  
    inc $fe                                     // $5773  
    dex                                         // $5775  
    bne L5766                                   // $5776  
    rts                                         // $5778  
L5779:
    ldx #$f4                                    // $5779  
    ldy #$7c                                    // $577b  
    stx $fb                                     // $577d  
    sty $fc                                     // $577f  
    ldx #$c8                                    // $5781  
    ldy #$57                                    // $5783  
    stx L5797+1                                 // $5785  
    sty L5797+2                                 // $5788  
    lda #$04                                    // $578b  
    sta $fa                                     // $578d  
    ldx #$00                                    // $578f  
L5791:
    lda #$09                                    // $5791  
    sta $ff                                     // $5793  
L5795:
    ldy #$00                                    // $5795  
L5797:
    lda $ffff,x                                 // $5797  
    sta ($fb),y                                 // $579a  
    inx                                         // $579c  
    bne L57a2                                   // $579d  
    inc L5797+2                                 // $579f  
L57a2:
    iny                                         // $57a2  
    cpy #$08                                    // $57a3  
    bcc L5797                                   // $57a5  
    lda $fb                                     // $57a7  
    clc                                         // $57a9  
    adc #$28                                    // $57aa  
    sta $fb                                     // $57ac  
    bcc L57b2                                   // $57ae  
    inc $fc                                     // $57b0  
L57b2:
    dec $ff                                     // $57b2  
    bne L5795                                   // $57b4  
    lda $fb                                     // $57b6  
    sec                                         // $57b8  
    sbc #$60                                    // $57b9  
    sta $fb                                     // $57bb  
    lda $fc                                     // $57bd  
    sbc #$01                                    // $57bf  
    sta $fc                                     // $57c1  
    dec $fa                                     // $57c3  
    bne L5791                                   // $57c5  
    rts                                         // $57c7  
    .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$4a,$4b,$40,$40,$40,$40,$40,$40  // $57c8  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$4c,$4d,$3f,$00,$00,$3f,$3f,$3f  // $57d8  
    .byte $20,$20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20  // $57e8  
    .byte $20,$20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$41,$41,$20,$20,$20  // $57f8  
    .byte $20,$20,$20,$3d,$3d,$20,$20,$20,$20,$20,$3c,$3c,$3c,$3c,$20,$20  // $5808  
    .byte $52,$20,$58,$40,$40,$40,$20,$20,$20,$20,$00,$00,$00,$00,$20,$20  // $5818  
    .byte $53,$20,$59,$00,$00,$3f,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20  // $5828  
    .byte $20,$20,$5b,$00,$00,$3e,$20,$20,$20,$20,$00,$00,$00,$00,$20,$20  // $5838  
    .byte $20,$20,$5a,$41,$41,$41,$20,$20,$20,$20,$3d,$3d,$3d,$3d,$20,$20  // $5848  
    .byte $3c,$3c,$20,$20,$20,$20,$20,$3c,$40,$40,$20,$20,$20,$20,$54,$40  // $5858  
    .byte $00,$00,$20,$20,$20,$20,$20,$00,$00,$00,$20,$20,$20,$20,$55,$3f  // $5868  
    .byte $00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$3e,$3e,$3e,$3e,$3e,$5f  // $5878  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$41,$41,$41,$41,$41,$41,$41,$5e  // $5888  
    .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$20  // $5898  
    .byte $40,$40,$40,$40,$40,$4f,$4e,$20,$00,$00,$00,$00,$00,$00,$00,$20  // $58a8  
    .byte $3f,$3f,$00,$00,$3f,$51,$50,$20,$20,$20,$00,$00,$20,$20,$20,$20  // $58b8  
    .byte $20,$20,$00,$00,$20,$20,$20,$20,$20,$20,$00,$00,$20,$20,$20,$20  // $58c8  
    .byte $20,$20,$41,$41,$20,$20,$20,$20,$20,$20,$3d,$3d,$20,$20,$20,$20  // $58d8  
L58e8:
    ldx #$6f                                    // $58e8  
    ldy #$05                                    // $58ea  
    stx $fb                                     // $58ec  
    sty $fc                                     // $58ee  
    ldx #$87                                    // $58f0  
    ldy #$05                                    // $58f2  
    stx $fd                                     // $58f4  
    sty $fe                                     // $58f6  
    lda $cf0a                                   // $58f8  
    asl                                         // $58fb  
    asl                                         // $58fc  
    asl                                         // $58fd  
    tax                                         // $58fe  
    lda #$05                                    // $58ff  
    sta $ff                                     // $5901  
    ldy #$00                                    // $5903  
L5905:
    lda D596b,x                                 // $5905  
    sta ($fb),y                                 // $5908  
    jsr L5958                                   // $590a  
    sta ($fd),y                                 // $590d  
    tya                                         // $590f  
    clc                                         // $5910  
    adc #$28                                    // $5911  
    tay                                         // $5913  
    bcc L591a                                   // $5914  
    inc $fc                                     // $5916  
    inc $fe                                     // $5918  
L591a:
    inx                                         // $591a  
    dec $ff                                     // $591b  
    bne L5905                                   // $591d  
    rts                                         // $591f  
L5920:
    ldx #$71                                    // $5920  
    ldy #$05                                    // $5922  
    stx $fb                                     // $5924  
    sty $fc                                     // $5926  
    ldx #$85                                    // $5928  
    ldy #$05                                    // $592a  
    stx $fd                                     // $592c  
    sty $fe                                     // $592e  
    lda $cf0a                                   // $5930  
    asl                                         // $5933  
    asl                                         // $5934  
    asl                                         // $5935  
    tax                                         // $5936  
    lda #$05                                    // $5937  
    sta $ff                                     // $5939  
    ldy #$00                                    // $593b  
L593d:
    lda D59b3,x                                 // $593d  
    sta ($fb),y                                 // $5940  
    jsr L5958                                   // $5942  
    sta ($fd),y                                 // $5945  
    tya                                         // $5947  
    clc                                         // $5948  
    adc #$28                                    // $5949  
    tay                                         // $594b  
    bcc L5952                                   // $594c  
    inc $fc                                     // $594e  
    inc $fe                                     // $5950  
L5952:
    inx                                         // $5952  
    dec $ff                                     // $5953  
    bne L593d                                   // $5955  
    rts                                         // $5957  
L5958:
    cmp #$00                                    // $5958  
    beq L596a                                   // $595a  
    cmp #$20                                    // $595c  
    beq L596a                                   // $595e  
    cmp #$39                                    // $5960  
    bcs L5968                                   // $5962  
    adc #$03                                    // $5964  
    bne L596a                                   // $5966  
L5968:
    sbc #$03                                    // $5968  
L596a:
    rts                                         // $596a  
D596b:
    .byte $36,$37,$38,$20,$20,$00,$00,$00,$00,$36,$37,$38,$38,$00,$00,$00  // $596b  
    .byte $00,$36,$36,$37,$37,$00,$00,$00,$00,$00,$36,$36,$36,$00,$00,$00  // $597b  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$36,$36,$00,$00,$00,$00,$00,$00  // $598b  
    .byte $37,$37,$36,$00,$00,$00,$00,$00,$38,$37,$36,$00,$00,$00,$00,$00  // $599b  
    .byte $20,$38,$37,$36,$00,$00,$00,$00       // $59ab  
D59b3:
    .byte $3b,$3b,$3a,$3a,$3a,$00,$00,$00,$3b,$3b,$3a,$3a,$3a,$00,$00,$00  // $59b3  
    .byte $20,$20,$3b,$3b,$3b,$00,$00,$00,$20,$20,$20,$20,$20,$00,$00,$00  // $59c3  
    .byte $20,$20,$20,$20,$20,$00,$00,$00,$3b,$3b,$20,$20,$20,$00,$00,$00  // $59d3  
    .byte $3b,$3b,$3b,$20,$20,$00,$00,$00,$3a,$3a,$3b,$20,$20,$00,$00,$00  // $59e3  
    .byte $3a,$3a,$3b,$20,$20,$00,$00,$00       // $59f3  
L59fb:
    lda $cf0a                                   // $59fb  
    asl                                         // $59fe  
    cmp #$08                                    // $59ff  
    bcc L5a05                                   // $5a01  
    lda #$08                                    // $5a03  
L5a05:
    sta $ff                                     // $5a05  
    lda #$00                                    // $5a07  
    ldx #$00                                    // $5a09  
L5a0b:
    cpx $ff                                     // $5a0b  
    bne L5a11                                   // $5a0d  
    lda #$55                                    // $5a0f  
L5a11:
    sta D21e0,x                                 // $5a11  
    inx                                         // $5a14  
    cpx #$08                                    // $5a15  
    bcc L5a0b                                   // $5a17  
    rts                                         // $5a19  
L5a1a:
    lda $cf0a                                   // $5a1a  
    asl                                         // $5a1d  
    sec                                         // $5a1e  
    sbc #$09                                    // $5a1f  
    bcs L5a25                                   // $5a21  
    lda #$ff                                    // $5a23  
L5a25:
    sta $ff                                     // $5a25  
    lda #$00                                    // $5a27  
    ldx #$07                                    // $5a29  
L5a2b:
    cpx $ff                                     // $5a2b  
    bne L5a31                                   // $5a2d  
    lda #$55                                    // $5a2f  
L5a31:
    sta D21e8,x                                 // $5a31  
    dex                                         // $5a34  
    bpl L5a2b                                   // $5a35  
    rts                                         // $5a37  
L5a38:
    lda $cf0a                                   // $5a38  
    clc                                         // $5a3b  
    adc #$04                                    // $5a3c  
    cmp #$08                                    // $5a3e  
    bcc L5a44                                   // $5a40  
    lda #$08                                    // $5a42  
L5a44:
    sta $ff                                     // $5a44  
    lda #$00                                    // $5a46  
    ldx #$00                                    // $5a48  
L5a4a:
    sta D21f0,x                                 // $5a4a  
    inx                                         // $5a4d  
    cpx $ff                                     // $5a4e  
    bne L5a54                                   // $5a50  
    lda #$55                                    // $5a52  
L5a54:
    cpx #$08                                    // $5a54  
    bcc L5a4a                                   // $5a56  
    rts                                         // $5a58  
L5a59:
    lda $cf0a                                   // $5a59  
    sec                                         // $5a5c  
    sbc #$04                                    // $5a5d  
    bcs L5a63                                   // $5a5f  
    lda #$00                                    // $5a61  
L5a63:
    sta $ff                                     // $5a63  
    lda #$00                                    // $5a65  
    ldx #$07                                    // $5a67  
L5a69:
    sta D21f8,x                                 // $5a69  
    cpx $ff                                     // $5a6c  
    bne L5a72                                   // $5a6e  
    lda #$55                                    // $5a70  
L5a72:
    dex                                         // $5a72  
    bpl L5a69                                   // $5a73  
    rts                                         // $5a75  
L5a76:
    ldx #$0f                                    // $5a76  
    lda #$00                                    // $5a78  
L5a7a:
    sta D2200,x                                 // $5a7a  
    dex                                         // $5a7d  
    bpl L5a7a                                   // $5a7e  
    lda $cf0a                                   // $5a80  
    sec                                         // $5a83  
    sbc #$04                                    // $5a84  
    bcs L5a8a                                   // $5a86  
    lda #$00                                    // $5a88  
L5a8a:
    asl                                         // $5a8a  
    cmp #$08                                    // $5a8b  
    bcs L5a9b                                   // $5a8d  
    tax                                         // $5a8f  
L5a90:
    lda D2000,x                                 // $5a90  
    sta D2200,x                                 // $5a93  
    inx                                         // $5a96  
    cpx #$08                                    // $5a97  
    bcc L5a90                                   // $5a99  
L5a9b:
    lda $cf0a                                   // $5a9b  
    asl                                         // $5a9e  
    cmp #$08                                    // $5a9f  
    bcc L5aa5                                   // $5aa1  
    lda #$08                                    // $5aa3  
L5aa5:
    tax                                         // $5aa5  
    dex                                         // $5aa6  
    bmi L5ab2                                   // $5aa7  
L5aa9:
    lda D2000,x                                 // $5aa9  
    sta D2208,x                                 // $5aac  
    dex                                         // $5aaf  
    bpl L5aa9                                   // $5ab0  
L5ab2:
    rts                                         // $5ab2  
L5ab3:
    lda D060f                                   // $5ab3  
    jsr L186f                                   // $5ab6  
    lda D0611                                   // $5ab9  
    jsr L1882                                   // $5abc  
    ldy #$07                                    // $5abf  
L5ac1:
    lda ($fb),y                                 // $5ac1  
    and D2208,y                                 // $5ac3  
    sta D2210,y                                 // $5ac6  
    lda ($fd),y                                 // $5ac9  
    and D2208,y                                 // $5acb  
    sta D2218,y                                 // $5ace  
    dey                                         // $5ad1  
    bpl L5ac1                                   // $5ad2  
    lda D0627                                   // $5ad4  
    jsr L186f                                   // $5ad7  
    lda D0625                                   // $5ada  
    jsr L1882                                   // $5add  
    ldy #$07                                    // $5ae0  
L5ae2:
    lda ($fb),y                                 // $5ae2  
    and D2208,y                                 // $5ae4  
    sta D2220,y                                 // $5ae7  
    lda ($fd),y                                 // $5aea  
    and D2208,y                                 // $5aec  
    sta D2228,y                                 // $5aef  
    dey                                         // $5af2  
    bpl L5ae2                                   // $5af3  
    lda #$42                                    // $5af5  
    sta D060f                                   // $5af7  
    lda #$43                                    // $5afa  
    sta D0611                                   // $5afc  
    lda #$44                                    // $5aff  
    sta D0627                                   // $5b01  
    lda #$45                                    // $5b04  
    sta D0625                                   // $5b06  
    rts                                         // $5b09  
L5b0a:
    lda D056f                                   // $5b0a  
    jsr L186f                                   // $5b0d  
    lda D0571                                   // $5b10  
    jsr L1882                                   // $5b13  
    ldy #$07                                    // $5b16  
L5b18:
    lda ($fb),y                                 // $5b18  
    sta $fa                                     // $5b1a  
    lsr                                         // $5b1c  
    ora $fa                                     // $5b1d  
    eor #$ff                                    // $5b1f  
    and D21f8,y                                 // $5b21  
    ora $fa                                     // $5b24  
    sta D2230,y                                 // $5b26  
    lda ($fd),y                                 // $5b29  
    sta $fa                                     // $5b2b  
    lsr                                         // $5b2d  
    ora $fa                                     // $5b2e  
    eor #$ff                                    // $5b30  
    and D21f8,y                                 // $5b32  
    ora $fa                                     // $5b35  
    sta D2238,y                                 // $5b37  
    dey                                         // $5b3a  
    bpl L5b18                                   // $5b3b  
    lda D0587                                   // $5b3d  
    jsr L186f                                   // $5b40  
    lda D0585                                   // $5b43  
    jsr L1882                                   // $5b46  
    ldy #$07                                    // $5b49  
L5b4b:
    lda ($fb),y                                 // $5b4b  
    sta $fa                                     // $5b4d  
    lsr                                         // $5b4f  
    ora $fa                                     // $5b50  
    eor #$ff                                    // $5b52  
    and D21f8,y                                 // $5b54  
    ora $fa                                     // $5b57  
    sta D2240,y                                 // $5b59  
    lda ($fd),y                                 // $5b5c  
    sta $fa                                     // $5b5e  
    lsr                                         // $5b60  
    ora $fa                                     // $5b61  
    eor #$ff                                    // $5b63  
    and D21f8,y                                 // $5b65  
    ora $fa                                     // $5b68  
    sta D2248,y                                 // $5b6a  
    dey                                         // $5b6d  
    bpl L5b4b                                   // $5b6e  
    lda #$46                                    // $5b70  
    sta D056f                                   // $5b72  
    lda #$47                                    // $5b75  
    sta D0571                                   // $5b77  
    lda #$48                                    // $5b7a  
    sta D0587                                   // $5b7c  
    lda #$49                                    // $5b7f  
    sta D0585                                   // $5b81  
    rts                                         // $5b84  
L5b85:
    ldx $cf0a                                   // $5b85  
    lda D5bad,x                                 // $5b88  
    sta D0544                                   // $5b8b  
    jsr L5958                                   // $5b8e  
    sta D0562                                   // $5b91  
    lda D5bb6,x                                 // $5b94  
    sta D0545                                   // $5b97  
    jsr L5958                                   // $5b9a  
    sta D0561                                   // $5b9d  
    lda D5bbf,x                                 // $5ba0  
    sta D054c                                   // $5ba3  
    jsr L5958                                   // $5ba6  
    sta D055a                                   // $5ba9  
    rts                                         // $5bac  
D5bad:
    .byte $00,$00,$00,$00,$00,$36,$38,$20,$20   // $5bad  
D5bb6:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$37   // $5bb6  
D5bbf:
    .byte $20,$20,$20,$20,$20,$3b,$3b,$3a,$3a   // $5bbf  
L5bc8:
    lda D0544                                   // $5bc8  
    jsr L186f                                   // $5bcb  
    lda D0545                                   // $5bce  
    jsr L1882                                   // $5bd1  
    ldy #$07                                    // $5bd4  
L5bd6:
    lda ($fb),y                                 // $5bd6  
    and D2200,y                                 // $5bd8  
    sta D2250,y                                 // $5bdb  
    lda ($fb),y                                 // $5bde  
    sta $fa                                     // $5be0  
    lsr                                         // $5be2  
    ora $fa                                     // $5be3  
    and D21f8,y                                 // $5be5  
    sta D2260,y                                 // $5be8  
    lda ($fd),y                                 // $5beb  
    and D2200,y                                 // $5bed  
    sta D2258,y                                 // $5bf0  
    lda ($fd),y                                 // $5bf3  
    sta $fa                                     // $5bf5  
    lsr                                         // $5bf7  
    ora $fa                                     // $5bf8  
    and D21f8,y                                 // $5bfa  
    sta D2268,y                                 // $5bfd  
    dey                                         // $5c00  
    bpl L5bd6                                   // $5c01  
    rts                                         // $5c03  
L5c04:
    lda D0562                                   // $5c04  
    jsr L186f                                   // $5c07  
    lda D0561                                   // $5c0a  
    jsr L1882                                   // $5c0d  
    ldy #$07                                    // $5c10  
L5c12:
    lda ($fb),y                                 // $5c12  
    and D2200,y                                 // $5c14  
    sta D2270,y                                 // $5c17  
    lda ($fb),y                                 // $5c1a  
    sta $fa                                     // $5c1c  
    lsr                                         // $5c1e  
    ora $fa                                     // $5c1f  
    and D21f8,y                                 // $5c21  
    sta D2280,y                                 // $5c24  
    lda ($fd),y                                 // $5c27  
    and D2200,y                                 // $5c29  
    sta D2278,y                                 // $5c2c  
    lda ($fd),y                                 // $5c2f  
    sta $fa                                     // $5c31  
    lsr                                         // $5c33  
    ora $fa                                     // $5c34  
    and D21f8,y                                 // $5c36  
    sta D2288,y                                 // $5c39  
    dey                                         // $5c3c  
    bpl L5c12                                   // $5c3d  
    rts                                         // $5c3f  
L5c40:
    lda D054c                                   // $5c40  
    jsr L186f                                   // $5c43  
    lda D055a                                   // $5c46  
    jsr L1882                                   // $5c49  
    ldy #$07                                    // $5c4c  
L5c4e:
    lda ($fb),y                                 // $5c4e  
    and D2200,y                                 // $5c50  
    sta D2290,y                                 // $5c53  
    lda ($fb),y                                 // $5c56  
    sta $fa                                     // $5c58  
    lsr                                         // $5c5a  
    ora $fa                                     // $5c5b  
    and D21f8,y                                 // $5c5d  
    sta D2298,y                                 // $5c60  
    lda ($fd),y                                 // $5c63  
    and D2200,y                                 // $5c65  
    sta D22a0,y                                 // $5c68  
    lda ($fd),y                                 // $5c6b  
    sta $fa                                     // $5c6d  
    lsr                                         // $5c6f  
    ora $fa                                     // $5c70  
    and D21f8,y                                 // $5c72  
    sta D22a8,y                                 // $5c75  
    dey                                         // $5c78  
    bpl L5c4e                                   // $5c79  
    rts                                         // $5c7b  
L5c7c:
    ldx $cf0a                                   // $5c7c  
    cpx #$02                                    // $5c7f  
    bcs L5c97                                   // $5c81  
    lda #$36                                    // $5c83  
    sta D0544                                   // $5c85  
    lda #$3b                                    // $5c88  
    sta D054c                                   // $5c8a  
    lda #$39                                    // $5c8d  
    sta D0562                                   // $5c8f  
    lda #$38                                    // $5c92  
    sta D055a                                   // $5c94  
L5c97:
    rts                                         // $5c97  
L5c98:
    lda $cf0a                                   // $5c98  
    ldx #$00                                    // $5c9b  
    cmp #$03                                    // $5c9d  
    bcc L5ca9                                   // $5c9f  
    ldx #$03                                    // $5ca1  
    cmp #$06                                    // $5ca3  
    bcc L5ca9                                   // $5ca5  
    ldx #$06                                    // $5ca7  
L5ca9:
    ldy #$00                                    // $5ca9  
L5cab:
    lda D5cbc,x                                 // $5cab  
    sta D0577,y                                 // $5cae  
    inx                                         // $5cb1  
    tya                                         // $5cb2  
    clc                                         // $5cb3  
    adc #$28                                    // $5cb4  
    tay                                         // $5cb6  
    cpy #$78                                    // $5cb7  
    bcc L5cab                                   // $5cb9  
    rts                                         // $5cbb  
D5cbc:
    .byte $00,$36,$36,$00,$00,$00,$36,$00,$00   // $5cbc  
L5cc5:
    lda $cf0a                                   // $5cc5  
    ldx #$00                                    // $5cc8  
    cmp #$06                                    // $5cca  
    bcc L5cd0                                   // $5ccc  
    ldx #$36                                    // $5cce  
L5cd0:
    stx D054e                                   // $5cd0  
    ldx #$00                                    // $5cd3  
    cmp #$03                                    // $5cd5  
    bcs L5cdb                                   // $5cd7  
    ldx #$36                                    // $5cd9  
L5cdb:
    stx D05ee                                   // $5cdb  
    rts                                         // $5cde  
L5cdf:
    lda D0577                                   // $5cdf  
    jsr L186f                                   // $5ce2  
    lda D05c7                                   // $5ce5  
    jsr L1882                                   // $5ce8  
    ldy #$07                                    // $5ceb  
L5ced:
    lda ($fb),y                                 // $5ced  
    sta $fa                                     // $5cef  
    lsr                                         // $5cf1  
    ora $fa                                     // $5cf2  
    eor #$ff                                    // $5cf4  
    and D21f8,y                                 // $5cf6  
    ora $fa                                     // $5cf9  
    sta D22b0,y                                 // $5cfb  
    lda ($fd),y                                 // $5cfe  
    sta $fa                                     // $5d00  
    lsr                                         // $5d02  
    ora $fa                                     // $5d03  
    eor #$ff                                    // $5d05  
    and D21f0,y                                 // $5d07  
    ora $fa                                     // $5d0a  
    sta D22b8,y                                 // $5d0c  
    dey                                         // $5d0f  
    bpl L5ced                                   // $5d10  
    lda #$56                                    // $5d12  
    sta D0577                                   // $5d14  
    lda #$57                                    // $5d17  
    sta D05c7                                   // $5d19  
    rts                                         // $5d1c  
L5d1d:
    lda D054e                                   // $5d1d  
    jsr L186f                                   // $5d20  
    lda D05ee                                   // $5d23  
    jsr L1882                                   // $5d26  
    ldy #$07                                    // $5d29  
L5d2b:
    lda ($fb),y                                 // $5d2b  
    and D2200,y                                 // $5d2d  
    sta D22c0,y                                 // $5d30  
    lda ($fb),y                                 // $5d33  
    sta $ff                                     // $5d35  
    lsr                                         // $5d37  
    ora $ff                                     // $5d38  
    and D21f8,y                                 // $5d3a  
    sta D22c8,y                                 // $5d3d  
    lda ($fd),y                                 // $5d40  
    and D2208,y                                 // $5d42  
    sta D22d0,y                                 // $5d45  
    lda ($fd),y                                 // $5d48  
    sta $ff                                     // $5d4a  
    lsr                                         // $5d4c  
    ora $ff                                     // $5d4d  
    and D21f0,y                                 // $5d4f  
    sta D22d8,y                                 // $5d52  
    dey                                         // $5d55  
    bpl L5d2b                                   // $5d56  
    rts                                         // $5d58  
L5d59:
    lda $cf0a                                   // $5d59  
    ldx #$00                                    // $5d5c  
    cmp #$03                                    // $5d5e  
    bcc L5d6a                                   // $5d60  
    ldx #$05                                    // $5d62  
    cmp #$06                                    // $5d64  
    bcc L5d6a                                   // $5d66  
    ldx #$0a                                    // $5d68  
L5d6a:
    ldy #$00                                    // $5d6a  
L5d6c:
    lda D5d7d,x                                 // $5d6c  
    sta D052d,y                                 // $5d6f  
    inx                                         // $5d72  
    tya                                         // $5d73  
    clc                                         // $5d74  
    adc #$28                                    // $5d75  
    tay                                         // $5d77  
    cpy #$c8                                    // $5d78  
    bcc L5d6c                                   // $5d7a  
    rts                                         // $5d7c  
D5d7d:
    .byte $00,$00,$00,$39,$39,$00,$00,$00,$00,$00,$39,$39,$39,$00,$00  // $5d7d  
L5d8c:
    lda D052d                                   // $5d8c  
    jsr L186f                                   // $5d8f  
    lda D05cd                                   // $5d92  
    jsr L1882                                   // $5d95  
    ldy #$07                                    // $5d98  
L5d9a:
    lda ($fb),y                                 // $5d9a  
    and D2200,y                                 // $5d9c  
    sta D22e0,y                                 // $5d9f  
    lda ($fd),y                                 // $5da2  
    sta $ff                                     // $5da4  
    lsr                                         // $5da6  
    ora $ff                                     // $5da7  
    eor #$ff                                    // $5da9  
    and D21f0,y                                 // $5dab  
    ora $ff                                     // $5dae  
    sta D22e8,y                                 // $5db0  
    dey                                         // $5db3  
    bpl L5d9a                                   // $5db4  
    lda #$5c                                    // $5db6  
    sta D052d                                   // $5db8  
    lda #$5d                                    // $5dbb  
    sta D05cd                                   // $5dbd  
    rts                                         // $5dc0  
L5dc1:
    ldx $cf0a                                   // $5dc1  
    lda D5dcb,x                                 // $5dc4  
    sta D05fb                                   // $5dc7  
    rts                                         // $5dca  
D5dcb:
    .byte $3a,$3a,$39,$39,$00,$00,$00,$00,$00   // $5dcb  
L5dd4:
    lda D05fb                                   // $5dd4  
    jsr L186f                                   // $5dd7  
    ldy #$07                                    // $5dda  
L5ddc:
    lda ($fb),y                                 // $5ddc  
    and D2208,y                                 // $5dde  
    sta D22f0,y                                 // $5de1  
    lda ($fb),y                                 // $5de4  
    sta $ff                                     // $5de6  
    lsr                                         // $5de8  
    ora $ff                                     // $5de9  
    and D21f0,y                                 // $5deb  
    sta D22f8,y                                 // $5dee  
    dey                                         // $5df1  
    bpl L5ddc                                   // $5df2  
    rts                                         // $5df4  
L5df5:
    ldx $cf0a                                   // $5df5  
    cpx #$07                                    // $5df8  
    bcc L5e01                                   // $5dfa  
    lda #$39                                    // $5dfc  
    sta D05fb                                   // $5dfe  
L5e01:
    rts                                         // $5e01  
L5e02:
    dec $cf8f                                   // $5e02  
    bpl L5e19                                   // $5e05  
    lda #$07                                    // $5e07  
    sta $cf8f                                   // $5e09  
    ldx $cf90                                   // $5e0c  
    inx                                         // $5e0f  
    cpx #$74                                    // $5e10  
    bcc L5e16                                   // $5e12  
    ldx #$00                                    // $5e14  
L5e16:
    stx $cf90                                   // $5e16  
L5e19:
    rts                                         // $5e19  
L5e1a:
    lda #$07                                    // $5e1a  
    sta $fc                                     // $5e1c  
    sta $fe                                     // $5e1e  
    ldx #$70                                    // $5e20  
    ldy #$98                                    // $5e22  
    lda $cf0f                                   // $5e24  
    cmp #$03                                    // $5e27  
    bne L5e32                                   // $5e29  
    stx $fd                                     // $5e2b  
    sty $fb                                     // $5e2d  
    jmp L5e36                                   // $5e2f  
L5e32:
    stx $fb                                     // $5e32  
    sty $fd                                     // $5e34  
L5e36:
    ldx $cf90                                   // $5e36  
    ldy #$27                                    // $5e39  
L5e3b:
    lda #$20                                    // $5e3b  
    sta ($fd),y                                 // $5e3d  
    lda D5e6f,x                                 // $5e3f  
    cmp #$d1                                    // $5e42  
    bne L5e4a                                   // $5e44  
    lda #$51                                    // $5e46  
    bne L5e4c                                   // $5e48  
L5e4a:
    and #$3f                                    // $5e4a  
L5e4c:
    sta ($fb),y                                 // $5e4c  
    lda #$00                                    // $5e4e  
    bcs L5e60                                   // $5e50  
    lda #$01                                    // $5e52  
    cpx #$38                                    // $5e54  
    bcs L5e60                                   // $5e56  
    lda #$07                                    // $5e58  
    cpx #$1d                                    // $5e5a  
    bcs L5e60                                   // $5e5c  
    lda #$07                                    // $5e5e  
L5e60:
    sta $db70,y                                 // $5e60  
    sta $db98,y                                 // $5e63  
    dex                                         // $5e66  
    bpl L5e6b                                   // $5e67  
    ldx #$73                                    // $5e69  
L5e6b:
    dey                                         // $5e6b  
    bpl L5e3b                                   // $5e6c  
    rts                                         // $5e6e  
D5e6f:
    .byte $d1,$20,$43,$4f,$50,$59,$52,$49,$47,$48,$54,$20,$43,$4f,$44,$45  // $5e6f  
    .byte $4d,$41,$53,$54,$45,$52,$53,$20,$31,$39,$39,$30,$20,$d1,$20,$50  // $5e7f  
    .byte $52,$4f,$47,$52,$41,$4d,$20,$42,$59,$20,$53,$54,$45,$56,$45,$20  // $5e8f  
    .byte $57,$41,$4c,$54,$45,$52,$53,$20,$d1,$20,$50,$52,$45,$53,$53,$20  // $5e9f  
    .byte $46,$49,$52,$45,$20,$54,$4f,$20,$50,$4c,$41,$59,$20,$d1,$20,$50  // $5eaf  
    .byte $52,$45,$53,$53,$20,$46,$37,$20,$46,$4f,$52,$20,$44,$45,$4d,$4f  // $5ebf  
    .byte $20,$4d,$4f,$44,$45,$20,$d1,$20,$46,$31,$20,$54,$4f,$20,$52,$45  // $5ecf  
    .byte $53,$45,$54,$20                       // $5edf  
L5ee3:
    lda #$ef                                    // $5ee3  
    sta CIA1_PRA                                // $5ee5  
    lda CIA1_PRB                                // $5ee8  
    cmp #$ef                                    // $5eeb  
    bne L5f36                                   // $5eed  
    lda $cfc8                                   // $5eef  
    beq L5f3b                                   // $5ef2  
    lda #$00                                    // $5ef4  
    sta $cfc8                                   // $5ef6  
    sta D866d                                   // $5ef9  
    sta $cfca                                   // $5efc  
    sta $cfcb                                   // $5eff  
    lda #$ff                                    // $5f02  
    sta D8000                                   // $5f04  
    lda $cefa                                   // $5f07  
    eor #$01                                    // $5f0a  
    and #$01                                    // $5f0c  
    sta $cefa                                   // $5f0e  
    jsr L751f                                   // $5f11  
    jsr L466d                                   // $5f14  
    lda #$0f                                    // $5f17  
    sta SID_MODE_VOL                            // $5f19  
    lda #$00                                    // $5f1c  
    sta SID_RES_FILT                            // $5f1e  
    lda #$06                                    // $5f21  
    sta SID_V1_AD                               // $5f23  
    lda #$32                                    // $5f26  
    sta SID_V1_FREQ_HI                          // $5f28  
    sta SID_V1_FREQ_LO                          // $5f2b  
    lda #$21                                    // $5f2e  
    sta SID_V1_CTRL                             // $5f30  
    jmp L5f3b                                   // $5f33  
L5f36:
    lda #$01                                    // $5f36  
    sta $cfc8                                   // $5f38  
L5f3b:
    lda $cefa                                   // $5f3b  
    beq L5f5d                                   // $5f3e  
    lda D866d                                   // $5f40  
    bne L5f5d                                   // $5f43  
    lda $cf36                                   // $5f45  
    cmp #$03                                    // $5f48  
    beq L5f50                                   // $5f4a  
    cmp #$fc                                    // $5f4c  
    bne L5f5d                                   // $5f4e  
L5f50:
    lda #$01                                    // $5f50  
    sta D8000                                   // $5f52  
    lda #$00                                    // $5f55  
    sta $cfca                                   // $5f57  
    sta $cfcb                                   // $5f5a  
L5f5d:
    jsr L8001                                   // $5f5d  
    rts                                         // $5f60  
L5f61:
    lda $cf87                                   // $5f61  
    bne L5fa1                                   // $5f64  
    lda $cefa                                   // $5f66  
    beq L5fa1                                   // $5f69  
    lda #$01                                    // $5f6b  
    sta $cf7a                                   // $5f6d  
    lda #$80                                    // $5f70  
    sta $cfc9                                   // $5f72  
    lda #$03                                    // $5f75  
    sta D8000                                   // $5f77  
L5f7a:
    lda #$01                                    // $5f7a  
    jsr L4664                                   // $5f7c  
    jsr L8001                                   // $5f7f  
    lda #$04                                    // $5f82  
    sta SID_MODE_VOL                            // $5f84  
    dec $cfc9                                   // $5f87  
    bne L5f7a                                   // $5f8a  
    jsr L466d                                   // $5f8c  
    lda #$1f                                    // $5f8f  
    sta SID_MODE_VOL                            // $5f91  
    lda #$44                                    // $5f94  
    sta SID_RES_FILT                            // $5f96  
    lda #$00                                    // $5f99  
    sta $cf7a                                   // $5f9b  
    jmp L5fa6                                   // $5f9e  
L5fa1:
    lda #$19                                    // $5fa1  
    jsr L4664                                   // $5fa3  
L5fa6:
    rts                                         // $5fa6  
L5fa7:
    lda $cfb4                                   // $5fa7  
    beq L5fe7                                   // $5faa  
    bne L5fe7                                   // $5fac  
    jsr L74c4                                   // $5fae  
    lda #$01                                    // $5fb1  
    sta $cf7a                                   // $5fb3  
    lda #$80                                    // $5fb6  
    sta $cfc9                                   // $5fb8  
    lda #$04                                    // $5fbb  
    sta D8000                                   // $5fbd  
L5fc0:
    lda #$01                                    // $5fc0  
    jsr L4664                                   // $5fc2  
    jsr L8001                                   // $5fc5  
    lda #$04                                    // $5fc8  
    sta SID_MODE_VOL                            // $5fca  
    dec $cfc9                                   // $5fcd  
    bne L5fc0                                   // $5fd0  
    jsr L466d                                   // $5fd2  
    lda #$1f                                    // $5fd5  
    sta SID_MODE_VOL                            // $5fd7  
    lda #$44                                    // $5fda  
    sta SID_RES_FILT                            // $5fdc  
    lda #$00                                    // $5fdf  
    sta $cf7a                                   // $5fe1  
    jmp L5fec                                   // $5fe4  
L5fe7:
    lda #$14                                    // $5fe7  
    jsr L4664                                   // $5fe9  
L5fec:
    rts                                         // $5fec  
    lda VIC_IRQ_STATUS                          // $5fed  
    and #$01                                    // $5ff0  
    bne L5ff7                                   // $5ff2  
    jmp KERNAL_IRQ                              // $5ff4  
L5ff7:
    sta VIC_IRQ_STATUS                          // $5ff7  
    ldx $cf0d                                   // $5ffa  
    inx                                         // $5ffd  
    cpx #$0c                                    // $5ffe  
    bcc L6004                                   // $6000  
    ldx #$00                                    // $6002  
L6004:
    stx $cf0d                                   // $6004  
    lda D61a9,x                                 // $6007  
    sta VIC_RASTER                              // $600a  
    txa                                         // $600d  
    beq L6016                                   // $600e  
    jsr L6079                                   // $6010  
    jmp KERNAL_IRQ_EXIT                         // $6013  
L6016:
    lda $cf1a                                   // $6016  
    beq L601e                                   // $6019  
    dec $cf1a                                   // $601b  
L601e:
    lda #$ff                                    // $601e  
    sta CIA1_DDRA                               // $6020  
    lda #$fe                                    // $6023  
    sta CIA1_PRA                                // $6025  
    lda CIA1_PRB                                // $6028  
    cmp #$ef                                    // $602b  
    bne L6044                                   // $602d  
    lda $cf76                                   // $602f  
    ora $cfb8                                   // $6032  
    bne L6044                                   // $6035  
    ldx #$fe                                    // $6037  
    sei                                         // $6039  
    txs                                         // $603a  
    cld                                         // $603b  
    lda #$01                                    // $603c  
    sta CIA1_CRA                                // $603e  
    jmp L4029                                   // $6041  
L6044:
    ldx #$07                                    // $6044  
L6046:
    lda $f8,x                                   // $6046  
    pha                                         // $6048  
    dex                                         // $6049  
    bpl L6046                                   // $604a  
    lda #$03                                    // $604c  
    ora $cfb0                                   // $604e  
    sta VIC_CTRL1                               // $6051  
    lda #$c8                                    // $6054  
    sta VIC_CTRL2                               // $6056  
    lda #$18                                    // $6059  
    sta VIC_MEMSETUP                            // $605b  
    lda $cf76                                   // $605e  
    beq L6069                                   // $6061  
    jsr L5685                                   // $6063  
    jmp L606c                                   // $6066  
L6069:
    jsr L61b7                                   // $6069  
L606c:
    ldx #$00                                    // $606c  
L606e:
    pla                                         // $606e  
    sta $f8,x                                   // $606f  
    inx                                         // $6071  
    cpx #$08                                    // $6072  
    bne L606e                                   // $6074  
    jmp KERNAL_IRQ_EXIT                         // $6076  
L6079:
    cmp #$01                                    // $6079  
    bne L608b                                   // $607b  
    ldx #$05                                    // $607d  
L607f:
    dex                                         // $607f  
    bpl L607f                                   // $6080  
    lda #$08                                    // $6082  
    sta VIC_BORDER                              // $6084  
    sta VIC_BG0                                 // $6087  
    rts                                         // $608a  
L608b:
    cmp #$02                                    // $608b  
    bne L609d                                   // $608d  
    ldx #$04                                    // $608f  
L6091:
    dex                                         // $6091  
    bpl L6091                                   // $6092  
    lda #$09                                    // $6094  
    sta VIC_BORDER                              // $6096  
    sta VIC_BG0                                 // $6099  
    rts                                         // $609c  
L609d:
    cmp #$03                                    // $609d  
    bne L60d4                                   // $609f  
    ldx #$03                                    // $60a1  
L60a3:
    dex                                         // $60a3  
    bpl L60a3                                   // $60a4  
    lda $cf0f                                   // $60a6  
    ora $cfb0                                   // $60a9  
    tay                                         // $60ac  
    lda $cf0e                                   // $60ad  
    ora #$d0                                    // $60b0  
    ldx #$08                                    // $60b2  
    stx VIC_BG0                                 // $60b4  
    stx VIC_BORDER                              // $60b7  
    sty VIC_CTRL1                               // $60ba  
    ldx #$d0                                    // $60bd  
    lda $cf0e                                   // $60bf  
    ora $cf45                                   // $60c2  
    ora $cf76                                   // $60c5  
    bne L60cc                                   // $60c8  
    ldx #$d8                                    // $60ca  
L60cc:
    txa                                         // $60cc  
    ora $cf0e                                   // $60cd  
    sta VIC_CTRL2                               // $60d0  
    rts                                         // $60d3  
L60d4:
    cmp #$04                                    // $60d4  
    bne L60f4                                   // $60d6  
    ldx #$04                                    // $60d8  
    lda $cf0f                                   // $60da  
    bne L60e2                                   // $60dd  
    sec                                         // $60df  
    bcs L60e8                                   // $60e0  
L60e2:
    cmp #$06                                    // $60e2  
    bcs L60e8                                   // $60e4  
    ldx #$0c                                    // $60e6  
L60e8:
    dex                                         // $60e8  
    bpl L60e8                                   // $60e9  
    lda #$00                                    // $60eb  
    sta VIC_BORDER                              // $60ed  
    sta VIC_BG0                                 // $60f0  
    rts                                         // $60f3  
L60f4:
    cmp #$05                                    // $60f4  
    bne L6105                                   // $60f6  
    lda #$00                                    // $60f8  
    ldx $cf76                                   // $60fa  
    bne L6101                                   // $60fd  
    lda #$09                                    // $60ff  
L6101:
    sta VIC_BG0                                 // $6101  
    rts                                         // $6104  
L6105:
    cmp #$06                                    // $6105  
    bne L612a                                   // $6107  
    ldx $cf87                                   // $6109  
    beq L6129                                   // $610c  
    jsr L4ca8                                   // $610e  
    lda VIC_SPR_PRIORITY                        // $6111  
    ora #$80                                    // $6114  
    sta VIC_SPR_PRIORITY                        // $6116  
    lda VIC_SPR_MULTICOLOR                      // $6119  
    and #$7f                                    // $611c  
    sta VIC_SPR_MULTICOLOR                      // $611e  
    lda #$00                                    // $6121  
    sta VIC_SPR_EXPAND_Y                        // $6123  
    sta VIC_SPR_EXPAND_X                        // $6126  
L6129:
    rts                                         // $6129  
L612a:
    cmp #$07                                    // $612a  
    bne L614b                                   // $612c  
    ldx $cf76                                   // $612e  
    beq L614a                                   // $6131  
    ldx #$2b                                    // $6133  
L6135:
    dex                                         // $6135  
    bne L6135                                   // $6136  
    ldx #$15                                    // $6138  
    ldy #$1b                                    // $613a  
    lda #$c0                                    // $613c  
    ora $cf8f                                   // $613e  
    stx VIC_MEMSETUP                            // $6141  
    sty VIC_CTRL1                               // $6144  
    sta VIC_CTRL2                               // $6147  
L614a:
    rts                                         // $614a  
L614b:
    cmp #$08                                    // $614b  
    bne L6162                                   // $614d  
    ldx $cf76                                   // $614f  
    beq L6161                                   // $6152  
    ldx #$02                                    // $6154  
L6156:
    dex                                         // $6156  
    bne L6156                                   // $6157  
    lda #$08                                    // $6159  
    sta VIC_BORDER                              // $615b  
    sta VIC_BG0                                 // $615e  
L6161:
    rts                                         // $6161  
L6162:
    cmp #$09                                    // $6162  
    bne L6179                                   // $6164  
    ldx $cf76                                   // $6166  
    beq L6178                                   // $6169  
    ldx #$0a                                    // $616b  
L616d:
    dex                                         // $616d  
    bne L616d                                   // $616e  
    lda #$09                                    // $6170  
    sta VIC_BORDER                              // $6172  
    sta VIC_BG0                                 // $6175  
L6178:
    rts                                         // $6178  
L6179:
    cmp #$0a                                    // $6179  
    bne L6192                                   // $617b  
    lda #$00                                    // $617d  
    ldx $cf76                                   // $617f  
    beq L618b                                   // $6182  
    ldx #$08                                    // $6184  
L6186:
    dex                                         // $6186  
    bne L6186                                   // $6187  
    lda #$08                                    // $6189  
L618b:
    sta VIC_BORDER                              // $618b  
    sta VIC_BG0                                 // $618e  
    rts                                         // $6191  
L6192:
    cmp #$0b                                    // $6192  
    bne L61a8                                   // $6194  
    ldx $cf76                                   // $6196  
    beq L61a8                                   // $6199  
    ldx #$08                                    // $619b  
L619d:
    dex                                         // $619d  
    bne L619d                                   // $619e  
    lda #$0c                                    // $61a0  
    sta VIC_BORDER                              // $61a2  
    sta VIC_BG0                                 // $61a5  
L61a8:
    rts                                         // $61a8  
D61a9:
    .byte $2a,$31,$39,$3e,$53,$69,$c7,$e1,$e7,$f0,$f6,$fa,$ff,$ff  // $61a9  
L61b7:
    lda $ceff                                   // $61b7  
    beq L61bf                                   // $61ba  
    jsr L1a84                                   // $61bc  
L61bf:
    lda $cf87                                   // $61bf  
    bne L61d1                                   // $61c2  
    lda $cf52                                   // $61c4  
    beq L61d1                                   // $61c7  
    jsr L1ab6                                   // $61c9  
    and #$1f                                    // $61cc  
    sta $cf54                                   // $61ce  
L61d1:
    jsr L66ed                                   // $61d1  
    lda $cf54                                   // $61d4  
    sta $cf8c                                   // $61d7  
    lda $cf4e                                   // $61da  
    ora $cf4d                                   // $61dd  
    bne L6255                                   // $61e0  
    lda VIC_SPR_BG_COLL                         // $61e2  
    and #$08                                    // $61e5  
    beq L6225                                   // $61e7  
    lda #$01                                    // $61e9  
    sta $cf4e                                   // $61eb  
    lda #$00                                    // $61ee  
    sta $cf00                                   // $61f0  
    sta $cf01                                   // $61f3  
    sta $cf52                                   // $61f6  
    sta $cf53                                   // $61f9  
    sta $cf51                                   // $61fc  
    sta $cf50                                   // $61ff  
    sta $cfa3                                   // $6202  
    sta $cfbf                                   // $6205  
    lda #$1f                                    // $6208  
    sta $cf54                                   // $620a  
    lda $cfb6                                   // $620d  
    beq L6222                                   // $6210  
    lda #$00                                    // $6212  
    sta $cfb6                                   // $6214  
    sta SID_V2_CTRL                             // $6217  
    lda #$01                                    // $621a  
    sta $cfb4                                   // $621c  
    jsr L74c4                                   // $621f  
L6222:
    jmp L6255                                   // $6222  
L6225:
    jsr L4e8a                                   // $6225  
    bcc L6255                                   // $6228  
    lda #$01                                    // $622a  
    sta $cf4d                                   // $622c  
    lda #$00                                    // $622f  
    sta $cf52                                   // $6231  
    sta $cf53                                   // $6234  
    sta $cf50                                   // $6237  
    sta $cf9a                                   // $623a  
    sta $cfb5                                   // $623d  
    lda #$1f                                    // $6240  
    sta $cf54                                   // $6242  
    lda $cfb6                                   // $6245  
    beq L6255                                   // $6248  
    lda #$00                                    // $624a  
    sta $cfb6                                   // $624c  
    sta SID_V2_CTRL                             // $624f  
    jsr L7482                                   // $6252  
L6255:
    dec $cf5d                                   // $6255  
    bpl L625f                                   // $6258  
    lda #$05                                    // $625a  
    sta $cf5d                                   // $625c  
L625f:
    lda $cfbc                                   // $625f  
    beq L626e                                   // $6262  
    dec $cfbc                                   // $6264  
    bne L626e                                   // $6267  
    lda #$01                                    // $6269  
    sta VIC_BG2                                 // $626b  
L626e:
    jsr L743e                                   // $626e  
    jsr L735c                                   // $6271  
    jsr L737f                                   // $6274  
    jsr L4b15                                   // $6277  
    jsr L4b5a                                   // $627a  
    jsr L4ba2                                   // $627d  
    jsr L646a                                   // $6280  
    jsr L6d28                                   // $6283  
    jsr L0a4d                                   // $6286  
    jsr L0a0b                                   // $6289  
    lda $cf53                                   // $628c  
    beq L62a0                                   // $628f  
    jsr L0d45                                   // $6291  
    jsr L19b8                                   // $6294  
    jsr L7567                                   // $6297  
    jsr L3d12                                   // $629a  
    jsr L1647                                   // $629d  
L62a0:
    lda $cf7a                                   // $62a0  
    bne L62a8                                   // $62a3  
    jsr L1596                                   // $62a5  
L62a8:
    jsr L6a90                                   // $62a8  
    lda $cfa3                                   // $62ab  
    beq L62b3                                   // $62ae  
    jsr L3bd5                                   // $62b0  
L62b3:
    lda $cf50                                   // $62b3  
    ora $cf73                                   // $62b6  
    beq L62be                                   // $62b9  
    jsr L3dbe                                   // $62bb  
L62be:
    jsr L51c4                                   // $62be  
    lda $cf73                                   // $62c1  
    beq L62c9                                   // $62c4  
    jsr L511a                                   // $62c6  
L62c9:
    lda $cf51                                   // $62c9  
    beq L62d1                                   // $62cc  
    jsr L3b2d                                   // $62ce  
L62d1:
    lda $cf87                                   // $62d1  
    beq L62d9                                   // $62d4  
    jsr L671f                                   // $62d6  
L62d9:
    ldx $cf87                                   // $62d9  
    bne L62e1                                   // $62dc  
    jsr L4ca8                                   // $62de  
L62e1:
    jsr L436b                                   // $62e1  
    jsr L69e6                                   // $62e4  
    jsr L6c08                                   // $62e7  
    jsr L6c7d                                   // $62ea  
    jsr L6e62                                   // $62ed  
    lda $cf84                                   // $62f0  
    bne L6318                                   // $62f3  
    lda $cf03                                   // $62f5  
    sta VIC_SPR3_X                              // $62f8  
    sta VIC_SPR2_X                              // $62fb  
    lda $cf06                                   // $62fe  
    sta VIC_SPR3_Y                              // $6301  
    sta VIC_SPR2_Y                              // $6304  
    lda VIC_SPR_X_MSB                           // $6307  
    ldx $cf04                                   // $630a  
    beq L6313                                   // $630d  
    ora #$0c                                    // $630f  
    bne L6315                                   // $6311  
L6313:
    and #$f3                                    // $6313  
L6315:
    sta VIC_SPR_X_MSB                           // $6315  
L6318:
    lda $ceff                                   // $6318  
    beq L6320                                   // $631b  
    jsr L6321                                   // $631d  
L6320:
    rts                                         // $6320  
L6321:
    jsr L6844                                   // $6321  
    lda $cf37                                   // $6324  
    sta $cf09                                   // $6327  
    lda $cf38                                   // $632a  
    sta $cf0a                                   // $632d  
    lda $cf09                                   // $6330  
    cmp $cf0b                                   // $6333  
    bne L6343                                   // $6336  
    lda $cf0a                                   // $6338  
    cmp $cf0c                                   // $633b  
    bne L6343                                   // $633e  
    jmp L63af                                   // $6340  
L6343:
    ldx $cf09                                   // $6343  
    stx $fb                                     // $6346  
    ldx $cf0a                                   // $6348  
    stx $fc                                     // $634b  
    jsr L0c33                                   // $634d  
    clc                                         // $6350  
    jsr L6864                                   // $6351  
    clc                                         // $6354  
    jsr L6920                                   // $6355  
    jsr L38c0                                   // $6358  
    jsr L1744                                   // $635b  
    jsr L534a                                   // $635e  
    jsr L1794                                   // $6361  
    jsr L53f8                                   // $6364  
    jsr L1806                                   // $6367  
    jsr L5450                                   // $636a  
    jsr L16f3                                   // $636d  
    jsr L53a1                                   // $6370  
    jsr L1895                                   // $6373  
    jsr L54a6                                   // $6376  
    jsr L54ff                                   // $6379  
    ldx $cf09                                   // $637c  
    stx $fb                                     // $637f  
    ldx $cf0a                                   // $6381  
    stx $fc                                     // $6384  
    jsr L11be                                   // $6386  
    jsr L12c4                                   // $6389  
    jsr L1371                                   // $638c  
    jsr L52b8                                   // $638f  
    jsr L13ca                                   // $6392  
    jsr L14ad                                   // $6395  
    jsr L14fb                                   // $6398  
    jsr L6786                                   // $639b  
    jsr L192a                                   // $639e  
    jsr L198e                                   // $63a1  
    jsr L0da4                                   // $63a4  
    jsr L72b5                                   // $63a7  
    lda #$01                                    // $63aa  
    sta $cfa7                                   // $63ac  
L63af:
    ldx $cf09                                   // $63af  
    stx $cf0b                                   // $63b2  
    ldx $cf0a                                   // $63b5  
    stx $cf0c                                   // $63b8  
    lda $cf50                                   // $63bb  
    ora $cf73                                   // $63be  
    beq L63d0                                   // $63c1  
    lda $cfa7                                   // $63c3  
    beq L63d0                                   // $63c6  
    lda #$00                                    // $63c8  
    sta $cfa7                                   // $63ca  
    jsr L6d91                                   // $63cd  
L63d0:
    rts                                         // $63d0  
L63d1:
    lda VIC_SPR_ENABLE                          // $63d1  
    and #$cc                                    // $63d4  
    sta VIC_SPR_ENABLE                          // $63d6  
    lda VIC_SPR_PRIORITY                        // $63d9  
    and #$cc                                    // $63dc  
    sta VIC_SPR_PRIORITY                        // $63de  
    lda #$00                                    // $63e1  
    sta $cf53                                   // $63e3  
    sta $cf51                                   // $63e6  
    jsr L466d                                   // $63e9  
    lda #$00                                    // $63ec  
    sta $cf82                                   // $63ee  
    lda #$50                                    // $63f1  
    sta $cf83                                   // $63f3  
    lda #$01                                    // $63f6  
    sta $cf84                                   // $63f8  
    lda #$80                                    // $63fb  
    sta SID_V1_SR                               // $63fd  
    lda #$04                                    // $6400  
    sta SID_V1_PW_HI                            // $6402  
    lda #$41                                    // $6405  
    sta SID_V1_CTRL                             // $6407  
    lda #$f0                                    // $640a  
    sta SID_V2_SR                               // $640c  
    lda #$11                                    // $640f  
    sta SID_V2_CTRL                             // $6411  
    lda #$07                                    // $6414  
    sta $cf7f                                   // $6416  
    lda #$4f                                    // $6419  
    sta $cf80                                   // $641b  
    lda #$d6                                    // $641e  
    sta $cf81                                   // $6420  
    lda VIC_SPR_X_MSB                           // $6423  
    and #$ee                                    // $6426  
    ora #$22                                    // $6428  
    sta VIC_SPR_X_MSB                           // $642a  
    lda #$db                                    // $642d  
    sta D07fc                                   // $642f  
    sta D07fd                                   // $6432  
    lda #$07                                    // $6435  
    sta VIC_SPR4_COL                            // $6437  
    sta VIC_SPR5_COL                            // $643a  
    lda #$07                                    // $643d  
    sta VIC_SPR_MC0                             // $643f  
    lda VIC_SPR_MULTICOLOR                      // $6442  
    ora #$33                                    // $6445  
    sta VIC_SPR_MULTICOLOR                      // $6447  
    lda VIC_SPR_EXPAND_X                        // $644a  
    ora #$20                                    // $644d  
    sta VIC_SPR_EXPAND_X                        // $644f  
    lda #$00                                    // $6452  
    sta $cf7a                                   // $6454  
    lda #$01                                    // $6457  
    sta $cf85                                   // $6459  
    lda #$01                                    // $645c  
    jsr L4664                                   // $645e  
    lda VIC_SPR_ENABLE                          // $6461  
    ora #$33                                    // $6464  
    sta VIC_SPR_ENABLE                          // $6466  
    rts                                         // $6469  
L646a:
    lda $cf45                                   // $646a  
    beq L6481                                   // $646d  
    lda $cf5e                                   // $646f  
    lsr                                         // $6472  
    lsr                                         // $6473  
    ldx $cf5f                                   // $6474  
    bne L647e                                   // $6477  
    eor #$ff                                    // $6479  
    clc                                         // $647b  
    adc #$01                                    // $647c  
L647e:
    sta $cf82                                   // $647e  
L6481:
    lda $cf84                                   // $6481  
    bne L6489                                   // $6484  
    jmp L64f7                                   // $6486  
L6489:
    lda $cf83                                   // $6489  
    clc                                         // $648c  
    adc $cf82                                   // $648d  
    sta $cf83                                   // $6490  
    and #$7f                                    // $6493  
    lsr                                         // $6495  
    lsr                                         // $6496  
    lsr                                         // $6497  
    lsr                                         // $6498  
    lsr                                         // $6499  
    clc                                         // $649a  
    adc #$c9                                    // $649b  
    sta D07f8                                   // $649d  
    clc                                         // $64a0  
    adc #$04                                    // $64a1  
    sta D07f9                                   // $64a3  
    ldx #$00                                    // $64a6  
    ldy #$02                                    // $64a8  
    lda $cf83                                   // $64aa  
    bpl L64b3                                   // $64ad  
    ldx #$02                                    // $64af  
    ldy #$00                                    // $64b1  
L64b3:
    stx VIC_SPR0_COL                            // $64b3  
    stx VIC_SPR1_COL                            // $64b6  
    sty VIC_SPR_MC1                             // $64b9  
    lda $cf7f                                   // $64bc  
    sta VIC_SPR0_X                              // $64bf  
    lda $cf80                                   // $64c2  
    sta VIC_SPR1_X                              // $64c5  
    lda $cf81                                   // $64c8  
    sta VIC_SPR0_Y                              // $64cb  
    sta VIC_SPR1_Y                              // $64ce  
    jsr L64f8                                   // $64d1  
    ldx $cf85                                   // $64d4  
    beq L64f7                                   // $64d7  
    lda #$00                                    // $64d9  
    sta $fa                                     // $64db  
    lda $cf82                                   // $64dd  
    bpl L64e7                                   // $64e0  
    eor #$ff                                    // $64e2  
    clc                                         // $64e4  
    adc #$01                                    // $64e5  
L64e7:
    ldx #$03                                    // $64e7  
L64e9:
    lsr                                         // $64e9  
    ror $fa                                     // $64ea  
    dex                                         // $64ec  
    bne L64e9                                   // $64ed  
    sta SID_V1_FREQ_HI                          // $64ef  
    lda $fa                                     // $64f2  
    sta SID_V1_FREQ_LO                          // $64f4  
L64f7:
    rts                                         // $64f7  
L64f8:
    lda $cf7f                                   // $64f8  
    cmp #$18                                    // $64fb  
    bcs L6504                                   // $64fd  
    ldx #$00                                    // $64ff  
    jmp L651b                                   // $6501  
L6504:
    cmp #$30                                    // $6504  
    bcs L650f                                   // $6506  
    sec                                         // $6508  
    sbc #$18                                    // $6509  
    tax                                         // $650b  
    jmp L651b                                   // $650c  
L650f:
    sec                                         // $650f  
    sbc #$30                                    // $6510  
    tax                                         // $6512  
    lda VIC_SPR_EXPAND_X                        // $6513  
    ora #$10                                    // $6516  
    jmp L6520                                   // $6518  
L651b:
    lda VIC_SPR_EXPAND_X                        // $651b  
    and #$ef                                    // $651e  
L6520:
    sta VIC_SPR_EXPAND_X                        // $6520  
    stx VIC_SPR4_X                              // $6523  
    lda $cf80                                   // $6526  
    clc                                         // $6529  
    adc #$18                                    // $652a  
    sta VIC_SPR5_X                              // $652c  
    lda $cf81                                   // $652f  
    sta VIC_SPR4_Y                              // $6532  
    sta VIC_SPR5_Y                              // $6535  
    rts                                         // $6538  
L6539:
    ldx #$e0                                    // $6539  
    lda $cf2d                                   // $653b  
    cmp #$04                                    // $653e  
    bcs L6544                                   // $6540  
    ldx #$18                                    // $6542  
L6544:
    stx $fa                                     // $6544  
    lda #$01                                    // $6546  
    sta $cf75                                   // $6548  
L654b:
    lda #$01                                    // $654b  
    jsr L4664                                   // $654d  
    inc $cf7f                                   // $6550  
    dec $cf80                                   // $6553  
    lda $cf80                                   // $6556  
    cmp #$09                                    // $6559  
    bcs L654b                                   // $655b  
    lda #$00                                    // $655d  
    sta $cf75                                   // $655f  
    sta SID_V2_FREQ_HI                          // $6562  
    sec                                         // $6565  
    jsr L3ba5                                   // $6566  
L6569:
    lda #$05                                    // $6569  
    jsr L4664                                   // $656b  
    lda $fa                                     // $656e  
    bpl L6578                                   // $6570  
    dec $cf82                                   // $6572  
    jmp L657b                                   // $6575  
L6578:
    inc $cf82                                   // $6578  
L657b:
    cmp $cf82                                   // $657b  
    bne L6569                                   // $657e  
    lda #$14                                    // $6580  
    jsr L4664                                   // $6582  
    lda #$01                                    // $6585  
    sta $cf75                                   // $6587  
L658a:
    lda #$04                                    // $658a  
    jsr L4664                                   // $658c  
    inc $cf81                                   // $658f  
    lda $cf81                                   // $6592  
    cmp #$dd                                    // $6595  
    bcc L658a                                   // $6597  
    lda #$00                                    // $6599  
    sta $cf75                                   // $659b  
    sta SID_V2_FREQ_HI                          // $659e  
    lda #$01                                    // $65a1  
    sta $cf7a                                   // $65a3  
    rts                                         // $65a6  
L65a7:
    lda #$00                                    // $65a7  
    sta $cf82                                   // $65a9  
    sta $cf7a                                   // $65ac  
    lda #$1e                                    // $65af  
    jsr L4664                                   // $65b1  
    jsr L466d                                   // $65b4  
    lda #$f0                                    // $65b7  
    sta SID_V2_SR                               // $65b9  
    lda #$11                                    // $65bc  
    sta SID_V2_CTRL                             // $65be  
    lda #$01                                    // $65c1  
    sta $cf75                                   // $65c3  
L65c6:
    lda #$04                                    // $65c6  
    jsr L4664                                   // $65c8  
    dec $cf81                                   // $65cb  
    lda $cf81                                   // $65ce  
    cmp #$d6                                    // $65d1  
    bne L65c6                                   // $65d3  
    lda #$00                                    // $65d5  
    sta $cf75                                   // $65d7  
    sta SID_V2_FREQ_HI                          // $65da  
    lda #$14                                    // $65dd  
    jsr L4664                                   // $65df  
    lda #$01                                    // $65e2  
    sta $cf75                                   // $65e4  
L65e7:
    lda #$01                                    // $65e7  
    jsr L4664                                   // $65e9  
    inc $cf80                                   // $65ec  
    dec $cf7f                                   // $65ef  
    lda $cf80                                   // $65f2  
    cmp #$4f                                    // $65f5  
    bne L65e7                                   // $65f7  
    lda #$00                                    // $65f9  
    sta $cf75                                   // $65fb  
    sta SID_V2_FREQ_HI                          // $65fe  
    lda #$14                                    // $6601  
    jsr L4664                                   // $6603  
    lda #$00                                    // $6606  
    sta $cf84                                   // $6608  
    lda VIC_SPR_ENABLE                          // $660b  
    and #$cc                                    // $660e  
    sta VIC_SPR_ENABLE                          // $6610  
    lda VIC_SPR_MULTICOLOR                      // $6613  
    and #$cc                                    // $6616  
    sta VIC_SPR_MULTICOLOR                      // $6618  
    lda VIC_SPR_EXPAND_X                        // $661b  
    and #$cc                                    // $661e  
    sta VIC_SPR_EXPAND_X                        // $6620  
    lda #$00                                    // $6623  
    sta VIC_SPR4_COL                            // $6625  
    rts                                         // $6628  
L6629:
    lda #$09                                    // $6629  
    sta SID_V3_FREQ_HI                          // $662b  
    lda #$32                                    // $662e  
    sta SID_FC_HI                               // $6630  
    lda $cf5e                                   // $6633  
    asl                                         // $6636  
    ldx $cf85                                   // $6637  
    beq L6642                                   // $663a  
    ldx $cf65                                   // $663c  
    beq L6642                                   // $663f  
    asl                                         // $6641  
L6642:
    bcc L6646                                   // $6642  
    lda #$ff                                    // $6644  
L6646:
    and #$f0                                    // $6646  
    sta $fa                                     // $6648  
    sta SID_V3_SR                               // $664a  
    lda $cf86                                   // $664d  
    cmp $fa                                     // $6650  
    bcs L6659                                   // $6652  
    lda #$80                                    // $6654  
    sta SID_V3_CTRL                             // $6656  
L6659:
    lda #$81                                    // $6659  
    sta SID_V3_CTRL                             // $665b  
    lda $fa                                     // $665e  
    sta $cf86                                   // $6660  
    rts                                         // $6663  
L6664:
    lda #$00                                    // $6664  
    sta VIC_SPR_ENABLE                          // $6666  
    sta $cf8b                                   // $6669  
    lda #$01                                    // $666c  
    sta $cf8a                                   // $666e  
    sta $cf87                                   // $6671  
    sta $cf88                                   // $6674  
    lda #$a0                                    // $6677  
    sta VIC_SPR_MULTICOLOR                      // $6679  
    lda #$0e                                    // $667c  
    sta VIC_SPR_MC1                             // $667e  
    lda #$01                                    // $6681  
    sta VIC_SPR_MC0                             // $6683  
    lda #$06                                    // $6686  
    sta VIC_SPR5_COL                            // $6688  
    lda #$00                                    // $668b  
    sta VIC_SPR7_COL                            // $668d  
    lda VIC_SPR_X_MSB                           // $6690  
    and #$5f                                    // $6693  
    sta VIC_SPR_X_MSB                           // $6695  
    lda #$a0                                    // $6698  
    sta VIC_SPR5_X                              // $669a  
    lda #$44                                    // $669d  
    sta VIC_SPR5_Y                              // $669f  
    lda #$d5                                    // $66a2  
    sta D07fd                                   // $66a4  
    rts                                         // $66a7  
    .byte $ad,$89,$cf,$f0,$3f,$ad,$4d,$cf,$0d,$4e,$cf,$2d,$8d,$cf,$f0,$0b  // $66a8  
    .byte $a9,$00,$8d,$89,$cf,$8d,$8a,$cf,$4c,$d2,$66,$ad,$54,$cf,$cd,$8c  // $66b8  
    .byte $cf,$d0,$07,$ad,$8a,$cf,$c9,$ff,$d0,$17,$ae,$8b,$cf,$ad,$8c,$cf  // $66c8  
    .byte $9d,$00,$1c,$ad,$8a,$cf,$9d,$80,$1c,$ee,$8b,$cf,$a9,$00,$8d,$8a  // $66d8  
    .byte $cf,$ee,$8a,$cf,$60                   // $66e8  
L66ed:
    lda $cf88                                   // $66ed  
    beq L671e                                   // $66f0  
    dec $cf8a                                   // $66f2  
    bne L6709                                   // $66f5  
    ldx $cf8b                                   // $66f7  
    lda D1c00,x                                 // $66fa  
    sta $cf54                                   // $66fd  
    lda D1c80,x                                 // $6700  
    sta $cf8a                                   // $6703  
    inc $cf8b                                   // $6706  
L6709:
    lda $cf8a                                   // $6709  
    beq L6719                                   // $670c  
    lda $cf4d                                   // $670e  
    ora $cf4e                                   // $6711  
    and $cf8d                                   // $6714  
    beq L671e                                   // $6717  
L6719:
    lda #$00                                    // $6719  
    sta $cf88                                   // $671b  
L671e:
    rts                                         // $671e  
L671f:
    ldx $cf8b                                   // $671f  
    cpx #$03                                    // $6722  
    bcc L674e                                   // $6724  
    cpx #$10                                    // $6726  
    bcc L672f                                   // $6728  
    lda $cf4d                                   // $672a  
    bne L674e                                   // $672d  
L672f:
    lda $cf54                                   // $672f  
    and #$0f                                    // $6732  
    eor #$0f                                    // $6734  
    tax                                         // $6736  
    lda D6776,x                                 // $6737  
    clc                                         // $673a  
    adc #$d1                                    // $673b  
    sta D07fd                                   // $673d  
    ldx #$06                                    // $6740  
    lda $cf54                                   // $6742  
    and #$10                                    // $6745  
    bne L674b                                   // $6747  
    ldx #$0e                                    // $6749  
L674b:
    stx VIC_SPR5_COL                            // $674b  
L674e:
    lda #$9a                                    // $674e  
    sta VIC_SPR7_X                              // $6750  
    lda #$41                                    // $6753  
    sta VIC_SPR7_Y                              // $6755  
    lda #$da                                    // $6758  
    sta D07ff                                   // $675a  
    lda VIC_SPR_PRIORITY                        // $675d  
    and #$7f                                    // $6760  
    sta VIC_SPR_PRIORITY                        // $6762  
    lda VIC_SPR_MULTICOLOR                      // $6765  
    ora #$80                                    // $6768  
    sta VIC_SPR_MULTICOLOR                      // $676a  
    lda #$80                                    // $676d  
    sta VIC_SPR_EXPAND_Y                        // $676f  
    sta VIC_SPR_EXPAND_X                        // $6772  
    rts                                         // $6775  
D6776:
    .byte $04,$01,$07,$04,$03,$00,$06,$04,$05,$02,$08,$05,$04,$01,$07,$04  // $6776  
L6786:
    ldy #$07                                    // $6786  
L6788:
    lda D2118,y                                 // $6788  
    sta $fa                                     // $678b  
    lsr                                         // $678d  
    ora $fa                                     // $678e  
    eor #$ff                                    // $6790  
    and D2188,y                                 // $6792  
    ora $fa                                     // $6795  
    sta D24c0,y                                 // $6797  
    lda D2138,y                                 // $679a  
    sta $fa                                     // $679d  
    lsr                                         // $679f  
    ora $fa                                     // $67a0  
    eor #$ff                                    // $67a2  
    and D21a0,y                                 // $67a4  
    ora $fa                                     // $67a7  
    sta D24c8,y                                 // $67a9  
    dey                                         // $67ac  
    bpl L6788                                   // $67ad  
    rts                                         // $67af  
L67b0:
    lda #$00                                    // $67b0  
    sta $cf93                                   // $67b2  
    lda #$0f                                    // $67b5  
    sta SID_V3_FREQ_HI                          // $67b7  
    lda #$80                                    // $67ba  
    sta SID_V3_CTRL                             // $67bc  
    lda #$00                                    // $67bf  
    sta SID_V3_FREQ_LO                          // $67c1  
    sta SID_V3_AD                               // $67c4  
    lda #$40                                    // $67c7  
    sta SID_V3_SR                               // $67c9  
    lda #$04                                    // $67cc  
    sta $cf11                                   // $67ce  
    lda #$3f                                    // $67d1  
    sta SID_MODE_VOL                            // $67d3  
    lda #$6e                                    // $67d6  
    sta SID_FC_HI                               // $67d8  
    lda #$81                                    // $67db  
    sta SID_V3_CTRL                             // $67dd  
    rts                                         // $67e0  
L67e1:
    ldx $cf2d                                   // $67e1  
    lda D398d,x                                 // $67e4  
    sta $fb                                     // $67e7  
    lda #$08                                    // $67e9  
    sta $ff                                     // $67eb  
    lda $cf9b                                   // $67ed  
    sta $fa                                     // $67f0  
L67f2:
    ror $fa                                     // $67f2  
    bcs L6826                                   // $67f4  
    ldx $fb                                     // $67f6  
    lda D3991,x                                 // $67f8  
    sta $fd                                     // $67fb  
    inx                                         // $67fd  
    lda D3991,x                                 // $67fe  
    clc                                         // $6801  
    adc #$78                                    // $6802  
    sta $fe                                     // $6804  
    inx                                         // $6806  
    ldy #$00                                    // $6807  
    lda D3991,x                                 // $6809  
    beq L6810                                   // $680c  
    ldy #$03                                    // $680e  
L6810:
    sty $f9                                     // $6810  
    lda #$02                                    // $6812  
    sta $fc                                     // $6814  
    ldx $f9                                     // $6816  
L6818:
    lda D41f0,x                                 // $6818  
    tay                                         // $681b  
    lda D6832,x                                 // $681c  
    sta ($fd),y                                 // $681f  
    inx                                         // $6821  
    dec $fc                                     // $6822  
    bpl L6818                                   // $6824  
L6826:
    lda $fb                                     // $6826  
    clc                                         // $6828  
    adc #$03                                    // $6829  
    sta $fb                                     // $682b  
    dec $ff                                     // $682d  
    bne L67f2                                   // $682f  
    rts                                         // $6831  
D6832:
    .byte $fd,$fe,$ff,$fa,$fb,$fc,$9d,$9e,$9f,$9a,$9b,$9c,$0a,$20,$02,$06  // $6832  
    .byte $20,$0e                               // $6842  
L6844:
    lda $cf94                                   // $6844  
    bne L685e                                   // $6847  
    lda $cf15                                   // $6849  
    beq L6856                                   // $684c  
    ldx $cfaf                                   // $684e  
    cmp D685f,x                                 // $6851  
    bcc L685e                                   // $6854  
L6856:
    sec                                         // $6856  
    jsr L6864                                   // $6857  
    sec                                         // $685a  
    jsr L6920                                   // $685b  
L685e:
    rts                                         // $685e  
D685f:
    .byte $86,$85,$84,$83,$82                   // $685f  
L6864:
    lda #$01                                    // $6864  
    bcs L686a                                   // $6866  
    lda #$00                                    // $6868  
L686a:
    sta $cf94                                   // $686a  
    ldx $cf09                                   // $686d  
    lda D68ea,x                                 // $6870  
    sta $fb                                     // $6873  
    lda D68f3,x                                 // $6875  
    sta $fc                                     // $6878  
    bcc L6880                                   // $687a  
    asl $fb                                     // $687c  
    asl $fc                                     // $687e  
L6880:
    ldx $cf0a                                   // $6880  
    lda D68d8,x                                 // $6883  
    sta $fd                                     // $6886  
    lda D68e1,x                                 // $6888  
    sta $fe                                     // $688b  
    lda D68fc,x                                 // $688d  
    sta $f8                                     // $6890  
    lda D6905,x                                 // $6892  
    sta $f9                                     // $6895  
    lda D690e,x                                 // $6897  
    sta $fa                                     // $689a  
    lda D6917,x                                 // $689c  
    sta $ff                                     // $689f  
    ldx #$01                                    // $68a1  
L68a3:
    lda D204f,x                                 // $68a3  
    cpx #$09                                    // $68a6  
    bcc L68b3                                   // $68a8  
    lda #$00                                    // $68aa  
    cpx #$11                                    // $68ac  
    bcc L68b3                                   // $68ae  
    lda D1fff,x                                 // $68b0  
L68b3:
    cpx $fd                                     // $68b3  
    bcc L68cf                                   // $68b5  
    cpx $fe                                     // $68b7  
    bcs L68cf                                   // $68b9  
    cpx $f8                                     // $68bb  
    beq L68cd                                   // $68bd  
    cpx $f9                                     // $68bf  
    beq L68cd                                   // $68c1  
    ora $fc                                     // $68c3  
    cpx $fa                                     // $68c5  
    bcc L68cf                                   // $68c7  
    cpx $ff                                     // $68c9  
    bcs L68cf                                   // $68cb  
L68cd:
    ora $fb                                     // $68cd  
L68cf:
    sta D27e7,x                                 // $68cf  
    inx                                         // $68d2  
    cpx #$19                                    // $68d3  
    bcc L68a3                                   // $68d5  
    rts                                         // $68d7  
D68d8:
    .byte $00,$00,$01,$03,$05,$07,$09,$0b,$0d   // $68d8  
D68e1:
    .byte $0d,$0f,$11,$13,$15,$17,$19,$19,$19   // $68e1  
D68ea:
    .byte $10,$10,$14,$14,$14,$14,$14,$04,$04   // $68ea  
D68f3:
    .byte $44,$44,$41,$41,$41,$41,$41,$11,$11   // $68f3  
D68fc:
    .byte $00,$00,$02,$04,$06,$08,$0a,$0c,$0e   // $68fc  
D6905:
    .byte $0b,$0d,$0f,$11,$13,$15,$17,$19,$19   // $6905  
D690e:
    .byte $00,$01,$03,$05,$07,$09,$0b,$0d,$0f   // $690e  
D6917:
    .byte $0b,$0d,$0f,$11,$13,$15,$17,$19,$19   // $6917  
L6920:
    ldx $cf09                                   // $6920  
    lda D69b0,x                                 // $6923  
    sta $f8                                     // $6926  
    lda D69b9,x                                 // $6928  
    sta $f9                                     // $692b  
    lda D69c2,x                                 // $692d  
    sta $fa                                     // $6930  
    lda D69cb,x                                 // $6932  
    sta $fb                                     // $6935  
    lda D69d4,x                                 // $6937  
    sta $fc                                     // $693a  
    lda D69dd,x                                 // $693c  
    sta $fd                                     // $693f  
    bcc L694f                                   // $6941  
    asl $f8                                     // $6943  
    asl $f9                                     // $6945  
    asl $fa                                     // $6947  
    asl $fb                                     // $6949  
    asl $fc                                     // $694b  
    asl $fd                                     // $694d  
L694f:
    ldx $cf0a                                   // $694f  
    lda D699e,x                                 // $6952  
    sta $fe                                     // $6955  
    lda D69a7,x                                 // $6957  
    sta $ff                                     // $695a  
    ldx #$07                                    // $695c  
L695e:
    ldy #$00                                    // $695e  
    lda D2030,x                                 // $6960  
    cpx $fe                                     // $6963  
    bcc L697a                                   // $6965  
    beq L6976                                   // $6967  
    cpx $ff                                     // $6969  
    beq L6976                                   // $696b  
    bcs L697a                                   // $696d  
    ldy $fc                                     // $696f  
    ora $fb                                     // $6971  
    jmp L697a                                   // $6973  
L6976:
    ldy $f9                                     // $6976  
    ora $f8                                     // $6978  
L697a:
    sta D27d0,x                                 // $697a  
    tya                                         // $697d  
    sta D27d8,x                                 // $697e  
    lda D2070,x                                 // $6981  
    cpx $fe                                     // $6984  
    bcc L6997                                   // $6986  
    beq L6995                                   // $6988  
    cpx $ff                                     // $698a  
    beq L6995                                   // $698c  
    bcs L6997                                   // $698e  
    ora $fd                                     // $6990  
    jmp L6997                                   // $6992  
L6995:
    ora $fa                                     // $6995  
L6997:
    sta D27e0,x                                 // $6997  
    dex                                         // $699a  
    bpl L695e                                   // $699b  
    rts                                         // $699d  
D699e:
    .byte $00,$00,$00,$00,$01,$01,$02,$02,$03   // $699e  
D69a7:
    .byte $04,$05,$05,$06,$07,$07,$07,$07,$07   // $69a7  
D69b0:
    .byte $55,$55,$15,$45,$11,$04,$01,$00,$00   // $69b0  
D69b9:
    .byte $44,$51,$54,$55,$55,$55,$15,$45,$11   // $69b9  
D69c2:
    .byte $00,$00,$40,$10,$44,$51,$54,$55,$55   // $69c2  
D69cb:
    .byte $55,$55,$55,$15,$05,$01,$00,$00,$00   // $69cb  
D69d4:
    .byte $50,$54,$55,$55,$55,$55,$55,$15,$05   // $69d4  
D69dd:
    .byte $00,$00,$00,$40,$50,$54,$55,$55,$55   // $69dd  
L69e6:
    lda $cf9c                                   // $69e6  
    beq L69ff                                   // $69e9  
    dec $cf9c                                   // $69eb  
    bne L69ff                                   // $69ee  
    lda #$02                                    // $69f0  
    sta $cf9c                                   // $69f2  
    ldx $cf55                                   // $69f5  
    bne L6a02                                   // $69f8  
    lda #$00                                    // $69fa  
    sta $cf9c                                   // $69fc  
L69ff:
    jmp L6a65                                   // $69ff  
L6a02:
    dex                                         // $6a02  
    stx $cf55                                   // $6a03  
    lda D7800,x                                 // $6a06  
    sta $fd                                     // $6a09  
    lda D7900,x                                 // $6a0b  
    sta $fe                                     // $6a0e  
    ldy #$00                                    // $6a10  
    lda ($fd),y                                 // $6a12  
    cmp #$63                                    // $6a14  
    beq L6a1c                                   // $6a16  
    cmp #$b2                                    // $6a18  
    bne L6a23                                   // $6a1a  
L6a1c:
    lda #$20                                    // $6a1c  
    sta ($fd),y                                 // $6a1e  
    jmp L6a2b                                   // $6a20  
L6a23:
    ldx $cf9a                                   // $6a23  
    bne L6a2b                                   // $6a26  
    jsr L6a66                                   // $6a28  
L6a2b:
    ldx $cf55                                   // $6a2b  
    beq L6a47                                   // $6a2e  
    dex                                         // $6a30  
    lda D7800,x                                 // $6a31  
    sta $fd                                     // $6a34  
    lda D7900,x                                 // $6a36  
    sta $fe                                     // $6a39  
    ldy #$00                                    // $6a3b  
    lda ($fd),y                                 // $6a3d  
    cmp #$63                                    // $6a3f  
    bne L6a47                                   // $6a41  
    lda #$b2                                    // $6a43  
    sta ($fd),y                                 // $6a45  
L6a47:
    lda $cf9a                                   // $6a47  
    bne L6a5d                                   // $6a4a  
    lda $cfb4                                   // $6a4c  
    bne L6a5d                                   // $6a4f  
    lda #$12                                    // $6a51  
    ldx $cf4d                                   // $6a53  
    beq L6a5a                                   // $6a56  
    lda #$28                                    // $6a58  
L6a5a:
    jsr L732a                                   // $6a5a  
L6a5d:
    lda $cf9a                                   // $6a5d  
    beq L6a65                                   // $6a60  
    dec $cf9a                                   // $6a62  
L6a65:
    rts                                         // $6a65  
L6a66:
    cmp #$fb                                    // $6a66  
    beq L6a6e                                   // $6a68  
    cmp #$fe                                    // $6a6a  
    bne L6a74                                   // $6a6c  
L6a6e:
    jsr L6ba7                                   // $6a6e  
    jmp L6a8f                                   // $6a71  
L6a74:
    cmp #$00                                    // $6a74  
    bne L6a7d                                   // $6a76  
    lda #$29                                    // $6a78  
    jmp L6a8c                                   // $6a7a  
L6a7d:
    cmp #$29                                    // $6a7d  
    bne L6a86                                   // $6a7f  
    lda #$52                                    // $6a81  
    jmp L6a8c                                   // $6a83  
L6a86:
    cmp #$25                                    // $6a86  
    bne L6a8f                                   // $6a88  
    lda #$51                                    // $6a8a  
L6a8c:
    jsr L6b56                                   // $6a8c  
L6a8f:
    rts                                         // $6a8f  
L6a90:
    lda $cfa5                                   // $6a90  
    bne L6a98                                   // $6a93  
    jmp L6b16                                   // $6a95  
L6a98:
    lda $cfa0                                   // $6a98  
    bne L6aa5                                   // $6a9b  
    sta $cfbb                                   // $6a9d  
    lda #$00                                    // $6aa0  
    jmp L6ab8                                   // $6aa2  
L6aa5:
    ldx $cfbb                                   // $6aa5  
    dex                                         // $6aa8  
    bpl L6aad                                   // $6aa9  
    ldx #$01                                    // $6aab  
L6aad:
    stx $cfbb                                   // $6aad  
    lda #$01                                    // $6ab0  
    cpx #$01                                    // $6ab2  
    bcs L6ab8                                   // $6ab4  
    lda #$0c                                    // $6ab6  
L6ab8:
    jsr L755d                                   // $6ab8  
    lda $cf5d                                   // $6abb  
    and #$01                                    // $6abe  
    bne L6ad9                                   // $6ac0  
    lda $cf9c                                   // $6ac2  
    beq L6b0c                                   // $6ac5  
    ldx #$8f                                    // $6ac7  
    ldy #$0a                                    // $6ac9  
    lda $cf4d                                   // $6acb  
    beq L6ad4                                   // $6ace  
    ldx #$18                                    // $6ad0  
    ldy #$0e                                    // $6ad2  
L6ad4:
    lda #$11                                    // $6ad4  
    jmp L6b00                                   // $6ad6  
L6ad9:
    lda $cfa0                                   // $6ad9  
    beq L6b0c                                   // $6adc  
    dec $cfa0                                   // $6ade  
    lda #$50                                    // $6ae1  
    ldx #$00                                    // $6ae3  
    ldy $cf4d                                   // $6ae5  
    beq L6aee                                   // $6ae8  
    lda #$00                                    // $6aea  
    ldx #$01                                    // $6aec  
L6aee:
    jsr L4a9f                                   // $6aee  
    ldx #$a5                                    // $6af1  
    ldy #$1f                                    // $6af3  
    lda $cf4d                                   // $6af5  
    beq L6afe                                   // $6af8  
    ldx #$3e                                    // $6afa  
    ldy #$2a                                    // $6afc  
L6afe:
    lda #$11                                    // $6afe  
L6b00:
    stx SID_V3_FREQ_LO                          // $6b00  
    sty SID_V3_FREQ_HI                          // $6b03  
    sta SID_V3_CTRL                             // $6b06  
    jmp L6b16                                   // $6b09  
L6b0c:
    lda #$00                                    // $6b0c  
    sta SID_V3_FREQ_LO                          // $6b0e  
    lda #$00                                    // $6b11  
    sta SID_V3_FREQ_HI                          // $6b13  
L6b16:
    rts                                         // $6b16  
L6b17:
    sta $fa                                     // $6b17  
    lda $fd                                     // $6b19  
    sec                                         // $6b1b  
    sbc $fa                                     // $6b1c  
    sta $fb                                     // $6b1e  
    lda $fe                                     // $6b20  
    sbc #$00                                    // $6b22  
    sta $fc                                     // $6b24  
    ldx $cf2d                                   // $6b26  
    lda D398d,x                                 // $6b29  
    sta $fa                                     // $6b2c  
    lda #$01                                    // $6b2e  
    sta $ff                                     // $6b30  
    ldy #$08                                    // $6b32  
L6b34:
    ldx $fa                                     // $6b34  
    lda D3991,x                                 // $6b36  
    cmp $fb                                     // $6b39  
    bne L6b45                                   // $6b3b  
    inx                                         // $6b3d  
    lda D3991,x                                 // $6b3e  
    cmp $fc                                     // $6b41  
    beq L6b54                                   // $6b43  
L6b45:
    lda $fa                                     // $6b45  
    clc                                         // $6b47  
    adc #$03                                    // $6b48  
    sta $fa                                     // $6b4a  
    asl $ff                                     // $6b4c  
    dey                                         // $6b4e  
    bne L6b34                                   // $6b4f  
    sec                                         // $6b51  
    bcs L6b55                                   // $6b52  
L6b54:
    clc                                         // $6b54  
L6b55:
    rts                                         // $6b55  
L6b56:
    jsr L6b17                                   // $6b56  
    bcs L6b8b                                   // $6b59  
    lda $ff                                     // $6b5b  
    eor #$ff                                    // $6b5d  
    and $cf9b                                   // $6b5f  
    sta $cf9b                                   // $6b62  
    lda $fa                                     // $6b65  
    ldx $cf96                                   // $6b67  
    beq L6b7b                                   // $6b6a  
    pha                                         // $6b6c  
    lda #$04                                    // $6b6d  
    sta $cf99                                   // $6b6f  
    lda #$01                                    // $6b72  
    sta $cf96                                   // $6b74  
    jsr L6c08                                   // $6b77  
    pla                                         // $6b7a  
L6b7b:
    sta $cf98                                   // $6b7b  
    lda #$00                                    // $6b7e  
    sta $cf99                                   // $6b80  
    lda #$01                                    // $6b83  
    sta $cf96                                   // $6b85  
    jsr L6b8c                                   // $6b88  
L6b8b:
    rts                                         // $6b8b  
L6b8c:
    lda #$00                                    // $6b8c  
    sta SID_V2_CTRL                             // $6b8e  
    sta SID_V2_SR                               // $6b91  
    sta SID_V2_FREQ_LO                          // $6b94  
    lda #$04                                    // $6b97  
    sta SID_V2_AD                               // $6b99  
    lda #$ff                                    // $6b9c  
    sta SID_V2_FREQ_HI                          // $6b9e  
    lda #$81                                    // $6ba1  
    sta SID_V2_CTRL                             // $6ba3  
    rts                                         // $6ba6  
L6ba7:
    lda #$29                                    // $6ba7  
    jsr L6b17                                   // $6ba9  
    bcs L6c07                                   // $6bac  
    lda $fa                                     // $6bae  
    ldx $cf9d                                   // $6bb0  
    beq L6bbf                                   // $6bb3  
    pha                                         // $6bb5  
    lda #$01                                    // $6bb6  
    sta $cf9d                                   // $6bb8  
    jsr L6c7d                                   // $6bbb  
    pla                                         // $6bbe  
L6bbf:
    sta $cf9e                                   // $6bbf  
    lda #$10                                    // $6bc2  
    sta $cf9d                                   // $6bc4  
    lda #$00                                    // $6bc7  
    sta SID_V2_CTRL                             // $6bc9  
    sta SID_V2_AD                               // $6bcc  
    sta SID_V2_PW_LO                            // $6bcf  
    sta SID_V2_PW_HI                            // $6bd2  
    lda #$50                                    // $6bd5  
    sta SID_V2_SR                               // $6bd7  
    lda #$41                                    // $6bda  
    sta SID_V2_CTRL                             // $6bdc  
    ldx #$15                                    // $6bdf  
    ldy #$1f                                    // $6be1  
    lda $cf4d                                   // $6be3  
    beq L6bec                                   // $6be6  
    ldx #$1c                                    // $6be8  
    ldy #$31                                    // $6bea  
L6bec:
    stx SID_V2_FREQ_HI                          // $6bec  
    sty SID_V2_FREQ_LO                          // $6bef  
    lda #$02                                    // $6bf2  
    jsr L74fb                                   // $6bf4  
    lda #$0a                                    // $6bf7  
    ldx $cf4d                                   // $6bf9  
    bne L6c00                                   // $6bfc  
    lda #$0a                                    // $6bfe  
L6c00:
    clc                                         // $6c00  
    adc $cfa0                                   // $6c01  
    sta $cfa0                                   // $6c04  
L6c07:
    rts                                         // $6c07  
L6c08:
    lda $cf96                                   // $6c08  
    beq L6c61                                   // $6c0b  
    dec $cf96                                   // $6c0d  
    bne L6c61                                   // $6c10  
    lda #$01                                    // $6c12  
    ldx $cf4d                                   // $6c14  
    bne L6c1b                                   // $6c17  
    lda #$02                                    // $6c19  
L6c1b:
    sta $cf96                                   // $6c1b  
    inc $cf99                                   // $6c1e  
    lda $cf99                                   // $6c21  
    cmp #$05                                    // $6c24  
    bcc L6c45                                   // $6c26  
    jsr L6c62                                   // $6c28  
    ldx #$00                                    // $6c2b  
    stx $cf96                                   // $6c2d  
    lda #$01                                    // $6c30  
    jsr L74fb                                   // $6c32  
    lda #$05                                    // $6c35  
    ldx $cf4d                                   // $6c37  
    bne L6c3e                                   // $6c3a  
    lda #$05                                    // $6c3c  
L6c3e:
    clc                                         // $6c3e  
    adc $cfa0                                   // $6c3f  
    sta $cfa0                                   // $6c42  
L6c45:
    lda $cf99                                   // $6c45  
    asl                                         // $6c48  
    sta $fb                                     // $6c49  
    asl                                         // $6c4b  
    asl                                         // $6c4c  
    clc                                         // $6c4d  
    adc $fb                                     // $6c4e  
    sta $cf32                                   // $6c50  
    lda #$00                                    // $6c53  
    sta $cf3a                                   // $6c55  
    lda $cf98                                   // $6c58  
    sta $cf31                                   // $6c5b  
    jsr L3939                                   // $6c5e  
L6c61:
    rts                                         // $6c61  
L6c62:
    lda #$00                                    // $6c62  
    sta SID_V1_CTRL                             // $6c64  
    sta SID_V1_SR                               // $6c67  
    sta SID_V1_FREQ_LO                          // $6c6a  
    lda #$09                                    // $6c6d  
    sta SID_V1_AD                               // $6c6f  
    lda #$64                                    // $6c72  
    sta SID_V1_FREQ_HI                          // $6c74  
    lda #$81                                    // $6c77  
    sta SID_V1_CTRL                             // $6c79  
    rts                                         // $6c7c  
L6c7d:
    lda $cf9d                                   // $6c7d  
    bne L6c85                                   // $6c80  
    jmp L6cf5                                   // $6c82  
L6c85:
    dec $cf9d                                   // $6c85  
    bne L6c9a                                   // $6c88  
    lda #$05                                    // $6c8a  
    ldx $cf4d                                   // $6c8c  
    bne L6c93                                   // $6c8f  
    lda #$05                                    // $6c91  
L6c93:
    clc                                         // $6c93  
    adc $cfa0                                   // $6c94  
    lda $cfa0                                   // $6c97  
L6c9a:
    ldx $cf9e                                   // $6c9a  
    lda D3991,x                                 // $6c9d  
    sta $fb                                     // $6ca0  
    inx                                         // $6ca2  
    lda D3991,x                                 // $6ca3  
    sta $fc                                     // $6ca6  
    inx                                         // $6ca8  
    ldy D3991,x                                 // $6ca9  
    sty $fa                                     // $6cac  
    lda $cf9d                                   // $6cae  
    bne L6cbc                                   // $6cb1  
    iny                                         // $6cb3  
    iny                                         // $6cb4  
    iny                                         // $6cb5  
    iny                                         // $6cb6  
    lda #$00                                    // $6cb7  
    jmp L6cc8                                   // $6cb9  
L6cbc:
    and #$03                                    // $6cbc  
    cmp #$01                                    // $6cbe  
    bcc L6cc4                                   // $6cc0  
    iny                                         // $6cc2  
    iny                                         // $6cc3  
L6cc4:
    tax                                         // $6cc4  
    lda D6cf6,x                                 // $6cc5  
L6cc8:
    sta SID_V2_PW_HI                            // $6cc8  
    tya                                         // $6ccb  
    sta $f8                                     // $6ccc  
    asl                                         // $6cce  
    clc                                         // $6ccf  
    adc $f8                                     // $6cd0  
    sta $f8                                     // $6cd2  
    lda $fa                                     // $6cd4  
    asl                                         // $6cd6  
    clc                                         // $6cd7  
    adc $fa                                     // $6cd8  
    sta $fa                                     // $6cda  
    lda #$02                                    // $6cdc  
    sta $f9                                     // $6cde  
L6ce0:
    ldy $fa                                     // $6ce0  
    lda D41f0,y                                 // $6ce2  
    tay                                         // $6ce5  
    ldx $f8                                     // $6ce6  
    lda D6832,x                                 // $6ce8  
    sta ($fb),y                                 // $6ceb  
    inc $fa                                     // $6ced  
    inc $f8                                     // $6cef  
    dec $f9                                     // $6cf1  
    bpl L6ce0                                   // $6cf3  
L6cf5:
    rts                                         // $6cf5  
D6cf6:
    .byte $08,$07,$06,$05                       // $6cf6  
L6cfa:
    lda #$01                                    // $6cfa  
    jsr L4664                                   // $6cfc  
    lda $cf94                                   // $6cff  
    clc                                         // $6d02  
    pha                                         // $6d03  
    bne L6d07                                   // $6d04  
    sec                                         // $6d06  
L6d07:
    php                                         // $6d07  
    jsr L6864                                   // $6d08  
    plp                                         // $6d0b  
    jsr L6920                                   // $6d0c  
    ldx #$2f                                    // $6d0f  
L6d11:
    lda D27d0,x                                 // $6d11  
    sta D24d0,x                                 // $6d14  
    dex                                         // $6d17  
    bpl L6d11                                   // $6d18  
    clc                                         // $6d1a  
    pla                                         // $6d1b  
    beq L6d1f                                   // $6d1c  
    sec                                         // $6d1e  
L6d1f:
    php                                         // $6d1f  
    jsr L6864                                   // $6d20  
    plp                                         // $6d23  
    jsr L6920                                   // $6d24  
    rts                                         // $6d27  
L6d28:
    lda $cf18                                   // $6d28  
    beq L6d90                                   // $6d2b  
    dec $cf17                                   // $6d2d  
    bpl L6d3a                                   // $6d30  
    lda #$02                                    // $6d32  
    sta $cf17                                   // $6d34  
    inc $cf18                                   // $6d37  
L6d3a:
    ldx $cf17                                   // $6d3a  
    lda #$00                                    // $6d3d  
    cpx #$00                                    // $6d3f  
    beq L6d51                                   // $6d41  
    lda #$01                                    // $6d43  
    cpx #$02                                    // $6d45  
    beq L6d51                                   // $6d47  
    ldy $cf2d                                   // $6d49  
    lda D4195,y                                 // $6d4c  
    and #$07                                    // $6d4f  
L6d51:
    ldy $cf18                                   // $6d51  
    cpy #$10                                    // $6d54  
    bne L6d63                                   // $6d56  
    cpx #$00                                    // $6d58  
    bne L6d61                                   // $6d5a  
    ldy #$00                                    // $6d5c  
    sty $cf18                                   // $6d5e  
L6d61:
    lda #$01                                    // $6d61  
L6d63:
    sta VIC_BG2                                 // $6d63  
    cpx #$02                                    // $6d66  
    bne L6d7e                                   // $6d68  
    lda #$64                                    // $6d6a  
    sta SID_V2_FREQ_HI                          // $6d6c  
    lda #$70                                    // $6d6f  
    sta SID_V1_FREQ_HI                          // $6d71  
    lda #$00                                    // $6d74  
    sta SID_V2_FREQ_LO                          // $6d76  
    lda #$00                                    // $6d79  
    sta SID_V1_FREQ_LO                          // $6d7b  
L6d7e:
    cpx #$00                                    // $6d7e  
    bne L6d90                                   // $6d80  
    lda #$00                                    // $6d82  
    sta SID_V2_FREQ_HI                          // $6d84  
    sta SID_V1_FREQ_HI                          // $6d87  
    sta SID_V2_FREQ_LO                          // $6d8a  
    sta SID_V1_FREQ_LO                          // $6d8d  
L6d90:
    rts                                         // $6d90  
L6d91:
    ldx $cf09                                   // $6d91  
    lda D6e59,x                                 // $6d94  
    sta $f8                                     // $6d97  
    ldx $cf0a                                   // $6d99  
    lda D6e59,x                                 // $6d9c  
    sta $f9                                     // $6d9f  
    lda D07fb                                   // $6da1  
    jsr L6dd2                                   // $6da4  
    lda $fa                                     // $6da7  
    beq L6db5                                   // $6da9  
L6dab:
    lda ($fb),y                                 // $6dab  
    sta D3700,y                                 // $6dad  
    iny                                         // $6db0  
    cpy $fa                                     // $6db1  
    bcc L6dab                                   // $6db3  
L6db5:
    lda ($fb),y                                 // $6db5  
    and D3880,x                                 // $6db7  
    sta D3700,y                                 // $6dba  
    inx                                         // $6dbd  
    iny                                         // $6dbe  
    cpy $ff                                     // $6dbf  
    bcc L6db5                                   // $6dc1  
    cpy #$3f                                    // $6dc3  
    bcs L6dd1                                   // $6dc5  
L6dc7:
    lda ($fb),y                                 // $6dc7  
    sta D3700,y                                 // $6dc9  
    iny                                         // $6dcc  
    cpy #$3f                                    // $6dcd  
    bcc L6dc7                                   // $6dcf  
L6dd1:
    rts                                         // $6dd1  
L6dd2:
    ldx #$00                                    // $6dd2  
    stx $fb                                     // $6dd4  
    lsr                                         // $6dd6  
    ror $fb                                     // $6dd7  
    lsr                                         // $6dd9  
    ror $fb                                     // $6dda  
    sta $fc                                     // $6ddc  
    ldy #$3e                                    // $6dde  
L6de0:
    lda ($fb),y                                 // $6de0  
    eor #$ff                                    // $6de2  
    sta D3880,y                                 // $6de4  
    dey                                         // $6de7  
    bpl L6de0                                   // $6de8  
    lda $f8                                     // $6dea  
    cmp #$04                                    // $6dec  
    beq L6e28                                   // $6dee  
    bcs L6e10                                   // $6df0  
    sta $fa                                     // $6df2  
    lda #$04                                    // $6df4  
    sec                                         // $6df6  
    sbc $fa                                     // $6df7  
    tay                                         // $6df9  
L6dfa:
    ldx #$3c                                    // $6dfa  
L6dfc:
    sec                                         // $6dfc  
    ror D3880,x                                 // $6dfd  
    ror D3881,x                                 // $6e00  
    ror D3882,x                                 // $6e03  
    dex                                         // $6e06  
    dex                                         // $6e07  
    dex                                         // $6e08  
    bpl L6dfc                                   // $6e09  
    dey                                         // $6e0b  
    bne L6dfa                                   // $6e0c  
    beq L6e28                                   // $6e0e  
L6e10:
    sec                                         // $6e10  
    sbc #$04                                    // $6e11  
    tay                                         // $6e13  
L6e14:
    ldx #$3c                                    // $6e14  
L6e16:
    sec                                         // $6e16  
    rol D3882,x                                 // $6e17  
    rol D3881,x                                 // $6e1a  
    rol D3880,x                                 // $6e1d  
    dex                                         // $6e20  
    dex                                         // $6e21  
    dex                                         // $6e22  
    bpl L6e16                                   // $6e23  
    dey                                         // $6e25  
    bne L6e14                                   // $6e26  
L6e28:
    ldx #$00                                    // $6e28  
    ldy #$3f                                    // $6e2a  
    lda $f9                                     // $6e2c  
    cmp #$04                                    // $6e2e  
    beq L6e44                                   // $6e30  
    bcs L6e3c                                   // $6e32  
    tax                                         // $6e34  
    lda D6e51,x                                 // $6e35  
    tax                                         // $6e38  
    jmp L6e44                                   // $6e39  
L6e3c:
    sec                                         // $6e3c  
    sbc #$05                                    // $6e3d  
    tay                                         // $6e3f  
    lda D6e55,y                                 // $6e40  
    tay                                         // $6e43  
L6e44:
    stx $fa                                     // $6e44  
    sty $ff                                     // $6e46  
    lda #$3f                                    // $6e48  
    sec                                         // $6e4a  
    sbc $ff                                     // $6e4b  
    tax                                         // $6e4d  
    ldy #$00                                    // $6e4e  
    rts                                         // $6e50  
D6e51:
    .byte $0c,$09,$06,$03                       // $6e51  
D6e55:
    .byte $3c,$39,$36,$33                       // $6e55  
D6e59:
    .byte $02,$03,$03,$04,$04,$04,$05,$05,$06   // $6e59  
L6e62:
    ldx $cfa8                                   // $6e62  
    beq L6ebd                                   // $6e65  
    dex                                         // $6e67  
    bne L6eba                                   // $6e68  
    lda $cfa9                                   // $6e6a  
    bne L6e8d                                   // $6e6d  
    ldx #$00                                    // $6e6f  
    stx SID_V1_CTRL                             // $6e71  
    stx SID_V1_AD                               // $6e74  
    stx SID_V2_CTRL                             // $6e77  
    stx SID_V2_AD                               // $6e7a  
    ldx #$70                                    // $6e7d  
    stx SID_V1_SR                               // $6e7f  
    stx SID_V2_SR                               // $6e82  
    ldx #$21                                    // $6e85  
    stx SID_V1_CTRL                             // $6e87  
    stx SID_V2_CTRL                             // $6e8a  
L6e8d:
    ldx #$00                                    // $6e8d  
    ldy #$00                                    // $6e8f  
    and #$01                                    // $6e91  
    beq L6e99                                   // $6e93  
    ldx #$31                                    // $6e95  
    ldy #$1c                                    // $6e97  
L6e99:
    stx SID_V1_FREQ_LO                          // $6e99  
    sty SID_V1_FREQ_HI                          // $6e9c  
    ldx #$00                                    // $6e9f  
    ldy #$00                                    // $6ea1  
    and #$01                                    // $6ea3  
    beq L6eab                                   // $6ea5  
    ldx #$78                                    // $6ea7  
    ldy #$1c                                    // $6ea9  
L6eab:
    stx SID_V2_FREQ_LO                          // $6eab  
    sty SID_V2_FREQ_HI                          // $6eae  
    ldy $cfa9                                   // $6eb1  
    ldx D6ebe,y                                 // $6eb4  
    inc $cfa9                                   // $6eb7  
L6eba:
    stx $cfa8                                   // $6eba  
L6ebd:
    rts                                         // $6ebd  
D6ebe:
    .byte $02,$06,$06,$05,$01,$06,$06,$05,$01,$06,$00  // $6ebe  
L6ec9:
    ldx #$0c                                    // $6ec9  
    lda #$00                                    // $6ecb  
L6ecd:
    sta D3759,x                                 // $6ecd  
    dex                                         // $6ed0  
    dex                                         // $6ed1  
    dex                                         // $6ed2  
    bpl L6ecd                                   // $6ed3  
    lda $cf42                                   // $6ed5  
    cmp #$02                                    // $6ed8  
    bcs L6ee3                                   // $6eda  
    lda $cf43                                   // $6edc  
    cmp #$02                                    // $6edf  
    bcc L6ee6                                   // $6ee1  
L6ee3:
    jmp L6fca                                   // $6ee3  
L6ee6:
    ldx #$04                                    // $6ee6  
L6ee8:
    lda D6fe1,x                                 // $6ee8  
    sta D6fee,x                                 // $6eeb  
    dex                                         // $6eee  
    bpl L6ee8                                   // $6eef  
    lda $cf3c                                   // $6ef1  
    ldx $cf42                                   // $6ef4  
    jsr L6fcb                                   // $6ef7  
    stx $f8                                     // $6efa  
    lda $cf3d                                   // $6efc  
    ldx $cf43                                   // $6eff  
    jsr L6fcb                                   // $6f02  
    stx $f9                                     // $6f05  
    lda $f8                                     // $6f07  
    beq L6f2a                                   // $6f09  
    bmi L6f1b                                   // $6f0b  
    tay                                         // $6f0d  
L6f0e:
    ldx #$04                                    // $6f0e  
L6f10:
    lsr D6fee,x                                 // $6f10  
    dex                                         // $6f13  
    bpl L6f10                                   // $6f14  
    dey                                         // $6f16  
    bne L6f0e                                   // $6f17  
    beq L6f2a                                   // $6f19  
L6f1b:
    eor #$ff                                    // $6f1b  
    tay                                         // $6f1d  
    iny                                         // $6f1e  
L6f1f:
    ldx #$04                                    // $6f1f  
L6f21:
    asl D6fee,x                                 // $6f21  
    dex                                         // $6f24  
    bpl L6f21                                   // $6f25  
    dey                                         // $6f27  
    bne L6f1f                                   // $6f28  
L6f2a:
    ldx #$00                                    // $6f2a  
    ldy #$05                                    // $6f2c  
    lda $f9                                     // $6f2e  
    beq L6f3c                                   // $6f30  
    bmi L6f38                                   // $6f32  
    tax                                         // $6f34  
    jmp L6f3c                                   // $6f35  
L6f38:
    clc                                         // $6f38  
    adc #$05                                    // $6f39  
    tay                                         // $6f3b  
L6f3c:
    stx $fa                                     // $6f3c  
    sty $ff                                     // $6f3e  
    lda #$05                                    // $6f40  
    sec                                         // $6f42  
    sbc $ff                                     // $6f43  
    tax                                         // $6f45  
    ldy #$00                                    // $6f46  
    lda $fa                                     // $6f48  
    beq L6f56                                   // $6f4a  
    lda #$00                                    // $6f4c  
L6f4e:
    sta D6fe6,y                                 // $6f4e  
    iny                                         // $6f51  
    cpy $fa                                     // $6f52  
    bcc L6f4e                                   // $6f54  
L6f56:
    lda D6fee,x                                 // $6f56  
    and D6fe1,y                                 // $6f59  
    sta D6fe6,y                                 // $6f5c  
    inx                                         // $6f5f  
    iny                                         // $6f60  
    cpy $ff                                     // $6f61  
    bcc L6f56                                   // $6f63  
    cpy #$05                                    // $6f65  
    bcs L6f73                                   // $6f67  
    lda #$00                                    // $6f69  
L6f6b:
    sta D6fe6,y                                 // $6f6b  
    iny                                         // $6f6e  
    cpy #$05                                    // $6f6f  
    bcc L6f6b                                   // $6f71  
L6f73:
    lda $f8                                     // $6f73  
    bpl L6f8d                                   // $6f75  
    eor #$ff                                    // $6f77  
    clc                                         // $6f79  
    adc #$01                                    // $6f7a  
    lsr                                         // $6f7c  
    beq L6f9c                                   // $6f7d  
    tay                                         // $6f7f  
L6f80:
    ldx #$04                                    // $6f80  
L6f82:
    lsr D6fe6,x                                 // $6f82  
    dex                                         // $6f85  
    bpl L6f82                                   // $6f86  
    dey                                         // $6f88  
    bne L6f80                                   // $6f89  
    beq L6f9c                                   // $6f8b  
L6f8d:
    lsr                                         // $6f8d  
    beq L6f9c                                   // $6f8e  
    tay                                         // $6f90  
L6f91:
    ldx #$04                                    // $6f91  
L6f93:
    asl D6fe6,x                                 // $6f93  
    dex                                         // $6f96  
    bpl L6f93                                   // $6f97  
    dey                                         // $6f99  
    bne L6f91                                   // $6f9a  
L6f9c:
    ldx #$00                                    // $6f9c  
    ldy #$00                                    // $6f9e  
    lda $f9                                     // $6fa0  
    beq L6fb8                                   // $6fa2  
    bmi L6fab                                   // $6fa4  
    lsr                                         // $6fa6  
    tay                                         // $6fa7  
    jmp L6fb8                                   // $6fa8  
L6fab:
    eor #$ff                                    // $6fab  
    clc                                         // $6fad  
    adc #$01                                    // $6fae  
    lsr                                         // $6fb0  
    sta $fa                                     // $6fb1  
    asl                                         // $6fb3  
    clc                                         // $6fb4  
    adc $fa                                     // $6fb5  
    tax                                         // $6fb7  
L6fb8:
    lda D6fe6,y                                 // $6fb8  
    sta D3759,x                                 // $6fbb  
    inx                                         // $6fbe  
    inx                                         // $6fbf  
    inx                                         // $6fc0  
    iny                                         // $6fc1  
    cpy #$05                                    // $6fc2  
    bcs L6fca                                   // $6fc4  
    cpx #$0f                                    // $6fc6  
    bcc L6fb8                                   // $6fc8  
L6fca:
    rts                                         // $6fca  
L6fcb:
    beq L6fd2                                   // $6fcb  
    eor #$ff                                    // $6fcd  
    sec                                         // $6fcf  
    sbc #$01                                    // $6fd0  
L6fd2:
    ldx #$fd                                    // $6fd2  
    sec                                         // $6fd4  
L6fd5:
    inx                                         // $6fd5  
    sbc #$33                                    // $6fd6  
    bcs L6fd5                                   // $6fd8  
    cpx #$03                                    // $6fda  
    bne L6fe0                                   // $6fdc  
    ldx #$02                                    // $6fde  
L6fe0:
    rts                                         // $6fe0  
D6fe1:
    .byte $1c,$3e,$3e,$3e,$1c                   // $6fe1  
D6fe6:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       // $6fe6  
D6fee:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       // $6fee  
L6ff6:
    ldx #$07                                    // $6ff6  
    lda #$00                                    // $6ff8  
L6ffa:
    sta D2318,x                                 // $6ffa  
    dex                                         // $6ffd  
    bpl L6ffa                                   // $6ffe  
    rts                                         // $7000  
L7001:
    lda #$01                                    // $7001  
    jsr L4664                                   // $7003  
    dec $cfae                                   // $7006  
    bpl L7063                                   // $7009  
    ldx $cfad                                   // $700b  
    dex                                         // $700e  
    bpl L7013                                   // $700f  
    ldx #$05                                    // $7011  
L7013:
    stx $cfad                                   // $7013  
    lda D706c,x                                 // $7016  
    sta $cfae                                   // $7019  
    lda D7072,x                                 // $701c  
    sta VIC_SPR3_COL                            // $701f  
    cpx #$00                                    // $7022  
    bne L702d                                   // $7024  
    lda $fa                                     // $7026  
    bne L702d                                   // $7028  
    sec                                         // $702a  
    bcs L706b                                   // $702b  
L702d:
    cpx #$03                                    // $702d  
    bne L7063                                   // $702f  
    lda #$08                                    // $7031  
    sta SID_V1_CTRL                             // $7033  
    sta SID_V2_CTRL                             // $7036  
    lda #$09                                    // $7039  
    sta SID_V1_FREQ_HI                          // $703b  
    sta SID_V2_FREQ_HI                          // $703e  
    lda #$00                                    // $7041  
    sta SID_V1_FREQ_LO                          // $7043  
    lda #$28                                    // $7046  
    sta SID_V2_FREQ_LO                          // $7048  
    lda #$69                                    // $704b  
    sta SID_V1_AD                               // $704d  
    sta SID_V2_AD                               // $7050  
    lda #$00                                    // $7053  
    sta SID_V1_SR                               // $7055  
    sta SID_V2_SR                               // $7058  
    lda #$11                                    // $705b  
    sta SID_V1_CTRL                             // $705d  
    sta SID_V2_CTRL                             // $7060  
L7063:
    lda $fa                                     // $7063  
    bne L706a                                   // $7065  
    jmp L7001                                   // $7067  
L706a:
    clc                                         // $706a  
L706b:
    rts                                         // $706b  
D706c:
    .byte $32,$02,$02,$02,$02,$02               // $706c  
D7072:
    .byte $01,$0f,$0c,$0b,$0c,$0f               // $7072  
L7078:
    sei                                         // $7078  
    lda #$36                                    // $7079  
    sta $01                                     // $707b  
    lda #$00                                    // $707d  
    sta VIC_BORDER                              // $707f  
    lda #$0b                                    // $7082  
    sta VIC_CTRL1                               // $7084  
    lda #$00                                    // $7087  
    ldx #$00                                    // $7089  
L708b:
    sta $cf00,x                                 // $708b  
    inx                                         // $708e  
    bne L708b                                   // $708f  
    lda #$ff                                    // $7091  
    sta CIA1_DDRA                               // $7093  
    lda #$01                                    // $7096  
    sta $cfb8                                   // $7098  
    lda #$08                                    // $709b  
    sta $cfb0                                   // $709d  
    lda #$07                                    // $70a0  
    sta $cf57                                   // $70a2  
    ldx #$77                                    // $70a5  
    lda #$20                                    // $70a7  
L70a9:
    sta D0400,x                                 // $70a9  
    dex                                         // $70ac  
    bpl L70a9                                   // $70ad  
    ldx #$27                                    // $70af  
    lda #$01                                    // $70b1  
L70b3:
    sta COLOR_RAM,x                             // $70b3  
    dex                                         // $70b6  
    bpl L70b3                                   // $70b7  
    ldx #$ca                                    // $70b9  
    ldy #$00                                    // $70bb  
L70bd:
    jsr L7283                                   // $70bd  
    cpx #$cf                                    // $70c0  
    bcc L70bd                                   // $70c2  
    ldy #$0c                                    // $70c4  
L70c6:
    jsr L7283                                   // $70c6  
    cpx #$d4                                    // $70c9  
    bcc L70c6                                   // $70cb  
    ldy #$18                                    // $70cd  
L70cf:
    jsr L7283                                   // $70cf  
    cpx #$d9                                    // $70d2  
    bcc L70cf                                   // $70d4  
    ldy #$20                                    // $70d6  
L70d8:
    jsr L7283                                   // $70d8  
    cpx #$db                                    // $70db  
    bcc L70d8                                   // $70dd  
    ldx #$4f                                    // $70df  
L70e1:
    ldy #$07                                    // $70e1  
L70e3:
    lda D4c3e,y                                 // $70e3  
    sta D2730,x                                 // $70e6  
    dex                                         // $70e9  
    dey                                         // $70ea  
    bpl L70e3                                   // $70eb  
    txa                                         // $70ed  
    bpl L70e1                                   // $70ee  
    ldx #$07                                    // $70f0  
    lda #$00                                    // $70f2  
L70f4:
    sta D2760,x                                 // $70f4  
    sta D2778,x                                 // $70f7  
    dex                                         // $70fa  
    bpl L70f4                                   // $70fb  
    ldy #$05                                    // $70fd  
    ldx #$eb                                    // $70ff  
L7101:
    txa                                         // $7101  
    sta D0405,y                                 // $7102  
    dex                                         // $7105  
    dey                                         // $7106  
    bpl L7101                                   // $7107  
    ldy #$05                                    // $7109  
    ldx #$f5                                    // $710b  
L710d:
    txa                                         // $710d  
    sta D0422,y                                 // $710e  
    dex                                         // $7111  
    dey                                         // $7112  
    bpl L710d                                   // $7113  
    lda #$ee                                    // $7115  
    sta D041d                                   // $7117  
    lda #$ef                                    // $711a  
    sta D041e                                   // $711c  
    jsr L73cb                                   // $711f  
    lda #$b4                                    // $7122  
    sta D040b                                   // $7124  
    sta D0417                                   // $7127  
    sta D041f                                   // $712a  
    jsr L751f                                   // $712d  
    lda #$00                                    // $7130  
    jsr L755d                                   // $7132  
    ldx #$2f                                    // $7135  
L7137:
    lda D7494,x                                 // $7137  
    sta D25f0,x                                 // $713a  
    dex                                         // $713d  
    bpl L7137                                   // $713e  
    ldx #$1f                                    // $7140  
L7142:
    lda D74db,x                                 // $7142  
    sta D2620,x                                 // $7145  
    dex                                         // $7148  
    bpl L7142                                   // $7149  
    lda $ceff                                   // $714b  
    beq L7196                                   // $714e  
    lda #$18                                    // $7150  
    sta $cfb0                                   // $7152  
    jsr L4524                                   // $7155  
    lda $cefe                                   // $7158  
    sta $cf2d                                   // $715b  
    jsr L4048                                   // $715e  
    jsr L413d                                   // $7161  
    jsr L40fc                                   // $7164  
    lda #$01                                    // $7167  
    sta $cf53                                   // $7169  
    sta $cf52                                   // $716c  
    lda #$80                                    // $716f  
    sta $028a                                   // $7171  
    ldx #$1c                                    // $7174  
L7176:
    lda $d6,x                                   // $7176  
    sta $02e0,x                                 // $7178  
    dex                                         // $717b  
    bpl L7176                                   // $717c  
    ldx #$18                                    // $717e  
L7180:
    lda $da,x                                   // $7180  
    and #$7f                                    // $7182  
    sta $da,x                                   // $7184  
    dex                                         // $7186  
    bmi L7192                                   // $7187  
    lda $da,x                                   // $7189  
    ora #$80                                    // $718b  
    sta $da,x                                   // $718d  
    dex                                         // $718f  
    bpl L7180                                   // $7190  
L7192:
    lda #$ff                                    // $7192  
    sta $d6                                     // $7194  
L7196:
    lda #$18                                    // $7196  
    sta VIC_MEMSETUP                            // $7198  
    lda #$d8                                    // $719b  
    sta VIC_CTRL2                               // $719d  
    lda #$c0                                    // $71a0  
    sta VIC_SPR_PRIORITY                        // $71a2  
    lda #$00                                    // $71a5  
    sta VIC_BG1                                 // $71a7  
    lda #$01                                    // $71aa  
    sta VIC_BG2                                 // $71ac  
    lda #$ff                                    // $71af  
    sta VIC_SPR_ENABLE                          // $71b1  
    lda #$00                                    // $71b4  
    sta VIC_SPR1_COL                            // $71b6  
    lda #$01                                    // $71b9  
    sta VIC_SPR3_COL                            // $71bb  
    lda #$00                                    // $71be  
    sta VIC_SPR4_COL                            // $71c0  
    lda #$0f                                    // $71c3  
    sta VIC_SPR6_COL                            // $71c5  
    lda #$00                                    // $71c8  
    sta VIC_SPR7_COL                            // $71ca  
    lda #$00                                    // $71cd  
    ldx #$3e                                    // $71cf  
L71d1:
    sta D31c0,x                                 // $71d1  
    sta D3780,x                                 // $71d4  
    sta D3740,x                                 // $71d7  
    dex                                         // $71da  
    bpl L71d1                                   // $71db  
    jsr L466d                                   // $71dd  
    lda #$44                                    // $71e0  
    sta SID_RES_FILT                            // $71e2  
    lda #$1f                                    // $71e5  
    sta SID_MODE_VOL                            // $71e7  
    ldx #$7f                                    // $71ea  
    lda #$00                                    // $71ec  
L71ee:
    sta D2008,x                                 // $71ee  
    dex                                         // $71f1  
    bpl L71ee                                   // $71f2  
    ldx #$07                                    // $71f4  
L71f6:
    lda #$bb                                    // $71f6  
    sta D2000,x                                 // $71f8  
    dex                                         // $71fb  
    lda #$ee                                    // $71fc  
    sta D2000,x                                 // $71fe  
    dex                                         // $7201  
    bpl L71f6                                   // $7202  
    ldx #$07                                    // $7204  
L7206:
    lda D2000,x                                 // $7206  
    sta D23e0,x                                 // $7209  
    sta D23f0,x                                 // $720c  
    sta D2400,x                                 // $720f  
    sta D2410,x                                 // $7212  
    lda #$00                                    // $7215  
    sta D2100,x                                 // $7217  
    sta D2588,x                                 // $721a  
    sta D2598,x                                 // $721d  
    lda #$55                                    // $7220  
    sta D2500,x                                 // $7222  
    dex                                         // $7225  
    bpl L7206                                   // $7226  
    lda #$ed                                    // $7228  
    sta CINV                                    // $722a  
    lda #$5f                                    // $722d  
    sta CINV_HI                                 // $722f  
    lda #$f1                                    // $7232  
    sta VIC_IRQ_ENABLE                          // $7234  
    lda #$00                                    // $7237  
    sta CIA1_CRA                                // $7239  
    sta VIC_RASTER                              // $723c  
    lda #$8f                                    // $723f  
    sta NMINV                                   // $7241  
    lda #$72                                    // $7244  
    sta NMINV_HI                                // $7246  
    ldx #$81                                    // $7249  
    ldy #$ea                                    // $724b  
    stx CBINV                                   // $724d  
    sty CBINV_HI                                // $7250  
    lda #$2a                                    // $7253  
    sta VIC_RASTER                              // $7255  
    lda #$01                                    // $7258  
    sta $cf0f                                   // $725a  
    lda VIC_IRQ_STATUS                          // $725d  
    sta VIC_IRQ_STATUS                          // $7260  
    cli                                         // $7263  
    lda $ceff                                   // $7264  
    beq L7282                                   // $7267  
    lda #$13                                    // $7269  
    jsr $f1ca                                   // $726b  
L726e:
    jsr CHRIN                                   // $726e  
    jmp L726e                                   // $7271  
    .byte $a9,$37,$85,$01,$20,$cc,$ff,$d8,$58,$a9,$58,$4c,$b3,$9b  // $7274  
L7282:
    rts                                         // $7282  
L7283:
    txa                                         // $7283  
    sta D0400,y                                 // $7284  
    lda #$07                                    // $7287  
    sta COLOR_RAM,y                             // $7289  
    inx                                         // $728c  
    iny                                         // $728d  
    rts                                         // $728e  
    .byte $ee,$b7,$cf,$40                       // $728f  
D7293:
    .byte $00,$3c,$00,$ff,$00,$ff,$00,$3c,$08,$0c,$0a,$09,$09,$78,$f8,$70  // $7293  
L72a3:
    ldx #$05                                    // $72a3  
L72a5:
    lda D72af,x                                 // $72a5  
    sta $d811,x                                 // $72a8  
    dex                                         // $72ab  
    bpl L72a5                                   // $72ac  
    rts                                         // $72ae  
D72af:
    .byte $00,$0e,$03,$0d,$07,$01               // $72af  
L72b5:
    ldx $cf09                                   // $72b5  
    lda D72f6,x                                 // $72b8  
    sta $f8                                     // $72bb  
    ldx $cf0a                                   // $72bd  
    lda D72f6,x                                 // $72c0  
    sta $f9                                     // $72c3  
    lda $cf6a                                   // $72c5  
    jsr L6dd2                                   // $72c8  
    lda $fa                                     // $72cb  
    beq L72d9                                   // $72cd  
L72cf:
    lda ($fb),y                                 // $72cf  
    sta D3780,y                                 // $72d1  
    iny                                         // $72d4  
    cpy $fa                                     // $72d5  
    bcc L72cf                                   // $72d7  
L72d9:
    lda ($fb),y                                 // $72d9  
    and D3880,x                                 // $72db  
    sta D3780,y                                 // $72de  
    inx                                         // $72e1  
    iny                                         // $72e2  
    cpy $ff                                     // $72e3  
    bcc L72d9                                   // $72e5  
    cpy #$3f                                    // $72e7  
    bcs L72f5                                   // $72e9  
L72eb:
    lda ($fb),y                                 // $72eb  
    sta D3780,y                                 // $72ed  
    iny                                         // $72f0  
    cpy #$3f                                    // $72f1  
    bcc L72eb                                   // $72f3  
L72f5:
    rts                                         // $72f5  
D72f6:
    .byte $07,$06,$05,$05,$04,$04,$03,$02,$01   // $72f6  
L72ff:
    ldx #$05                                    // $72ff  
    lda #$20                                    // $7301  
L7303:
    sta D0411,x                                 // $7303  
    dex                                         // $7306  
    bpl L7303                                   // $7307  
    lda $cfb2                                   // $7309  
    lsr                                         // $730c  
    lsr                                         // $730d  
    lsr                                         // $730e  
    tax                                         // $730f  
    tay                                         // $7310  
    beq L731c                                   // $7311  
    dex                                         // $7313  
    lda #$bc                                    // $7314  
L7316:
    sta D0411,x                                 // $7316  
    dex                                         // $7319  
    bpl L7316                                   // $731a  
L731c:
    lda $cfb2                                   // $731c  
    and #$07                                    // $731f  
    beq L7329                                   // $7321  
    clc                                         // $7323  
    adc #$b4                                    // $7324  
    sta D0411,y                                 // $7326  
L7329:
    rts                                         // $7329  
L732a:
    tax                                         // $732a  
    bmi L7342                                   // $732b  
    clc                                         // $732d  
    adc $cfb1                                   // $732e  
    tax                                         // $7331  
    lda $cfb2                                   // $7332  
    adc #$00                                    // $7335  
    cmp #$30                                    // $7337  
    bcc L7352                                   // $7339  
    ldx #$00                                    // $733b  
    lda #$30                                    // $733d  
    jmp L7352                                   // $733f  
L7342:
    clc                                         // $7342  
    adc $cfb1                                   // $7343  
    tax                                         // $7346  
    lda $cfb2                                   // $7347  
    sbc #$00                                    // $734a  
    bpl L7352                                   // $734c  
    ldx #$00                                    // $734e  
    lda #$00                                    // $7350  
L7352:
    stx $cfb1                                   // $7352  
    sta $cfb2                                   // $7355  
    jsr L72ff                                   // $7358  
    rts                                         // $735b  
L735c:
    lda $cfb3                                   // $735c  
    beq L737e                                   // $735f  
    lda $cfb2                                   // $7361  
    cmp #$30                                    // $7364  
    bcs L736e                                   // $7366  
    inc $cfb2                                   // $7368  
    jmp L737b                                   // $736b  
L736e:
    lda #$00                                    // $736e  
    sta $cfb3                                   // $7370  
    sta $cfb1                                   // $7373  
    lda #$30                                    // $7376  
    sta $cfb2                                   // $7378  
L737b:
    jsr L72ff                                   // $737b  
L737e:
    rts                                         // $737e  
L737f:
    lda $cfb5                                   // $737f  
    beq L73ca                                   // $7382  
    lda $cf53                                   // $7384  
    beq L73ca                                   // $7387  
    lda $cf15                                   // $7389  
    beq L73ca                                   // $738c  
    lda #$f2                                    // $738e  
    jsr L732a                                   // $7390  
    lda $cfbf                                   // $7393  
    beq L73ca                                   // $7396  
    lda $cfb2                                   // $7398  
    bne L73ca                                   // $739b  
    jsr L7482                                   // $739d  
    lda #$01                                    // $73a0  
    sta $cfb6                                   // $73a2  
    sta $cfb9                                   // $73a5  
    lda #$28                                    // $73a8  
    sta $cfba                                   // $73aa  
    lda #$00                                    // $73ad  
    sta $cfb5                                   // $73af  
    lda #$00                                    // $73b2  
    sta SID_V1_CTRL                             // $73b4  
    sta SID_V1_FREQ_LO                          // $73b7  
    sta SID_V1_FREQ_HI                          // $73ba  
    sta SID_V1_AD                               // $73bd  
    lda #$30                                    // $73c0  
    sta SID_V1_SR                               // $73c2  
    lda #$21                                    // $73c5  
    sta SID_V1_CTRL                             // $73c7  
L73ca:
    rts                                         // $73ca  
L73cb:
    ldx #$3f                                    // $73cb  
    lda #$00                                    // $73cd  
L73cf:
    sta D25a8,x                                 // $73cf  
    dex                                         // $73d2  
    bpl L73cf                                   // $73d3  
    lda #$02                                    // $73d5  
    sta $fa                                     // $73d7  
    lda #$80                                    // $73d9  
    sta $ff                                     // $73db  
L73dd:
    ldx $fa                                     // $73dd  
    ldy #$05                                    // $73df  
    lda $ff                                     // $73e1  
L73e3:
    sta D25a8,x                                 // $73e3  
    inx                                         // $73e6  
    dey                                         // $73e7  
    bne L73e3                                   // $73e8  
    lda $fa                                     // $73ea  
    clc                                         // $73ec  
    adc #$08                                    // $73ed  
    sta $fa                                     // $73ef  
    sec                                         // $73f1  
    ror $ff                                     // $73f2  
    bcc L73dd                                   // $73f4  
    rts                                         // $73f6  
L73f7:
    lda #$00                                    // $73f7  
    ldx $cf4d                                   // $73f9  
    beq L7400                                   // $73fc  
    lda #$01                                    // $73fe  
L7400:
    sta $fa                                     // $7400  
    ldy #$00                                    // $7402  
    ldx $cf55                                   // $7404  
    beq L7429                                   // $7407  
L7409:
    dex                                         // $7409  
    lda D7800,x                                 // $740a  
    sta $fd                                     // $740d  
    lda D7900,x                                 // $740f  
    sta $fe                                     // $7412  
    lda ($fd),y                                 // $7414  
    cmp #$63                                    // $7416  
    bne L7425                                   // $7418  
    lda $fe                                     // $741a  
    clc                                         // $741c  
    adc #$d4                                    // $741d  
    sta $fe                                     // $741f  
    lda $fa                                     // $7421  
    sta ($fd),y                                 // $7423  
L7425:
    cpx #$00                                    // $7425  
    bne L7409                                   // $7427  
L7429:
    rts                                         // $7429  
L742a:
    ldx #$07                                    // $742a  
L742c:
    lda D7436,x                                 // $742c  
    sta D2318,x                                 // $742f  
    dex                                         // $7432  
    bpl L742c                                   // $7433  
    rts                                         // $7435  
D7436:
    .byte $00,$78,$3c,$1e,$7f,$3c,$1e,$0f       // $7436  
L743e:
    ldx $cfb6                                   // $743e  
    beq L7475                                   // $7441  
    dex                                         // $7443  
    bne L7464                                   // $7444  
    ldy $cfb9                                   // $7446  
    dey                                         // $7449  
    bpl L7453                                   // $744a  
    ldy #$05                                    // $744c  
    lda #$19                                    // $744e  
    sta $cfba                                   // $7450  
L7453:
    sty $cfb9                                   // $7453  
    ldx #$05                                    // $7456  
    lda D7476,y                                 // $7458  
L745b:
    sta $d811,x                                 // $745b  
    dex                                         // $745e  
    bpl L745b                                   // $745f  
    ldx D747c,y                                 // $7461  
L7464:
    stx $cfb6                                   // $7464  
    lda $cfb9                                   // $7467  
    beq L746f                                   // $746a  
    inc $cfba                                   // $746c  
L746f:
    lda $cfba                                   // $746f  
    sta SID_V1_FREQ_HI                          // $7472  
L7475:
    rts                                         // $7475  
D7476:
    .byte $01,$0f,$0c,$0b,$0c,$0f               // $7476  
D747c:
    .byte $10,$03,$03,$03,$03,$03               // $747c  
L7482:
    ldx #$05                                    // $7482  
    ldy #$c3                                    // $7484  
L7486:
    tya                                         // $7486  
    sta D0411,x                                 // $7487  
    lda #$01                                    // $748a  
    sta $d811,x                                 // $748c  
    dey                                         // $748f  
    dex                                         // $7490  
    bpl L7486                                   // $7491  
    rts                                         // $7493  
D7494:
    .byte $00,$ff,$83,$99,$83,$99,$83,$ff,$00,$ff,$c3,$99,$81,$99,$99,$ff  // $7494  
    .byte $00,$ff,$c3,$99,$9f,$99,$c3,$ff,$00,$ff,$99,$93,$87,$93,$99,$ff  // $74a4  
    .byte $00,$ff,$99,$99,$99,$99,$c3,$ff,$00,$ff,$83,$99,$83,$9f,$9f,$ff  // $74b4  
L74c4:
    ldx #$05                                    // $74c4  
L74c6:
    lda D74d5,x                                 // $74c6  
    sta D0411,x                                 // $74c9  
    lda #$01                                    // $74cc  
    sta $d811,x                                 // $74ce  
    dex                                         // $74d1  
    bpl L74c6                                   // $74d2  
    rts                                         // $74d4  
D74d5:
    .byte $c6,$c4,$c5,$c5,$c7,$20               // $74d5  
D74db:
    .byte $00,$ff,$c3,$99,$99,$99,$c3,$ff,$00,$ff,$81,$9f,$87,$9f,$9f,$ff  // $74db  
    .byte $00,$01,$03,$03,$03,$03,$03,$01,$00,$80,$c0,$c0,$c0,$c0,$c0,$80  // $74eb  
L74fb:
    ldx $cfb4                                   // $74fb  
    bne L751e                                   // $74fe  
    ldx $cf4d                                   // $7500  
    beq L7506                                   // $7503  
    asl                                         // $7505  
L7506:
    clc                                         // $7506  
    adc #$01                                    // $7507  
    clc                                         // $7509  
    adc $cfb2                                   // $750a  
    cmp #$30                                    // $750d  
    bcc L7518                                   // $750f  
    ldx #$00                                    // $7511  
    stx $cfb1                                   // $7513  
    lda #$30                                    // $7516  
L7518:
    sta $cfb2                                   // $7518  
    jsr L72ff                                   // $751b  
L751e:
    rts                                         // $751e  
L751f:
    ldy #$07                                    // $751f  
    lda $cefa                                   // $7521  
    beq L7528                                   // $7524  
    ldy #$0f                                    // $7526  
L7528:
    ldx #$07                                    // $7528  
L752a:
    lda D7293,y                                 // $752a  
    sta D25a0,x                                 // $752d  
    dey                                         // $7530  
    dex                                         // $7531  
    bpl L752a                                   // $7532  
    rts                                         // $7534  
L7535:
    ldx #$07                                    // $7535  
L7537:
    lda D7541,x                                 // $7537  
    sta D25a0,x                                 // $753a  
    dex                                         // $753d  
    bpl L7537                                   // $753e  
    rts                                         // $7540  
D7541:
    .byte $02,$0e,$02,$92,$62,$92,$02,$0f       // $7541  
L7549:
    ldx #$07                                    // $7549  
L754b:
    lda D7555,x                                 // $754b  
    sta D25a0,x                                 // $754e  
    dex                                         // $7551  
    bpl L754b                                   // $7552  
    rts                                         // $7554  
D7555:
    .byte $1e,$01,$91,$61,$92,$04,$08,$1f       // $7555  
L755d:
    sta $d80b                                   // $755d  
    sta $d817                                   // $7560  
    sta $d81f                                   // $7563  
    rts                                         // $7566  
L7567:
    ldx $cfbd                                   // $7567  
    beq L7593                                   // $756a  
    dec $cfbd                                   // $756c  
    cpx #$02                                    // $756f  
    bne L7582                                   // $7571  
    lda #$46                                    // $7573  
    sta SID_V2_FREQ_HI                          // $7575  
    lda #$00                                    // $7578  
    sta SID_V2_FREQ_LO                          // $757a  
    lda #$21                                    // $757d  
    sta SID_V2_CTRL                             // $757f  
L7582:
    cpx #$01                                    // $7582  
    bne L7593                                   // $7584  
    lda #$11                                    // $7586  
    sta SID_V2_CTRL                             // $7588  
    lda #$00                                    // $758b  
    sta SID_V2_FREQ_LO                          // $758d  
    sta SID_V2_FREQ_HI                          // $7590  
L7593:
    rts                                         // $7593  
D7594:
    .byte $00,$00,$3e,$60,$3c,$06,$7c,$00,$00,$00,$3c,$60,$60,$60,$3c,$00  // $7594  
    .byte $00,$00,$78,$cc,$cc,$cc,$78,$00,$00,$00,$f8,$cc,$f8,$d8,$cc,$00  // $75a4  
    .byte $00,$00,$fc,$c0,$f0,$c0,$fc,$00,$00,$00,$7c,$66,$7c,$60,$60,$00  // $75b4  
    .byte $00,$00,$3c,$66,$66,$66,$3c,$00,$00,$00,$63,$63,$6b,$7f,$36,$00  // $75c4  
    .byte $00,$00,$3f,$30,$3c,$30,$3f,$00,$00,$00,$3e,$33,$3e,$36,$33,$00  // $75d4  
    .byte $00,$00,$60,$60,$60,$60,$7e,$00,$00,$00,$7e,$60,$78,$60,$7e,$00  // $75e4  
    .byte $00,$00,$66,$66,$66,$3c,$18,$00,$00,$00,$7e,$60,$78,$60,$7e,$00  // $75f4  
    .byte $00,$00,$60,$60,$60,$60,$7e,$00,$00,$00,$66,$66,$7e,$66,$66,$00  // $7604  
    .byte $00,$00,$3c,$18,$18,$18,$3c,$00       // $7614  
L761c:
    lda #$a2                                    // $761c  
    sta VIC_SPR0_Y                              // $761e  
    clc                                         // $7621  
    adc #$15                                    // $7622  
    sta VIC_SPR1_Y                              // $7624  
    sta VIC_SPR2_Y                              // $7627  
    sta VIC_SPR3_Y                              // $762a  
    clc                                         // $762d  
    adc #$15                                    // $762e  
    sta VIC_SPR4_Y                              // $7630  
    sta VIC_SPR5_Y                              // $7633  
    sta VIC_SPR6_Y                              // $7636  
    lda #$07                                    // $7639  
    sta VIC_SPR1_X                              // $763b  
    sta VIC_SPR4_X                              // $763e  
    clc                                         // $7641  
    adc #$18                                    // $7642  
    sta VIC_SPR0_X                              // $7644  
    sta VIC_SPR2_X                              // $7647  
    sta VIC_SPR5_X                              // $764a  
    clc                                         // $764d  
    adc #$18                                    // $764e  
    sta VIC_SPR3_X                              // $7650  
    sta VIC_SPR6_X                              // $7653  
    lda #$ff                                    // $7656  
    sta VIC_SPR_X_MSB                           // $7658  
    lda #$7f                                    // $765b  
    sta VIC_SPR_ENABLE                          // $765d  
    sta VIC_SPR_MULTICOLOR                      // $7660  
    lda #$00                                    // $7663  
    sta VIC_SPR_EXPAND_Y                        // $7665  
    sta VIC_SPR_EXPAND_X                        // $7668  
    sta VIC_SPR_PRIORITY                        // $766b  
    lda #$07                                    // $766e  
    sta VIC_SPR_MC0                             // $7670  
    lda #$0e                                    // $7673  
    sta VIC_SPR_MC1                             // $7675  
    ldy #$a0                                    // $7678  
    ldx #$00                                    // $767a  
L767c:
    lda #$06                                    // $767c  
    sta VIC_SPR0_COL,x                          // $767e  
    tya                                         // $7681  
    iny                                         // $7682  
    sta D07f8,x                                 // $7683  
    inx                                         // $7686  
    cpx #$08                                    // $7687  
    bcc L767c                                   // $7689  
    rts                                         // $768b  
L768c:
    ldx #$00                                    // $768c  
L768e:
    lda D2800,x                                 // $768e  
    tay                                         // $7691  
    lda D8d00,x                                 // $7692  
    sta D2800,x                                 // $7695  
    tya                                         // $7698  
    sta D8d00,x                                 // $7699  
    lda D2900,x                                 // $769c  
    tay                                         // $769f  
    lda D8e00,x                                 // $76a0  
    sta D2900,x                                 // $76a3  
    tya                                         // $76a6  
    sta D8e00,x                                 // $76a7  
    inx                                         // $76aa  
    bne L768e                                   // $76ab  
    rts                                         // $76ad  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$f4,$ff,$ff,$ff  // $76ae  
    .byte $df,$00,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$09,$00  // $76be  
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $76ce  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $76de  
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $76ee  
    .byte $00,$00,$83,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $76fe  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$cf,$ff,$ff,$ff,$ff  // $770e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $771e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$f4,$ff,$ff,$ff  // $772e  
    .byte $df,$00,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$09,$00  // $773e  
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $774e  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $775e  
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $776e  
    .byte $00,$00,$8b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $777e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$cf,$ff,$ff,$ff,$ff  // $778e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $779e  
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$7c,$ff,$ff,$ff  // $77ae  
    .byte $df,$40,$00,$00,$00,$00,$cf,$00,$00,$00,$00,$00,$cf,$00,$01,$00  // $77be  
    .byte $cf,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $77ce  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $77de  
    .byte $00,$cf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cc,$00,$00,$00  // $77ee  
    .byte $00,$00                               // $77fe  
D7800:
    .byte $ca,$cb,$cc,$cd,$ce,$e6,$e7,$e8,$e9,$ea,$eb,$34,$cf,$d0,$d1,$d2  // $7800  
    .byte $d3,$20,$20,$20,$20,$20,$20,$b4,$d4,$d5,$d6,$d7,$d8,$ee,$ef,$b4  // $7810  
    .byte $d9,$da,$f0,$f1,$f2,$f3,$f4,$f5,$20,$20,$20,$20,$20,$20,$20,$20  // $7820  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $7830  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $7840  
D7850:
    .byte $b0,$a1,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2  // $7850  
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2  // $7860  
    .byte $a2,$a2,$a2,$a2,$a2,$a3,$a4,$a0,$af,$78,$a0,$a0,$a0,$a0,$a0,$a0  // $7870  
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0  // $7880  
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$79,$a5,$a0  // $7890  
    .byte $ae,$a0,$6c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c,$8c  // $78a0  
    .byte $8c,$8c,$8c,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8e,$8d  // $78b0  
    .byte $8d,$8d,$8e,$8e,$6c,$a0,$a6,$a0,$ae,$a0,$97,$11,$0a,$0a,$0a,$0a  // $78c0  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a  // $78d0  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$12,$00,$00,$8b,$21,$12,$8f,$a0,$a6,$a0  // $78e0  
    .byte $ae,$a0,$97,$1e,$b1,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $78f0  
D7900:
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$b1,$1b,$00  // $7900  
    .byte $29,$2a,$20,$1b,$8f,$a0,$a6,$a0,$ae,$a0,$96,$89,$24,$20,$b1,$4a  // $7910  
    .byte $01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02  // $7920  
    .byte $02,$03,$45,$b1,$20,$28,$86,$29,$2a,$20,$28,$86,$90,$a0,$a6,$a0  // $7930  
    .byte $ae,$74,$96,$00,$23,$24,$20,$4c,$25,$00,$00,$00,$00,$00,$7c,$00  // $7940  
    .byte $00,$00,$00,$7c,$00,$00,$00,$00,$00,$29,$46,$20,$28,$27,$29,$2a  // $7950  
    .byte $20,$28,$27,$00,$90,$77,$a6,$a0,$ae,$74,$96,$00,$00,$23,$24,$20  // $7960  
    .byte $26,$25,$00,$00,$00,$29,$7d,$25,$00,$00,$29,$7d,$25,$00,$00,$00  // $7970  
    .byte $29,$2a,$20,$28,$27,$29,$2a,$20,$28,$27,$00,$00,$90,$77,$a6,$a0  // $7980  
    .byte $ae,$74,$96,$00,$00,$00,$23,$24,$20,$26,$25,$00,$82,$83,$20,$81  // $7990  
    .byte $80,$82,$83,$20,$81,$80,$00,$29,$2a,$20,$28,$27,$29,$2a,$20,$50  // $79a0  
    .byte $27,$00,$00,$00,$90,$77,$a6,$a0,$ae,$74,$97,$11,$12,$00,$00,$23  // $79b0  
    .byte $24,$20,$26,$25,$00,$23,$7f,$27,$5b,$5c,$23,$7f,$27,$00,$29,$2a  // $79c0  
    .byte $20,$28,$27,$8a,$2a,$20,$b1,$51,$0b,$0a,$0a,$12,$8f,$77,$a6,$a0  // $79d0  
    .byte $ae,$73,$97,$14,$13,$00,$00,$00,$23,$24,$20,$26,$25,$00,$7e,$61  // $79e0  
    .byte $2a,$26,$5d,$7e,$00,$29,$2a,$20,$28,$27,$00,$1f,$b1,$20,$20,$20  // $79f0  
    .byte $20,$20,$20,$0e,$8f,$76,$a6,$a0,$ae,$73,$96,$00,$00,$00,$00,$00  // $7a00  
    .byte $00,$23,$24,$20,$26,$25,$00,$62,$24,$28,$5e,$00,$29,$2a,$20,$28  // $7a10  
    .byte $27,$00,$00,$14,$02,$02,$02,$02,$03,$04,$20,$0e,$91,$76,$a6,$a0  // $7a20  
    .byte $ae,$73,$95,$11,$12,$00,$11,$12,$00,$00,$23,$24,$20,$26,$25,$00  // $7a30  
    .byte $5f,$60,$00,$29,$2a,$20,$50,$27,$00,$00,$00,$00,$00,$00,$00,$00  // $7a40  
    .byte $00,$05,$20,$0e,$91,$76,$a6,$a0,$ae,$73,$95,$14,$13,$00,$14,$13  // $7a50  
    .byte $00,$00,$00,$23,$24,$20,$26,$25,$00,$00,$29,$2a,$20,$b1,$51,$0b  // $7a60  
    .byte $0a,$0a,$0a,$0a,$0a,$12,$00,$00,$00,$06,$20,$0e,$91,$76,$a6,$a0  // $7a70  
    .byte $ae,$72,$96,$00,$00,$00,$00,$00,$00,$00,$00,$00,$23,$24,$20,$26  // $7a80  
    .byte $25,$82,$83,$b1,$20,$20,$20,$20,$20,$20,$b3,$b3,$b3,$0e,$00,$00  // $7a90  
    .byte $00,$06,$20,$0e,$91,$75,$a6,$a0,$ae,$72,$95,$11,$12,$00,$11,$12  // $7aa0  
    .byte $00,$11,$12,$00,$00,$23,$24,$20,$26,$25,$88,$1d,$02,$02,$02,$02  // $7ab0  
    .byte $02,$02,$02,$02,$02,$13,$00,$00,$00,$06,$20,$0e,$91,$75,$a6,$a0  // $7ac0  
    .byte $ae,$72,$95,$14,$13,$00,$14,$13,$00,$14,$13,$00,$00,$00,$23,$24  // $7ad0  
    .byte $20,$26,$25,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7ae0  
    .byte $00,$07,$20,$0e,$91,$75,$a6,$a0,$ae,$72,$96,$00,$00,$00,$00,$00  // $7af0  
    .byte $00,$00,$00,$00,$00,$00,$00,$23,$24,$20,$33,$34,$0a,$0a,$0a,$0a  // $7b00  
    .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$09,$08,$20,$0e,$91,$75,$a6,$a0  // $7b10  
    .byte $ae,$00,$95,$11,$12,$00,$11,$12,$00,$11,$12,$00,$11,$12,$00,$00  // $7b20  
    .byte $23,$24,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $7b30  
    .byte $20,$20,$20,$0e,$91,$00,$a6,$a0,$ae,$00,$95,$14,$13,$00,$14,$13  // $7b40  
    .byte $00,$14,$13,$00,$14,$13,$00,$00,$00,$88,$1d,$02,$02,$02,$02,$02  // $7b50  
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$13,$91,$00,$a6,$a0  // $7b60  
    .byte $ae,$00,$00,$94,$94,$93,$94,$94,$93,$94,$94,$93,$94,$94,$93,$93  // $7b70  
    .byte $93,$93,$94,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92  // $7b80  
    .byte $92,$92,$92,$92,$00,$00,$a6,$a0,$ad,$7b,$00,$00,$00,$00,$00,$00  // $7b90  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7ba0  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7a,$a7,$a0  // $7bb0  
D7bc0:
    .byte $ac,$ab,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $7bc0  
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $7bd0  
    .byte $aa,$aa,$aa,$aa,$aa,$a9,$a8,$a0       // $7be0  
D7be8:
    .byte $00,$00,$ff,$ff,$eb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7be8  
    .byte $c7,$a0,$dc,$a7,$a7,$db,$de,$b8       // $7bf8  
D7c00:
    .byte $ca,$cb,$cc,$4d,$ce,$e6,$e7,$e8,$e9,$ea,$eb,$b4,$cf,$d0,$d1,$d2  // $7c00  
    .byte $d3,$20,$20,$20,$20,$20,$20,$b4,$d4,$d5,$d6,$d7,$d8,$ee,$ef,$b4  // $7c10  
    .byte $d9,$da,$f0,$f1,$f2,$f3,$f4           // $7c20  
D7c27:
    .byte $f5,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $7c27  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  // $7c37  
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20   // $7c47  
D7c50:
    .byte $b0                                   // $7c50  
D7c51:
    .byte $a1,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2  // $7c51  
    .byte $a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2,$a2  // $7c61  
    .byte $a2,$a2,$a2,$a2                       // $7c71  
D7c75:
    .byte $a3                                   // $7c75  
D7c76:
    .byte $a4,$a0                               // $7c76  
D7c78:
    .byte $af                                   // $7c78  
D7c79:
    .byte $78,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0  // $7c79  
    .byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0  // $7c89  
    .byte $a0,$a0,$a0,$a0                       // $7c99  
D7c9d:
    .byte $79                                   // $7c9d  
D7c9e:
    .byte $a5,$a0,$ae,$a0,$6c,$8c,$8c,$8c,$8d,$8c,$8c,$8c,$8c,$8c,$8c,$8c  // $7c9e  
    .byte $8c,$8c,$8c,$8c,$8c,$8e,$8d,$8e,$8e,$8d,$8e,$8e,$8e,$8e,$8e,$8e  // $7cae  
    .byte $8e,$8e,$8e,$8e,$8e,$8e,$6c,$a0,$a6,$a0,$ae,$a0,$97,$11,$0a,$12  // $7cbe  
    .byte $00,$11,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$12,$00,$11  // $7cce  
    .byte $12,$00,$11,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$12,$8f,$a0  // $7cde  
    .byte $a6,$a0,$ae,$a0,$97,$06,$20,$0e,$00,$1e,$b1,$20,$20,$20,$20,$20  // $7cee  
    .byte $20,$20,$20,$20,$20,$0e,$00,$14,$13,$00,$06,$20,$20,$20,$20,$20  // $7cfe  
    .byte $20,$20,$20,$20,$20,$0e,$8f,$a0,$a6,$a0,$ae,$a0,$97,$06,$20,$0e  // $7d0e  
    .byte $00,$89,$24,$20,$b1,$4a,$01,$02,$02,$02,$03,$04,$20,$0d,$00,$00  // $7d1e  
    .byte $00,$00,$07,$20,$10,$01,$02,$02,$02,$02,$03,$04,$20,$0e,$8f,$a0  // $7d2e  
    .byte $a6,$a0,$ae,$74,$97,$06,$20,$0e,$00,$00,$23,$24,$20,$4c,$25,$00  // $7d3e  
    .byte $00,$00,$00,$05,$20,$0c,$0b,$0a,$0a,$09,$08,$20,$0f,$00,$00,$00  // $7d4e  
    .byte $00,$00,$00,$05,$20,$0e,$8f,$77,$a6,$a0,$ae,$74,$97,$06,$20,$0e  // $7d5e  
    .byte $00,$00,$00,$23,$24,$20,$26,$25,$00,$00,$00,$06,$20,$20,$20,$20  // $7d6e  
    .byte $20,$20,$20,$20,$0e,$00,$00,$11,$12,$00,$00,$06,$20,$0e,$8f,$77  // $7d7e  
    .byte $a6,$a0,$ae,$74,$97,$06,$20,$35,$00,$00,$00,$00,$23,$24,$20,$26  // $7d8e  
    .byte $85,$00,$00,$14,$02,$02,$02,$02,$02,$02,$02,$02,$13,$00,$00,$14  // $7d9e  
    .byte $13,$00,$00,$06,$20,$0e,$8f,$77,$a6,$a0,$ae,$74,$97,$1e,$20,$36  // $7dae  
    .byte $25,$00,$00,$00,$00,$23,$2d,$20,$1a,$00,$00,$00,$00,$00,$00,$00  // $7dbe  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$20,$0e,$8f,$77  // $7dce  
    .byte $a6,$a0,$ae,$73,$96,$89,$24,$20,$26,$25,$00,$00,$00,$00,$2e,$20  // $7dde  
    .byte $0e,$00,$00,$11,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$12,$00,$00,$11  // $7dee  
    .byte $12,$00,$00,$06,$20,$0e,$8f,$76,$a6,$a0,$ae,$73,$96,$00,$23,$24  // $7dfe  
    .byte $20,$26,$25,$00,$00,$00,$06,$20,$0e,$00,$00,$06,$20,$20,$20,$20  // $7e0e  
    .byte $20,$b3,$b3,$b3,$0e,$00,$00,$14,$13,$00,$00,$2f,$20,$0e,$91,$76  // $7e1e  
    .byte $a6,$a0,$ae,$73,$96,$00,$00,$23,$24,$20,$26,$25,$00,$00,$06,$20  // $7e2e  
    .byte $0e,$00,$00,$06,$20,$10,$01,$02,$02,$02,$02,$02,$13,$00,$00,$00  // $7e3e  
    .byte $00,$00,$29,$30,$20,$1b,$91,$76,$a6,$a0,$ae,$73,$96,$00,$00,$00  // $7e4e  
    .byte $23,$24,$20,$26,$25,$00,$06,$20,$0e,$00,$00,$06,$20,$0f,$00,$00  // $7e5e  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$29,$2a,$20,$28,$86,$90,$76  // $7e6e  
    .byte $a6,$a0,$ae,$72,$96,$00,$00,$00,$00,$23,$24,$20,$26,$25,$07,$20  // $7e7e  
    .byte $0e,$00,$00,$06,$20,$0e,$00,$00,$11,$12,$00,$11,$12,$00,$00,$00  // $7e8e  
    .byte $29,$2a,$20,$28,$27,$00,$90,$75,$a6,$a0,$ae,$72,$95,$11,$19,$84  // $7e9e  
    .byte $00,$00,$23,$24,$20,$3c,$3d,$20,$0e,$00,$00,$06,$20,$0e,$00,$00  // $7eae  
    .byte $14,$13,$00,$14,$13,$00,$00,$29,$2a,$20,$28,$27,$00,$00,$90,$75  // $7ebe  
    .byte $a6,$a0,$ae,$72,$95,$06,$20,$26,$25,$00,$00,$23,$24,$20,$b1,$20  // $7ece  
    .byte $0e,$00,$00,$06,$20,$0d,$00,$00,$00,$00,$00,$00,$00,$00,$29,$2a  // $7ede  
    .byte $20,$28,$27,$8b,$21,$12,$91,$75,$a6,$a0,$ae,$72,$95,$06,$20,$20  // $7eee  
    .byte $26,$85,$00,$00,$23,$24,$20,$20,$0e,$00,$00,$06,$20,$0c,$0b,$0a  // $7efe  
    .byte $0a,$0a,$0a,$0a,$0a,$31,$32,$20,$28,$27,$8a,$2a,$20,$0e,$91,$75  // $7f0e  
    .byte $a6,$a0,$ae,$00,$95,$06,$20,$20,$20,$1a,$00,$00,$00,$23,$24,$b1  // $7f1e  
    .byte $0e,$00,$00,$06,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$28  // $7f2e  
    .byte $27,$00,$1f,$20,$20,$0e,$91,$00,$a6,$a0,$ae,$00,$95,$14,$02,$02  // $7f3e  
    .byte $02,$13,$00,$00,$00,$00,$88,$1d,$13,$00,$00,$14,$02,$02,$02,$02  // $7f4e  
    .byte $02,$02,$02,$02,$02,$02,$1c,$87,$00,$00,$14,$02,$02,$13,$91,$00  // $7f5e  
    .byte $a6,$a0,$ae,$00,$00,$94,$94,$94,$94,$94,$93,$93,$93,$93,$93,$94  // $7f6e  
    .byte $94,$93,$93,$94,$94,$92,$92,$92,$92,$92,$92,$92,$92,$92,$92,$93  // $7f7e  
    .byte $93,$93,$92,$92,$92,$92,$00,$00,$a6,$a0  // $7f8e  
D7f98:
    .byte $ad                                   // $7f98  
D7f99:
    .byte $7b,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7f99  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7fa9  
    .byte $00,$00,$00,$00                       // $7fb9  
D7fbd:
    .byte $7a                                   // $7fbd  
D7fbe:
    .byte $a7,$a0                               // $7fbe  
D7fc0:
    .byte $ac                                   // $7fc0  
D7fc1:
    .byte $ab,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $7fc1  
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $7fd1  
    .byte $aa,$aa,$aa,$aa                       // $7fe1  
D7fe5:
    .byte $a9                                   // $7fe5  
D7fe6:
    .byte $a8,$a0,$00,$00,$ff,$ff,$eb,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $7fe6  
    .byte $00,$00,$c7,$dd,$dc,$a7,$a7,$d2,$de,$b8  // $7ff6  
D8000:
    .byte $00                                   // $8000  
L8001:
    lda D8000                                   // $8001  
    bne L800f                                   // $8004  
    sta D866d                                   // $8006  
    jsr L8478                                   // $8009  
L800c:
    jmp L8472                                   // $800c  
L800f:
    cmp #$06                                    // $800f  
    bcs L8050                                   // $8011  
    sbc #$00                                    // $8013  
    asl                                         // $8015  
    sta L801a+1                                 // $8016  
    asl                                         // $8019  
L801a:
    adc #$00                                    // $801a  
    tay                                         // $801c  
    ldx #$00                                    // $801d  
L801f:
    lda D8735,y                                 // $801f  
    sta D86bc,x                                 // $8022  
    iny                                         // $8025  
    lda D8735,y                                 // $8026  
    sta D86bf,x                                 // $8029  
    iny                                         // $802c  
    inx                                         // $802d  
    cpx #$03                                    // $802e  
    bne L801f                                   // $8030  
    ldx #$02                                    // $8032  
L8034:
    lda #$00                                    // $8034  
    sta D8688,x                                 // $8036  
    sta D868b,x                                 // $8039  
    sta D8670,x                                 // $803c  
    jsr L84c3                                   // $803f  
    dex                                         // $8042  
    bpl L8034                                   // $8043  
    jsr L8647                                   // $8045  
    lda #$01                                    // $8048  
    sta D866d                                   // $804a  
    jmp L8472                                   // $804d  
L8050:
    lda D866d                                   // $8050  
    beq L800c                                   // $8053  
    inc D86c9                                   // $8055  
    inc D86ca                                   // $8058  
    inc D86cb                                   // $805b  
    ldx #$02                                    // $805e  
    stx D866c                                   // $8060  
L8063:
    ldx D866c                                   // $8063  
    lda D8658,x                                 // $8066  
    sta D86cc                                   // $8069  
    lda D866f                                   // $806c  
    bne L8084                                   // $806f  
    dec D8688,x                                 // $8071  
    bmi L8098                                   // $8074  
    lda D869d,x                                 // $8076  
    beq L8095                                   // $8079  
    inc D8669,x                                 // $807b  
    jsr L8483                                   // $807e  
    jmp L83ec                                   // $8081  
L8084:
    lda D86a0,x                                 // $8084  
    beq L8095                                   // $8087  
    dec D86a0,x                                 // $8089  
    dec D8669,x                                 // $808c  
    jsr L8483                                   // $808f  
    jmp L83ec                                   // $8092  
L8095:
    jmp L81dd                                   // $8095  
L8098:
    lda #$00                                    // $8098  
    ldy D868b,x                                 // $809a  
    cpy #$02                                    // $809d  
    beq L80a7                                   // $809f  
    sta D868e,x                                 // $80a1  
    sta D868b,x                                 // $80a4  
L80a7:
    sta D86c2                                   // $80a7  
    sta D8694,x                                 // $80aa  
    sta D869d,x                                 // $80ad  
    lda #$03                                    // $80b0  
    sta D86c6,x                                 // $80b2  
    lda D867f,x                                 // $80b5  
    sta $a7                                     // $80b8  
    lda D8682,x                                 // $80ba  
    sta $a8                                     // $80bd  
L80bf:
    ldy D86c2                                   // $80bf  
    inc D86c2                                   // $80c2  
    lda ($a7),y                                 // $80c5  
    iny                                         // $80c7  
    cmp #$ff                                    // $80c8  
    bne L80d7                                   // $80ca  
    jsr L84c3                                   // $80cc  
    lda #$00                                    // $80cf  
    sta D86c2                                   // $80d1  
    jmp L80bf                                   // $80d4  
L80d7:
    cmp #$fe                                    // $80d7  
    bne L80e3                                   // $80d9  
    lda #$00                                    // $80db  
    sta D8000                                   // $80dd  
    jmp L8001                                   // $80e0  
L80e3:
    cmp #$fd                                    // $80e3  
    bne L80f4                                   // $80e5  
    lda ($a7),y                                 // $80e7  
    iny                                         // $80e9  
    sta SID_MODE_VOL                            // $80ea  
    lda ($a7),y                                 // $80ed  
    iny                                         // $80ef  
    cmp #$ff                                    // $80f0  
    beq L80bf                                   // $80f2  
L80f4:
    cmp #$f0                                    // $80f4  
    bcc L8100                                   // $80f6  
    and #$0f                                    // $80f8  
    sta D866e                                   // $80fa  
    lda ($a7),y                                 // $80fd  
    iny                                         // $80ff  
L8100:
    cmp #$c0                                    // $8100  
    bcc L810f                                   // $8102  
    and #$1f                                    // $8104  
    asl                                         // $8106  
    asl                                         // $8107  
    asl                                         // $8108  
    sta D86c3,x                                 // $8109  
    lda ($a7),y                                 // $810c  
    iny                                         // $810e  
L810f:
    cmp #$80                                    // $810f  
    bcc L811b                                   // $8111  
    and #$3f                                    // $8113  
    sta D8685,x                                 // $8115  
    lda ($a7),y                                 // $8118  
    iny                                         // $811a  
L811b:
    cmp #$60                                    // $811b  
    bcc L814d                                   // $811d  
    cmp #$7b                                    // $811f  
    bne L8140                                   // $8121  
    lda #$00                                    // $8123  
    sta D868e,x                                 // $8125  
    lda #$01                                    // $8128  
    sta D868b,x                                 // $812a  
    lda ($a7),y                                 // $812d  
    iny                                         // $812f  
    clc                                         // $8130  
    adc D8691,x                                 // $8131  
    sta D8694,x                                 // $8134  
    lda ($a7),y                                 // $8137  
    iny                                         // $8139  
    sta D8697,x                                 // $813a  
    jmp L814a                                   // $813d  
L8140:
    cmp #$7a                                    // $8140  
    bne L814d                                   // $8142  
    lda ($a7),y                                 // $8144  
    iny                                         // $8146  
    sta D86b1,x                                 // $8147  
L814a:
    lda ($a7),y                                 // $814a  
    iny                                         // $814c  
L814d:
    sty D86c2                                   // $814d  
    clc                                         // $8150  
    adc D8691,x                                 // $8151  
    sta D8669,x                                 // $8154  
    pha                                         // $8157  
    ldy D86c3,x                                 // $8158  
    lda #$ff                                    // $815b  
    sta D86c9,x                                 // $815d  
    lda D8756,y                                 // $8160  
    sta L8179+1                                 // $8163  
    pla                                         // $8166  
    beq L8176                                   // $8167  
    lda D868e,x                                 // $8169  
    bne L8176                                   // $816c  
    lda D8759,y                                 // $816e  
    beq L8176                                   // $8171  
    sta D868e,x                                 // $8173  
L8176:
    jsr L8483                                   // $8176  
L8179:
    lda #$00                                    // $8179  
    ldy D86cc                                   // $817b  
    pha                                         // $817e  
    and #$f0                                    // $817f  
    sta D8679,x                                 // $8181  
    sta SID_V1_PW_LO,y                          // $8184  
    pla                                         // $8187  
    and #$0f                                    // $8188  
    sta D867c,x                                 // $818a  
    sta SID_V1_PW_HI,y                          // $818d  
    lda D8666,x                                 // $8190  
    beq L81b4                                   // $8193  
    lda D86c3,x                                 // $8195  
    tax                                         // $8198  
    lda D8754,x                                 // $8199  
    sta SID_V1_AD,y                             // $819c  
    lda D8755,x                                 // $819f  
    sta SID_V1_SR,y                             // $81a2  
    lda #$00                                    // $81a5  
    sta SID_V1_CTRL,y                           // $81a7  
    lda D8753,x                                 // $81aa  
    and #$f0                                    // $81ad  
    ora #$05                                    // $81af  
    sta SID_V1_CTRL,y                           // $81b1  
L81b4:
    ldx D866c                                   // $81b4  
    lda D867f,x                                 // $81b7  
    clc                                         // $81ba  
    adc D86c2                                   // $81bb  
    sta D867f,x                                 // $81be  
    bcc L81c6                                   // $81c1  
    inc D8682,x                                 // $81c3  
L81c6:
    lda D8685,x                                 // $81c6  
    sta D8688,x                                 // $81c9  
    lda D86b1,x                                 // $81cc  
    sta D86b4,x                                 // $81cf  
    ldy D865b,x                                 // $81d2  
    iny                                         // $81d5  
    tya                                         // $81d6  
    sta D86a6,x                                 // $81d7  
    jmp L83ec                                   // $81da  
L81dd:
    lda D8669,x                                 // $81dd  
    beq L81ef                                   // $81e0  
    ldy D86c3,x                                 // $81e2  
    lda D875a,y                                 // $81e5  
    and #$08                                    // $81e8  
    beq L81f2                                   // $81ea  
    jmp L8257                                   // $81ec  
L81ef:
    jmp L83ec                                   // $81ef  
L81f2:
    lda D875a,y                                 // $81f2  
    and #$04                                    // $81f5  
    beq L81fc                                   // $81f7  
    jmp L8273                                   // $81f9  
L81fc:
    ldy D86c3,x                                 // $81fc  
    lda D875a,y                                 // $81ff  
    ldy D86cc                                   // $8202  
    and #$01                                    // $8205  
    beq L8254                                   // $8207  
    ldy D86c3,x                                 // $8209  
    lda D8757,y                                 // $820c  
    and #$0f                                    // $820f  
    asl                                         // $8211  
    asl                                         // $8212  
    tay                                         // $8213  
    lda D86ed,y                                 // $8214  
    sta L8235+1                                 // $8217  
    lda D86ee,y                                 // $821a  
    sta L8235+2                                 // $821d  
    lda D86ef,y                                 // $8220  
    sta L8240+1                                 // $8223  
    lda D86f0,y                                 // $8226  
    sta L8240+2                                 // $8229  
    lda D86c9,x                                 // $822c  
    cmp #$1f                                    // $822f  
    bcs L8254                                   // $8231  
    pha                                         // $8233  
    tay                                         // $8234  
L8235:
    lda D8705,y                                 // $8235  
    ldy D86cc                                   // $8238  
    sta SID_V1_CTRL,y                           // $823b  
    pla                                         // $823e  
    tay                                         // $823f  
L8240:
    lda D86f5,y                                 // $8240  
    ldy D86cc                                   // $8243  
    clc                                         // $8246  
    adc #$0d                                    // $8247  
    sta SID_V1_FREQ_HI,y                        // $8249  
    lda #$00                                    // $824c  
    sta SID_V1_FREQ_LO,y                        // $824e  
    jmp L83ec                                   // $8251  
L8254:
    jmp L82a1                                   // $8254  
L8257:
    ldy D86c3,x                                 // $8257  
    lda D86c9,x                                 // $825a  
    cmp #$01                                    // $825d  
    bcs L828f                                   // $825f  
    lda #$48                                    // $8261  
    ldy D86cc                                   // $8263  
    sta SID_V1_FREQ_HI,y                        // $8266  
    lda #$00                                    // $8269  
    sta SID_V1_FREQ_LO,y                        // $826b  
    lda #$81                                    // $826e  
    jmp L8298                                   // $8270  
L8273:
    ldy D86c3,x                                 // $8273  
    lda D86c9,x                                 // $8276  
    cmp #$01                                    // $8279  
    bcs L828f                                   // $827b  
    lda #$48                                    // $827d  
    ldy D86cc                                   // $827f  
    sta SID_V1_FREQ_HI,y                        // $8282  
    lda #$00                                    // $8285  
    sta SID_V1_FREQ_LO,y                        // $8287  
    lda #$11                                    // $828a  
    jmp L8298                                   // $828c  
L828f:
    jsr L8483                                   // $828f  
    ldy D86c3,x                                 // $8292  
    lda D8753,y                                 // $8295  
L8298:
    ldy D86cc                                   // $8298  
    sta SID_V1_CTRL,y                           // $829b  
    jmp L83ec                                   // $829e  
L82a1:
    lda D868b,x                                 // $82a1  
    bne L82ae                                   // $82a4  
    ldy D86c3,x                                 // $82a6  
    lda D8757,y                                 // $82a9  
    bne L82b1                                   // $82ac  
L82ae:
    jmp L8363                                   // $82ae  
L82b1:
    pha                                         // $82b1  
    and #$0f                                    // $82b2  
    sta D86aa                                   // $82b4  
    pla                                         // $82b7  
    lsr                                         // $82b8  
    lsr                                         // $82b9  
    lsr                                         // $82ba  
    lsr                                         // $82bb  
    sta D86a9                                   // $82bc  
    ldy D8669,x                                 // $82bf  
    lda D85e7,y                                 // $82c2  
    sec                                         // $82c5  
    sbc D85e6,y                                 // $82c6  
    sta D86b9                                   // $82c9  
    lda D8586,y                                 // $82cc  
    sbc D8585,y                                 // $82cf  
    sta D86ba                                   // $82d2  
L82d5:
    dec D86aa                                   // $82d5  
    bmi L82e3                                   // $82d8  
    lsr D86ba                                   // $82da  
    ror D86b9                                   // $82dd  
    jmp L82d5                                   // $82e0  
L82e3:
    lda D86ab,x                                 // $82e3  
    bpl L82f2                                   // $82e6  
    dec D86ae,x                                 // $82e8  
    bne L8300                                   // $82eb  
    inc D86ab,x                                 // $82ed  
    bpl L8300                                   // $82f0  
L82f2:
    inc D86ae,x                                 // $82f2  
    lda D86ae,x                                 // $82f5  
    cmp D86a9                                   // $82f8  
    bcc L8300                                   // $82fb  
    dec D86ab,x                                 // $82fd  
L8300:
    lda D86b4,x                                 // $8300  
    beq L830b                                   // $8303  
    dec D86b4,x                                 // $8305  
    jmp L83ec                                   // $8308  
L830b:
    lda D8673,x                                 // $830b  
    sta D86b7                                   // $830e  
    lda D8676,x                                 // $8311  
    sta D86b8                                   // $8314  
    lda D86a9                                   // $8317  
    lsr                                         // $831a  
    tay                                         // $831b  
L831c:
    dey                                         // $831c  
    bmi L8335                                   // $831d  
    lda D86b7                                   // $831f  
    sec                                         // $8322  
    sbc D86b9                                   // $8323  
    sta D86b7                                   // $8326  
    lda D86b8                                   // $8329  
    sbc D86ba                                   // $832c  
    sta D86b8                                   // $832f  
    jmp L831c                                   // $8332  
L8335:
    ldy D86ae,x                                 // $8335  
L8338:
    dey                                         // $8338  
    bmi L8351                                   // $8339  
    lda D86b7                                   // $833b  
    clc                                         // $833e  
    adc D86b9                                   // $833f  
    sta D86b7                                   // $8342  
    lda D86b8                                   // $8345  
    adc D86ba                                   // $8348  
    sta D86b8                                   // $834b  
    jmp L8338                                   // $834e  
L8351:
    ldy D86cc                                   // $8351  
    lda D86b7                                   // $8354  
    sta SID_V1_FREQ_LO,y                        // $8357  
    lda D86b8                                   // $835a  
    sta SID_V1_FREQ_HI,y                        // $835d  
    jmp L83ec                                   // $8360  
L8363:
    lda D868e,x                                 // $8363  
    beq L839e                                   // $8366  
    sta D86bb                                   // $8368  
    jsr L849e                                   // $836b  
L836e:
    ldy D86a6,x                                 // $836e  
    lda D86cd,y                                 // $8371  
    cmp #$ff                                    // $8374  
    bne L8381                                   // $8376  
    lda D865b,x                                 // $8378  
    sta D86a6,x                                 // $837b  
    jmp L836e                                   // $837e  
L8381:
    clc                                         // $8381  
    adc D8669,x                                 // $8382  
    ldy D86cc                                   // $8385  
    tax                                         // $8388  
    lda D85e6,x                                 // $8389  
    sta SID_V1_FREQ_LO,y                        // $838c  
    lda D8585,x                                 // $838f  
    sta SID_V1_FREQ_HI,y                        // $8392  
    ldx D866c                                   // $8395  
    inc D86a6,x                                 // $8398  
    jmp L83ec                                   // $839b  
L839e:
    lda D8694,x                                 // $839e  
    beq L83ec                                   // $83a1  
    sta L84fe+1                                 // $83a3  
    lda D8697,x                                 // $83a6  
    pha                                         // $83a9  
    and #$0f                                    // $83aa  
    sta L83c0+1                                 // $83ac  
    sta L854e+1                                 // $83af  
    pla                                         // $83b2  
    lsr                                         // $83b3  
    lsr                                         // $83b4  
    lsr                                         // $83b5  
    lsr                                         // $83b6  
    clc                                         // $83b7  
    adc D8688,x                                 // $83b8  
    cmp D8685,x                                 // $83bb  
    bcs L83ec                                   // $83be  
L83c0:
    adc #$00                                    // $83c0  
    cmp D8685,x                                 // $83c2  
    bcc L83ec                                   // $83c5  
    ldy D8669,x                                 // $83c7  
    jsr L84fe                                   // $83ca  
    ldx D866c                                   // $83cd  
    ldy D86cc                                   // $83d0  
    lda D8673,x                                 // $83d3  
L83d6:
    clc                                         // $83d6  
L83d7:
    adc D869a                                   // $83d7  
    sta D8673,x                                 // $83da  
    sta SID_V1_FREQ_LO,y                        // $83dd  
    lda D8676,x                                 // $83e0  
L83e3:
    adc D869b                                   // $83e3  
    sta D8676,x                                 // $83e6  
    sta SID_V1_FREQ_HI,y                        // $83e9  
L83ec:
    lda D8685,x                                 // $83ec  
    beq L840a                                   // $83ef  
    lsr                                         // $83f1  
    cmp D8688,x                                 // $83f2  
    bne L840a                                   // $83f5  
    ldy D86c3,x                                 // $83f7  
    lda D8753,y                                 // $83fa  
    and #$0f                                    // $83fd  
    clc                                         // $83ff  
    rol                                         // $8400  
    rol                                         // $8401  
    rol                                         // $8402  
    rol                                         // $8403  
    ldy D86cc                                   // $8404  
    sta SID_V1_CTRL,y                           // $8407  
L840a:
    ldy D86c3,x                                 // $840a  
    lda D8758,y                                 // $840d  
    beq L845f                                   // $8410  
    lda D86a3,x                                 // $8412  
    bne L8437                                   // $8415  
    lda D8679,x                                 // $8417  
    clc                                         // $841a  
    adc D8758,y                                 // $841b  
    pha                                         // $841e  
    sta D8679,x                                 // $841f  
    lda D867c,x                                 // $8422  
    adc #$00                                    // $8425  
    sta D867c,x                                 // $8427  
    pha                                         // $842a  
    cmp #$0f                                    // $842b  
    bcc L8454                                   // $842d  
    lda #$01                                    // $842f  
    sta D86a3,x                                 // $8431  
    jmp L8454                                   // $8434  
L8437:
    lda D8679,x                                 // $8437  
    sec                                         // $843a  
    sbc D8758,y                                 // $843b  
    pha                                         // $843e  
    sta D8679,x                                 // $843f  
    lda D867c,x                                 // $8442  
    sbc #$00                                    // $8445  
    sta D867c,x                                 // $8447  
    pha                                         // $844a  
    cmp #$08                                    // $844b  
    bcs L8454                                   // $844d  
    lda #$00                                    // $844f  
    sta D86a3,x                                 // $8451  
L8454:
    ldy D86cc                                   // $8454  
    pla                                         // $8457  
    sta SID_V1_PW_HI,y                          // $8458  
    pla                                         // $845b  
    sta SID_V1_PW_LO,y                          // $845c  
L845f:
    dec D866c                                   // $845f  
    bmi L8467                                   // $8462  
    jmp L8063                                   // $8464  
L8467:
    dec D866f                                   // $8467  
    bpl L8472                                   // $846a  
    lda D866e                                   // $846c  
    sta D866f                                   // $846f  
L8472:
    lda #$ff                                    // $8472  
    sta D8000                                   // $8474  
    rts                                         // $8477  
L8478:
    ldy #$18                                    // $8478  
    lda #$00                                    // $847a  
L847c:
    sta SID_V1_FREQ_LO,y                        // $847c  
    dey                                         // $847f  
    bpl L847c                                   // $8480  
    rts                                         // $8482  
L8483:
    ldy D8669,x                                 // $8483  
    lda D85e6,y                                 // $8486  
    sta D8673,x                                 // $8489  
    pha                                         // $848c  
    lda D8585,y                                 // $848d  
    sta D8676,x                                 // $8490  
    ldy D86cc                                   // $8493  
    sta SID_V1_FREQ_HI,y                        // $8496  
    pla                                         // $8499  
    sta SID_V1_FREQ_LO,y                        // $849a  
    rts                                         // $849d  
L849e:
    ldy D865b,x                                 // $849e  
    iny                                         // $84a1  
    ldx #$00                                    // $84a2  
L84a4:
    ror D86bb                                   // $84a4  
    bcc L84b0                                   // $84a7  
    lda D865e,x                                 // $84a9  
    sta D86cd,y                                 // $84ac  
    iny                                         // $84af  
L84b0:
    inx                                         // $84b0  
    cpx #$08                                    // $84b1  
    bne L84a4                                   // $84b3  
    ldx D866c                                   // $84b5  
    lda #$ff                                    // $84b8  
    sta D86cd,y                                 // $84ba  
    lda #$00                                    // $84bd  
    sta D8694,x                                 // $84bf  
    rts                                         // $84c2  
L84c3:
    lda D86bc,x                                 // $84c3  
    sta $a9                                     // $84c6  
    lda D86bf,x                                 // $84c8  
    sta $aa                                     // $84cb  
L84cd:
    ldy D8670,x                                 // $84cd  
    inc D8670,x                                 // $84d0  
    lda ($a9),y                                 // $84d3  
    bpl L84eb                                   // $84d5  
    cmp #$ff                                    // $84d7  
    bne L84e2                                   // $84d9  
    lda #$00                                    // $84db  
    sta D8670,x                                 // $84dd  
    beq L84cd                                   // $84e0  
L84e2:
    clc                                         // $84e2  
    adc #$40                                    // $84e3  
    sta D8691,x                                 // $84e5  
    jmp L84cd                                   // $84e8  
L84eb:
    asl                                         // $84eb  
    tay                                         // $84ec  
    lda D87fb,y                                 // $84ed  
    sta D867f,x                                 // $84f0  
    sta $a7                                     // $84f3  
    lda D87fc,y                                 // $84f5  
    sta D8682,x                                 // $84f8  
    sta $a8                                     // $84fb  
    rts                                         // $84fd  
L84fe:
    ldx #$00                                    // $84fe  
    cpy L84fe+1                                 // $8500  
    bcs L8528                                   // $8503  
    lda #$18                                    // $8505  
    sta L83d6                                   // $8507  
    lda #$6d                                    // $850a  
    sta L83d7                                   // $850c  
    sta L83e3                                   // $850f  
    sec                                         // $8512  
    lda D85e6,x                                 // $8513  
    sbc D85e6,y                                 // $8516  
    sta D869a                                   // $8519  
    lda D8585,x                                 // $851c  
    sbc D8585,y                                 // $851f  
    sta D869b                                   // $8522  
    jmp L8548                                   // $8525  
L8528:
    lda #$38                                    // $8528  
    sta L83d6                                   // $852a  
    lda #$ed                                    // $852d  
    sta L83d7                                   // $852f  
    sta L83e3                                   // $8532  
    sec                                         // $8535  
    lda D85e6,y                                 // $8536  
    sbc D85e6,x                                 // $8539  
    sta D869a                                   // $853c  
    lda D8585,y                                 // $853f  
    sbc D8585,x                                 // $8542  
    sta D869b                                   // $8545  
L8548:
    ldy D866e                                   // $8548  
    lda #$00                                    // $854b  
    clc                                         // $854d  
L854e:
    adc #$00                                    // $854e  
    dey                                         // $8550  
    bpl L854e                                   // $8551  
    sta D869c                                   // $8553  
    clc                                         // $8556  
    ldx #$10                                    // $8557  
    lda #$00                                    // $8559  
L855b:
    rol D869a                                   // $855b  
    rol D869b                                   // $855e  
    rol                                         // $8561  
    bcs L8569                                   // $8562  
    cmp D869c                                   // $8564  
    bcc L856d                                   // $8567  
L8569:
    sbc D869c                                   // $8569  
    sec                                         // $856c  
L856d:
    dex                                         // $856d  
    bne L855b                                   // $856e  
    rol D869a                                   // $8570  
    rol D869b                                   // $8573  
    asl                                         // $8576  
    cmp D869c                                   // $8577  
    bcc L8584                                   // $857a  
    inc D869a                                   // $857c  
    bne L8584                                   // $857f  
    inc D869b                                   // $8581  
L8584:
    rts                                         // $8584  
D8585:
    .byte $00                                   // $8585  
D8586:
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02  // $8586  
    .byte $02,$02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06  // $8596  
    .byte $06,$07,$07,$07,$08,$08,$09,$09,$0a,$0b,$0b,$0c,$0d,$0e,$0e,$0f  // $85a6  
    .byte $10,$11,$12,$13,$15,$16,$17,$19,$1a,$1c,$1d,$1f,$21,$23,$25,$27  // $85b6  
    .byte $2a,$2c,$2f,$32,$35,$38,$3b,$3f,$43,$47,$4b,$4f,$54,$59,$5e,$64  // $85c6  
    .byte $6a,$70,$77,$7e,$86,$8e,$96,$9f,$a8,$b3,$bd,$c8,$d4,$e1,$ee,$fd  // $85d6  
D85e6:
    .byte $00                                   // $85e6  
D85e7:
    .byte $0c,$1c,$2d,$3e,$51,$66,$7b,$91,$a9,$c3,$dd,$fa,$18,$38,$5a,$7d  // $85e7  
    .byte $a3,$cc,$f6,$23,$5d,$86,$bb,$f4,$30,$70,$b4,$fb,$47,$98,$ed,$47  // $85f7  
    .byte $a7,$0c,$77,$e9,$61,$e1,$68,$f7,$8f,$30,$da,$8f,$4e,$18,$ef,$d2  // $8607  
    .byte $c3,$c3,$d1,$ef,$1f,$60,$b5,$1e,$9c,$31,$df,$a5,$87,$86,$a2,$df  // $8617  
    .byte $3e,$c1,$6b,$3c,$39,$63,$be,$4b,$0f,$0c,$45,$bf,$7d,$83,$d6,$79  // $8627  
    .byte $73,$c7,$7c,$97,$1e,$18,$8b,$7e,$fa,$06,$ac,$f3,$e6,$8f,$f8,$2e  // $8637  
L8647:
    jsr L8478                                   // $8647  
    lda #$07                                    // $864a  
    sta SID_MODE_VOL                            // $864c  
    lda #$00                                    // $864f  
    sta D866f                                   // $8651  
    sta D866d                                   // $8654  
    rts                                         // $8657  
D8658:
    .byte $00,$07,$0e                           // $8658  
D865b:
    .byte $00,$0a,$14                           // $865b  
D865e:
    .byte $03,$04,$05,$07,$08,$09,$0c,$18       // $865e  
D8666:
    .byte $01,$01,$01                           // $8666  
D8669:
    .byte $00,$00,$00                           // $8669  
D866c:
    .byte $00                                   // $866c  
D866d:
    .byte $00                                   // $866d  
D866e:
    .byte $01                                   // $866e  
D866f:
    .byte $00                                   // $866f  
D8670:
    .byte $00,$00,$00                           // $8670  
D8673:
    .byte $00,$00,$00                           // $8673  
D8676:
    .byte $00,$00,$00                           // $8676  
D8679:
    .byte $00,$00,$00                           // $8679  
D867c:
    .byte $00,$00,$00                           // $867c  
D867f:
    .byte $00,$00,$00                           // $867f  
D8682:
    .byte $00,$00,$00                           // $8682  
D8685:
    .byte $00,$00,$00                           // $8685  
D8688:
    .byte $00,$00,$00                           // $8688  
D868b:
    .byte $00,$00,$00                           // $868b  
D868e:
    .byte $00,$00,$00                           // $868e  
D8691:
    .byte $00,$00,$00                           // $8691  
D8694:
    .byte $00,$00,$00                           // $8694  
D8697:
    .byte $00,$00,$00                           // $8697  
D869a:
    .byte $00                                   // $869a  
D869b:
    .byte $00                                   // $869b  
D869c:
    .byte $00                                   // $869c  
D869d:
    .byte $00,$00,$00                           // $869d  
D86a0:
    .byte $00,$00,$00                           // $86a0  
D86a3:
    .byte $00,$00,$00                           // $86a3  
D86a6:
    .byte $00,$00,$00                           // $86a6  
D86a9:
    .byte $00                                   // $86a9  
D86aa:
    .byte $00                                   // $86aa  
D86ab:
    .byte $00,$00,$00                           // $86ab  
D86ae:
    .byte $00,$00,$00                           // $86ae  
D86b1:
    .byte $00,$00,$00                           // $86b1  
D86b4:
    .byte $00,$00,$00                           // $86b4  
D86b7:
    .byte $00                                   // $86b7  
D86b8:
    .byte $00                                   // $86b8  
D86b9:
    .byte $00                                   // $86b9  
D86ba:
    .byte $00                                   // $86ba  
D86bb:
    .byte $00                                   // $86bb  
D86bc:
    .byte $00,$00,$00                           // $86bc  
D86bf:
    .byte $00,$00,$00                           // $86bf  
D86c2:
    .byte $00                                   // $86c2  
D86c3:
    .byte $00,$00,$00                           // $86c3  
D86c6:
    .byte $03,$03,$03                           // $86c6  
D86c9:
    .byte $00                                   // $86c9  
D86ca:
    .byte $00                                   // $86ca  
D86cb:
    .byte $00                                   // $86cb  
D86cc:
    .byte $00                                   // $86cc  
D86cd:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $86cd  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $86dd  
D86ed:
    .byte $05                                   // $86ed  
D86ee:
    .byte $87                                   // $86ee  
D86ef:
    .byte $f5                                   // $86ef  
D86f0:
    .byte $86,$25,$87,$15,$87                   // $86f0  
D86f5:
    .byte $1a,$01,$ff,$20,$0a,$12,$04,$16,$00,$00,$00,$00,$00,$00,$00,$00  // $86f5  
D8705:
    .byte $81,$41,$40,$80,$80,$80,$80,$80,$10,$10,$10,$10,$10,$10,$10,$10  // $8705  
    .byte $1f,$ff,$1f,$51,$53,$f9,$24,$33,$f0,$e0,$00,$00,$00,$00,$00,$00  // $8715  
    .byte $81,$40,$81,$81,$81,$40,$81,$81,$40,$80,$10,$10,$10,$10,$10,$10  // $8725  
D8735:
    .byte $3b,$88,$83,$88,$b1,$88,$cf,$88,$e0,$88,$f5,$88,$fe,$88,$02,$89  // $8735  
    .byte $06,$89,$0a,$89,$0e,$89,$0e,$89,$0a,$8c,$0d,$8c,$10,$8c  // $8745  
D8753:
    .byte $00                                   // $8753  
D8754:
    .byte $00                                   // $8754  
D8755:
    .byte $00                                   // $8755  
D8756:
    .byte $00                                   // $8756  
D8757:
    .byte $00                                   // $8757  
D8758:
    .byte $00                                   // $8758  
D8759:
    .byte $00                                   // $8759  
D875a:
    .byte $00,$44,$03,$f8,$82,$00,$10,$00,$04,$44,$08,$59,$23,$00,$90,$00  // $875a  
    .byte $04,$42,$02,$ea,$00,$42,$30,$00,$02,$24,$06,$cd,$03,$41,$05,$00  // $876a  
    .byte $00,$44,$04,$78,$08,$00,$46,$4a,$01,$22,$04,$97,$03,$00,$23,$4a  // $877a  
    .byte $00,$22,$04,$57,$03,$00,$20,$64,$00,$44,$07,$7b,$08,$42,$00,$00  // $878a  
    .byte $04,$44,$04,$7e,$05,$42,$30,$c0,$00,$44,$07,$ad,$08,$41,$00,$00  // $879a  
    .byte $00,$42,$08,$db,$03,$41,$da,$00,$02,$44,$02,$9d,$06,$41,$60,$00  // $87aa  
    .byte $00,$44,$02,$79,$08,$00,$01,$00,$04,$81,$07,$98,$08,$20,$0a,$00  // $87ba  
    .byte $01,$44,$04,$9d,$07,$42,$30,$00,$00,$44,$03,$49,$08,$41,$40,$00  // $87ca  
    .byte $04,$42,$07,$7d,$02,$41,$46,$00,$00,$22,$04,$d7,$03,$00,$23,$4a  // $87da  
    .byte $00,$44,$04,$9d,$01,$42,$08,$00,$00,$44,$04,$9d,$05,$41,$28,$00  // $87ea  
    .byte $00                                   // $87fa  
D87fb:
    .byte $16                                   // $87fb  
D87fc:
    .byte $89,$7d,$89,$92,$89,$78,$89,$f7,$89,$28,$8a,$7b,$8a,$2d,$89,$44  // $87fc  
    .byte $89,$a7,$89,$bc,$89,$ba,$8a,$cd,$89,$c1,$8a,$c8,$8a,$57,$89,$6d  // $880c  
    .byte $89,$e2,$89,$cf,$8a,$f6,$8a,$19,$8b,$2d,$8b,$40,$8b,$53,$8b,$66  // $881c  
    .byte $8b,$82,$8b,$b4,$8b,$c3,$8b,$d2,$8b,$e0,$8b,$e7,$8b,$f8,$8b,$c0  // $882c  
    .byte $0f,$0f,$0f,$0f,$c0,$00,$c5,$00,$00,$c0,$00,$00,$c5,$00,$00,$c0  // $883c  
    .byte $00,$c2,$00,$c7,$00,$c0,$07,$08,$c1,$0d,$c2,$0d,$d0,$0b,$d4,$0b  // $884c  
    .byte $da,$0b,$e0,$0b,$c0,$0f,$0f,$c2,$0f,$c5,$00,$c8,$00,$00,$bb,$0f  // $885c  
    .byte $cc,$10,$c2,$00,$c7,$00,$00,$c2,$00,$00,$c7,$00,$00,$c2,$00,$c4  // $886c  
    .byte $00,$c9,$00,$c2,$07,$08,$ff,$cc,$01,$01,$01,$01,$01,$02,$02,$01  // $887c  
    .byte $01,$02,$02,$01,$ce,$01,$02,$c0,$09,$0a,$0e,$0e,$12,$bc,$01,$c0  // $888c  
    .byte $03,$bb,$01,$c0,$13,$ce,$01,$02,$02,$01,$01,$02,$02,$01,$d0,$01  // $889c  
    .byte $02,$c2,$09,$0a,$ff,$c0,$03,$03,$03,$03,$c0,$04,$05,$06,$0c,$0c  // $88ac  
    .byte $0c,$0c,$0c,$0c,$bd,$0c,$c0,$0c,$0c,$0c,$bb,$0c,$c0,$11,$c2,$04  // $88bc  
    .byte $05,$06,$ff,$c0,$14,$be,$14,$b9,$14,$be,$14,$b4,$14,$11,$14,$ad  // $88cc  
    .byte $14,$b2,$14,$ff,$cc,$15,$ca,$16,$cc,$17,$ca,$16,$c0,$15,$ca,$16  // $88dc  
    .byte $cc,$17,$ca,$16,$c0,$19,$cc,$19,$ff,$c0,$18,$be,$18,$c5,$18,$be  // $88ec  
    .byte $18,$ff,$c0,$1a,$03,$ff,$c0,$1b,$03,$ff,$c0,$1c,$03,$ff,$c0,$1d  // $88fc  
    .byte $03,$ff,$c0,$1e,$03,$ff,$c0,$1f,$03,$ff,$c1,$81,$13,$13,$1f,$13  // $890c  
    .byte $cd,$43,$c1,$1f,$13,$1f,$13,$1f,$1f,$13,$cd,$43,$37,$c1,$13,$1f  // $891c  
    .byte $ff,$c1,$81,$13,$13,$1f,$13,$cd,$37,$c1,$1f,$13,$1f,$18,$18,$24  // $892c  
    .byte $18,$cd,$43,$37,$c1,$18,$24,$ff,$c1,$81,$18,$18,$24,$18,$24,$24  // $893c  
    .byte $18,$24,$1f,$1f,$2b,$1f,$2b,$2b,$1f,$2b,$ff,$f2,$c1,$81,$13,$13  // $894c  
    .byte $1f,$13,$1f,$c0,$00,$c1,$13,$1f,$13,$1f,$1f,$13,$1f,$1d,$13,$1f  // $895c  
    .byte $ff,$c1,$83,$0e,$1a,$1a,$1c,$11,$1d,$12,$1e,$ff,$f2,$c0,$9f,$00  // $896c  
    .byte $ff,$c6,$83,$2b,$2b,$81,$2b,$83,$2b,$81,$2b,$83,$2b,$81,$2b,$83  // $897c  
    .byte $2b,$81,$2b,$2b,$1f,$ff,$c7,$83,$2b,$2b,$81,$2b,$83,$2b,$81,$2b  // $898c  
    .byte $83,$2b,$81,$2b,$83,$2b,$81,$2b,$2b,$1f,$ff,$d2,$83,$43,$43,$81  // $899c  
    .byte $43,$83,$43,$81,$43,$83,$3c,$81,$3c,$83,$3c,$81,$3c,$3c,$30,$ff  // $89ac  
    .byte $d2,$83,$3c,$3c,$81,$3c,$83,$3c,$81,$3c,$37,$37,$83,$37,$37,$37  // $89bc  
    .byte $ff,$c2,$81,$7a,$0c,$2b,$2b,$37,$2b,$37,$37,$2b,$37,$2b,$37,$37  // $89cc  
    .byte $2b,$37,$37,$2b,$37,$ff,$ce,$81,$32,$83,$32,$81,$32,$30,$83,$30  // $89dc  
    .byte $81,$30,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$ff,$c4,$81,$7a,$0f,$37  // $89ec  
    .byte $83,$37,$85,$35,$83,$37,$81,$34,$35,$83,$34,$81,$32,$85,$37,$97  // $89fc  
    .byte $34,$83,$00,$83,$37,$3a,$39,$81,$37,$39,$83,$37,$81,$35,$37,$83  // $8a0c  
    .byte $35,$81,$34,$32,$30,$95,$37,$83,$32,$34,$37,$ff,$c8,$81,$7a,$0c  // $8a1c  
    .byte $39,$83,$3b,$81,$39,$83,$3b,$81,$39,$3b,$39,$3b,$39,$3b,$39,$3b  // $8a2c  
    .byte $39,$ca,$95,$7a,$0e,$37,$c8,$83,$34,$37,$35,$81,$34,$34,$36,$34  // $8a3c  
    .byte $37,$34,$39,$34,$3a,$34,$3a,$34,$3a,$39,$37,$32,$d0,$80,$32,$33  // $8a4c  
    .byte $34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f,$40,$41,$42,$43  // $8a5c  
    .byte $44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$51,$ff,$cf  // $8a6c  
    .byte $81,$7a,$0c,$2d,$2d,$39,$2d,$39,$37,$2d,$39,$2d,$39,$39,$2d,$39  // $8a7c  
    .byte $37,$2d,$36,$81,$36,$37,$83,$36,$81,$34,$36,$34,$8d,$32,$83,$30  // $8a8c  
    .byte $81,$2f,$30,$83,$2f,$81,$2d,$2f,$2d,$8f,$2b,$81,$00,$81,$37,$37  // $8a9c  
    .byte $83,$37,$81,$34,$83,$32,$85,$37,$83,$43,$4f,$ca,$1f,$ff,$d3,$87  // $8aac  
    .byte $7a,$12,$0c,$10,$ff,$d3,$8f,$7a,$12,$0c,$10,$ff,$f2,$d1,$bf,$7a  // $8abc  
    .byte $12,$1f,$ff,$cc,$81,$7a,$0f,$43,$83,$43,$85,$41,$83,$43,$81,$40  // $8acc  
    .byte $41,$83,$40,$81,$3e,$85,$43,$9f,$1f,$cc,$83,$2d,$81,$2d,$2d,$83  // $8adc  
    .byte $31,$34,$37,$3a,$87,$37,$cc,$9f,$21,$ff,$ca,$80,$2b,$2c,$2d,$2e  // $8aec  
    .byte $2f,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e  // $8afc  
    .byte $3f,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$ff,$f2,$c7,$81  // $8b0c  
    .byte $34,$34,$34,$34,$34,$83,$34,$34,$81,$34,$83,$34,$81,$34,$85,$34  // $8b1c  
    .byte $ff,$cd,$81,$2d,$34,$39,$2d,$34,$39,$2d,$34,$39,$2d,$34,$39,$2d  // $8b2c  
    .byte $34,$39,$2d,$ff,$cd,$81,$39,$34,$2d,$39,$34,$2d,$39,$34,$2d,$39  // $8b3c  
    .byte $34,$2d,$39,$34,$2d,$39,$ff,$cd,$81,$36,$32,$2d,$36,$32,$2d,$36  // $8b4c  
    .byte $32,$2d,$36,$32,$2d,$36,$32,$2d,$36,$ff,$c1,$81,$7a,$0c,$21,$21  // $8b5c  
    .byte $83,$21,$ce,$81,$2a,$c1,$1c,$1f,$83,$21,$81,$21,$83,$21,$ce,$81  // $8b6c  
    .byte $45,$c1,$1c,$83,$1f,$ff,$d4,$81,$7a,$10,$31,$2d,$32,$2d,$34,$2d  // $8b7c  
    .byte $36,$2d,$34,$32,$2d,$83,$31,$81,$32,$83,$31,$8f,$2f,$89,$23,$81  // $8b8c  
    .byte $2d,$83,$2b,$81,$2a,$26,$2b,$26,$2d,$26,$2f,$26,$2d,$2b,$26,$2a  // $8b9c  
    .byte $26,$2b,$83,$2d,$8f,$2b,$29,$ff,$f2,$c1,$81,$13,$13,$1f,$13,$13  // $8bac  
    .byte $83,$11,$8f,$13,$81,$00,$ff,$cb,$81,$7a,$0e,$32,$3e,$34,$40,$35  // $8bbc  
    .byte $41,$36,$42,$8f,$37,$ff,$c4,$81,$7a,$0c,$37,$37,$43,$37,$41,$85  // $8bcc  
    .byte $3e,$8f,$43,$ff,$f2,$c4,$9f,$7a,$0c,$13,$ff,$c9,$83,$2b,$81,$2b  // $8bdc  
    .byte $83,$37,$81,$2b,$37,$37,$37,$83,$2b,$89,$37,$ff,$c1,$83,$13,$81  // $8bec  
    .byte $13,$83,$1f,$81,$13,$83,$1f,$81,$13,$83,$11,$89,$1f,$ff,$c0,$19  // $8bfc  
    .byte $ff,$c0,$03,$ff,$c0,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c0c  
    .byte $ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c1c  
    .byte $ff,$ff,$ff,$ff,$8b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$bd,$ff  // $8c2c  
    .byte $ff,$ff,$ff,$9f,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$00,$00,$ff  // $8c3c  
    .byte $cd,$00,$cd,$00,$00,$00,$00,$00,$00,$ff,$00,$00,$cd,$00,$00,$00  // $8c4c  
    .byte $00,$00,$00,$cd,$00,$00,$00,$cd,$00,$00,$00,$00,$00,$ff,$ff,$ff  // $8c5c  
    .byte $cf,$00,$ef,$00,$cd,$00,$00,$00,$00,$00,$00,$00,$00,$cd,$00,$00  // $8c6c  
    .byte $00,$00,$fc,$fc,$cb,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c7c  
    .byte $ff,$ef,$ff,$ff,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c8c  
    .byte $ff,$ff,$ff,$ff,$df,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  // $8c9c  
    .byte $ff,$ff,$ff,$ff,$83,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$ff  // $8cac  
    .byte $ff,$ff,$ff,$9f,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$00,$00,$ff  // $8cbc  
    .byte $cd,$00,$cd,$00,$00,$00,$00,$00,$00,$ff,$00,$00,$cd,$00,$00,$00  // $8ccc  
    .byte $00,$00,$00,$cd,$00,$00,$00,$cd,$00,$00,$00,$00,$00,$ff,$ff,$ff  // $8cdc  
    .byte $cf,$00,$ef,$00,$cd,$00,$00,$00,$00,$00,$00,$00,$00,$cd,$00,$00  // $8cec  
    .byte $00,$00,$f4,$f4                       // $8cfc  
D8d00:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $8d00  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $8d10  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // $8d20  
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$55,$00,$00  // $8d30  
    .byte $00,$00,$01,$00,$00,$15,$00,$00,$54,$00,$01,$43,$00,$05,$33,$00  // $8d40  
    .byte $14,$c4,$00,$53,$c4,$00,$53,$11,$01,$4f,$11,$01,$4f,$10,$05,$3c  // $8d50  
    .byte $4f,$05,$3c,$4c,$05,$3c,$4c,$05,$3c,$41,$14,$f1,$41,$14,$f1,$41  // $8d60  
    .byte $14,$f1,$45,$14,$f1,$55,$14,$f1,$50,$14,$f1,$0c,$14,$fc,$f1,$62  // $8d70  
    .byte $55,$55,$50,$40,$00,$55,$3f,$ff,$05,$ff,$fc,$f0,$ff,$f1,$3f,$ff  // $8d80  
    .byte $f1,$3f,$ff,$f1,$3f,$3f,$f1,$33,$3f,$c5,$04,$cf,$04,$dd,$10,$54  // $8d90  
    .byte $d1,$54,$44,$54,$45,$c4,$40,$c5,$c5,$55,$cd,$55,$50,$55,$50,$04  // $8da0  
    .byte $54,$0f,$c5,$03,$ff,$14,$3f,$f8,$54,$4f,$f1,$44,$7c,$c5,$34,$0b  // $8db0  
    .byte $00,$00,$00,$00,$00,$00,$40,$00,$00,$50,$00,$00,$14,$00,$00,$c5  // $8dc0  
    .byte $00,$00,$f1,$40,$00,$f1,$40,$00,$fc,$50,$00,$3c,$50,$00,$3c,$14  // $8dd0  
    .byte $00,$c1,$01,$50,$55,$55,$01,$51,$50,$05,$05,$05,$14,$40,$c4,$50  // $8de0  
    .byte $3f,$d1,$40,$e3,$94,$50,$84,$90,$14,$19,$10,$05,$41,$10,$55,$20  // $8df0  
D8e00:
    .byte $14,$cf,$c5,$14,$13,$15,$14,$14,$51,$14,$4d,$41,$14,$44,$41,$14  // $8e00  
    .byte $44,$51,$01,$11,$51,$01,$15,$46,$05,$14,$04,$05,$02,$84,$05,$0a  // $8e10  
    .byte $85,$15,$0a,$85,$14,$12,$85,$14,$52,$84,$14,$14,$a2,$54,$05,$2a  // $8e20  
    .byte $54,$01,$42,$50,$00,$54,$40,$00,$15,$00,$00,$01,$00,$00,$00,$86  // $8e30  
    .byte $21,$04,$a4,$05,$45,$24,$84,$41,$45,$84,$48,$45,$18,$45,$48,$11  // $8e40  
    .byte $55,$22,$15,$40,$40,$14,$15,$45,$81,$54,$54,$15,$40,$42,$54,$21  // $8e50  
    .byte $2a,$52,$a8,$aa,$0a,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa  // $8e60  
    .byte $aa,$aa,$a0,$2a,$aa,$05,$40,$00,$55,$55,$55,$50,$15,$55,$00,$86  // $8e70  
    .byte $54,$95,$50,$41,$54,$00,$55,$01,$00,$40,$85,$00,$2a,$85,$00,$0a  // $8e80  
    .byte $85,$00,$52,$14,$00,$0a,$14,$00,$aa,$14,$00,$aa,$14,$00,$a8,$50  // $8e90  
    .byte $00,$a8,$50,$00,$a1,$40,$00,$a1,$40,$00,$85,$00,$00,$14,$00,$00  // $8ea0  
    .byte $50,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08  // $8eb0  
    .byte $08,$8d,$82,$02,$a9,$04,$8d,$88,$02,$60,$6a,$fc,$cd,$fb,$31,$ea  // $8ec0  
    .byte $2c,$f9,$a9,$7f,$8d,$0d,$dc,$8d,$0d,$dd,$8d,$00,$dc,$a9,$08,$8d  // $8ed0  
    .byte $0e,$dc,$8d,$0e,$dd,$8d,$0f,$dc,$8d,$0f,$dd,$a2,$00,$8e,$03,$dc  // $8ee0  
    .byte $8e,$03,$dd,$8e,$18,$d4,$ca,$8e,$02,$dc,$a9,$07,$8d,$00,$dd,$a9  // $8ef0  

// ============================================================================
// junk_8f00  ($8f00-$9fff)
// Not used: leftover RAM contents (a 256 byte KERNAL fragment, repeated)
// ============================================================================
* = $8f00 "junk_8f00"
junk_8f00:
    .import binary "bin/junk_8f00.bin"
    .assert "junk_8f00 size", * - junk_8f00, $1100

// ============================================================================
// charset_backup  ($a000-$afff)
// Overwritten at start-up with a copy of the two character sets
// ($2000-$27FF -> $A000, $7800-$7FFF -> $A800). The bytes here are leftovers.
// ============================================================================
* = $a000 "charset_backup"
charset_backup:
    .import binary "bin/charset_backup.bin"
    .assert "charset_backup size", * - charset_backup, $1000

// ============================================================================
// junk_b000  ($b000-$cdff)
// Not used: leftover RAM contents
// ============================================================================
* = $b000 "junk_b000"
junk_b000:
    .import binary "bin/junk_b000.bin"
    .assert "junk_b000 size", * - junk_b000, $1e00

// ============================================================================
// variables  ($ce00-$cfff)
// Game variables ($CE00-$CFFF, see the labels at the top of the file).
// The game sets them before use; the bytes here are leftovers.
// ============================================================================
* = $ce00 "variables"
variables:
    .import binary "bin/variables.bin"
    .assert "variables size", * - variables, $0200

// ============================================================================
// ram_d000  ($d000-$dfff)
// RAM under the I/O area: not used, leftovers
// ============================================================================
* = $d000 "ram_d000"
ram_d000:
    .import binary "bin/ram_d000.bin"
    .assert "ram_d000 size", * - ram_d000, $1000

// ============================================================================
// ram_e000  ($e000-$ffff)
// RAM under the KERNAL ROM: not used, leftovers (an unrelated picture)
// ============================================================================
* = $e000 "ram_e000"
ram_e000:
    .import binary "bin/ram_e000.bin"
    .assert "ram_e000 size", * - ram_e000, $2000

