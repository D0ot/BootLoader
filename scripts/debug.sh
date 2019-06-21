#!/bin/bash

gdb -s build/img.elf -ex "target remote localhost:1234
set architecture i8086 
set disassembly-flavor intel 
display/i \$cs*16+\$pc "