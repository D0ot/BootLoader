#!/bin/bash

qemu-system-i386 -hda boot.bin -gdb tcp::1234 -S -monitor stdio