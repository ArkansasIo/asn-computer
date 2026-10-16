#include "platform.h"
#include <assert.h>
#include <stdio.h>

int main(void) {
    struct altair_state state;
    altair_reset(&state);
    assert(state.pc == 0);
    assert(state.cycles == 0);
    assert(state.status == ALTAIR_STATUS_READY);
    assert(altair_self_test(&state));

    altair_tick(&state, 7);
    assert(state.pc == 7);
    assert(state.cycles == 7);
    assert(state.address == 7);
    assert(state.data == 0);

    assert(altair_framebuffer_bytes() == UINT64_C(33177600));
    altair_tick(NULL, 100);
    altair_reset(NULL);
    puts("platform tests: PASS");
    return 0;
}
