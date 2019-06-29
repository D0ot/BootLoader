.intel_syntax noprefix
.code16

/*
User Program Header Definition

--------------------------------------------------
1   Program Size in Bytes           4 Bytes
2   Stack Size in Byte              4 Bytes

3   Entry Point offset              2 Bytes

4   function talbe                  20 Bytes
    Currently is 
    _wrap_ter_putchar                   4 Bytes
    _wrap_ter_show                      4 Bytes
    _wrap_ter_setcur                    4 Bytes
    _wrap_ter_getoffset                 4 Bytes
    _wrap_disk_read                     4 Bytes


--------------------------------------------------

Note :  1. stack is following the program in memory

*/


.set SECTOR_SIZE, 0x200

.set PROGRAM_SIZE_OFFSET, 0x00
.set STACK_SIZE_OFFSET, PROGRAM_SIZE_OFFSET + 4
.set ENTRY_POINT_OFFSET, STACK_SIZE_OFFSET + 4
.set FUNCTION_TABLE_OFFSET, ENTRY_POINT_OFFSET + 2






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

_system_stack:
.word 0x00
.word 0x00

_small_heap:
.word 0x00
.word 0x00

.section .text


.global _loader_entry
.type _loader_entry STT_FUNC
_loader_entry:
    mov bx, OFFSET _msg1
    call [_terminal_show]

    mov bx, OFFSET _msg2
    call [_terminal_show]

    mov ax, 0x5
    mov bx, 0x900
    mov ds, bx
    mov bx, 0
    call _loader_load

    push si
    push ax
    push cx
    push bx

    mov bx, OFFSET _msg3
    call [_terminal_show]

    mov bx, OFFSET _msg4
    call [_terminal_show]

    pop bx
    pop cx
    pop ax
    pop si

    mov word ptr [_system_stack + 0], sp
    mov word ptr [_system_stack + 2], ss

    // START USING USER STACK

    mov ss, cx
    mov sp, bx

    mov word ptr [_small_heap], ax
    mov word ptr [_small_heap + 2], si
    call far [_small_heap]

    mov bx, 0xC
    jmp _exit_loop


.global _loader_load
.type _loader_load STT_FUNC
/*! 
    \brief  load a user program from disk
    
    \param  ax first sector index
    \param  dx dx:0 is physical address
    
    \return si:ax as entry point
            cx:bx as user stack

    it will change es
*/

_loader_load:

    push ds

    push dx // for later use, see comments below

    push ax

    mov ds, dx
    mov bx, 0

    mov cx, 0x100

    call [_disk_read]

    mov ax, ds:[PROGRAM_SIZE_OFFSET]
    mov dx, ds:[PROGRAM_SIZE_OFFSET + 2]
    mov cx, SECTOR_SIZE 

    div cx
    mov cx, ax
    cmp dx, 0
    je _loader_load_s0
    
    // when remainder is not zero
    // read one more sector
    inc cx 

// when remainder is zero or when not zero but wiht cx increased
_loader_load_s0:
    
    // for we have read one sector
    dec cx

    // we should to blance the stack
    pop ax

    // when we jmp to _loader_load_s1
    // we must have vaild bx
    mov bx, 0 + SECTOR_SIZE 

    cmp cx, 0
    je _loader_load_s1

    inc ax

    push ax
    push cx

    push bx

    mov si, sp

_loader_load_loop0:

    
    mov ss:[si + 2], cx
    mov cx, 0x100
    call [_disk_read]

    mov bx, ss:[si]
    mov ax, ss:[si + 4]


    inc ax
    add bx, SECTOR_SIZE

    cmp bx, 0xFE00 // SECTOR * 127

    // the largest value a word can save is in bx
    // we have to change ds,
    // and this is why we push dx at function start
    jne _loader_load_s2
    push ax
    mov ax, ds
    add ax, 0xFE0 // (0xFE00 / 0x10) and 0xFE00 = SECTOR_SIZE * 127
    mov dx, ax
    mov bx, 0
    pop ax

_loader_load_s2:

    mov ss:[si], bx
    mov ss:[si + 4], ax

    mov cx, ss:[si + 2]
    loop _loader_load_loop0

    //blance the stack
    pop bx
    add sp, 0x04
    

// when load finish
// then we need to organize data
_loader_load_s1:
    pop dx

    // now we have two addresses:
    // ds:bx , end address
    // es:0 , start address
    mov es, dx


    // set function table
    
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 0], OFFSET _wrap_ter_putchar
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 2], 0

    mov word ptr es:[FUNCTION_TABLE_OFFSET + 4], OFFSET _wrap_ter_show
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 6], 0

    mov word ptr es:[FUNCTION_TABLE_OFFSET + 8], OFFSET _wrap_ter_setcur
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 10], 0

    mov word ptr es:[FUNCTION_TABLE_OFFSET + 12], OFFSET _wrap_ter_getoffset
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 14], 0

    mov word ptr es:[FUNCTION_TABLE_OFFSET + 16], OFFSET _wrap_disk_read
    mov word ptr es:[FUNCTION_TABLE_OFFSET + 18], 0

    //setup stack for user program

    mov di, bx // for temporary storage
    mov ax, es:[STACK_SIZE_OFFSET + 0]
    mov dx, es:[STACK_SIZE_OFFSET + 2]
    mov cl, 0x10
    div cl
    add bx, dx
    mov cx, ds
    add cx, ax // now cx:bx is user stack address

    mov ax, bx
    mov bl, 0x10
    div bl
    mov bh, 0
    mov bl, al
    add cx, bx
    mov bl, ah // made cx bigger and bx smaller

    mov ax, es:[ENTRY_POINT_OFFSET]
    mov cl, 0x10
    div cl
    mov si, ds
    mov ch, 0
    mov cl, al
    add si, cx
    mov ah, 0
    
    pop ds

    ret

.global _wrap_ter_putchar
.type _wrap_ter_putchar STT_FUNC
/*!
    \brief  wrapping ...
            return with retf
    \param  al : the char to print
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
    \brief  wrapping the _terminal_show function call.
            return with retf
    \param  bx is buffer address
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
    \brief  wrapping the _terminal_setcur function call.
            return with retf
    \param  ax : the offset, max value is (HEIGHT * WIDTH - 1)
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
    \brief  wrapping the _terminal_getoffset function call.
            return with retf
    \param  ax : al is row, ah is colum
    \return ax : the offset
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
    \brief  wrapping ...
            return with retf

    \param  ax : index of sector to read, only 7 bit works
    \param  bx : buffer to store data
    \param  cx : count times, 1-Word(2-Byte) read per count

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







