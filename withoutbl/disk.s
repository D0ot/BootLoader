.intel_syntax noprefix
.code16

.section .sector2
.ascii "Hello From Sector2\0"

.section .sector3
.ascii "Hola From Sector3\0"

.section .text
.global _disk_read
.type _disk_read STT_FUNC
/*
    ax , index of sector to read, only 7 bit work
    bx , buffer to store data
    cx , size of word(2-byte) to read
*/

_disk_read: 

    push ax
    mov al, 1
    mov dx, 0x1F2
    out dx, al
    pop ax

    mov dx, 0x1F3
    out dx, al

    inc dx      /*0x1F4*/
    mov al, ah
    out dx, al

    inc dx      /*0x1F5*/  
    mov ax, 0x00
    out dx, al

    inc dx      /*0x1F6*/
    mov al, 0xE0
    out dx, al

    inc dx      /*0x1F7*/
    mov al, 0x20
    out dx, al
dr_wait:
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz dr_wait

    /*cx is buffer size*/
    push cx
    mov dx, 0x1F0

dr_read:
    in ax, dx
    mov ds:[bx], ax
    add bx, 2
    loop dr_read

    pop ax
    mov cx, 512
    sub cx, ax

/*
    read the rest dummy data
    if we do not do so, next time when we read,
    the data would be the rest of last time.
*/

dr_read_zero: 
    in ax, dx
    loop dr_read_zero

    ret





    
