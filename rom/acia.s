                    .setcpu "65c02"

                    .include "dp.inc.s"
                    .include "io.inc.s"
                    .include "macros.inc.s"

                    ACIA_BUFFER_LENGTH = 10

                    .export acia_init
                    .export acia_getc
                    .export acia_gets
                    .export acia_putc
                    .export acia_puts
                    .export acia_put_newline

                    .code

; Initialize the ACIA
acia_init:          pha
                    lda #(ACIA_PARITY_DISABLE | ACIA_ECHO_DISABLE | ACIA_TX_INT_DISABLE_RTS_LOW | ACIA_RX_INT_DISABLE | ACIA_DTR_LOW)
                    sta ACIA_COMMAND
                    lda #(ACIA_STOP_BITS_1 | ACIA_DATA_BITS_8 | ACIA_CLOCK_INT | ACIA_BAUD_19200)
                    sta ACIA_CONTROL
                    pla
                    rts

; Send the character in A
acia_putc:          pha
@wait_txd_empty:    lda ACIA_STATUS
                    and #ACIA_STATUS_TX_EMPTY
                    beq @wait_txd_empty
                    pla
                    sta ACIA_DATA
                    rts

; Send the zero terminated string pointed to by R0
acia_puts:          phay
                    ldy #0
@next_char:         lda (R0),y
                    beq @eos
                    jsr acia_putc
                    iny
                    bne @next_char
@eos:               play
                    rts

; Wait until a character was reveiced and return it in A
acia_getc:
@wait_rxd_full:     lda ACIA_STATUS
                    and #ACIA_STATUS_RX_FULL
                    beq @wait_rxd_full
                    lda ACIA_DATA
                    rts

; Wait until a \n terminated string was received and store it at (R0)
; The accu contains the maximum number of characters to read
; The \n is removed and the string is zero terminated
; After receiving the maximum number of characters, any following characters are discarded
; The buffer at (R0) must be of size maximum number of characters plus 1
acia_gets:          sta TMP0
                    phay
                    ldy #0
@next_char:         jsr acia_getc
                    cmp #$0a
                    beq @eos
@check_max_chars:   cpy TMP0
                    beq @next_char
                    sta (R0),y
                    iny
                    bne @next_char
@eos:               lda #0
                    sta (R0),y
                    play
                    rts

; Send a newline character
acia_put_newline:   lda #$0a
                    jmp acia_putc
