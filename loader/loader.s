.intel_syntax noprefix
.code16

/*
User Program Header Definition

--------------------------------------------------
1   Program Size in sectors         2 Byte
2   Stack Size in Byte              2 Byte
    x 16

3   Entry Point Segment address     2 Byte

4   function talbe                  10 Byte
    Currently is 
    _wrap_ter_putchar                   2 Byte
    _wrap_ter_show                      2 Byte
    _wrap_ter_setcur                    2 Byte
    _wrap_ter_getoffset                 2 Byte
    _wrap_disk_read                     2 Byte

5   Stack Address in Segment        2 Byte


--------------------------------------------------

Note : ds should be same with cs

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
/*! 
    /brief  load a user program from disk
    
    /param  ax first sector index
    /param  dx dx:0 is physical address
    
    /return al 1 successful
            bx segment address of entry point, no offset

*/

_loader_load:

    // first calculate the segment:offset model address
    // from physical address

    mov ds, dx
    mov cx, 256
    xor bx, bx
    push ax
    push dx
    call _disk_read
    mov cx, ds:[0]
    cmp cx, 1
    je _loader_load_finsh 
    pop dx
    pop ax

    mov bx, 0
    sub cx, 1


_loader_load_loop1:

    inc ax
    add bx, 256

    push ax  
    push bx
    push cx

    mov cx, 256
    call [_disk_read]

    pop cx
    pop bx
    pop ax
    loop _loader_load_loop1
    
_loader_load_finsh:
    mov al, ds:[2]




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







