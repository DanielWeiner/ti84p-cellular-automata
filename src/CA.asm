.include "ti83plus.inc"
.org    $9D93
.db     t2ByteTok, tasmCmp
    bcall(_ClrLCDFull)
    bcall(_HomeUp)
    bcall(_RunIndicOff)
    CALL Main.Main
    bcall(_ClrScrnFull)
    bcall(_Disp)
    RET
.include "main.asm"

