import gdb
import os
from elftools.elf.elffile import ELFFile


def getSectionAddr(filename, section_name):
    with open(filename, 'rb') as f:
        elffile = ELFFile(f)
        dot_text = elffile.get_section_by_name(section_name)
        if not dot_text:
            print('WARNING: The section:\"{}\" dose not exists in file:\"{}\".'.format(section_name, filename))
            return 0
        
        return dot_text['sh_addr']

def myGDBAutoLoadSymFile(filename):
    addr = getSectionAddr(filename, '.text')
    gdb.execute('add-symbol-file ' + filename + ' ' + hex(addr))


def main():
    gdb.execute('target remote localhost:1234')
    gdb.execute('set architecture i8086')
    gdb.execute('set disassembly-flavor intel')

    myGDBAutoLoadSymFile('debug/boot.debug')
    myGDBAutoLoadSymFile('debug/loader.debug')

    gdb.execute('b _start')

main()