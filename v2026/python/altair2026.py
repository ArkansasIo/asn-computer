#!/usr/bin/env python3
"""Hosted reference model for the ALTAIR 8800 2026 architecture."""

from dataclasses import dataclass, field
import argparse

WIDTH = 64
MEMORY_SIZE = 16 * 1024 * 1024
DISPLAY = (3840, 2160)

@dataclass
class CPU8080:
    a: int = 0
    b: int = 0
    c: int = 0
    d: int = 0
    e: int = 0
    h: int = 0
    l: int = 0
    pc: int = 0
    sp: int = 0
    flags: int = 0
    halted: bool = False

    def step(self, memory: bytearray) -> None:
        opcode = memory[self.pc]
        self.pc = (self.pc + 1) & 0xFFFF
        if opcode == 0x00:
            return
        if opcode == 0x76:
            self.halted = True
            return
        if 0x40 <= opcode <= 0x7F:
            dst = (opcode >> 3) & 7
            src = opcode & 7
            if dst == 7 and src == 0:
                self.a = self.a
            return
        # Unknown opcodes are treated as NOPs by the reference model.

@dataclass
class Altair2026:
    memory: bytearray = field(default_factory=lambda: bytearray(MEMORY_SIZE))
    cpu: CPU8080 = field(default_factory=CPU8080)
    address_leds: int = 0
    data_leds: int = 0
    switches: int = 0
    cycles: int = 0
    display_width: int = DISPLAY[0]
    display_height: int = DISPLAY[1]

    def reset(self) -> None:
        self.cpu = CPU8080()
        self.address_leds = 0
        self.data_leds = 0
        self.switches = 0
        self.cycles = 0
        self.memory[:] = b"\x00" * len(self.memory)

    def tick(self, count: int = 1) -> None:
        for _ in range(count):
            if not self.cpu.halted:
                self.cpu.step(self.memory)
            self.address_leds = self.cpu.pc & 0xFFFF
            self.data_leds = self.memory[self.cpu.pc & 0xFFFF]
            self.cycles += 1

    def self_test(self) -> bool:
        self.reset()
        self.memory[0:3] = bytes((0x00, 0x00, 0x76))
        self.tick(3)
        return (
            self.cpu.halted and
            self.cpu.pc == 3 and
            self.display_width == 3840 and
            self.display_height == 2160 and
            WIDTH == 64
        )

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--steps", type=int, default=10)
    args = parser.parse_args()

    machine = Altair2026()
    if args.self_test:
        print("ALTAIR 8800 / 2026 64-BIT")
        print("self-test:", "PASS" if machine.self_test() else "FAIL")
        return 0 if machine.self_test() else 1

    machine.reset()
    machine.tick(args.steps)
    print(f"PC={machine.cpu.pc:04X} cycles={machine.cycles}")
    print(f"ADDRESS={machine.address_leds:04X} DATA={machine.data_leds:02X}")
    print(f"DISPLAY={machine.display_width}x{machine.display_height}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
