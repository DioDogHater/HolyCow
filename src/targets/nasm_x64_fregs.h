#ifndef NASM_x64_FREGS_H
#define NASM_x64_FREGS_H

#include "../generator/target_requirements.h"

#undef FREG_COUNT
#define FREG_COUNT 16

#define DEFINE_XMM_REG(n) \
freg_t xmm##n##_ss[2] = {FREG("xmm" #n, false, NULL), NULL_FREG};
#define XMM_REG(n) FREG("xmm" #n, true, xmm##n##_ss)

DEFINE_XMM_REG(0)
DEFINE_XMM_REG(1)
DEFINE_XMM_REG(2)
DEFINE_XMM_REG(3)
DEFINE_XMM_REG(4)
DEFINE_XMM_REG(5)
DEFINE_XMM_REG(6)
DEFINE_XMM_REG(7)
DEFINE_XMM_REG(8)
DEFINE_XMM_REG(9)
DEFINE_XMM_REG(10)
DEFINE_XMM_REG(11)
DEFINE_XMM_REG(12)
DEFINE_XMM_REG(13)
DEFINE_XMM_REG(14)
DEFINE_XMM_REG(15)

freg_t fregs[FREG_COUNT + 1] = {
    XMM_REG(0),
    XMM_REG(1),
    XMM_REG(2),
    XMM_REG(3),
    XMM_REG(4),
    XMM_REG(5),
    XMM_REG(6),
    XMM_REG(7),
    XMM_REG(8),
    XMM_REG(9),
    XMM_REG(10),
    XMM_REG(11),
    XMM_REG(12),
    XMM_REG(13),
    XMM_REG(14),
    XMM_REG(15),
    NULL_FREG
};

#endif
