
#if undefined(RANDOM_ASM)
#define RANDOM_ASM
.module Random
UpdateSeed:
    LD HL, (Seed)
    INC HL
    LD (Seed), HL
    RET
GenerateWord: ; Generates a psuedo-random 16-bit word in HL. Destroys AF, DE
; See https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random#Combined_LFSR.2FLCG.2C_32-bit_seeds
Seed = $+1
    LD HL, 0 ; Seed is generated using input delay as a source of entropy
    LD D, H
    LD E, L
    ADD HL, HL
    ADD HL, HL
    INC L
    ADD HL, DE
    LD (Seed), HL
Seed2 = $+1
    LD HL, 25771 ; Some arbitrary non-zero seed is used here
    ADD HL, HL
    SBC A, A
    AND %00101101
    XOR L
    LD L, A
    LD (Seed2), HL
    ADD HL, DE
    RET
.endmodule ; Random
#endif ; RANDOM_ASM
