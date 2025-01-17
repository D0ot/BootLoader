TOOLS_PREFIX = /usr/local/cross/bin/i686-elf-

CC = ${TOOLS_PREFIX}gcc
CXX = ${TOOLS_PREFIX}g++
LD = ${TOOLS_PREIFX}ld
AS = ${TOOLS_PREFIX}as
OBJCOPY = ${TOOLS_PREIFX}objcopy

BIN = img.bin


AS_FLAGS = -g
LINK_FLAGS = -ffreestanding -nostdlib -g

OBJCOPY_GENBIN_FLAGS = -O binary -S
OBJCOPY_GENSYM_FLAGS = --only-keep-debug


CLEAN_CMD = rm -f *.elf *.bin *.o *.debug

