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

.set FREERAM0, 0x7C00
.set FREERAM1, FREERAM0 + 512
.set FREERAM2, FREERAM1 + 512
.set FREERAM3, FREERAM2 + 512
.set FREERAM4, FREERAM3 + 512

.set STACKSIZE, 128

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
.skip STACKSIZE, 0x00

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
    mov bx, OFFSET _msg
    call _terminal_show

    mov ax, 0x0202
    call _termianl_getoffset
    call _terminal_setpos
    call _terminal_getpos
    add ax, 0x01
    call _terminal_setpos
    
    mov ax, 0x0303
    call _termianl_getoffset
    call _terminal_setpos
    call _terminal_getpos
    add ax, 0x01
    mov bx, ax

    mov ax, 1
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0001
    mov bx, OFFSET _buffer
    call _terminal_show

    mov ax, 2
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0002
    mov bx, OFFSET _buffer
    call _terminal_show

    jmp inf_loop

.global _terminal_init
.type _terminal_init STT_FUNC
_terminal_init:
    mov ax, DISRAM
    mov es, ax
    mov bx, 0
    mov cx, HEIGHT
ti_s0:
    push bx
    push cx
    call _terminal_clearline
    pop cx
    pop bx
    inc bx
    loop ti_s0
    ret

.global _terminal_clearline
.type _terminal_clearline STT_FUNC
/*
    bl : row to clear
*/
_terminal_clearline: 
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

.global _termianl_getoffset
.type _termianl_getoffset STT_FUNC
/*
    ax : al is row, ah is column

    return ax as offset, max value is (HEIGHT * WIDTH - 1)
*/

_termianl_getoffset : 
    mov dh, 0
    mov dl, ah 
    mov bl, al 
    mov al, WIDTH 
    mul bl
    add ax, dx
    ret

.global _terminal_setpos
.type _terminal_setpos STT_FUNC
/*
    ax : the offset , max value is (HEIGHT * WIDTH - 1)
*/
_terminal_setpos:

    push ax
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    pop ax
    out dx, al


    push ax
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    pop ax
    mov al, ah
    out dx, al
    ret

.global _terminal_getpos
.type _terminal_getpos STT_FUNC
/*
    return ax as offset, max value is (WIDTH * HEIGHT - 1) 
*/
_terminal_getpos:
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    in al, dx
    mov ah, al

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    in al, dx
    ret






.global _terminal_show
.type _terminal_show STT_FUNC
/*
    al is row
    ah is column
    bx is buffer address
*/
_terminal_show: 

    mov di, bx
    call _termianl_getoffset
    shl ax, 1
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

