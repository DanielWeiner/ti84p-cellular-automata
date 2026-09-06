#if undefined(INPUT_ASM)
#define INPUT_ASM

.include "ti83plus.inc"

.module Input
    ArrowKeyGroup = %11111110
    EnterKeyGroup = %11111101

    EnterKey = %11111110

    DownKey  = %11111110
    LeftKey  = %11111101
    RightKey = %11111011
    UpKey    = %11110111

ReadEnter:
    LD A, EnterKeyGroup
    OUT (1), A
    IN A, (1)
    CP EnterKey
    JR Z, __EnterKeyPressed
    XOR A
    RET
__EnterKeyPressed:
    LD HL, $5000
    DI
__DelayLoop:
    NOP
    NOP
    NOP
    NOP
    DEC HL
    LD A, H
    OR L
    JR NZ, __DelayLoop
    EI
    LD A, skEnter
    RET
ReadArrow: 
    LD A, ArrowKeyGroup ; Load the arrow key group mask into A
    OUT (1), A ; Request key group from port 1
    IN A, (1)
    CP $FF
    JR Z, __NoKeyPressed
    LD HL, 0
    LD (__KeyUps), HL
    LD B, A
    LD A, (__DebouncedLastKey)
    CP B
    JR NZ, __KeyChanged
    LD HL, (__Bounces)
    LD A, H
    CP $0F
    JR NC, __ProcessKey
    INC HL
    LD (__Bounces), HL ; Increment the bounce counter
    XOR A
    RET
__NoKeyPressed:
    XOR A
    LD HL, (__KeyUps)
    LD A, H
    CP $02
    JR NC, __DefiniteKeyUp
    INC HL
    LD (__KeyUps), HL
    XOR A
    RET
__DefiniteKeyUp:
    LD A, $FF
    SBC HL, HL
    LD (__DebouncedLastKey), A
    LD (__Bounces), HL
    XOR A
    RET
__KeyChanged:
    LD A, B ; 
    LD (__DebouncedLastKey), A; Update the last debounced key value
    LD HL, 0
    LD (__Bounces), HL ; Reset the bounce counter
__ProcessKey:
    LD A, B
    CP DownKey
    JR Z, __DownKeyPressed
    CP LeftKey
    JR Z, __LeftKeyPressed
    CP RightKey
    JR Z, __RightKeyPressed
    CP UpKey
    JR Z, __UpKeyPressed
    XOR A
    RET
__DownKeyPressed:
    LD A, skDown
    RET

__LeftKeyPressed:
    LD A, skLeft
    RET

__RightKeyPressed:
    LD A, skRight
    RET

__UpKeyPressed:
    LD A, skUp
    RET
__KeyUps:
    .dw 0
__DebouncedLastKey:
    .db 0
__Bounces:
    .dw 0
.endmodule ; Input

#endif ; INPUT_ASM