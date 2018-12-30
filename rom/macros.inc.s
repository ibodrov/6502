;; Push A and Y
.macro phay
  pha
  phy
.endmacro

;; Pull A and Y
.macro play
  ply
  pla
.endmacro

;; Load zero page register reg/reg+1 with the 16-bit value, destroys A
.macro ld16 reg, value
  lda #<(value)
  sta reg
  lda #>(value)
  sta reg + 1
.endmacro
