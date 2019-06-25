include config/config.mk


.PHONY: all clean debug

all : 
	cd boot && make all
	cd loader && make all
	cd user && make all

	cp boot/boot.bin build/img.bin
	cp boot/boot.elf build/img.elf
	cat loader/loader.bin >> build/img.bin

	cp boot/boot.sym debug/
	cp loader/loader.sym debug/

clean : 
	cd boot && make clean
	cd loader && make clean
	cd user && make clean
	rm -f build/*
	rm -f debug/*
	

debug : all
	gnome-terminal --geometry=80x14+0+1200 -- ./scripts/test.sh
	gnome-terminal --geometry=130x80+1600+0 -- ./scripts/debugp.sh 
