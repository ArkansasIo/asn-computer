#include "platform.h"
#include <string.h>

void altair_reset(struct altair_state *s) {
    if (!s) return;
    memset(s, 0, sizeof(*s));
    s->status = ALTAIR_STATUS_READY;
    s->display_mode = ALTAIR_DISPLAY_WIDTH;
}

void altair_tick(struct altair_state *s, uint64_t cycles) {
    if (!s) return;
    s->cycles += cycles;
    s->pc += cycles;
    s->address = s->pc & 0xFFFFu;
    s->data = (s->pc ^ s->cycles) & 0xFFu;
}

uint64_t altair_framebuffer_bytes(void) {
    return (uint64_t)ALTAIR_DISPLAY_WIDTH *
           (uint64_t)ALTAIR_DISPLAY_HEIGHT *
           (uint64_t)(ALTAIR_DISPLAY_BPP / 8u);
}

int altair_self_test(struct altair_state *s) {
    if (!s) return 0;
    if (s->display_mode != ALTAIR_DISPLAY_WIDTH) return 0;
    if (ALTAIR_CPU_BITS != 64u || ALTAIR_ADDR_BITS != 64u) return 0;
    if (ALTAIR_DISPLAY_WIDTH != 3840u || ALTAIR_DISPLAY_HEIGHT != 2160u) return 0;
    if (altair_framebuffer_bytes() != UINT64_C(33177600)) return 0;
    return 1;
}
