include config/config.mk


.PHONY: all clean debug

all : 
	cd boot && make
	cd loader && make
	cd user && make

	cp boot/boot.bin build/img.bin
	cp boot/boot.elf build/img.elf


clean : 
	cd boot && make clean
	cd loader && make clean
	cd user && make clean
	rm -f build/*
	
debug : all
	gnome-terminal --geometry=80x40+0+900 -e ./scripts/test.sh
	gnome-terminal --geometry=130x80+1600+0 -e ./scripts/debug.sh 
