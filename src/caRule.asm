#if undefined(CARULE_ASM)
#define CARULE_ASM

.include "constants.inc"
.include "globals.asm"
.include "random.asm"
.include "graphics.asm"

.module CARule

VisualizeRule: ; Renders the CA rule visualizer. A = 0: Draw the neighborhood squares, 1: Draw the rule application squares only
    OR   A
    LD   HL, __DrawNeighborhoodJump
    JR   Z,  __NoSkipDrawNeighborhood
    LD   DE, __SkipDrawNeighborhood
    JR   __WriteDrawNeighborhoodJump
__NoSkipDrawNeighborhood:
    LD   DE, __StartDrawNeighborhood
__WriteDrawNeighborhoodJump:
    LD   (HL), E
    INC  HL
    LD   (HL), D
    LD   DE, $0324
    LD   C, 4
    CALL __VisualizeRuleHalf
    LD   DE, $0333
    LD   C, 0
    CALL __VisualizeRuleHalf
    RET
__VisualizeRuleHalf:
    LD   B, 4
__VisualizeRuleLoop:
    DEC  B
    PUSH BC
    
    LD   A, C
    ADD  A, B

    PUSH BC
    LD   C, A
    LD   B, A
    PUSH DE
    PUSH AF
    LD   A, 1
    JR   Z, __VisualizeRuleCompareBit
__VisualizeRuleBitShift:
    RLA
    DJNZ __VisualizeRuleBitShift
__VisualizeRuleCompareBit:
    LD   HL, Globals.CARule
    AND  (HL)
    JR   NZ, __FilledRuleBit:
    LD   HL, Graphics.EmptySquareSprite
    JR   __DrawRuleBit
__FilledRuleBit:
    LD   HL, Graphics.FilledSquareSprite
__DrawRuleBit:
    LD   A, C
    LD   BC, $0507

    EX   DE, HL
    ADD  HL, BC
    EX   DE, HL
    
    PUSH HL
    PUSH DE
    LD   HL, $0404
    LD   B, 0
    CALL Graphics.DrawRect
    POP  DE
    POP  HL
    CALL Graphics.DrawSprite
    POP  AF
    POP  DE
    POP  BC

__DrawNeighborhoodJump = $+1
    JP   __StartDrawNeighborhood
__StartDrawNeighborhood:
    PUSH AF
    PUSH BC
    PUSH DE
    LD   BC, $0405
    EX   DE, HL
    ADD  HL, BC
    EX   DE, HL
    LD   HL, Graphics.DashSprite
    CALL Graphics.DrawSprite
    POP  DE
    POP  BC
    POP  AF

    RRC  A
    RRC  A
    RRC  A
    LD   B, 3
__DrawNeighborhoodLoop:
    RLA
    JR   C, __FilledSquare
    LD   HL, Graphics.EmptySquareSprite
    JR   __DrawSprite
__FilledSquare:
    LD   HL, Graphics.FilledSquareSprite
__DrawSprite:
    PUSH BC
    PUSH DE
    PUSH AF
    CALL Graphics.DrawSprite
    POP  AF
    POP  DE
    LD   BC, $0500
    EX   DE, HL
    ADD  HL, BC
    EX   DE, HL
    POP  BC
    DJNZ __DrawNeighborhoodLoop
__EndDrawNeighborhood:
    LD   BC, $0300
    EX   DE, HL
    ADD  HL, BC
    EX   DE, HL
    POP  BC
    XOR  A
    OR   B
    JR   NZ, __VisualizeRuleLoop
    RET
__SkipDrawNeighborhood:
    LD   BC, $0F00
    EX   DE, HL
    ADD  HL, BC
    EX   DE, HL
    JR   __EndDrawNeighborhood
DrawCA:
    CALL Graphics.ClearScreenBuffer
    CALL DrawFirstRow
    CALL FillCA
    RET

DrawFirstRow:
    LD   A, (Globals.Row1Selection)
    CP   Globals.OneCellSelection
    JR   Z, __DrawFirstRowOneCell
    CP   Globals.OneCellInverseSelection
    JR   Z, __DrawFirstRowOneCellInverse
    JR   __DrawFirstRowRandom
