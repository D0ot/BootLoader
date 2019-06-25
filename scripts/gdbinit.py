import gdb
import os
import sh

def addSymFileAuto(string):
    


def main():
    gdb.execute("target remote localhost:1234")
    gdb.execute("set architecture i8086")
    gdb.execute("set disassembly-flavor intel")

    gdb.execute("add-symbol-file boot/boot.elf 0x7C00")
    gdb.execute("add-symbol-file loader/loader.elf 0x8200")
    gdb.execute("b _start")

main()