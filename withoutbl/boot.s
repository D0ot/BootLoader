.intel_syntax noprefix
.code16

.set MAGIC1, 0x55
.set MAGIC2, 0xAA


.set VRAM, 0xB800
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
.set HEAPSIZE, 512
.section .mbrcheck
.byte MAGIC1
.byte MAGIC2

.section .data
_buffer:
.skip 0x20, 0x00
_msg:
.ascii "Hello World\0"


.section .stack
.skip STACKSIZE, 0x00

.section .heap
.skip HEAPSIZE - 1, 0x00


.set TER_ROW, .heap
.set TER_COL, .heap + 1






.section .text
.global _start 
.type _start STT_FUNC 

_start:
    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, OFFSET .stack + STACKSIZE

    call _terminal_init

    mov ax, 0x0
    call _terminal_getoffset
    call _terminal_setcur
    mov bx, OFFSET _msg
    call _terminal_show

    

    mov ax, 1
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0001
    call _terminal_getoffset
    call _terminal_setcur
    mov bx, OFFSET _buffer
    call _terminal_show

    mov ax, 2
    mov bx, OFFSET _buffer
    mov cx, 10
    call _disk_read

    mov ax, 0x0002
    call _terminal_getoffset
    call _terminal_setcur
    mov bx, OFFSET _buffer
    call _terminal_show


    mov word ptr [TER_ROW], 0x0018
    mov al, 'H'
    call _terminal_puchar
    mov al, 'E'
    call _terminal_puchar

    mov al, '\n'
    call _terminal_puchar

    mov al, 'H'
    call _terminal_puchar


    jmp inf_loop

.global _terminal_init
.type _terminal_init STT_FUNC
_terminal_init:
    mov ax, VRAM
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

    mov byte ptr[TER_COL], 0
    mov byte ptr[TER_ROW], 0

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

.global _terminal_getoffset
.type _terminal_getoffset STT_FUNC
/*
    ax : al is row, ah is column

    return ax as offset, max value is (HEIGHT * WIDTH - 1)
*/

_terminal_getoffset : 
    mov dh, 0
    mov dl, ah 
    mov bl, al 
    mov al, WIDTH 
    mul bl
    add ax, dx
    ret

.global _terminal_setcur
.type _terminal_setcur STT_FUNC
/*
    ax : the offset , max value is (HEIGHT * WIDTH - 1)
*/
_terminal_setcur:

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

.global _terminal_getcur
.type _terminal_getcur STT_FUNC
/*
    return ax as offset, max value is (WIDTH * HEIGHT - 1) 
*/
_terminal_getcur:
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
    call _terminal_getcur
    shl ax, 1
    mov dx, ax
    mov bx, 0
    mov ax, VRAM
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


.global _terminal_puchar
.type _terminal_puchar STT_FUNC
/*!
    \brief put a char on screen
    \param al the char to put
*/
_terminal_puchar:
    cmp al, '\n'
    je tp_s1

// the char is not newline
tp_s0:
    push ax
    mov ax, [TER_ROW]
    call _terminal_getoffset
    shl ax
    mov bx, ax
    mov ax, VRAM
    mov es, ax
    pop ax
    mov ah, DEFCOLOR
    mov es:[bx], ax
    cmp byte ptr [TER_COL], WIDTH - 1
    je tp_s1
    inc byte ptr ds:[TER_COL] 
    ret

// the cursor should be at next line.
tp_s1:
    cmp byte ptr [TER_ROW], HEIGHT - 1
    jne tp_s2

// should scroll
    push ds
    call _terminal_scroll
    pop ds
    mov bl, HEIGHT - 1
    call _terminal_clearline // clear line at bottom
    sub byte ptr [TER_ROW], 1

//should not scroll
tp_s2:
    inc byte ptr [TER_ROW]
    mov byte ptr [TER_COL], 0

    call _terminal_getoffset
    shl ax
    call _terminal_setcur
    ret

.global _terminal_scroll
.type _terminal_scroll STT_FUNC
/*!
    /brief  scroll the screen one line up
            it will not modify the TER_ROW and TER_COL
            it will not clear the line at bottom
            WARNING: it will change "ds" register
            
*/
_terminal_scroll:
    mov cx, ( (HEIGHT - 1) * WIDTH) / 2
    mov ax, VRAM
    cld
    mov ds, ax
    mov es, ax
    mov si, WIDTH * 2
    mov di, 0
    rep movsw
    ret

    