__DrawFirstRowOneCellInverse:
    CALL _DrawFirstRowFill
    LD   A, (Globals.Row2Selection)
    CP   Globals.LeftSelection
    JR   Z, __DrawFirstRowOneCellInverseLeft
    CP   Globals.CenterSelection
    JR   Z, __DrawFirstRowOneCellInverseCenter
    CP   Globals.RightSelection
    JR   __DrawFirstRowOneCellInverseRight
__DrawFirstRowOneCellInverseLeft:
    LD   HL, Screen.Address
    LD   A, %01111111
    LD   (HL), A
    RET
__DrawFirstRowOneCellInverseCenter:
    LD   HL, Screen.Address + (Screen.WidthBytes / 2) - 1
    LD   A, %11111110
    LD   (HL), A
    RET
__DrawFirstRowOneCellInverseRight:
    LD   HL, Screen.Address + (Screen.WidthBytes - 1)
    LD   A, %11111110
    LD   (HL), A
    RET
__DrawFirstRowOneCell:
    LD   A, (Globals.Row2Selection)
    CP   Globals.LeftSelection
    JR   Z, __DrawFirstRowOneCellLeft
    CP   Globals.CenterSelection
    JR   Z, __DrawFirstRowOneCellCenter
    CP   Globals.RightSelection
    JR   __DrawFirstRowOneCellRight
__DrawFirstRowOneCellLeft:
    LD   HL, Screen.Address
    LD   A, %10000000
    LD   (HL), A
    RET
__DrawFirstRowOneCellCenter:
    LD   HL, Screen.Address + (Screen.WidthBytes / 2) - 1
    LD   A, %00000001
    LD   (HL), A
    RET
__DrawFirstRowOneCellRight:
    LD   HL, Screen.Address + (Screen.WidthBytes - 1)
    LD   A, %00000001
    LD   (HL), A
    RET
__DrawFirstRowRandom:
    LD   A, (Globals.RandomSeedDensity)
    CP   100
    JR   Z, _DrawFirstRowFill
    LD   D, 0
    LD   E, A
    LD   HL, Globals.PercentageTable
    ADD  HL, DE
    LD   A, (HL)
    LD   (_DensityThreshold), A
    LD   C, Screen.WidthBytes
    LD   HL, Screen.Address
_DrawFirstRowRandomLoop:
    PUSH HL
    LD   B, 4
    LD   E, 0
_GenerateDensityByte:
    PUSH DE
    CALL Random.GenerateWord
    POP  DE
_DensityThreshoLD   = $+1
    LD   D, 0
    LD   A, L
    CP   D
    RR   E
    LD   A, H
    CP   D
    RR   E
    DJNZ _GenerateDensityByte
    LD   A, E
    POP  HL
    LD   (HL), A
    INC  HL
    DEC  C
    JR   NZ, _DrawFirstRowRandomLoop
    RET

_DrawFirstRowFill:
    LD   HL, Screen.Address
    LD   A, $FF
    LD   (HL), A
    LD   DE, Screen.Address + 1
    LD   BC, Screen.WidthBytes - 1
    LDIR
    RET

FillCA:
    CALL CacheRule
    LD   A, (Globals.Row3Selection)
    CP   Globals.WrapSelection
    JR   Z, __CARowWrap
    CP   Globals.MatchEdgeSelection
    JR   Z, __CARowMatchEdge
    CP   Globals.BlackSelection
    JR   Z, __CARowBlack
    JR   __CARowWhite
__CARowWrap:
    LD   DE, __CARowStartWrap
    LD   BC, __CARowEndWrap
    JR   __FillCARowStart
__CARowMatchEdge:
    LD   DE, __CARowStartMatchEdge
    LD   BC, __CARowEndMatchEdge
    JR   __FillCARowStart
__CARowBlack:
    LD   DE, __CARowStartBlack
    LD   BC, __CARowEndBlack
    JR   __FillCARowStart
__CARowWhite:
    LD   DE, __CARowStartWhite
    LD   BC, __CARowEndWhite
    LD   HL, RowStartJumpAddr
__FillCARowStart:
    LD   HL, RowStartJumpAddr
    LD   A, E
    LD   (HL), A
    INC  HL
    LD   A, D
    LD   (HL), A
    
    LD   HL, RowEndJumpAddr
    LD   A, C
    LD   (HL), A
    INC  HL
    LD   A, B
    LD   (HL), A

    LD   HL, Screen.Address
    LD   B, Screen.Height - 1
