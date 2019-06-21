TOOLS_PREFIX = /usr/local/cross/bin/i686-elf-

CC = ${TOOLS_PREFIX}gcc
CXX = ${TOOLS_PREFIX}g++
LD = ${TOOLS_PREIFX}ld
AS = ${TOOLS_PREFIX}as
OBJCOPY = ${TOOLS_PREIFX}objcopy

AS_FLAGS = -g
LINK_FLAGS = -ffreestanding -nostdlib -g
OBJCOPY_FLAGS = -O binary
