
#if undefined(FUNCTIONS_INC)
#define FUNCTIONS_INC
.include "constants.inc"

.function lbps(str)
    .db strlength(str), str
.endfunction

#endif ; FUNCTIONS_INC
