CC ?= cc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Wpedantic -Werror
BUILD := build
SOURCES := src/main.c src/platform.c
OBJECTS := $(SOURCES:src/%.c=$(BUILD)/%.o)

.PHONY: all test clean
all: $(BUILD)/altair2026

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c include/platform.h | $(BUILD)
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

$(BUILD)/altair2026: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@

test: $(BUILD)/altair2026
	./$(BUILD)/altair2026
	python3 -m unittest discover -s tests -p 'test_*.py'

clean:
	rm -rf $(BUILD)
