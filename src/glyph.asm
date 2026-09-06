#if undefined(GLYPH_ASM)
#define GLYPH_ASM

.include "ti83plus.inc"
.module Glyph
    Max = $F4
    Count = Max + 1
    Height = 7
    DataSize = 9
    TableSize = Count * DataSize
CreateGlyphTable:
    LD HL, GlyphTableVar
    RST rMOV9TOOP1
    LD HL, TableSize
    bcall(_CreateAppVar)
    LD (GlyphTableEntryAddr), HL
    LD (GlyphTableAddr), DE
    RET
GetGlyphSpriteAddr: ; A = character, returns HL = sprite address, destroys HL, DE
    LD L, A
    LD H, 0
    LD D, H
    LD E, L
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    LD DE, (GlyphTableAddr)
    ADD HL, DE
    RET
    
LoadGlyphs:
    LD B, 0
    LD DE, (GlyphTableAddr)
__LoadGlyphsLoop:
    PUSH BC
    LD L, B
    LD H, 0
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    PUSH DE
    bcall(_Load_SFont)
    POP DE
    LD A, (HL)   ; Load glyph width
    INC HL       ; Move to glyph data
    LD (DE), A
    INC DE
    LD C, A
    LD A, Height
    LD (DE), A   ; Load glyph height
    INC DE
    LD A, 8
    SUB C        ; A = 8 - glyph width, bytes to shift left
    LD (__LeftShifts), A
    LD B, 7      ; iterate 7 times for each row of the glyph
__CopyGlyphsLoop:
    PUSH BC
__LeftShifts = $+1
    LD B, 0      ; B = bytes to shift left
    LD A, (HL)   ; Load the current glyph row
    INC HL
__ShiftGlyphLoop:
    SLA A
    DJNZ __ShiftGlyphLoop
    LD (DE), A   ; Store the shifted glyph row
    INC DE
    POP BC
    DJNZ __CopyGlyphsLoop
    POP BC
    INC B
    LD A, B
    CP Glyph.Max + 1
    JR NZ, __LoadGlyphsLoop
    RET
DeleteGlyphTable:
    LD HL, (GlyphTableAddr)
    EX DE, HL
    LD HL, (GlyphTableEntryAddr)
    LD B, 0
    bcall(_DelVar)
    LD HL, 0
    LD (GlyphTableAddr), HL
    LD (GlyphTableEntryAddr), HL
    RET
GlyphTableVar:
    .db AppVarObj, 'GLYPHS', 0
GlyphTableAddr:
    .dw 0
GlyphTableEntryAddr:
    .dw 0
.endmodule ; Glyph

#endif ; GLYPH_ASM