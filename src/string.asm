#if undefined(STRING_ASM)
#define STRING_ASM

.include "graphics.asm"
.include "glyph.asm"
.include "math.asm"

.module String
ConvertHLToDigitString: ; Converts HL to a digit string, and returns the string address in HL. Destroys B, DE
    LD DE, __Digits + 5
    LD C, 0
    LD B, C
__ConvertHLToDigitStringLoop: 
    PUSH BC
    CALL Math.DivHLBy10
    POP BC
    ADD A, '0'
    LD (DE), A
    DEC DE
    INC B
    LD A, H
    OR L
    JR NZ, __ConvertHLToDigitStringLoop
    EX DE, HL
    LD (HL), B
    RET
__Digits: 
    .fill 6, 0 ; five digits plus length byte
GetWidth:      ; HL = string address, returns A = string width, destroys BC, DE, HL
    LD B, (HL) ; String length byte
    INC HL
    LD C, 0
__GetStringWidthLoop:
    PUSH HL
    LD A, (HL)
    CALL Glyph.GetGlyphSpriteAddr
    LD A, (HL)
    ADD A, C
    LD C, A
    POP HL
    INC HL
    DJNZ __GetStringWidthLoop

    RET
Draw:          ; HL = string address, D = x, E = y
    LD B, (HL) ; Load string length into B
    INC HL     ; Move past the string length byte
__DrawStringLoop:
    LD A, (HL) ; Load the current character
    PUSH HL
    PUSH DE
    PUSH DE
    CALL Glyph.GetGlyphSpriteAddr
    LD C, (HL) ; Load the sprite width into C
    POP DE
    PUSH BC
    CALL Graphics.DrawSprite
    POP BC    ; Restore HL to point to the current character in the string
    POP DE
    LD A, D
    ADD A, C
    LD D, A
    POP HL
    INC HL
    DJNZ __DrawStringLoop
    RET

.endmodule ; String
#endif ; STRING_ASM