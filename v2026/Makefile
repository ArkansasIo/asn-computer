CC ?= cc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Wpedantic -Werror
BUILD := build
OBJECTS := $(BUILD)/main.o $(BUILD)/platform.o

.PHONY: all test clean
all: $(BUILD)/altair2026

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c include/platform.h | $(BUILD)
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

$(BUILD)/altair2026: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@

$(BUILD)/test_platform: tests/test_platform.c src/platform.c include/platform.h | $(BUILD)
	$(CC) $(CFLAGS) -Iinclude tests/test_platform.c src/platform.c -o $@

test: $(BUILD)/altair2026 $(BUILD)/test_platform
	./$(BUILD)/altair2026
	./$(BUILD)/test_platform
	python3 -m unittest discover -s tests -p 'test_*.py'

clean:
	rm -rf $(BUILD)
