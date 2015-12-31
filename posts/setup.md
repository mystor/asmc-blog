# Setup

## Operating System

Writing code this low-level is OS specific, which means that we need a standard
operating system. This project will be running code specific to 64-bit linux,
running on a x86-64 processor architecture. Specifically, the linux kernel which
I am writing this code with is 3.16.0 (in case something breaks in the future).

If you aren't running linux, then you'll probably want to run it in a virtual
machine. [Virtualbox](https://virtualbox.com) is a good tool for this.

## Assembler

You'll also need to install the [netwide assembler (NASM)](https://nasm.us/).
This is the assembler (basically an assembly-language compiler) which we will
use for writing code. Linux also comes with an assembler, called `as`. However,
we will not be using it, as NASM has a much more powerful preprocessor which
will allow us to build useful abstractions as we write the program.

Assembling an assembly file named `asmc.asm` looks something like this:

```bash
$ nasm -g -f elf64 -o asmc.o asmc.asm
```

The flags mean the following:

* `-g` tells NASM to emit debug information (which will be useful for debugging
later!)

* `-f elf64` tells NASM that we are compiling an object file for 64-bit linux-like
environments (linux executables use "ELF" (Executable and Linkable Format)).

* `-o asmc.o` tells NASM to write the output to a file named `asmc.o`

* `asmc.asm` tells NASM to read from the file named `asmc.asm`

## Linking

When you assemble a file with NASM, it generates an object (`.o`) file. This is
a file containing code which has not yet been set up for execution. We then need
to "link" it with any other objects which it depends on, turning it into an
executable. As we aren't using any other objects, the linker (`ld`) call is
fairly simple.

```bash
$ ld -o asmc asmc.o
```

The `-o` flag and positional argument mean the same thing as with NASM. The
output `asmc` file can be executed as follows:

```bash
$ ./asmc
```

## Build Script

On most modern machines, assembling this entire program should be very fast, so
we can skip complex build systems and simply write a shell script to do the build
for us:

```sh
#!/bin/sh

set -x # Print out each instruction as we execute it

# Try to compile and link the program
if nasm -g -f elf64 -o asmc.o asmc.asm && ld -o asmc asmc.o; then
    if [ "$1" = "debug" ]; then
        gdb ./asmc # If "debug" is passed as the first argument, debug it
    else
        ./asmc # Otherwise run the executable if the build succeeded
    fi
fi

# Print the status code which either nasm or the program execution exited with
exit $?
```
