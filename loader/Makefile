include ../config/config.mk


.PHONY: all clean

objects = loader.o

loader.bin : loader.elf
	${OBJCOPY} ${OBJCOPY_FLAGS} -S $< $@

loader.elf : ${objects} link.ld
	${CC} ${LINK_FLAGS} -T link.ld -o $@ ${objects}

${objects} : %.o : %.s
	${AS} ${AS_FLAGS} $< -o $@



all : loader.bin
	

clean :
	rm -f *.elf *.bin *.o