#include "platform.h"
#include <inttypes.h>
#include <stdio.h>

int main(void) {
    struct altair_state state;
    altair_reset(&state);
    altair_tick(&state, 1000);

    printf("ALTAIR 8800 / 2026 HOSTED REFERENCE\n");
    printf("Architecture model: %u-bit\n", ALTAIR_CPU_BITS);
    printf("PC=%" PRIx64 " cycles=%" PRIu64 " status=%u\n",
           state.pc, state.cycles, state.status);
    printf("Display target: %ux%u, 32 bpp\n",
           ALTAIR_DISPLAY_WIDTH, ALTAIR_DISPLAY_HEIGHT);
    printf("Framebuffer size: %" PRIu64 " bytes (single buffer)\n",
           altair_framebuffer_bytes());
    printf("Self-test: %s\n", altair_self_test(&state) ? "PASS" : "FAIL");
    return altair_self_test(&state) ? 0 : 1;
}
