#if undefined(MATH_ASM)
#define MATH_ASM

.module Math
DivHLBy10:      ; Divides HL in place by 10, remainder in A, destroys BC
    XOR A
    ADD HL, HL
    RLA
    ADD HL, HL
    RLA
    ADD HL, HL
    RLA
    LD B, 13
    LD C, 10
__DivHLBy10Loop:
    ADD HL, HL
    RLA
    CP C
    JR C, __DivHLBy10Next
    SUB C
    INC L
__DivHLBy10Next:
    DJNZ __DivHLBy10Loop
    RET
.endmodule ; Math

#endif ; MATH_ASM