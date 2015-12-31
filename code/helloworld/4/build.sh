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
