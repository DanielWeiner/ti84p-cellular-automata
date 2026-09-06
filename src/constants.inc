#if undefined(CONSTANTS_INC)
#define CONSTANTS_INC

.include "ti83plus.inc"

.module Screen 
    Width = 96
    Height = 64
    WidthBytes = Width / 8
    Pixels = Width * Height
    Bytes = Pixels / 8
    Words = Bytes / 2
    Address = plotSScreen
.endmodule

.module Opcode 
    OrHL = $B6
    AndHL = $A6
    XorHL = $AE
    AndE = $A3
    OrE = $B3
.endmodule ; Opcode

.module Character
    RightArrow = $05
    LeftArrow = $CF
.endmodule ; Character

#endif ; CONSTANTS_INC