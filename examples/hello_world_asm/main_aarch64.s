.section .rodata
message:
    .string "Hello, World!\n"

.section .text
.global main
.extern printf

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adrp x0, message
    add x0, x0, :lo12:message
    bl printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .note.GNU-stack,"",%progbits
