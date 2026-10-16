#include "platform.h"
#include <string.h>

void altair_reset(struct altair_state *s) {
    memset(s, 0, sizeof(*s));
    s->status = 1u;
    s->display_mode = 0x4B60u;
}

void altair_tick(struct altair_state *s, uint64_t cycles) {
    s->cycles += cycles;
    s->pc += cycles;
    s->address = s->pc & 0xFFFFu;
    s->data = (s->pc ^ s->cycles) & 0xFFu;
}

int altair_self_test(struct altair_state *s) {
    if (!s) return 0;
    if (s->display_mode != 0x4B60u) return 0;
    if (ALTAIR_CPU_BITS != 64u) return 0;
    if (ALTAIR_DISPLAY_WIDTH != 3840u || ALTAIR_DISPLAY_HEIGHT != 2160u) return 0;
    return 1;
}
