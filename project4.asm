.ORIG x3000

; all you gotta do is paste this into lc3sim then the solution SHOULD be stored (and correct) at memory address x3FFF is should hold x0027 (39)

LD R6, STACKBASE            ; initialize stack pointer
ADD R6, R6, #-3             ; reserve return slot + 2 argument slots
LD R0, ARRAYSIZE
STR R0, R6, #1              ; arg 2: arraySize
LEA R0, ARRAYDATA
STR R0, R6, #0              ; arg 1: address of array
JSR SUMOFSQUARES
ADD R6, R6, #2              ; pop args, total is left on top of stack
HALT

SUMOFSQUARES
ADD R6, R6, #-2             ; space for saved R7 and R5
STR R7, R6, #1              ; save return address
STR R5, R6, #0              ; save caller's frame pointer
ADD R5, R6, #-1             ; frame pointer = first local
ADD R6, R6, #-2             ; locals: counter at R5, sum at R5-1
AND R0, R0, #0
STR R0, R5, #0              ; counter = 0
STR R0, R5, #-1             ; sum = 0

SUMLOOP
LDR R0, R5, #0              ; load counter
LDR R1, R5, #4              ; load arraySize
NOT R1, R1
ADD R1, R1, #1              ; negate arraySize
ADD R0, R0, R1              ; counter - arraySize
BRzp SUMDONE                ; exit when counter >= arraySize
LDR R0, R5, #3              ; array base address
LDR R1, R5, #0
ADD R0, R0, R1              ; address of a[counter]
LDR R0, R0, #0              ; a[counter]
ADD R6, R6, #-2             ; return slot + argument slot for SQUARE
STR R0, R6, #0              ; push argument
JSR SQUARE
ADD R6, R6, #1              ; pop argument
LDR R0, R6, #0              ; read returned square
ADD R6, R6, #1              ; pop return slot
LDR R1, R5, #-1
ADD R1, R0, R1              ; square + sum
STR R1, R5, #-1             ; update sum
LDR R0, R5, #0
ADD R0, R0, #1
STR R0, R5, #0              ; counter++
BRnzp SUMLOOP

SUMDONE
LDR R0, R5, #-1
STR R0, R5, #5              ; write sum into return slot
ADD R6, R5, #1              ; pop locals
LDR R5, R6, #0              ; restore frame pointer
LDR R7, R6, #1              ; restore return address
ADD R6, R6, #2              ; pop saved registers
RET

SQUARE                      ; same prologue/epilogue pattern as SUMOFSQUARES, no locals
ADD R6, R6, #-2
STR R7, R6, #1
STR R5, R6, #0
ADD R5, R6, #-1
LDR R1, R5, #3              ; x
AND R0, R0, #0              ; product = 0
ADD R2, R1, #0              ; loop count = x
SQUARELOOP
BRnz SQUAREDONE             ; stop when count reaches 0
ADD R0, R0, R1              ; product += x
ADD R2, R2, #-1
BRnzp SQUARELOOP
SQUAREDONE
STR R0, R5, #4              ; write product into return slot
LDR R5, R6, #0
LDR R7, R6, #1
ADD R6, R6, #2
RET

STACKBASE .FILL x4000       ; bottom of runtime stack
ARRAYSIZE .FILL #5
ARRAYDATA .FILL #2          ; array contents: 2, 3, 5, 0, 1
.FILL #3
.FILL #5
.FILL #0
