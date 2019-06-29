.intel_syntax noprefix
.code16


.section .header

.global _program_size
_program_size:
.word 0x00
.word 0x00

_stack_size:
.word 0x02
.word 0x00

_entry_point:
.word 0x00
.word 0x00

_function_table:

_putchar_far:
.skip 2, 0x00

_show_far:
.skip 2, 0x00

_setcur_far:
.skip 2, 0x00

_getoffset_far:
.skip 2, 0x00

_disk_read_far:
.skip 2, 0x00


.section .data
_msg1:
.asciz "Using User Program\n"

.section .text
_user_entry:
    mov bx, OFFSET _msg1
    call far [_show_far]
_exit_loop:
    hlt
    jmp _exit_loop