__FillCARowLoop:
    PUSH BC
RowStartJumpAddr = $+1
    JP   __CARowStartWrap
__CARowStartWrap:
    LD   DE, Screen.WidthBytes - 1
    ADD  HL, DE
    LD   A, (HL) ; get the last byte of the row
    LD   DE, -(Screen.WidthBytes - 1)
    ADD  HL, DE
    AND  1
    LD   E, A
    JR   __CARowStart
__CARowStartMatchEdge:
    LD   A, (HL)
    LD   E, 0
    RLA
    RL   E ; shift the leftmost bit of the first byte in the row into E
    JR   __CARowStart
__CARowStartBlack:
    LD   E, 1 
    JR   __CARowStart
__CARowStartWhite:
    LD   E, 0
__CARowStart: ; E contains the boundary bit
    LD   D, 0 ; D contains the bits resulting from the CA rule application
    LD   A, (HL) ; load the first byte of the row
    INC  HL ; Next byte to shift into a
    LD   C, (HL)    
    SLA  C
    RLA
    RL   E ; Shift C left into A AND  then into E, moving the window of consideration right
    LD   B, Screen.WidthBytes - 1
__RowBytesLoop:
    PUSH HL
    LD   L, B
    LD   B, 7
__InnerBitLoop:
    CALL CalculateRuleBit
    DJNZ __InnerBitLoop
    LD   B, L
    POP  HL
    INC  HL
    LD   C, (HL)
    CALL CalculateRuleBit
    PUSH BC
    LD   BC, Screen.WidthBytes - 2
    ADD  HL, BC
    LD   (HL), D
    LD   BC, -Screen.WidthBytes + 2
    ADD  HL, BC
    POP  BC
    DJNZ __RowBytesLoop
    DEC  HL
RowEndJumpAddr = $+1
    JP   __CARowEndWrap
__CARowEndWrap:
    PUSH DE
    LD   DE, -Screen.WidthBytes + 1
    ADD  HL, DE
    LD   C, (HL)
    LD   DE, Screen.WidthBytes - 1
    ADD  HL, DE 
    POP  DE
    JR   __CARowEnd
__CARowEndMatchEdge:
    LD   A, (HL)
    AND  1
    RRCA
    LD   C, A
    JR   __CARowEnd
__CARowEndBlack:
    LD   C, $80
    JR   __CARowEnd
__CARowEndWhite:
    LD   C, 0
__CARowEnd:
    LD   A, (HL)
    SLA  C
    RLA ; bring the window back in A AND  C, preserving E which is already correct
    LD   B, 8
__InnerBitLoopLastByte:
    CALL CalculateRuleBit
    DJNZ __InnerBitLoopLastByte
    LD   BC, Screen.WidthBytes
    ADD  HL, BC
    LD   (HL), D
    LD   BC, -Screen.WidthBytes
    ADD  HL, BC
    INC  HL
    POP  BC
    DJNZ __FillCARowLoop
    CALL Graphics.WriteScreenBuffer
    RET
CalculateRuleBit:
    ; A = current byte in the row, C = next byte in the row, E = window of consideration, D = bits resulting from the CA rule application
    SLA  C
    RLA
    RL   E ; Shift C left into A AND  then into E, moving the window of consideration right
    PUSH AF
    LD   A, E
    AND  7
    LD   E, A
    PUSH DE
    PUSH HL
    LD   D, 0
    LD   HL, CARuleBitCache
    ADD  HL, DE ; get the nth bit of the CA rule from the cache
    LD   A, (HL)
    POP  HL
    POP  DE
    RRA ; Put the nth bit of the CA rule into the carry flag
    RL   D ; shift the carry flag into D
    POP  AF
    RET
CacheRule:
    LD   HL, CARuleBitCache
    LD   A, (Globals.CARule)
    LD   E, A
    LD   B, 8
__LoopRuleBits: ; Loop through each bit of the rule byte AND  store it cache[0..7]
    RR   E
    RLA
    LD   (HL), A
    XOR  A
    INC  HL
    DJNZ __LoopRuleBits
    RET
CARuleBitCache: ; Cache for the CA rule bits
    .fill 8, 0
.endmodule ; CARule
#endif ; CARULE_ASM