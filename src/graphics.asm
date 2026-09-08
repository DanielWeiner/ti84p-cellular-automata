#if undefined(GRAPHICS_ASM)
#define GRAPHICS_ASM

.include "constants.inc"

.module Graphics
    __LCD_BUSY_QUICK = $000B
WriteScreenBuffer:
    DI
    LD   HL, Screen.Address
    LD   A, $80           ; Set row 0
    OUT  ($10), A
    
    LD   C, $20-1         ; C will hold column

__ScreenBufferRow:
    INC  C
    LD   A, C
    CP   $2C             ; See if C exceeded maximum column value
    JR   Z, __EndScreenBuffer

    CALL __LCD_BUSY_QUICK
    OUT  ($10), A         ; Set column

    LD   B, 63            ; 63 display rows to a picture
    LD   DE, 12           ; Because LCD is read in column-major order, 
                            ; and picture data is in row-major order.

__ScreenBufferColumn:
    CALL __LCD_BUSY_QUICK
    LD   A, (HL)
    OUT  ($11), A         ; Write one byte to the LCD
    ADD  HL, DE
    DJNZ __ScreenBufferColumn

    CALL __LCD_BUSY_QUICK      ; Restart at row 0
    LD   A, $80
    OUT  ($10), A

    LD   DE, -(12 * 63) + 1    ; -(12*63) returns to the first row.
    ADD  HL, DE                ; + 1 moves one column over.
    JR   __ScreenBufferRow
__EndScreenBuffer:
    EI
    RET

ClearScreenBuffer:
    LD DE, Screen.Address + 1
    LD HL, Screen.Address
    XOR A
    LD (HL), A
    LD BC, Screen.Bytes - 1
    LDIR
    RET

DrawRectWhite = 0
DrawRectBlack = 1
DrawRectXor   = 2
DrawRectWhiteOpcode = Opcode.AndHL
DrawRectBlackOpcode = Opcode.OrHL
DrawRectXorOpcode   = Opcode.XorHL
DrawRect: ; D = x, E = y, H = length, L = height, B = 0: white, 1: black, 2: xor, default: black, Destroys all registers
    XOR  A          ; clear A
    OR   H          ; check if length is zero
    RET  Z          ; return if length is zero
    XOR  A
    OR   L          ; check if height is zero
    RET  Z          ; return if height is zero
    LD   A, Screen.Height - 1
    SUB  E          ; check if y is out of bounds
    RET  C          ; return if y is out of bounds
    INC  A          ; include the current pixel in the height calculation
    CP   L          ; check if the line height exceeds the remaining height
    JR   NC, $+3    ; Skip the clamping if the line height is within the remaining height
    LD   L, A
    LD   A, L
    LD   (__Height), A

    LD   A, Screen.Width - 1
    SUB  D          ; check if x is out of bounds
    RET  C          ; return if x is out of bounds
    INC  A          ; include the current pixel in the width calculation
    CP   H          ; check if the line length exceeds the remaining width
    JR   NC, $+3    ; Skip the clamping if the line length is within the remaining width
    LD   H, A       ; clamp the line length to the remaining width
    LD   C, H       ; C = length
    LD   A, B       ; Calculate the operation based on the color in B
    CP   DrawRectWhite
    JR   Z, __SetOperationWhite ; White byte = ~mask AND data
    CP   DrawRectBlack
    JR   Z, __SetOperationBlack ; Black byte = mask OR data
    CP   DrawRectXor
    JR   Z, __SetOperationXor   ; XOR byte = mask XOR data (flips color)
__SetOperationBlack:
    LD   A, DrawRectBlackOpcode
    JR   __SaveOperation
__SetOperationWhite:
    LD   A, DrawRectWhiteOpcode
    JR   __SaveOperation
__SetOperationXor:
    LD   A, DrawRectXorOpcode
