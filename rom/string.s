                    .setcpu "65c02"

                    .include "macros.inc.s"
                    .include "dp.inc.s"

                    .export fmt_hex_char
                    .export fmt_bin_string
                    .export fmt_hex_string
                    .export scan_hex_char
                    .export scan_hex
                    .export scan_hex16

                    .code

;; Format the value of the accu as a binary string
;; The string is written into (r0)..(r0)+8 (9 bytes)
fmt_bin_string:     sta tmp0
                    phay
                    ldy #8
                    lda #0
                    sta (r0),y
                    dey
@next_bit:          lsr tmp0
                    bcs @bit_is_1
@bit_is_0:          lda #'0'
                    jmp @store_char
@bit_is_1:          lda #'1'
@store_char:        sta (r0),y
                    dey
                    bpl @next_bit
                    play
                    rts

;; Convert the 4-bit value of the accu into it's hex ascii character
;; The hex ascii character is returned in the accu
fmt_hex_char:       cmp #10
                    bcc @less_then_10
@greater_then_10:   sec
                    sbc #10
                    clc
                    adc #'A'
                    rts
@less_then_10:      clc
                    adc #'0'
                    rts

;; Format the value of the accu as a hex string
;; The string is written into (r0)..(r0)+2 (3 bytes)
fmt_hex_string:     sta tmp0
                    phay
                    ldy #0
                    lda tmp0
                    lsr
                    lsr
                    lsr
                    lsr
                    jsr fmt_hex_char
                    sta (r0),y
                    iny
                    lda tmp0
                    and #$0f
                    jsr fmt_hex_char
                    sta (r0),y
                    iny
                    lda #0
                    sta (r0),y
                    play
                    rts

;; Convert the hex character in the accu to its integer value
;; The integer value is returned in the accu
scan_hex_char:      cmp #'0'
                    bcc @invalid
                    cmp #('9' + 1)
                    bcs @no_digit
                    sec
                    sbc #'0'
                    rts
@no_digit:          cmp #'A'
                    bcc @invalid
                    cmp #('F' + 1)
                    bcs @no_upper_hex
                    sec
                    sbc #('A' - 10)
                    rts
@no_upper_hex:      cmp #'a'
                    bcc @invalid
                    cmp #('f' + 1)
                    bcs @invalid
                    sec
                    sbc #('a' - 10)
                    rts
@invalid:           lda #0
                    rts

;; Convert two hex characters starting at (r0) into an integer value
;; The integer value is returned in the accu
scan_hex:           tya
                    pha
                    ldy #0
                    lda (r0),y
                    jsr scan_hex_char
                    asl
                    asl
                    asl
                    asl
                    sta tmp0
                    iny
                    lda (r0),y
                    jsr scan_hex_char
                    ora tmp0
                    sta tmp0
                    pla
                    tay
                    lda tmp0
                    rts

;; Convert four hex characters starting at (r0) into an integer value
;; The integer value is returned in res..res+1
scan_hex16:         phay
                    ldy #0
                    lda (r0),y
                    jsr scan_hex_char
                    asl
                    asl
                    asl
                    asl
                    sta res + 1
                    iny
                    lda (r0),y
                    jsr scan_hex_char
                    ora res + 1
                    sta res + 1
                    iny
                    lda (r0),y
                    jsr scan_hex_char
                    asl
                    asl
                    asl
                    asl
                    sta res
                    iny
                    lda (r0),y
                    jsr scan_hex_char
                    ora res
                    sta res
                    play
                    rts
