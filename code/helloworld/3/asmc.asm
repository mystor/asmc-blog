;;; -*- nasm -*-

%define SYS_EXIT 60

        global _start
_start:
        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
