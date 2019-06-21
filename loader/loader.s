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
    call [_terminal_show]
    



    mov bx, 0xC
    jmp _exit_loop


.global _loader_load
.type _loader_load STT_FUNC
_loader_load:

    ret



_exit_loop:
    inc bx
    hlt
    jmp _exit_loop







