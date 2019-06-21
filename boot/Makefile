include ../config/config.mk

objects = boot.o disk.o

boot.bin : boot.elf
	${OBJCOPY} ${OBJCOPY_FLAGS} -S $< $@

boot.elf : ${objects}
	${CC} ${LINK_FLAGS} -T link.ld -o $@ ${objects}


${objects} : %.o : %.s
	${AS} ${AS_FLAGS} $< -o $@ 

.PHONY : all obj clean 

all : boot.bin

obj : ${objects}

clean : 
	rm -f *.elf *.o *.bin