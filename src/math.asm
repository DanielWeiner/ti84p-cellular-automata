#if undefined(MATH_ASM)
#define MATH_ASM

.module Math
DivHLBy10:      ; Divides HL in place by 10, remainder in A, destroys BC
    XOR  A      ; Clear out the remainder accumulator
    ; As HL is shifted left into the remainder, the quotient is inserted into HL from the LSB, making use of the space made available by the shift
    ADD  HL, HL ; Shift HL left into remainder accumulator. No subtractions can be done in the first 3 iterations when dividing by 10
    RLA
    ADD  HL, HL
    RLA
    ADD  HL, HL
    RLA
    ; The quotient portion of HL is now prefixed with three 0's, which is always the case after division by 10.
    ; A contains three leading bits. When shifting another bit in, 10 can be subtracted from A at most 1 time
    LD   B, 13 ; 16 iterations minus the first three which are already done
    LD   C, 10 ; Divisor for the division by 10
__LongDivisionLoop:
    ADD  HL, HL ; shift another 0 into the quotient portion of HL
    RLA         ; shift a bit into remainder and check if 10 can be subtracted
__LongDivisionCheck:
    CP   C      ; if 10 can be subtracted from remainder, subtract it and set the quotient bit to 1
    JR   C, $+4 ; otherwise, skip both the subtraction and the increment of the quotient bit
    SUB  C      ; subtract 10 from remainder
    INC  L      ; quotient bit is now 1
    DJNZ __LongDivisionLoop
    RET

DivHLBy100: ; Divides HL in place by 100, remainder in A, destroys BC
    ; Similar to division by 10, we can shift HL into the remainder 7 times before subtraction
    ; By shifting HL 8 times into the remainder, the subtraction check needs to be done once, followed by 8 more iterations
    ; This allows us to jump into the main division loop at the comparison check after a simple shift of 8 bits
    LD   A, H   ; start by moving HL 8 bits left into remainder
    LD   H, L
    LD   L, 0
    LD   B, 9   ; Loop counter decrements after the initial check, and then runs 8 additional times
    LD   C, 100
    JR   __LongDivisionCheck ; Reuse the same loop for division by 100
.endmodule ; Math

#endif ; MATH_ASM