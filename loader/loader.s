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




.section .predata

.predata.start:

_terminal_putchar:
.word 0x00

_terminal_show:
.word 0x00

_terminal_setcur:
.word 0x00

_terminal_getoffset:
.word 0x00

_disk_read:
.word 0x00

.predata.end:

//this is a simple header
.section .header
.word .predata.end - .predata.start


.section .data
_msg1:
.asciz "Hello From Loader program.\n"
_msg2:
.asciz "Loading user program...\n"
_msg3:
.asciz "Done.\n"
_msg4:
.asciz "Runing user program.\n"

.section .text

/*
real entry offset will be 
[.header] + 2(header's size) + 2(ld scripts sig)
*/
.global _loader_entry
.type _loader_entry STT_FUNC
_loader_entry:
    mov bx, OFFSET _msg1
    call [_terminal_show]

    mov bx, OFFSET _msg2
    call [_terminal_show]

    call _loader_load

    mov bx, OFFSET _msg3
    call [_terminal_show]

    mov bx, OFFSET _msg4
    push 0x00
    push OFFSET _wrap_ter_show
    mov bp, sp
    call dword ptr ss:[bp]
    
    



    mov bx, 0xC
    jmp _exit_loop


.global _loader_load
.type _loader_load STT_FUNC
_loader_load:

    ret


.global _wrap_ter_putchar
.type _wrap_ter_putchar STT_FUNC
/*!
    /brief  wrapping ...
            return with retf
    /param  al : the char to print
*/
_wrap_ter_putchar:
    push ds
    push es
    mov ax, 0
    mov ds, ax
    call [_terminal_show]
    pop es
    pop ds
    retf


.global _wrap_ter_show
.type _wrap_ter_show STT_FUNC
/*!
    /brief  wrapping the _terminal_show function call.
            return with retf
    /param  bx is buffer address
*/
_wrap_ter_show:
    push ds
    push es
    mov ax, 0
    mov ds, ax
    call [_terminal_show]
    pop es
    pop ds
    retf


.global _wrap_ter_setcur
.type _wrap_ter_setcur STT_FUNC
/*!
    /brief  wrapping the _terminal_setcur function call.
            return with retf
    /param  ax : the offset, max value is (HEIGHT * WIDTH - 1)
*/
_wrap_ter_setcur:
    push ds
    push es
    mov ax, 0
    mov ds, ax
    call [_terminal_setcur]
    pop es
    pop ds 
    retf


.global _wrap_ter_getoffset
.type _wrap_ter_getoffset STT_FUNC
/*!
    /brief  wrapping the _terminal_getoffset function call.
            return with retf
    /param  ax : al is row, ah is colum
    /return ax : the offset
*/
_wrap_ter_getoffset:
    push ds
    push es
    mov ax, 0
    mov ds, ax
    call [_terminal_getoffset]
    pop es
    pop ds
    retf

.global _wrap_disk_read
.type _wrap_disk_read STT_FUNC
/*!
    /brief  wrapping ...
            return with retf

    /param  ax : index of sector to read, only 7 bit works
    /param  bx : buffer to store data
    /param  cx : count times, 1-Word(2-Byte) read per count

*/
_wrap_disk_read:
    push ds
    push es
    mov ax, 0
    mov ds, ax
    call [_disk_read]
    pop es
    pop ds
    retf



_exit_loop:
    inc bx
    hlt
    jmp _exit_loop