__SaveOperation:
    LD   (__Operation), A
    ; Convert x,y to screen address
    LD   A, D           ; A = x
    LD   H, 0 
    LD   D, H
    LD   L, E           ; HL and DE = y
    ADD  HL, HL         ; HL = 2 * y
    ADD  HL, DE         ; HL = 3 * y
    ADD  HL, HL         ; HL = 6 * y
    ADD  HL, HL         ; HL = 12 * y
    LD   E, A           ; E = x
    SRL  E              ; E = x / 2
    SRL  E              ; E = x / 4
    SRL  E              ; E = x / 8 
                        ; DE = byte offset
    AND  7              ; A = x % 8 (bit offset)
    ADD  HL, DE         ; HL = screen address offset
    LD   DE, Screen.Address 
    ADD  HL, DE         ; HL = final screen address

    LD   D, B           ; D = color
    LD   E, A           ; Bit offset in E to use later in calculating low bit offset
    
    OR   A              ; Check if we need to shift
    LD   A, $FF         ; Start with all bits set
    JR   Z, $+7         ; Z from the OR A instruction. If no shift is needed, skip the shift
    LD   B, E           ; Shift high mask to the offset
__ShiftHighMask:
    SRL  A              ; shift 0's right to create the high mask
    DJNZ __ShiftHighMask
    LD   (__HighMask), A
    LD   A, E           ; High bit offset in A
    ADD  A, C           ; add length to bit offset
    AND  7              ; A = (bit offset + length) % 8 = low bit offset of pixel following end of line
    LD   B, A           ; Store low bit offset in B
    OR   A              ; Check if we need to shift for the low mask
    LD   A, $FF         ; Start with all bits set for the low mask
    JR   Z, $+6         ; Z comes from the OR A instruction. If no shift is needed, skip the shift
__ShiftLowMask:
    SRL  A              ; shift 0's right to create the low mask
    DJNZ __ShiftLowMask
    CPL                 ; invert the bits - now it's 1's up to but not including the pixel following the end of the line
    LD   (__LowMask), A ; Store the low mask
    LD   A, E           ; A = original bit offset
    ADD  A, C           ; A = original bit offset + length
    LD   B, A           ; Store the total bit offset for later use
__HighMask = $+1
    LD   D, 0
__LowMask = $+1
    LD   E, 0
__Operation = $+1
    LD   C, 0
    LD   A, C
    CP   DrawRectWhiteOpcode
    JR   NZ, __NoInvertMasks
    ; For white, AND is used to preserve only the bits outside the line, while zeroing the bits within
    LD   A, D
    CPL
    LD   D, A
    LD   A, E
    CPL
    LD   E, A
__NoInvertMasks:
    LD   A, B ; A = total bit offset
__Height = $+1
    LD   B, 0
    SRL  A
    SRL  A
    SRL  A
    SUB  1            ; Middle bytes is (length + offset) / 8, minus the first byte
    JR   C, __OneByte ; If the line fits within one byte and is not a full byte, handle it as a special case
    JR   Z, __TwoBytes
    PUSH AF
    LD   A, B
    LD   (__MultiByteSetHeight), A
    POP  AF
    LD   B, A                     ; Store the number of middle bytes in B
    LD   A, Screen.WidthBytes - 1 ; adjust the row span for the middle bytes so we know where the next row starts
    SUB  B

    LD   (__MultiByteRowSpan), A
    LD   A, C
    LD   (__MultiByteHighOperation),   A
    LD   (__MultiByteMiddleOperation), A
    LD   (__MultiByteLowOperation),    A
__MultiByteSetHeight = $+1
    LD   C, 0
    CP   DrawRectWhiteOpcode
    JR   NZ, _WriteMultiByteNotWhite ; If not white, skip the mask inversion
    XOR  A
    LD   (__MultiByteMiddleValue), A
    JR   __WriteMultiByte
_WriteMultiByteNotWhite:
    LD   A, $FF
    LD   (__MultiByteMiddleValue), A
__WriteMultiByte:
    PUSH BC   ; Save height and middle bytes

    LD   A, D ; High mask
