#if undefined(UI_ASM)
#define UI_ASM

.include 'constants.inc'
.include 'graphics.asm'
.include 'string.asm'
.include 'glyph.asm'

.module UI
    
    .module RowFlags
        RowIndexMask = %00000011 ; Bits 0-1: Row index
        RenderLabel = %00000100 ; Rerender row label
        RenderLabelBit = 2 ; Bit position for RenderLabel
        RenderSelection = %00001000 ; Rerender row selection
        RenderSelectionBit = 3 ; Bit position for RenderSelection
        RenderRect = %00010000 ; Render row rectangle
        RenderRectBit = 4 ; Bit position for RenderRect
        RenderSelectionArrows = %00100000 ; Render arrows around selection
        RenderSelectionArrowsBit = 5 ; Bit position for RenderSelectionArrows
    .endmodule ; UI.RowFlags

    ArrowsWidth = 8
DrawRow: ; A = row flags HL = Label string, DE = Selection string
    BIT RowFlags.RenderLabelBit, A
    JR Z, __RowLabelEnd
    PUSH AF
    PUSH DE
    PUSH HL
    CALL DrawRowLabel
    POP HL
    POP DE
    POP AF
__RowLabelEnd:
    LD B, A
    AND RowFlags.RenderSelection | RowFlags.RenderLabel
    JR Z, __RowMiddleEnd
    LD A, B
    PUSH BC
    PUSH DE
    CALL DrawMiddle
    POP DE
    POP BC
__RowMiddleEnd:
    LD A, B
    BIT RowFlags.RenderSelectionBit, A
    JR Z, __RowSelectionEnd
    PUSH AF
    PUSH DE
    CALL DrawRowSelection
    POP DE
    POP AF
__RowSelectionEnd:
    BIT RowFlags.RenderRectBit, A
    JR Z, __RowRectEnd
    AND RowFlags.RowIndexMask
    CALL DrawRowRect
__RowRectEnd:
    RET
DrawRowSelection: ; DE = Selection string, HL = Label string
    EX DE, HL
    PUSH AF
    PUSH AF
    PUSH HL
    CALL String.GetWidth
    LD B, A
    POP HL
    POP AF
    AND RowFlags.RowIndexMask
    RLA
    RLA
    RLA
    ADD A, 2
    LD C, A
    POP AF
    PUSH AF
    PUSH BC
    PUSH HL
    PUSH DE
    BIT RowFlags.RenderSelectionArrowsBit, A
    JR Z, __NoAdjustSelectionArrows
    LD A, B
    ADD A, ArrowsWidth
    LD B, A
__NoAdjustSelectionArrows:
    LD H, B
    LD L, 7
    LD A, Screen.Width - 3
    SUB H
    LD D, A
    LD E, C
    LD B, 0
    CALL Graphics.DrawRect
    POP DE
    POP HL
    POP BC
    POP AF
    BIT RowFlags.RenderSelectionArrowsBit, A
    JR Z, __NoDrawRowArrows
    PUSH HL
    LD A, Character.LeftArrow
    CALL Glyph.GetGlyphSpriteAddr
    LD A, B
    ADD A, ArrowsWidth
    LD B, A
    LD A, Screen.Width - 3
    SUB B
    LD D, A
    LD E, C
    PUSH DE
    PUSH BC
    CALL Graphics.DrawSprite
    POP BC
    LD A, Character.RightArrow
    CALL Glyph.GetGlyphSpriteAddr
    LD D, Screen.Width - 7
    LD E, C
    CALL Graphics.DrawSprite
    POP DE
    POP HL
    LD A, D
    ADD A, 4
    LD D, A
    JR __EndDrawRowArrows
__NoDrawRowArrows:
    LD A, Screen.Width - 3
    SUB B
    LD D, A
    LD E, C
__EndDrawRowArrows:
    CALL String.Draw
    RET
DrawRowLabel: ; HL = label string, DE = selection string, A = row index
    AND RowFlags.RowIndexMask
    RLA
    RLA
    RLA
    LD E, 2
    ADD A, E
    LD D, E ; D = Label x
    INC D
    LD E, A ; E = Label y
    PUSH HL
    PUSH DE
    PUSH DE
    CALL String.GetWidth
    POP DE
    LD H, A
    LD L, 7
    LD B, 0
    CALL Graphics.DrawRect
    POP DE
    POP HL
    CALL String.Draw
    RET
DrawMiddle: ; HL = label string, DE = selection string
    PUSH AF
    PUSH AF
    PUSH HL
    PUSH DE
    CALL String.GetWidth
    POP DE
    LD B, A ; B = width of label string
    EX DE, HL
    PUSH DE
    PUSH BC
    CALL String.GetWidth
    POP BC
    LD C, A ; C = width of selection string
    POP DE
    POP HL
    POP AF
    BIT RowFlags.RenderSelectionArrowsBit, A
    JR Z, __NoAdjustMiddleArrows
    LD A, C
    ADD A, ArrowsWidth
    LD C, A ; C = width of selection string including arrows
__NoAdjustMiddleArrows:
    POP AF
    AND RowFlags.RowIndexMask
    RLA
    RLA
    RLA
    ADD A, 2
    LD E, A ; E = y position for drawing the middle rect
    LD A, B
    ADD A, 3
    LD D, A ; D = x position for drawing the middle rect
    LD A, Screen.Width - 6
    SUB B
    SUB C
    LD H, A
    LD L, 7
    LD B, 0
    CALL Graphics.DrawRect
    RET
DrawRowRect: ; A = row index
    RLA
    RLA
    RLA
    LD C, A
    LD B, 0
    PUSH BC
    LD HL, $0101
    ADD HL, BC
    LD DE, $5D09
    LD B, 2
    EX DE, HL
    CALL Graphics.DrawRect
    POP BC
    LD HL, $0202
    ADD HL, BC
    LD DE, $5B07
    LD B, 2
    EX DE, HL
    CALL Graphics.DrawRect
    RET

.endmodule ; UI

#endif ; UI_ASM