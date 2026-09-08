#if undefined(MAIN_ASM)
#define MAIN_ASM

.include "ti83plus.inc"
.include "functions.inc"
.include "constants.inc"

.include "graphics.asm"
.include "glyph.asm"
.include "string.asm"
.include "caRule.asm"
.include "input.asm"
.include "ui.asm"
.include "globals.asm"

.module Main
    InitialRowSelectedFlags =  UI.RowFlags.RenderRect | UI.RowFlags.RenderLabel | UI.RowFlags.RenderSelection | UI.RowFlags.RenderSelectionArrows
    InitialRowDeselectedFlags =  UI.RowFlags.RenderLabel | UI.RowFlags.RenderSelection 
    SelectRowFlags =  UI.RowFlags.RenderRect | UI.RowFlags.RenderSelection | UI.RowFlags.RenderSelectionArrows
    DeselectRowFlags =  UI.RowFlags.RenderRect | UI.RowFlags.RenderSelection 
    SameRowFlags =  UI.RowFlags.RenderSelection | UI.RowFlags.RenderSelectionArrows
Main:
    CALL Glyph.CreateGlyphTable
    CALL Glyph.LoadGlyphs
    ; Initialize the UI state
    CALL Graphics.ClearScreenBuffer
    CALL _LoadRow0Strings
    LD   A, 0 | InitialRowSelectedFlags
    CALL UI.DrawRow
    CALL _LoadRow1Strings
    LD   A, 1 | InitialRowDeselectedFlags
    CALL UI.DrawRow
    CALL _LoadRow2Strings
    LD   A, 2 | InitialRowDeselectedFlags
    CALL UI.DrawRow
    CALL _LoadRow3Strings
    LD   A, 3 | InitialRowDeselectedFlags
    CALL UI.DrawRow
    LD   A, 0
    CALL CARule.VisualizeRule
    CALL _DrawOkButton
    CALL _FillOkButton
_DrawBuf:
    CALL Graphics.WriteScreenBuffer
_KeyLoop:
    CALL Random.UpdateSeed ; Uses input delay as a source of entropy
    CALL Input.ReadArrow
HandlerAddr = $+1
    JP _HandlerRow0
__EndMain:
    CALL CARule.DrawCA
    bcall(_GetKey)
    CALL Glyph.DeleteGlyphTable
    CALL Graphics.ClearScreenBuffer
    RET
_DrawOkButton:
    LD   HL, $0D09
    LD   DE, $5124
    LD   B, 1
    CALL Graphics.DrawRect
    LD   HL, Globals.OkStr
    LD   DE, $5425
    CALL String.Draw
    RET
_FillOkButton:
    LD   HL, $0B07
    LD   DE, $5225
    LD   B, 2
    CALL Graphics.DrawRect
    RET
_ChangeHandler: ; Changes which routine is used to handle key presses; this is more efficient and easier to manage than conditionals per key press
    LD   HL, HandlerAddr
    LD   A, E
    LD   (HL), A
    INC  HL
    LD   A, D
    LD   (HL), A
    RET

_HandlerRow0:
    CP   skRight
    JR   Z, _Row0Right
    CP   skLeft
    JR   Z, _Row0Left
    CP   skUp
    JR   Z, _Row0Up
    CP   skDown
    JR   Z, _Row0Down
    JP   _KeyLoop
_Row0Right:
    LD   A, (Globals.CARule)
    INC  A
    LD   (Globals.CARule), A
    LD   A, 1
    CALL CARule.VisualizeRule
    CALL _LoadRow0Strings
    LD   A, 0 | SameRowFlags
    CALL UI.DrawRow
    JP   _DrawBuf
_Row0Left:
    LD   A, (Globals.CARule)
    DEC  A
    LD   (Globals.CARule), A
    LD   A, 1
    CALL CARule.VisualizeRule
    CALL _LoadRow0Strings
    LD   A, 0 | SameRowFlags
    CALL UI.DrawRow
    JP   _DrawBuf
_Row0Up:
    CALL _DeselectRow0
    CALL _SelectOkButton
    JP   _DrawBuf
_Row0Down:
    CALL _DeselectRow0
    CALL _SelectRow1
    JP   _DrawBuf
    
_HandlerRow1:
    CP   skRight
    JR   Z, _Row1Right
    CP   skLeft
    JR   Z, _Row1Left
    CP   skUp
    JR   Z, _Row1Up
    CP   skDown
    JR   Z, _Row1Down
    JP   _KeyLoop
