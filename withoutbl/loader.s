.intel_syntax noprefix
.code16

/*
User Program Header Definition

Content:

1Byte   Length, real length is 16 times of header value
1Byte   Entry offset, real offset is 16 times of header value
1Byte   PhyAddress, real flat address is 16 times of header value, shoud be writen by loader
Note: header is also 16Byte aligned

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







