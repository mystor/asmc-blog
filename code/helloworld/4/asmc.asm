;;; -*- nasm -*-

%define SYS_WRITE 1
%define SYS_EXIT 60
%define STDOUT 1

string:
        db "Hello, World!", 10
string_end:

        global _start
_start:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, string
        mov rdx, string_end - string
        syscall

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
