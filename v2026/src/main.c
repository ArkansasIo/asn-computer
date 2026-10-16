#include "platform.h"
#include <stdio.h>
#include <inttypes.h>

extern uint32_t cpu_enable_features(void);
extern uint32_t display_4k_mode(void);
extern uint64_t display_frame_bytes(void);
extern uint32_t frontpanel_mask_address(uint32_t);
extern uint32_t frontpanel_mask_data(uint32_t);
extern uint32_t frontpanel_set_switches(uint32_t);
extern uint32_t i8080_step(uint32_t);

void altair_runtime_init(void) {
    struct altair_state state;
    altair_reset(&state);
    cpu_enable_features();
    printf("ALTAIR 8800 / 2026 64-BIT\n");
    printf("4K mode: 0x%X, framebuffer: %" PRIu64 " bytes\n",
           display_4k_mode(), display_frame_bytes());
    printf("Front panel: A=%04X D=%02X SW=%04X\n",
           frontpanel_mask_address((uint32_t)state.address),
           frontpanel_mask_data((uint32_t)state.data),
           frontpanel_set_switches(state.switches));
    printf("8080 NOP class=%u\n", i8080_step(0x00));
}

int main(void) {
    struct altair_state state;
    altair_reset(&state);
    altair_tick(&state, 1000);
    printf("ALTAIR 8800 / 2026 64-BIT HOSTED TEST\n");
    printf("PC=%" PRIx64 " cycles=%" PRIu64 " status=%u\n",
           state.pc, state.cycles, state.status);
    printf("Self-test: %s\n", altair_self_test(&state) ? "PASS" : "FAIL");
    altair_runtime_init();
    return altair_self_test(&state) ? 0 : 1;
}