_Row1Right:
    LD   A, (Globals.Row1Selection)
    LD   B, A
    INC  A
    CP   Globals.Row1LastIndex + 1
    JR   NZ, __UpdateRow1
    XOR  A
    JR   __UpdateRow1
_Row1Left:
    LD   A, (Globals.Row1Selection)
    LD   B, A
    SUB  1
    JR   NC, __UpdateRow1
    LD   A, Globals.Row1LastIndex
__UpdateRow1:
    LD   (Globals.Row1Selection), A
    CP   Globals.RandomSelectionIndex
    JR   Z, __Row1RerenderRow2
    LD   A, B
    CP   Globals.RandomSelectionIndex
    JR   Z, __Row1RerenderRow2
__RenderRow1:
    CALL _LoadRow1Strings
    LD   A, 1 | SameRowFlags
    CALL UI.DrawRow
    JP   _DrawBuf
__Row1RerenderRow2:
    CALL _LoadRow2Strings
    LD   A, 2 | InitialRowDeselectedFlags
    CALL UI.DrawRow
    JR   __RenderRow1
_Row1Up:
    CALL _DeselectRow1
    CALL _SelectRow0
    JP   _DrawBuf
_Row1Down:
    CALL _DeselectRow1
    CALL _SelectRow2
    JP   _DrawBuf
_HandlerRow2Random:    
    CP   skRight
    JR   Z, _Row2RightRandom
    CP   skLeft
    JR   Z, _Row2LeftRandom
    JR   _HandlerRow2
_HandlerRow2Position:
    CP   skRight
    JR   Z, _Row2RightPosition
    CP   skLeft
    JR   Z, _Row2LeftPosition
_HandlerRow2:
    CP   skUp
    JR   Z, _Row2Up
    CP   skDown
    JR   Z, _Row2Down
    JP   _KeyLoop
_Row2RightPosition:
    LD   A, (Globals.Row2Selection)
    INC  A
    CP   Globals.Row2LastIndex + 1
    JR   NZ, __UpdateRow2Position
    XOR  A
    JR   __UpdateRow2Position
_Row2LeftPosition:
    LD   A, (Globals.Row2Selection)
    SUB  1
    JR   NC, __UpdateRow2Position
    LD   A, 2
    JR   __UpdateRow2Position
_Row2RightRandom:
    LD   A, (Globals.RandomSeedDensity)
    CP   100
    JP   Z, _KeyLoop
    INC  A
    JR   __UpdateRow2Random
_Row2LeftRandom:
    LD   A, (Globals.RandomSeedDensity)
    CP   0
    JP   Z, _KeyLoop
    DEC  A
    JR   __UpdateRow2Random
__UpdateRow2Position:
    LD   (Globals.Row2Selection), A
    JR   __UpdateRow2
__UpdateRow2Random:
    LD   (Globals.RandomSeedDensity), A
__UpdateRow2:
    CALL _LoadRow2Strings
    LD   A, 2 | SameRowFlags
    CALL UI.DrawRow
    JP   _DrawBuf
_Row2Up:
    CALL _DeselectRow2
    CALL _SelectRow1
    JP   _DrawBuf
_Row2Down:
    CALL _DeselectRow2
    CALL _SelectRow3
    JP   _DrawBuf

_HandlerRow3:
    CP   skRight
    JR   Z, _Row3Right
    CP   skLeft
    JR   Z, _Row3Left
    CP   skUp
    JR   Z, _Row3Up
    CP   skDown
    JR   Z, _Row3Down
    JP   _KeyLoop
_Row3Right:
    LD   A, (Globals.Row3Selection)
    INC  A
    JR   __UpdateRow3
_Row3Left:
    LD   A, (Globals.Row3Selection)
    DEC  A
__UpdateRow3:
    AND  3 ; There are four options, so just ANDing with 3 is sufficient to wrap
    LD   (Globals.Row3Selection), A
    CALL _LoadRow3Strings
    LD   A, 3 | SameRowFlags
    CALL UI.DrawRow
    JP   _DrawBuf
_Row3Up:
    CALL _DeselectRow3
    CALL _SelectRow2
    JP   _DrawBuf
_Row3Down:
    CALL _DeselectRow3
    CALL _SelectOkButton
    JP   _DrawBuf

