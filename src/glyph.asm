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
    LD   HL, GlyphTableVar
    RST  rMOV9TOOP1      ; OP1 = Data type (AppVarObj), followed by variable name ('GLYPHS')
    LD   HL, TableSize   ; Size of the variable is calculated to fit all the glyph sprites
    bcall(_CreateAppVar) ; HL = address of the entry in the allocation table, DE = address of the variable data
    LD   (GlyphTableEntryAddr), HL
    LD   (GlyphTableAddr), DE
    RET
GetGlyphSpriteAddr: ; Returns the memory address for the character's glyph sprite. A = character, returns HL = sprite address, destroys HL, DE
    LD   L, A
    LD   H, 0
    LD   D, H
    LD   E, L
    ADD  HL, HL
    ADD  HL, HL
    ADD  HL, HL
    ADD  HL, DE ; Each glyph is 9 bytes (width, height, 7 bytes of glyph data), so character index * 9 + base address of the glyph table
    LD   DE, (GlyphTableAddr)
    ADD  HL, DE
    RET
    
LoadGlyphs: ; Loads all variable width glyphs from the TI-84+ rom as sprites in RAM
    LD   B, 0 ;  counts up from 0, representing the current glyph index
    LD   DE, (GlyphTableAddr)
__LoadGlyphsLoop:
    PUSH BC
    LD   L, B
    LD   H, 0
    ADD  HL, HL
    ADD  HL, HL
    ADD  HL, HL ; _Load_SFont takes the character * 8 in HL
    PUSH DE
    bcall(_Load_SFont) ; HL is the address of the system character glyph data. 1 width byte, followed by 7 bytes of glyph data
    POP  DE
    LD   A, (HL)   ; Load glyph width
    INC  HL        ; Move to glyph data
    LD   (DE), A   ; Store glyph width in the glyph table
    INC  DE
    LD   C, A      ; Store glyph width in C for later calculations
    LD   A, Height ; Glyph height is constant 7
    LD   (DE), A   ; Load glyph height
    INC  DE
    LD   A, 8
    SUB  C         ; A = 8 - glyph width, bytes to shift left
    LD   (__LeftShifts), A
    LD   B, 7      ; iterate 7 times for each row of the glyph
__CopyGlyphsLoop:
    PUSH  BC
__LeftShifts = $+1
    LD   B, 0      ; B = bytes to shift left
    LD   A, (HL)   ; Load the current glyph row
    INC  HL
__ShiftGlyphLoop:
    SLA  A
    DJNZ __ShiftGlyphLoop
    LD   (DE), A   ; Store the shifted glyph row
    INC  DE
    POP  BC
    DJNZ __CopyGlyphsLoop
    POP  BC
    INC  B
    LD   A, B
    CP   Glyph.Max + 1
    JR   NZ, __LoadGlyphsLoop
    RET
DeleteGlyphTable:
    LD   HL, (GlyphTableAddr)
    EX   DE, HL
    LD   HL, (GlyphTableEntryAddr)
    LD   B, 0
    bcall(_DelVar)  ; DelVar takes the variable data address in DE and the variable entry address in HL
    LD   HL, 0
    LD   (GlyphTableAddr), HL      ; Clear the glyph table address
    LD   (GlyphTableEntryAddr), HL ; Clear the glyph table entry address
    RET
GlyphTableVar:
    .db AppVarObj, 'GLYPHS', 0
GlyphTableAddr:
    .dw 0
GlyphTableEntryAddr:
    .dw 0
.endmodule ; Glyph

#endif ; GLYPH_ASM