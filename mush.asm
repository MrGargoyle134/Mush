  .inesprg 1   ; PRG ROM
  .ineschr 1   ; CHR ROM
  .inesmir 1   ; Mirroring
  .inesmap 0

  .bank 0    ; Bank 0
  .org $C000 ; Start at $C000

;; Sprite 1: ;;
PosX1  .db 128
PosX2  .db 136
PosY1  .db 128
PosY2  .db 136

RESET:       ; RESET vector
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010

wblank1:
  BIT $2002
  BPL wblank1 ; While the PPU is not ready

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem

wblank2:
  BIT $2002
  BPL wblank2 ; While the PPU is not ready

;; Load the palette: ;;

LoadPalette:
  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00

LoadBkgPaletteLoop:
  LDA BkgPalette, x
  STA $2007
  INX
  CPX #$10
  BNE LoadBkgPaletteLoop

  LDX #$00

LoadSprPaletteLoop:
  LDA SprPalette, x
  STA $2007
  INX
  CPX #$10
  BNE LoadSprPaletteLoop

  ;; Load sprites: ;;

  Drawsprites:
  LDA #128
  STA $0200     ; Sprite 1 Y
  LDA #128
  STA $0204     ; Sprite 2 Y
  LDA #136
  STA $0208     ; Sprite 3 Y
  LDA #136
  STA $020C     ; Sprite 4 Y

  LDA #$00
  STA $0201     ; Sprite 1 tile
  LDA #$01
  STA $0205     ; Sprite 2 tile
  LDA #$02
  STA $0209     ; Sprite 3 Tile
  LDA #$03
  STA $020D     ; Sprite 4 tile

  LDA #$00
  STA $0202     ; Sprite 1 Attribute
  LDA #$00
  STA $0206     ; Sprite 2 Attribute
  LDA #$00
  STA $020A     ; Sprite 3 Attribute
  LDA #$00
  STA $020E     ; Sprite 4 Attribute

  LDA PosX1
  STA $0203     ; Sprite 1 X
  LDA #136
  STA $0207     ; Sprite 2 X
  LDA #128
  STA $020B     ; Sprite 3 X
  LDA #136
  STA $020F     ; Sprite 4 X

SetPPUCNT:
  LDA #%10000000 ; Execute NMI on vblank
  STA $2000      ; PPUCNT0

  LDA #%00010000 ; Show sprites
  STA $2001      ; PPUCNT1
  
Loop:
     JMP Loop


NMI:        ; The NMI Vector
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014

  RTI



  .bank 1    ; Bank 1
  .org $E000 ; Start at $E000

BkgPalette:
  .db $0F,$0F,$0F,$0F	;background 1
  .db $0F,$0F,$0F,$0F	;background 2
  .db $0F,$0F,$0F,$0F	;background 3
  .db $0F,$0F,$0F,$0F	;background 4
  .db $0F,$0F,$0F,$0F	;background 5

SprPalette: ; The Palette
  .db $0F,$1D,$05,$37	;sprite 1
  .db $0F,$1D,$05,$37	;sprite 2
  .db $0F,$1D,$05,$37	;sprite 3
  .db $0F,$1D,$05,$37	;sprite 4


  .org $FFFA ; Vectors
  .dw NMI
  .dw RESET
  .dw 0


  .bank 2    ; Bank 2 for graphic data
  .org $0000 ; Start at $0000
  .incbin "tiles.chr" ; Load tiles
