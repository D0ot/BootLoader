.intel_syntax noprefix
.code16

/*
User Program Header Definition

--------------------------------------------------
4Byte   Length
2Byte   Entry offset
4Byte   Flat Address of entry section

2Byte   Relocation Table size : number of entries

4Byte   Entry 1
4Byte   Entry 2
...
4Byte   Entry N
--------------------------------------------------

*/




.section .text

.global _loader_load
.type _loader_load STT_FUNC
/*! 
    \brief load user program from disk, it will call some functions in disk.s
    \param  ax  start sector of user program
    \param  bx  buffer to store the code, at least 0.5KiB
    \return ax  user program entry point
*/
_loader_load:
    push ax     //sp + 4
    push bx     //sp + 2
    mov cx, 256
    call _disk_read







