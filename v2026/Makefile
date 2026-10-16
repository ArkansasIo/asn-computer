NASM ?= nasm
CC ?= cc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Wpedantic
LDFLAGS ?=

BUILD=build
ASMOBJ=$(BUILD)/boot64.o $(BUILD)/cpu.o $(BUILD)/memory.o $(BUILD)/io.o $(BUILD)/display.o $(BUILD)/frontpanel.o
COBJ=$(BUILD)/main.o $(BUILD)/platform.o

all: $(BUILD)/altair2026

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: asm/%.asm | $(BUILD)
	$(NASM) -f elf64 $< -o $@

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

$(BUILD)/altair2026: $(ASMOBJ) $(COBJ)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	rm -rf $(BUILD)

.PHONY: all clean
