#if undefined(GLOBALS_ASM)
#define GLOBALS_ASM
.define relIndex(selections) ($ - selections) / 2
.define lastIndex(selections) ($ - 2 - selections) / 2
.module Globals
Row1Selection:
    .db 0
Row1Selections:
OneCellSelection = relIndex(Row1Selections)
    .dw OneCellStr
OneCellInverseSelection = relIndex(Row1Selections)
    .dw OneCellInverseStr
RandomSelection:
RandomSelectionIndex = relIndex(Row1Selections)
    .dw RandomStr
Row1LastIndex = lastIndex(Row1Selections)

Row2Selection:
    .db 0

Row2Selections:
CenterSelection = relIndex(Row2Selections)
    .dw CenterStr
RightSelection = relIndex(Row2Selections)
    .dw RightStr
LeftSelection = relIndex(Row2Selections)
    .dw LeftStr
Row2LastIndex = lastIndex(Row2Selections)

Row3Selection:
    .db 0
Row3Selections:
WrapSelection = relIndex(Row3Selections)
    .dw WrapStr
MatchEdgeSelection = relIndex(Row3Selections)
    .dw MatchEdgeStr
BlackSelection = relIndex(Row3Selections)
    .dw BlackStr
WhiteSelection = relIndex(Row3Selections)
    .dw WhiteStr
Row3LastIndex = lastIndex(Row3Selections)

RandomSeedDensity:
    .db 50
; When producing random pixels, the pixel density is calculated as follows:
; If density percent is 100, then all pixels will be produced.
; If PercentageTable[density percent] > random value, then produce the pixel.
PercentageTable:
    .for i = 0 to 99
        .db i * 256 / 100 
    .loop

CARule: 
    .db 30

RuleStr: 
    lbps('Rule:')
SeedStr:
    lbps('Seed:')
PositionStr:
    lbps('Position:')
EdgesStr:
    lbps('Edges:')
FilledPercentStr:
    lbps('Filled cells %:')
OkStr:
    lbps('Ok')
OneCellStr:
    lbps('One cell')
OneCellInverseStr:
    lbps('One cell, inverse')
RandomStr:
    lbps('Random')
LeftStr:
    lbps('Left')
CenterStr:
    lbps('Center')
RightStr:
    lbps('Right')
BlackStr:
    lbps('Black')
WhiteStr:
    lbps('White')
MatchEdgeStr:
    lbps('Match edge')
WrapStr:
    lbps('Wrap')

.endmodule

#endif