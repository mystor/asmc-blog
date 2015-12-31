# What is asmc?

I love understanding how the tools which I use everyday work, and to that end
I decided to write a compiler for a simple language in assembly. In the past,
I have used high level languages and libraries, such as C++ and LLVM, in order
to build compilers, but I felt that I didn't have a deep enough understanding
of how everything is built.

As the goal of this project was to learn, rather than to build anything
particularially useful, I decided that I would not use any libraries or
pre-written code (With the exception, of course, of Linux's system calls, which
you cannot write a user-space program without), writing every single component
from scratch, such that I understood the whole thing.

In this blog series, I will walk through the writing of a compiler in x86-64
assembly language. I hope that it will provide a way for people to learn the
same things I did, but without the sometimes-frustrating process of trying
to determine how to search for the information I need to proceed.

## How much should I know?

I want this to be approachable, which means that I hope that with this text one
can learn assembly, and write a compiler, without a sophisticated understanding
of system programming. However, I will almost certainly fail on that mark (which
is a bug - please [report it](https://github.com/mystor/asmc-blog/issues)),
because I haven't been in that position in a while, and have forgotten what I
can expect people to know.

That being said, I will expect readers to have a familiarity with the command
line, and will probably mention things like pointers without explaining what
they are. There are awesome tutorials out there for what these concepts are.
However, they are out of scope for this series.

## What tools?

* x86-64 assembly
* Intel-style syntax
* NASM assembler

## Q & A

### What assembler will you use?

I will assemble the program using the NASM assembler. This is mostly because it
has a powerful macro system, which allows the building of useful abstractions
over common patterns to make writing assembly code easier and less error-prone.

At the same time, it doesn't hide anything from us, so we truely do understand
everything which is going on, even once we have created an abstraction.

### Why x86-64?

x86{,-64} is the most popular architecture on standard desktop PCs (as of the
time of this writing). The 64-bit architecture was chosen simply because it has
8 extra registers (r8-r15), and I don't like messing around with the stack any
more than I have to.

### Will you use libc?

No, linux's system call interface is well-defined, and I want to have as few
dependencies and black-boxes as possible. As this isn't an OS course, we won't
be running on bare metal (having a debugger is really nice!), but the final
program will not link with any other libraries, including the C standard
library.

### Assembly is fast, so this will be fast, right?

No, this will be (hopefully) readable assembly, which means that it will be
doing lots and lots of horribly inefficient things. This exact same program
in C would run much faster, probably even without optimizations enabled, due
to modern C compilers not caring as much as I do about what the emitted machine
code looks like.

### You said something that was wrong / I want to help make this better

Awesome! I would love it if you
[filed an issue](https://github.com/mystor/asmc-blog/issues) or
[submitted a PR](https://github.com/mystor/asmc-blog/pulls) with feedback and/or
improvements!
