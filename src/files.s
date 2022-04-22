        .text

        .align  2
fileName1:
        .asciz  "res/atari1.bin"
fileName2:
        .asciz  "res/atari2.bin"
fileName3:
        .asciz  "res/atari3.bin"
fileName4:
        .asciz  "res/atari4.bin"
fileName5:
        .asciz  "res/atari5.bin"
fileName6:
        .asciz  "res/atari6.bin"
fileName7:
        .asciz  "res/atari7.bin"

        .align  131072
file1:
        .incbin "res/atari1.bin"
fileEnd1:

        .align  131072
file2:
        .incbin "res/atari2.bin"
fileEnd2:

        .align  131072
file3:
        .incbin "res/atari3.bin"
fileEnd3:

        .align  131072
file4:
        .incbin "res/atari4.bin"
fileEnd4:

        .align  131072
file5:
        .incbin "res/atari5.bin"
fileEnd5:

        .align  131072
file6:
        .incbin "res/atari6.bin"
fileEnd6:

        .align  131072
file7:
        .incbin "res/atari7.bin"
fileEnd7:

        .align  131072

        .global fileName
fileName:
        .long   fileName1
        .long   fileName2
        .long   fileName3
        .long   fileName4
        .long   fileName5
        .long   fileName6
        .long   fileName7

        .global fileSize
fileSize:
        .long   fileEnd1 - file1
        .long   fileEnd2 - file2
        .long   fileEnd3 - file3
        .long   fileEnd4 - file4
        .long   fileEnd5 - file5
        .long   fileEnd6 - file6
        .long   fileEnd7 - file7

        .global filePtr
filePtr:
        .long   file1
        .long   file2
        .long   file3
        .long   file4
        .long   file5
        .long   file6
        .long   file7

        .align  4
