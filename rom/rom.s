                    .setcpu "65c02"

                    .include "dp.inc.s"
                    .include "macros.inc.s"
                    .include "string.inc.s"
                    .include "acia.inc.s"
                    .include "io.inc.s"

                    .segment "VECTORS"

                    .word   nmi
                    .word   reset
                    .word   irq

                    .bss

                    BUFFER_LENGTH = 80
buffer:             .res BUFFER_LENGTH + 1, 0

                    .code

nmi:                rti

reset:              jmp main

irq:                rti

main:               jsr acia_init

                    ld16 R0, msg_welcome        ; print the welcome message
                    jsr acia_puts

loop:               ld16 R0, msg_prompt         ; print the prompt
                    jsr acia_puts

                    ld16 R0, buffer             ; store the pointer to the buffer in R0
                    lda #BUFFER_LENGTH          ; store the length of the buffer in A
                    jsr acia_gets               ; read the command

                    lda buffer
                    cmp #'m'                    ; check if the first symbol in the string is 'm'
                    bne @not_cmd_m
                    jsr cmd_memory
                    jmp loop

@not_cmd_m:         ld16 R0, msg_unknown_cmd    ; print the "unknown command" message
                    jsr acia_puts
                    jmp loop

msg_welcome:        .byte "Monitor v0.1", $0a, $00
msg_prompt:         .byte "> ", $00
msg_unknown_cmd:    .byte "Unknown command", $0a, $00

cmd_memory:         ld16 R0, buffer + 2
                    jsr scan_hex16

@print_address:     ld16 R0, buffer
                    lda RES + 1
                    jsr fmt_hex_string
                    ld16 R0, buffer + 2
                    lda RES
                    jsr fmt_hex_string
                    ld16 R0, buffer
                    jsr acia_puts
                    lda #' '
                    jsr acia_putc
                    jsr acia_putc

print_bytes:        ldy #0
                    ld16 R0, buffer
@next_byte:         lda (RES),y
                    jsr fmt_hex_string
                    jsr acia_puts
                    lda #' '
                    jsr acia_putc
                    cpy #7
                    bne @skip_mid_sep
                    jsr acia_putc
@skip_mid_sep:      iny
                    cpy #16
                    bne @next_byte

@print_chars:       lda #' '
                    jsr acia_putc
                    jsr acia_putc
                    lda #'|'
                    jsr acia_putc
                    ldy #0
@next_char:         lda (RES),y
                    cmp #$20
                    bcc @non_printable
                    cmp #$7e
                    bcs @non_printable
                    jmp @printable
@non_printable:     lda #'.'
@printable:         jsr acia_putc
                    iny
                    cpy #16
                    bne @next_char
                    lda #'|'
                    jsr acia_putc
                    jsr acia_put_newline
                    rts
