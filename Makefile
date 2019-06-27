include config/config.mk


.PHONY: all clean debug

all : 
	cd boot && make all
	cd loader && make all
	cd user && make all

	rm -f build/${BIN}
	cp boot/boot.elf build/img.elf

	touch build/${BIN}
	cat boot/boot.bin >> build/${BIN}
	cat loader/loader.bin >> build/${BIN}

	cp boot/boot.debug debug/
	cp loader/loader.debug debug/

clean : 
	cd boot && make clean
	cd loader && make clean
	cd user && make clean
	rm -f build/*
	rm -f debug/*
	

debug : all
	gnome-terminal --geometry=80x14+0+1200 -- ./scripts/test.sh
	gnome-terminal --geometry=130x80+1600+0 -- ./scripts/debugp.sh 
