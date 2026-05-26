.syntax unified
.arch armv7-a

.section .rodata
.balign 4
message:
    .asciz "Hello, World!\n"

.section .text
.global main
.type main, %function

main:
    push {fp, lr}
    add fp, sp, #4

    ldr r0, =message
    bl printf

    mov r0, #0
    pop {fp, pc}

.section .note.GNU-stack,"",%progbits
