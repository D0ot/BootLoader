include ../config/config.mk



.PHONY: clean

objects = user.o

user.bin : user.elf
	${OBJCOPY} ${OBJCOPY_GENBIN_FLAGS} $< $@

user.debug : user.elf
	${OBJCOPY} ${OBJCOPY_GENSYM_FLAGS} $< $@

user.elf : ${objects} link.ld
	${CC} ${LINK_FLAGS} -T link.ld -o $@ ${objects}


${objects} : %.o : %.s
	${AS} ${AS_FLAG} $< -o $@

all : user.bin user.debug

clean :
	${CLEAN_CMD}