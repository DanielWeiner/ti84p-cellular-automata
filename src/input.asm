#if undefined(INPUT_ASM)
#define INPUT_ASM

.include "ti83plus.inc"

.module Input
    KeyGroup6 = %10111111
ScanKeys:
    LD   B, KeyGroup6
__ReadKeysLoop:
    LD   A, B
    OUT  (1), A
    IN   A, (1)
    CP   $FF
    JR   NZ, __CalculateKey
    RRC  B
    JR   C, __ReadKeysLoop
    XOR  A
    RET
__CalculateKey: ; Calculate which key is pressed based on the key group in B
    BIT  0, B
    JR   Z, __CalculateKeyGroup0
    BIT  1, B
    JR   Z, __CalculateKeyGroup1
    BIT  2, B
    JR   Z, __CalculateKeyGroup2
    BIT  3, B
    JP Z, __CalculateKeyGroup3
    BIT  4, B
    JP Z, __CalculateKeyGroup4
    BIT  5, B
    JP Z, __CalculateKeyGroup5
    BIT  6, B
    JP Z, __CalculateKeyGroup6
    XOR  A
    RET
__CalculateKeyGroup0:
    BIT  0, A
    JR   NZ, $+5
    LD   A, skDown
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, skLeft
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, skRight
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, skUp
    RET
    XOR  A
    RET
__CalculateKeyGroup1:
    BIT  0, A
    JR   NZ, $+5
    LD   A, skEnter
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, skAdd
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, skSub
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, skMul
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skDiv
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, skPower
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skClear
    RET
    XOR  A
    RET
__CalculateKeyGroup2:
    BIT  0, A
    JR   NZ, $+5
    LD   A, skChs
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, sk3
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, sk6
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, sk9
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skLParen
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, skTan
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skVars
    RET
    XOR  A
    RET

__CalculateKeyGroup3:
    BIT  0, A
    JR   NZ, $+5
    LD   A, skDecPnt
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, sk2
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, sk5
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, sk8
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skRParen
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, skCos
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skPrgm
    RET
    BIT  7, A
    JR   NZ, $+5
    LD   A, skStat
    RET
    XOR  A
    RET

__CalculateKeyGroup4:
    BIT  0, A
    JR   NZ, $+5
    LD   A, sk0
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, sk1
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, sk4
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, sk7
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skComma
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, skSin
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skMatrix
    RET
    BIT  7, A
    JR   NZ, $+5
    LD   A, skGraphvar
    RET
    XOR  A
    RET
__CalculateKeyGroup5:
    BIT  1, A
    JR   NZ, $+5
    LD   A, skStore
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, skLn
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, skLog
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skSquare
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, skRecip
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skMath
    RET
    BIT  7, A
    JR   NZ, $+5
    LD   A, skAlpha
    RET
    XOR  A
    RET

__CalculateKeyGroup6:
    BIT  0, A
    JR   NZ, $+5
    LD   A, skGraph
    RET
    BIT  1, A
    JR   NZ, $+5
    LD   A, skTrace
    RET
    BIT  2, A
    JR   NZ, $+5
    LD   A, skZoom
    RET
    BIT  3, A
    JR   NZ, $+5
    LD   A, skWindow
    RET
    BIT  4, A
    JR   NZ, $+5
    LD   A, skYEqu
    RET
    BIT  5, A
    JR   NZ, $+5
    LD   A, sk2nd
    RET
    BIT  6, A
    JR   NZ, $+5
    LD   A, skMode
    RET
    BIT  7, A
    JR   NZ, $+5
    LD   A, skDel
    RET
    XOR  A
    RET
ReadKey: 
    CALL ScanKeys
    OR   A
    JR   Z, __NoKeyPressed
    LD   HL, 0
    LD   (__KeyUps), HL
    LD   B, A
    LD   A, (__DebouncedLastKey)
    CP   B
    JR   NZ, __KeyChanged ; If the key has changed, handle the key change immediately
    LD   HL, (__Bounces)  ; Check for bounces if key is unchanged. This allows the user to tap the key while avoiding duplicate presses
    LD   A, H
    CP   $0E              ; Count the bounces if key is unchanged. Bounce threshold is $0F00 (we don't care about the lower byte)
    LD   A, B
    RET  NC ; If the key is unchanged and the bounce threshold is met, report the key as pressed
    INC  HL               ; Increment the bounce counter if under the threshold
    LD   (__Bounces), HL  
    XOR  A                ; Report no key pressed until the debouncing threshold is met, at which point the key is held and each press is returned
    JR   ReadKey
__NoKeyPressed:
    LD   HL, (__KeyUps)
    LD   A, H
    CP   $01              ; Key may bounce between up and down at the beginning of the press, so wait for multiple key ups to be sure
    JR   NC, __DefiniteKeyUp
    INC  HL
    LD   (__KeyUps), HL
    XOR  A
    RET
__DefiniteKeyUp:         ; Key is definitely up
    LD   A, $FF
    SBC  HL, HL
    LD   (__DebouncedLastKey), A
    LD   (__Bounces), HL
    XOR  A
    RET
__KeyChanged:
    LD   A, B
    LD   (__DebouncedLastKey), A ; Update the last debounced key value
    LD   HL, 0
    LD   (__Bounces), HL         ; Reset the bounce counter
    RET
__KeyUps:
    .dw 0
__DebouncedLastKey:
    .db 0
__Bounces:
    .dw 0
.endmodule ; Input

#endif ; INPUT_ASM