__MultiByteHighOperation: ; Write the first byte in the row
    OR   (HL)
    LD   (HL), A
    INC  HL
__MiddleByteLoop:
__MultiByteMiddleValue = $+1 ; $FF for black and XOR, $00 for white
    LD   A, 0
__MultiByteMiddleOperation: ; Write the subsequent middle bytes in the row
    OR   (HL)
    LD   (HL), A
    INC  HL
    DJNZ __MiddleByteLoop

    LD   A, E               ; Low mask
__MultiByteLowOperation:    ; Write the last byte in the row
    OR   (HL)
    LD   (HL), A
__MultiByteRowSpan = $+1
    LD   C, 0               ; B is zero after the middle byte loop, and C contains the row span
    ADD  HL, BC             ; Advance to the next row, using the adjusted row span

    POP  BC                 ; Restore middle bytes and decrement height counter
    DEC  C
    JR   NZ, __WriteMultiByte
    RET
__OneByte:                       ; Line fits in a single byte, so combine high and low masks into one operation
    LD   A, C
    LD   (__OneByteOperation), A ; Operation against combined mask
    CP   DrawRectWhiteOpcode     ; Check which operation to combine masks with
    JR   NZ, __OneByteNotWhite   ; OR for black and XOR, AND for white
    LD   A, Opcode.OrE
    JR   __OneByteCombine
__OneByteNotWhite:
    LD   A, Opcode.AndE
__OneByteCombine:
    LD   (__OneByteComboOperation), A
    LD   A, D
__OneByteComboOperation:
    OR   E
    LD   C, A                  ; C contains the combined mask for the one-byte operation
    LD   DE, Screen.WidthBytes ; DE is added to HL to move to the next row after one byte
__OneByteLoop: ; Loop over height, writing one byte each time
    LD   A, C
__OneByteOperation:
    OR   (HL)
    LD   (HL), A
    ADD  HL, DE
    DJNZ __OneByteLoop
    RET
__TwoBytes: ; Line fits in two bytes, no middle byte loop 
    LD   A, C
    LD   (__TwoBytesHighOperation), A
    LD   (__TwoBytesLowOperation), A
    ; Avoid a push-pop by restoring masks to DE via SMC at each iteration
    LD   A, E
    LD   (__TwoByteMasks), A
    LD   A, D
    LD   (__TwoByteMasks+1), A
__WriteTwoBytes:
    LD   A, D
__TwoBytesHighOperation:
    OR   (HL)
    LD   (HL), A 
    INC  HL
    LD   A, E
__TwoBytesLowOperation:
    OR   (HL)
    LD   (HL), A
    LD   DE, Screen.WidthBytes - 1
    ADD  HL, DE
__TwoByteMasks = $+1
    LD   DE, 0
    DJNZ __WriteTwoBytes
    RET

DrawSprite:      ; HL = sprite address, D = x, E = y, Destroys BC, DE, HL, A
    LD   A, Screen.Width
    SUB  (HL)    ; Max x must be less than Screen.Width - sprite width
    INC  HL      ; Move to sprite height
    LD   C, A    ; C contains max x
    LD   A, D    ; Restore x to A
    CP   C
    RET  NC      ; If x >= max x, invalid, return
    LD   A, Screen.Height
    SUB  (HL)    ; Max y must be less than Screen.Height - sprite height
    LD   C, A    ; C contains max y
    LD   A, E    ; Restore y to A
    CP   C
    RET  NC      ; If y >= max y, invalid, return
    LD   A, D    ; Resore x to A
    PUSH HL      ; Store sprite height address

    ; Find the screen address to draw
    LD   H, 0
    LD   L, E    ; HL = y
    LD   D, H
    LD   E, L    ; DE = HL
    ADD  HL, HL  ; HL = 2y
    ADD  HL, DE  ; HL = 3y
    ADD  HL, HL  ; HL = 6y
    ADD  HL, HL  ; HL = 12y
    LD   E, A    ; E = x
    SRL  E
    SRL  E
    SRL  E       ; DE = byte offset
    AND  7       ; A = bit offset
    ADD  HL, DE  ; HL = pixel offset
    LD   DE, Screen.Address
    ADD  HL, DE  ; HL = screen pixel address
    EX   DE, HL  ; DE = screen pixel address
    POP  HL      ; HL = sprite height address
    OR   A       ; Check if bit offset is 0
    JR   Z, __DrawSpriteAligned
    DEC  HL      ; HL = sprite width address
    LD   C, A    ; C = bit offset
    LD   A, (HL) ; A = sprite width
    INC  HL;     ; HL = sprite height address
    ADD  A, C    ; A = sprite width + bit offset
    CP   8       ; Check if sprite width + bit offset <= 8
    JR   C, __DrawSpriteNotAlignedSingleByte ; If so, draw single byte
