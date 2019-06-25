#!/bin/bash

# replaced by debugp.sh
gdb -s build/img.elf -ex 'target remote localhost:1234' \
    -ex 'set architecture i8086'    \
    -ex 'set disassembly-flavor intel' \
    -x scripts/gdbinit
  