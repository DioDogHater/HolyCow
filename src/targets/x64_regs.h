#ifndef x64_REGS_H
#define x64_REGS_H

#include "../generator/target_requirements.h"

#undef REGISTER_COUNT
#define REGISTER_COUNT 14

#define DEFINE_BASIC_REG(a, m) \
reg_t reg_##a##l[2] =  {REGISTER(#a "l", 1, (m), NULL), NULL_REG};\
reg_t reg_##a##x[2] =  {REGISTER(#a "x", 2, (m), reg_##a##l), NULL_REG};\
reg_t reg_e##a##x[2] = {REGISTER("e" #a "x", 4, (m), reg_##a##x), NULL_REG};
#define BASIC_REG(a, m) REGISTER("r" #a "x", 8, (m), reg_e##a##x)

#define DEFINE_EXTENDED_REG(n, m) \
reg_t reg_r##n##b[2] = {REGISTER("r" #n "b", 1, (m), NULL), NULL_REG};\
reg_t reg_r##n##w[2] = {REGISTER("r" #n "w", 2, (m), reg_r##n##b), NULL_REG};\
reg_t reg_r##n##d[2] = {REGISTER("r" #n "d", 4, (m), reg_r##n##w), NULL_REG};
#define EXTENDED_REG(n, m) REGISTER("r" #n, 8, (m), reg_r##n##d)

#define DEFINE_RXI_REG(s, m) \
reg_t reg_##s##il[2] = {REGISTER(#s "il", 1, (m), NULL), NULL_REG};\
reg_t reg_##s##i[2] = {REGISTER(#s "i", 2, (m), reg_##s##il), NULL_REG};\
reg_t reg_e##s##i[2] = {REGISTER("e" #s "i", 4, (m), reg_##s##i), NULL_REG};
#define RXI_REG(s, m) REGISTER("r" #s "i", 8, (m), reg_e##s##i)

DEFINE_BASIC_REG(a, 0)
DEFINE_BASIC_REG(b, 1)
DEFINE_BASIC_REG(c, 2)
DEFINE_BASIC_REG(d, 3)
DEFINE_RXI_REG(s, 4)
DEFINE_RXI_REG(d, 5)
DEFINE_EXTENDED_REG(8, 6)
DEFINE_EXTENDED_REG(9, 7)
DEFINE_EXTENDED_REG(10, 8)
DEFINE_EXTENDED_REG(11, 9)
DEFINE_EXTENDED_REG(12, 10)
DEFINE_EXTENDED_REG(13, 11)
DEFINE_EXTENDED_REG(14, 12)
DEFINE_EXTENDED_REG(15, 13)

reg_t registers[REGISTER_COUNT+1] = {
    BASIC_REG(b,1),
    BASIC_REG(c,2),
    RXI_REG(s, 4),
    RXI_REG(d, 5),
    EXTENDED_REG(8, 6),
    EXTENDED_REG(9, 7),
    EXTENDED_REG(10, 8),
    EXTENDED_REG(11, 9),
    EXTENDED_REG(12, 10),
    EXTENDED_REG(13, 11),
    EXTENDED_REG(14, 12),
    EXTENDED_REG(15, 13),
    BASIC_REG(a,0),
    BASIC_REG(d,3),
    NULL_REG
};


#endif