__DrawSpriteNotAlignedTwoBytes:
    LD   B, (HL) ; B = sprite height counter
    INC  HL      ; HL = Sprite data address
    EX   DE, HL  ; HL = screen pixel address, DE = sprite data address
__DrawRowNotAlignedTwoBytes:
    PUSH BC
    LD   A, (DE) ; A = sprite data
    INC  DE   
    LD   B, C    ; B = bit offset
    LD   C, 0    ; C = second byte
__ShiftSpriteDataTwoBytes:
    SRL  A
    RR   C
    DJNZ __ShiftSpriteDataTwoBytes
    XOR  (HL)    ; Add sprite data to screen pixel data
    LD   (HL), A ; Store back to screen pixel data
    INC  HL      ; Move to next screen pixel address
    LD   A, C    ; A = second byte
    XOR  (HL)    ; Add second byte to screen pixel data
    LD   (HL), A ; Store back to screen pixel data
    LD   BC, Screen.WidthBytes - 1
    ADD  HL, BC  ; Move to next screen pixel address
    POP  BC
    DJNZ __DrawRowNotAlignedTwoBytes
    RET
__DrawSpriteNotAlignedSingleByte:
    LD   B, (HL) ; B = sprite height counter
    INC  HL      ; HL = Sprite data address
    EX   DE, HL  ; HL = screen pixel address, DE = sprite data address
__DrawRowNotAlignedSingleByte:
    PUSH  BC
    LD   A, (DE) ; A = sprite data
    INC  DE
    LD   B, C    ; B = bit offset
__ShiftSpriteDataSingleByte:
    SRL  A
    DJNZ __ShiftSpriteDataSingleByte
    XOR  (HL)    ; Add sprite data to screen pixel data
    LD   (HL), A ; Store back to screen pixel data
    LD   BC, Screen.WidthBytes
    ADD  HL, BC  ; Move to next screen pixel address
    POP  BC
    DJNZ __DrawRowNotAlignedSingleByte
    RET
__DrawSpriteAligned:
    LD   B, (HL) ; B = sprite height counter 
    INC  HL      ; HL = Sprite data address
    EX   DE, HL  ; HL = screen pixel address, DE = sprite data address
__DrawRowAligned:
    PUSH BC
    LD   A, (DE) ; A = sprite data
    INC  DE
    XOR  (HL)    ; Add sprite data to screen pixel data
    LD   (HL), A ; Store back to screen pixel data
    LD   BC, Screen.WidthBytes
    ADD  HL, BC  ; Move to next screen pixel address
    POP  BC
    DJNZ __DrawRowAligned
    RET
EmptySquareSprite:
    .db 4
    .db 4
    .db %01010000
    .db %10100000
    .db %01010000
    .db %10100000
    
FilledSquareSprite:
    .db 4
    .db 4
    .db %11110000
    .db %11110000
    .db %11110000
    .db %11110000
DashSprite:
    .db 4
    .db 1
    .db %1111000
.endmodule ; Graphics
#endif ; GRAPHICS_ASM