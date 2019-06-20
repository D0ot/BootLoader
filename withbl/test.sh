#!/bin/bash

qemu-system-i386 -kernel myos.bin -m 128 -monitor stdio -gdb tcp::1234 