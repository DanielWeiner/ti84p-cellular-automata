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
__DivHLBy10Loop:
    ADD HL, HL ; shift another 0 into the quotient portion of HL
    RLA        ; shift a bit into remainder and check if 10 can be subtracted
    CP C       ; if 10 can be subtracted from remainder, subtract it and set the quotient bit to 1
    JR C, __DivHLBy10Next ; otherwise, quotient bit remains 0
    SUB C      ; subtract 10 from remainder
    INC L      ; quotient bit is now 1
__DivHLBy10Next:
    DJNZ __DivHLBy10Loop
    RET
.endmodule ; Math

#endif ; MATH_ASM