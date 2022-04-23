file1:
        .incbin "res/atari1.bin"
fileEnd1:

        .align  131072

        .global filePtr
filePtr:
        .long   file1

        .align  4
