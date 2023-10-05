.data
test:
	.word 1
	.word 3
	.word 5
	.word 7
	.word 9
	.word 8
	.word 6
	.word 4
	.word 2
	.word 0

.global _start
.text
_start:
    LDR r1, =test
    MOV r0, #0
    MOV r3, #0
again:
    LDR r2,[r1]
    CMP r2,#0
    BEQ finish
    CMP r2,r3
    BGT big
    ADD r1,r1,#4
    B again

big:
    MOV r3,r2
    ADD r1,r1,#4
    B again
finish:
    MOV r0,r3
halt:
    BAL halt

.end