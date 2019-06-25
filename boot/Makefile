include ../config/config.mk

objects = boot.o disk.o

boot.bin : boot.elf
	${OBJCOPY} ${OBJCOPY_GENBIN_FLAGS} $< $@

boot.sym : boot.elf
	${OBJCOPY} ${OBJCOPY_GENSYM_FLAGS} $< $@

boot.elf : ${objects}
	${CC} ${LINK_FLAGS} -T link.ld -o $@ ${objects}


${objects} : %.o : %.s
	${AS} ${AS_FLAGS} $< -o $@ 

.PHONY : all obj clean 

all : boot.bin boot.sym

obj : ${objects}

clean : 
	${CLEAM_CMD}