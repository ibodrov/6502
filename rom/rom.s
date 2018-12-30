                    .setcpu "65c02"

                    .include "dp.inc.s"
                    .include "macros.inc.s"
                    .include "string.inc.s"
                    .include "acia.inc.s"
                    .include "io.inc.s"

                    .segment "VECTORS"

                    .res    2
                    .word   reset
                    .res    2

                    .bss

                    BUFFER_LENGTH = 80
buffer:             .res BUFFER_LENGTH + 1, 0

                    .code

reset:              jmp main

main:               jsr acia_init

                    ld16 R0, _intro             ; send _intro string
                    jsr acia_puts

loop:               ld16 R0, _prompt            ; send prompt
                    jsr acia_puts
                
                    ld16 R0, buffer             ; read string
                    lda #BUFFER_LENGTH
                    jsr acia_gets

                                                ; compare the first letter
                    cmp #'m'                    ; ...with 'm'
                    bne @not_cmd_m
                    jmp loop

@not_cmd_m:         ld16 R0, _unknown_cmd       ; send "unknown command" message
                    jsr acia_puts
                    jmp loop


_intro:             .byte $0d, $0a, "Monitor v0.1", $0d, $0a, $00
_prompt:            .byte "> ", $00
_unknown_cmd:       .byte "Unknown command", $0d, $0a, $00
