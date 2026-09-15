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
    CP   C      ; if 10 can be subtracted from remainder, subtract it and set the quotient bit to 1
    JR   C, $+4 ; otherwise, skip both the subtraction and the increment of the quotient bit
    SUB  C      ; subtract 10 from remainder
    INC  L      ; quotient bit is now 1
    DJNZ __LongDivisionLoop
    RET

DivHLBy100:    ; Divides HL in place by 100, remainder in A, destroys BC
    XOR  A     ; clear out carry flag for right shifts
               ; similar to division by 10, shift 6 bits of HL into A (first 6 bits are always 0 when dividing by 100)
    LD   A, H  ; start with a left shift of 8 bits into the remainder accumulator via a full byte copy
    LD   H, L
    LD   L, 0
    RRA        ; Then shift A into HL right twice to make a final count of 6 left shifts
    RR   H
    RR   L
    RRA
    RR   H
    RR   L
    LD   B, 10 ; initialize loop counter and divisor for division by 100
    LD   C, 100
    JR   __LongDivisionLoop ; Reuse the same loop for division by 100
.endmodule ; Math

#endif ; MATH_ASM