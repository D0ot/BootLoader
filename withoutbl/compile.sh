#!/bin/bash

i686-elf-as boot.s -o boot.o -g
i686-elf-as disk.s -o disk.o -g
i686-elf-gcc -T linker.ld -o boot.elf -ffreestanding -nostdlib boot.o disk.o -g
i686-elf-objcopy -O binary -S boot.elf boot.bin