_HandlerOkButton:
    CP   skUp
    JR   Z, _OkButtonUp
    CP   skDown
    JR   Z, _OkButtonDown
    CALL Input.ReadEnter
    CP   skEnter
    JP   Z, __EndMain
    JP   _KeyLoop
_OkButtonUp:
    CALL _SelectRow3
    CALL _FillOkButton
    JP   _DrawBuf
_OkButtonDown:
    CALL _SelectRow0
    CALL _FillOkButton
    JP   _DrawBuf
_SelectRow0:
    CALL _LoadRow0Strings
    LD   A, 0 | SelectRowFlags
    CALL UI.DrawRow
    LD   DE, _HandlerRow0
    CALL _ChangeHandler
    RET

_DeselectRow0:
    CALL _LoadRow0Strings
    LD   A, 0 | DeselectRowFlags
    CALL UI.DrawRow
    RET
_LoadRow0Strings:
    LD   A, (Globals.CARule)
    LD   H, 0
    LD   L, A
    CALL String.ConvertHLToDigitString
    EX   DE, HL
    LD   HL, Globals.RuleStr
    RET

_SelectRow1:
    CALL _LoadRow1Strings
    LD   A, 1 | SelectRowFlags
    CALL UI.DrawRow
    LD   DE, _HandlerRow1
    CALL _ChangeHandler
    RET

_DeselectRow1:
    CALL _LoadRow1Strings
    LD   A, 1 | DeselectRowFlags
    CALL UI.DrawRow
    RET
_LoadRow1Strings:
    LD   DE, Globals.SeedStr
    LD   HL, Globals.Row1Selections
    LD   B, 0
    LD   A, (Globals.Row1Selection)
    SLA  A
    LD   C, A
    ADD  HL, BC
    LD   A, (HL)
    INC  HL
    LD   H, (HL)
    LD   L, A
    EX   DE, HL
    RET

_SelectRow2:
    CALL _LoadRow2Strings
    LD   A, 2 | SelectRowFlags
    CALL UI.DrawRow
    LD   A, (Globals.Row1Selection)
    CP   Globals.RandomSelectionIndex
    JR   Z, __SelectRow2Random
    LD   DE, _HandlerRow2Position
    JR   __SelectRow2Done
__SelectRow2Random:
    LD   DE, _HandlerRow2Random
__SelectRow2Done:
    CALL _ChangeHandler
    RET
_DeselectRow2:
    CALL _LoadRow2Strings
    LD   A, 2 | DeselectRowFlags
    CALL UI.DrawRow
    RET
_LoadRow2Strings:
    LD   A, (Globals.Row1Selection)
    CP   Globals.RandomSelectionIndex
    JR   Z, __Row2RandomDensitySelected
    LD   DE, Globals.PositionStr
    LD   HL, Globals.Row2Selections
    LD   B, 0
    LD   A, (Globals.Row2Selection)
    SLA  A
    LD   C, A
    ADD  HL, BC
    LD   A, (HL)
    INC  HL
    LD   H, (HL)
    LD   L, A
    EX   DE, HL
    RET
__Row2RandomDensitySelected:
    LD   A, (Globals.RandomSeedDensity)
    LD   H, 0
    LD   L, A
    CALL String.ConvertHLToDigitString
    LD   DE, Globals.FilledPercentStr
    EX   DE, HL
    RET

_SelectRow3:
    CALL _LoadRow3Strings
    LD   A, 3 | SelectRowFlags
    CALL UI.DrawRow
    LD   DE, _HandlerRow3
    CALL _ChangeHandler
    RET

_DeselectRow3:
    CALL _LoadRow3Strings
    LD   A, 3 | DeselectRowFlags
    CALL UI.DrawRow
    RET
_LoadRow3Strings:
    LD   DE, Globals.EdgesStr
    LD   HL, Globals.Row3Selections
    LD   B, 0
    LD   A, (Globals.Row3Selection)
    SLA  A
    LD   C, A
    ADD  HL, BC
    LD   A, (HL)
    INC  HL
    LD   H, (HL)
    LD   L, A
    EX   DE, HL
    RET
_SelectOkButton:
    CALL _DrawOkButton
    LD   DE, _HandlerOkButton
    CALL _ChangeHandler
    RET



.endmodule ; Main
#endif ; MAIN_ASM