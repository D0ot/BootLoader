include ../config/config.mk


.PHONY: all clean

objects = loader.o

loader.bin : loader.elf
	${OBJCOPY} ${OBJCOPY_GENBIN_FLAGS} $< $@

loader.sym : loader.elf
	${OBJCOPY} ${OBJCOPY_GENSYM_FLAGS} $< $@

loader.elf : ${objects} link.ld
	${CC} ${LINK_FLAGS} -T link.ld -o $@ ${objects}

${objects} : %.o : %.s
	${AS} ${AS_FLAGS} $< -o $@



all : loader.bin loader.sym
	

clean :
	${CLEAM_CMD}