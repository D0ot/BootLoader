.intel_syntax noprefix
.code16

.set MAGIC1, 0x55
.set MAGIC2, 0xAA
.set DISRAM, 0xB800
.set FILLCHAR, ' '
.set DEFCOLOR, 0x07
.set HEIGHT, 25
.set WIDTH, 80
.set INITSEG, 0x7C0
.section .mbrcheck
.byte MAGIC1
.byte MAGIC2

.section .data
_buffer:
.skip 0x20, 0x00
.long 0xDEADBEFF
_msg:
.ascii "Hello World\0"

.section .stack
.skip 0x20, 0x00

.section .text
.global _start 
.type _start STT_FUNC 

_start:
    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, OFFSET .stack + 0x20

    call _terminal_init

    mov ax, 0x0
    push ax
    push OFFSET _msg 
    call _terminal_show
    pop dx
    pop dx

    mov ax, 1
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0001
    push ax
    push OFFSET _buffer
    call _terminal_show
    pop dx
    pop dx 

    mov ax, 2
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0002
    push ax
    push OFFSET _buffer
    call _terminal_show
    pop dx
    pop dx



    jmp inf_loop

.global _terminal_init
.type _terminal_init STT_FUNC
_terminal_init:
    mov ax, DISRAM
    mov es, ax
    mov ax, 0
    mov cx, HEIGHT
ti_s0:
    push cx
    push ax
    call _terminal_clearline
    pop ax
    pop cx
    inc ax
    loop ti_s0
    ret

.global _terminal_clearline
.type _terminal_clearline STT_FUNC
_terminal_clearline: /*(u16 row)*/
    mov bx, sp
    mov bl, ss:[bx + 2]
    mov al, WIDTH * 2
    mul bl
    mov bx, ax
    mov cx, WIDTH
    mov al, FILLCHAR
    mov ah, DEFCOLOR
tcl_s0:
    mov es:[bx], ax
    add bx, 2
    loop tcl_s0
    ret

.global _termianl_setpos
.type _termianl_setpos STT_FUNC
_termianl_setpos: /*(u8 row, u8 column), return ax as pos*/
    mov bx, sp
    mov dh, 0
    mov dl, ss:[bx + 3]
    add dl, dl
    mov bl, ss:[bx + 2]
    mov al, WIDTH * 2
    mul bl
    add ax, dx
    ret


.global _terminal_show
.type _terminal_show STT_FUNC
/*
    al is row
    ah is column
*/
_terminal_show: /* (u8 *str, u8 row, u8 column) the pointer is 16Bit */

    mov bx, sp 
    mov di, ss:[bx + 2]
    mov ax, ss:[bx + 4]
    push ax
    call _termianl_setpos
    pop dx
    mov dx, ax
    mov bx, 0
    mov ax, DISRAM
    mov es, ax
    mov ah, DEFCOLOR
show_s0:
    cmp byte ptr ds:[bx + di], 0
    je show_s1
    mov al, ds:[bx + di]
    mov si, bx
    mov bp, bx
    add bp, dx
    mov es:[bp + si], ax
    inc bx
    jmp show_s0
show_s1:
    ret

inf_loop:
    hlt
    jmp inf_loop

