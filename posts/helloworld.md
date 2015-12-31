# Hello, World!

Naturally, we need to start with writing the text "Hello, World!" to the screen.
In C, your first program to do this would look something like this:

```C
#include <stdio.h>
int main()
{
    printf("Hello, World!\n");
}
```

In assembly, it would also be possible to invoke the magical "printf" function,
however, that function comes from the C standard library, and in this project,
we aren't using any libraries! So instead, we need to go down to the basics.

## The First Assembly Program

Let's actually create that `asmc.asm` file now, and write the most basic
assembly program possible. We haven't figured out how to make our program have
side-effects yet, so the most impressive thing we can do is loop forever!

```nasm
_start:
        jmp _start
```

If we put that code into `asmc.asm`, and execute it, the program will not exit.
We can force it to exit by typing `^C` (Control-C) on the command prompt.

Here's the same source, with a bunch of comments added.

```nasm
;;; Comments in assembler are written starting with the ; character.
;;; In this text, you will find that left-aligned comments tend to begin
;;; with `;;;`, indented comments will begin with `;;` and comments on
;;; the same line as code will begin with `;`. This is purely a convention,
;;; and has no meaning.

;;; When a program begins, the code is loaded into memory, and the program begins
;;; executing instructions starting at this point.

;;; Whenever the "label" _start is referred to in the program, what it refers to
;;; is the memory address of the instruction following it.

;;; We also need to tell the assembler that the _start label should be visible
;;; to the linker, and we can do that by saying global _start
        global _start
_start:
        ;; The `jmp` instruction causes control flow to, instead of proceeding
        ;; to the following instruction, instead next execute the instruction
        ;; at the address passed to it.

        ;; By telling the program to execute the instruction at _start next,
        ;; we have created an infinite loop, as this instruction, and only
        ;; this instruction, will be executed over and over again.
        jmp _start

```

As you might have noticed, the entry point to a program isn't actually called
main, it's called _start. The C standard library provides this "symbol" for most
programs, which sets up the runtime, and then calls the main function.

## Exiting

Now that we have running forever down, the next big goal is stopping. The first
thought might be to simply not loop anymore, and instead just do nothing. The
`nop` instruction takes no arguments, and tells the processor to do nothing, so
let's try that!

```nasm
        global _start
_start:
        nop
```

Unfortunately, upon running it, we get the following:

```bash
$ ./build.sh
+ nasm -g -f elf64 -o asmc.o asmc.asm
+ ld -o asmc asmc.o
+ [  = debug ]
+ ./asmc
Segmentation fault (core dumped)
+ exit 139
```

Argh, not a segfault! This is because the machine executes the `nop` instruction,
and then proceeds to execute the instruction following it. Unfortunately, there is
no instruction following it, so the processor tries to read something which doesn't
exist, and we get a segfault. In a way, that successfully exits the program, but
probably not in the manner we intended.

## Exiting Cleanly

Instead, we need to ask the operating system to kill the program cleanly for us.
In order to talk to the operating system, we need to use something called a system
call.

There is a special instruction called `syscall` which triggers one of these. When
`syscall` is executed, the operating system takes over, and inspects the states of
the process' registers. Based on that state, it will perform some operation, and
potentially return control to the process. The system call we want to make is the
`SYS_EXIT` system call. We can check the [syscall table](syscall.md) to find what
we need to do for the sys_exit call:

| rax | System call | rdi | rsi | rdx | r10 | r8 | r9 |
|-----|-------------|-----|-----|-----|-----|----|----|
| 60 | sys_exit | int error_code |

This tells us that when we want to perform a sys_exit call, the register `rax`
must contain the number 60, and the register `rdi` must contain the error code
which we want to exit with. A successful exit on linux has the error code `0`,
so we want `rax` to have the value `60`, and `rdi` to have the value `0`.

To set the values of the registers, we can use the `mov` instruction. Writing
`mov rax, 60` will set the value of the `rax` register to `60`, and writing
`mov rdi, 0` will set the value of the `rdi` register to `0`. We then just
need to invoke the `syscall` instruction:

```nasm
        global _start
_start:
        mov rax, 60
        mov rdi, 0
        syscall
```

When we run this:

```bash
$ ./build.sh
+ nasm -g -f elf64 -o asmc.o asmc.asm
+ ld -o asmc asmc.o
+ [  = debug ]
+ ./asmc
+ exit 0
```

Yay! we got a successfully exiting program! If you want to fiddle with the exit
code, just change the `0` on line 4 to another value, and that will be the exit
code of the process!

Now, we don't want to write `mov rax, 60` every time we want to perform a
`SYS_EXIT` call, as that looks super ugly! Instead, we can add a macro which
NASM will understand to make the code easier to read.

```nasm
%define SYS_EXIT 60

        global _start
_start:
        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
```

`%define SYS_EXIT 60` basically means that whenever you see the text `SYS_EXIT`,
replace it with the number `60`. Now the code is a bit easier to read!

## Standard Out

Now, having a program exit is all well and good, but we wanted to print "Hello,
World!" to the screen! How do we do that?

On linux, the terminal displays text which is written to something known as
"Standard Out". In order to make text display on the terminal, thus, we need
to write to this "Standard Out".

| rax | System call | rdi | rsi | rdx | r10 | r8 | r9 |
|-----|-------------|-----|-----|-----|-----|----|----|
| 1 | sys_write | unsigned int fd | const char *buf | size_t count |

The syscall table tells us that the `SYS_WRITE` call, which allows us to write
to a "file" (such as Standard Out!) requires `rax` to contain the number 1,
`rdi` to contain the "file descriptor" of the file to write to, `rsi` to contain
a pointer to the text to write out, and `rdx` to contain the number of bytes to
write.

Standard Out always has the fixed file descriptor of `1`, and "Hello, World!\n"
takes up 14 bytes (including the newline), so now we just need to get the bytes
for "Hello, World!" into memory somewhere.

```nasm
%define SYS_WRITE 1
%define SYS_EXIT 60
%define STDOUT 1

        global _start
_start:
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, ???
        mov rdx, 14
        syscall

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
```

Just like how labels can be used to mark an instruction, they can also be used
to mark data. So, we can write the following:

```nasm
string:
        db "Hello, World!", 10
```

The `db` pseudo-instruction produces a series of bytes in the resulting program
which contain the bytes for the following string. We also add the character 10
(the newline character). So, now we have the string in memory. Because it's
labeled `string:`, we can just `mov rsi, string`, and we have a pointer to the
string! Horray!

There's another trick we can do, to reduce the use of magic numbers:

```nasm
string:
        db "Hello, World!", 10
string_end:

;;; ...

        mov rsi, string
        mov rdx, string_end - string
```

As `string_end` is the address of the memory after the end of the string,
the difference in the addresses is the length of the string, yay less magic
numbers.

Now we can run it:

```bash
$ ./build.sh
+ nasm -g -f elf64 -o asmc.o asmc.asm
+ ld -o asmc asmc.o
+ [  = debug ]
+ ./asmc
Hello, World!
+ exit 0
```

Hello, World achieved!
