#ifndef ALTAIR2026_PLATFORM_H
#define ALTAIR2026_PLATFORM_H

#include <stdint.h>

#define ALTAIR_YEAR 2026u
#define ALTAIR_CPU_BITS 64u
#define ALTAIR_ADDR_BITS 64u
#define ALTAIR_PAGE_SIZE 4096u
#define ALTAIR_DISPLAY_WIDTH 3840u
#define ALTAIR_DISPLAY_HEIGHT 2160u
#define ALTAIR_DISPLAY_BPP 32u
#define ALTAIR_S100_SLOTS 10u
#define ALTAIR_FRONT_SWITCHES 16u
#define ALTAIR_ADDRESS_LEDS 16u
#define ALTAIR_DATA_LEDS 8u
#define ALTAIR_NVME_LANES 4u
#define ALTAIR_PCIE_GEN 4u
#define ALTAIR_DDR5_MT 5600u
#define ALTAIR_STATUS_READY 1u

struct altair_state {
    uint64_t pc;
    uint64_t cycles;
    uint64_t address;
    uint64_t data;
    uint16_t switches;
    uint32_t status;
    uint32_t display_mode;
};

void altair_reset(struct altair_state *s);
void altair_tick(struct altair_state *s, uint64_t cycles);
uint64_t altair_framebuffer_bytes(void);
int altair_self_test(struct altair_state *s);

#endif
