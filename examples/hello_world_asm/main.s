.section .rodata
message:
    .string "Hello, World!\n"

.section .text
.global main
.extern printf

main:
    push %rbp
    mov %rsp, %rbp

    lea message(%rip), %rdi
    xor %rax, %rax
    call printf

    mov $0, %eax
    pop %rbp
    ret

.section .note.GNU-stack,"",@progbits