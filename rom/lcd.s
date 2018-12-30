                    .setcpu "65c02"

                    .include "dp.inc.s"
                    .include "macros.inc.s"
                    .include "io.inc.s"

                    .export lcd_init
                    .export lcd_clear
                    .export lcd_printc
                    .export lcd_prints

                    .code

;; Wait for LCD busy bit to clear
lcd_busy:           pha
lcd_busy0:          lda LCD_INST
                    and #$80
                    bne lcd_busy0
                    pla
                    rts

;; LCD initialization
;; registers are NOT preserved
lcd_init:           ldx #$04
lcd_init0:          lda #$38
                    sta LCD_INST
                    jsr lcd_busy
                    dex
                    bne lcd_init0
                    lda #$06
                    sta LCD_INST
                    jsr lcd_busy
                    lda #$0E
                    sta LCD_INST
                    jsr lcd_busy
                    lda #$01
                    sta LCD_INST
                    jsr lcd_busy
                    lda #$80
                    sta LCD_INST
                    jsr lcd_busy
                    rts

;; Clear LCD display and return cursor to home
;; registers are preserved
lcd_clear:          pha
                    lda #$01
                    sta LCD_INST
                    jsr lcd_busy
                    lda #$80
                    sta LCD_INST
                    jsr lcd_busy
                    pla
                    rts

;; Print a character on LCD (40 character) stored in A
lcd_printc:         pha
                    sta LCD_DATA
                    jsr lcd_busy
                    lda LCD_INST
                    and #$7F
                    cmp #$14
                    bne lcd_printc0
                    lda #$C0
                    sta LCD_INST
                    jsr lcd_busy
lcd_printc0:        pla
                    rts

;; Prints a null-terminated string on LCD, max 255 characters
;; registers are preserved
;; R0 - address of the string, 2 bytes
lcd_prints:         phay
                    ldy #$0
lcd_prints0:        lda (R0),Y
                    beq lcd_prints1
                    jsr lcd_printc
                    iny
                    bne lcd_prints0
lcd_prints1:        play
                    rts
