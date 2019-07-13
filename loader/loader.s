.intel_syntax noprefix
.code16

.set BASE_ADDR, 0x8200
.set GDT_BASE, BASE_ADDR + 0x200

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
.asciz "Enter protected mode...\n"

gdt_size:
.word 0x00
gdt_base:
.word 0x00
.word 0x00

jmp_addr:
.skip 4, 0x00

.section .text
.global _loader_entry
.type _loader_entry STT_FUNC
_loader_entry:
    mov bx, OFFSET _msg1
    call [_terminal_show]

    mov bx, OFFSET _msg2
    call [_terminal_show]

    call _enter_protectedmode


    jmp _exit_loop


.global _enter_protectedmode
.type _enter_protectedmode STT_FUNC
_enter_protectedmode:
    mov ax, GDT_BASE >> 4 
    mov ds, ax
    mov bx, 0
    mov es, bx

    mov word ptr [cs:OFFSET gdt_size], 47
    mov dword ptr [cs:OFFSET gdt_base], GDT_BASE

    // NULL
    mov dword ptr [bx + 0x00], 0x00
    mov dword ptr [bx + 0x04], 0x00

    // text of boot
    mov dword ptr [bx + 0x08], 0x7C0001FF
    mov dword ptr [bx + 0x0C], 0x00409E00

    // stack
    mov dword ptr [bx + 0x10], 0x7E0001ff
    mov dword ptr [bx + 0x14], 0x00409600


    // heap
    mov dword ptr [bx + 0x18], 0x800001FF
    mov dword ptr [bx + 0x1C], 0x00409200

    // text of loader
    mov dword ptr [bx + 0x20], 0x820001FF
    mov dword ptr [bx + 0x24], 0x00409800

    // gdt 
    mov dword ptr [bx + 0x28], 0x840001FF
    mov dword ptr [bx + 0x2C], 0x00409200

    mov ax, 0
    mov ds, ax
    mov bx, offset gdt_size
    lgdt [bx]


    in al, 0x92
    or al, 0x02
    out 0x92, al

    cli

    mov word ptr [jmp_addr + 2], 0x20
    mov word ptr [jmp_addr], (offset _flush)
    sub word ptr [jmp_addr], 0x8200
    mov bx, offset jmp_addr
    

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword ptr [bx]

.code32
_flush:
    inc eax 
    jmp _flush
    ret

.code16





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







