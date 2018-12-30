ASM_SOURCES = dp.s string.s acia.s lcd.s rom.s

%.o: %.s
	ca65 -o $@ -l $(@:.o=.lst) $<

all: rom

rom: $(ASM_SOURCES:.s=.o)
	cl65 -C rom.cfg -t none -o $@.bin $^

clean:
	rm -f *.o *.lst rom.bin
