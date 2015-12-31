;;; -*- nasm -*-

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
