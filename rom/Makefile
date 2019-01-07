C_SOURCES = debug.c
ASM_SOURCES = string.s65 acia.s65 lcd.s65 rom.s65

%.o: %.c
	cc65 --cpu 65c02 -O -t none -o $(@:.o=.s) $<
	ca65 --cpu 65c02 -o $@ -l $(@:.o=.lst) $(<:.c=.s)

%.o: %.s65
	ca65 -o $@ -l $(@:.o=.lst) $<

all: rom

rom: $(ASM_SOURCES:.s65=.o) $(C_SOURCES:.c=.o)
	cl65 -C rom.cfg -t none -o $@.bin $^

clean:
	rm -f *.o *.lst *.s *.map rom.bin
