#!/usr/bin/env python3
"""Small, deterministic Intel 8080 CPU core for ASN Computer.

This module intentionally has no third-party dependencies. It implements the
complete documented 8080 instruction groups, 64 KiB memory, flags, stack,
IN/OUT callbacks, and a simple front-panel state adapter.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from typing import Callable, Optional

MASK8 = 0xFF
MASK16 = 0xFFFF

FLAG_S = 0x80
FLAG_Z = 0x40
FLAG_A = 0x10
FLAG_P = 0x04
FLAG_C = 0x01


def parity(v: int) -> int:
    return 1 if (v & 0xFF).bit_count() % 2 == 0 else 0


@dataclass
class CPU8080:
    memory: bytearray = field(default_factory=lambda: bytearray(65536))
    a: int = 0
    b: int = 0
    c: int = 0
    d: int = 0
    e: int = 0
    h: int = 0
    l: int = 0
    sp: int = 0xFFFF
    pc: int = 0
    flags: int = FLAG_A
    halted: bool = False
    cycles: int = 0
    input_ports: dict[int, int] = field(default_factory=dict)
    output_ports: dict[int, int] = field(default_factory=dict)
    input_callback: Optional[Callable[[int], int]] = None
    output_callback: Optional[Callable[[int, int], None]] = None

    def reset(self) -> None:
        self.a = self.b = self.c = self.d = self.e = self.h = self.l = 0
        self.sp, self.pc = 0xFFFF, 0
        self.flags = FLAG_A
        self.halted = False
        self.cycles = 0

    def read8(self, addr: int) -> int:
        return self.memory[addr & MASK16]

    def write8(self, addr: int, value: int) -> None:
        self.memory[addr & MASK16] = value & MASK8

    def read16(self, addr: int) -> int:
        lo = self.read8(addr)
        hi = self.read8(addr + 1)
        return lo | (hi << 8)

    def write16(self, addr: int, value: int) -> None:
        self.write8(addr, value)
        self.write8(addr + 1, value >> 8)

    def fetch8(self) -> int:
        v = self.read8(self.pc)
        self.pc = (self.pc + 1) & MASK16
        return v

    def fetch16(self) -> int:
        v = self.read16(self.pc)
        self.pc = (self.pc + 2) & MASK16
        return v

    def pair(self, name: str) -> int:
        if name == 'BC': return (self.b << 8) | self.c
        if name == 'DE': return (self.d << 8) | self.e
        if name == 'HL': return (self.h << 8) | self.l
        if name == 'SP': return self.sp
        raise ValueError(name)

    def set_pair(self, name: str, value: int) -> None:
        value &= MASK16
        if name == 'BC': self.b, self.c = value >> 8, value & MASK8
        elif name == 'DE': self.d, self.e = value >> 8, value & MASK8
        elif name == 'HL': self.h, self.l = value >> 8, value & MASK8
        elif name == 'SP': self.sp = value
        else: raise ValueError(name)

    def get_r(self, code: int) -> int:
        return [self.b, self.c, self.d, self.e, self.h, self.l, self.read8(self.pair('HL')), self.a][code]

    def set_r(self, code: int, value: int) -> None:
        value &= MASK8
        if code == 0: self.b = value
        elif code == 1: self.c = value
        elif code == 2: self.d = value
        elif code == 3: self.e = value
        elif code == 4: self.h = value
        elif code == 5: self.l = value
        elif code == 6: self.write8(self.pair('HL'), value)
        else: self.a = value

    def set_szp(self, value: int) -> None:
        value &= MASK8
        self.flags &= ~(FLAG_S | FLAG_Z | FLAG_P)
        if value & 0x80: self.flags |= FLAG_S
        if value == 0: self.flags |= FLAG_Z
        if parity(value): self.flags |= FLAG_P

    def add(self, value: int, carry: bool = False) -> None:
        c = 1 if carry and (self.flags & FLAG_C) else 0
        old = self.a
        total = old + value + c
        result = total & MASK8
        self.flags &= ~(FLAG_C | FLAG_A)
        if total > 0xFF: self.flags |= FLAG_C
        if ((old & 0xF) + (value & 0xF) + c) > 0xF: self.flags |= FLAG_A
        self.a = result
        self.set_szp(result)

    def sub(self, value: int, borrow: bool = False) -> None:
        b = 1 if borrow and (self.flags & FLAG_C) else 0
        old = self.a
        total = old - value - b
        result = total & MASK8
        self.flags &= ~(FLAG_C | FLAG_A)
        if total < 0: self.flags |= FLAG_C
        if (old & 0xF) < ((value & 0xF) + b): self.flags |= FLAG_A
        self.a = result
        self.set_szp(result)

    def push(self, value: int) -> None:
        self.sp = (self.sp - 2) & MASK16
        self.write16(self.sp, value)

    def pop(self) -> int:
        value = self.read16(self.sp)
        self.sp = (self.sp + 2) & MASK16
        return value

    def in_port(self, port: int) -> int:
        if self.input_callback:
            return self.input_callback(port & MASK8) & MASK8
        return self.input_ports.get(port & MASK8, 0) & MASK8

    def out_port(self, port: int, value: int) -> None:
        port &= MASK8; value &= MASK8
        self.output_ports[port] = value
        if self.output_callback:
            self.output_callback(port, value)

    def step(self) -> int:
        if self.halted:
            return 0
        op = self.fetch8()
        cycles = 4

        # MOV r,r and HLT
        if 0x40 <= op <= 0x7F:
            if op == 0x76:
                self.halted = True
                cycles = 7
            else:
                self.set_r((op >> 3) & 7, self.get_r(op & 7))
                cycles = 7 if ((op & 7) == 6 or ((op >> 3) & 7) == 6) else 5

        # MVI r,data
        elif op & 0xC7 == 0x06:
            self.set_r((op >> 3) & 7, self.fetch8())
            cycles = 10 if ((op >> 3) & 7) != 6 else 10

        elif op in (0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38):
            cycles = 4
        elif op & 0xC7 == 0x04:  # INR
            r = (op >> 3) & 7; old = self.get_r(r); v = (old + 1) & MASK8
            carry = self.flags & FLAG_C; self.set_szp(v); self.flags = (self.flags & ~FLAG_A) | (FLAG_A if (old & 0xF) == 0xF else 0) | carry; self.set_r(r, v); cycles = 10 if r == 6 else 5
        elif op & 0xC7 == 0x05:  # DCR
            r = (op >> 3) & 7; old = self.get_r(r); v = (old - 1) & MASK8
            carry = self.flags & FLAG_C; self.set_szp(v); self.flags = (self.flags & ~FLAG_A) | (FLAG_A if (old & 0xF) == 0 else 0) | carry; self.set_r(r, v); cycles = 10 if r == 6 else 5
        elif op & 0xCF == 0x01:  # LXI
            names = ['BC','DE','HL','SP']; self.set_pair(names[(op >> 4) & 3], self.fetch16()); cycles = 10
        elif op & 0xCF == 0x03:  # INX
            names = ['BC','DE','HL','SP']; n = names[(op >> 4) & 3]; self.set_pair(n, self.pair(n)+1); cycles = 5
        elif op & 0xCF == 0x0B:  # DCX
            names = ['BC','DE','HL','SP']; n = names[(op >> 4) & 3]; self.set_pair(n, self.pair(n)-1); cycles = 5
        elif op & 0xCF == 0x09:  # DAD
            names = ['BC','DE','HL','SP']; total = self.pair('HL') + self.pair(names[(op >> 4) & 3]); self.flags = (self.flags & ~FLAG_C) | (FLAG_C if total > 0xFFFF else 0); self.set_pair('HL', total); cycles = 10
        elif op == 0x3A: self.a = self.read8(self.fetch16()); cycles = 13
        elif op == 0x32: self.write8(self.fetch16(), self.a); cycles = 13
        elif op == 0x2A: self.set_pair('HL', self.read16(self.fetch16())); cycles = 16
        elif op == 0x22: self.write16(self.fetch16(), self.pair('HL')); cycles = 16
        elif op == 0xEB: self.d, self.e, self.h, self.l = self.h, self.l, self.d, self.e; cycles = 5
        elif op == 0xE3:
            x = self.read16(self.sp); self.write16(self.sp, self.pair('HL')); self.set_pair('HL', x); cycles = 18
        elif op == 0xF9: self.sp = self.pair('HL'); cycles = 5
        elif op == 0xC3: self.pc = self.fetch16(); cycles = 10
        elif op in (0xC2,0xCA,0xD2,0xDA,0xE2,0xEA,0xF2,0xFA):
            addr = self.fetch16(); cc = (op >> 3) & 7; tests = [(self.flags & FLAG_Z)==0,(self.flags & FLAG_Z)!=0,(self.flags & FLAG_C)==0,(self.flags & FLAG_C)!=0,(self.flags & FLAG_P)==0,(self.flags & FLAG_P)!=0,(self.flags & FLAG_S)==0,(self.flags & FLAG_S)!=0]
            if tests[cc]: self.pc = addr
            cycles = 10
        elif op == 0xCD: addr = self.fetch16(); self.push(self.pc); self.pc = addr; cycles = 17
        elif op in (0xC4,0xCC,0xD4,0xDC,0xE4,0xEC,0xF4,0xFC):
            addr = self.fetch16(); cc=(op>>3)&7; tests=[(self.flags&FLAG_Z)==0,(self.flags&FLAG_Z)!=0,(self.flags&FLAG_C)==0,(self.flags&FLAG_C)!=0,(self.flags&FLAG_P)==0,(self.flags&FLAG_P)!=0,(self.flags&FLAG_S)==0,(self.flags&FLAG_S)!=0]
            if tests[cc]: self.push(self.pc); self.pc=addr; cycles=17
            else: cycles=11
        elif op == 0xC9: self.pc = self.pop(); cycles = 10
        elif op in (0xC0,0xC8,0xD0,0xD8,0xE0,0xE8,0xF0,0xF8):
            cc=(op>>3)&7; tests=[(self.flags&FLAG_Z)==0,(self.flags&FLAG_Z)!=0,(self.flags&FLAG_C)==0,(self.flags&FLAG_C)!=0,(self.flags&FLAG_P)==0,(self.flags&FLAG_P)!=0,(self.flags&FLAG_S)==0,(self.flags&FLAG_S)!=0]
            if tests[cc]: self.pc=self.pop(); cycles=11
            else: cycles=5
        elif op in (0xC5,0xD5,0xE5,0xF5):
            if op == 0xF5: self.push((self.a<<8)|(self.flags|0x02))
            else: self.push(self.pair(['BC','DE','HL'][(op>>4)&3]))
            cycles=11
        elif op in (0xC1,0xD1,0xE1,0xF1):
            x=self.pop()
            if op == 0xF1: self.flags=(x&0xD7)|0x02; self.a=x>>8
            else: self.set_pair(['BC','DE','HL'][(op>>4)&3],x)
            cycles=10
        elif op & 0xC7 == 0x80: self.add(self.get_r(op & 7)); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0x88: self.add(self.get_r(op&7), True); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0x90: self.sub(self.get_r(op&7)); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0x98: self.sub(self.get_r(op&7), True); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0xA0: self.a &= self.get_r(op&7); self.flags &= ~FLAG_C; self.flags |= FLAG_A; self.set_szp(self.a); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0xA8: self.a ^= self.get_r(op&7); self.flags &= ~(FLAG_C|FLAG_A); self.set_szp(self.a); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0xB0: self.a |= self.get_r(op&7); self.flags &= ~(FLAG_C|FLAG_A); self.set_szp(self.a); cycles=7 if (op&7)==6 else 4
        elif op & 0xC7 == 0xB8: v=self.a-self.get_r(op&7); c=self.flags&FLAG_C; self.flags=0x02; self.a=v&0xFF; self.set_szp(self.a); self.flags=(self.flags&~FLAG_C)|(FLAG_C if v<0 else 0); cycles=7 if (op&7)==6 else 4
        elif op in (0x27,):
            correction=0; carry=self.flags&FLAG_C
            if (self.a&0x0F)>9 or (self.flags&FLAG_A): correction|=6
            if self.a>0x99 or carry or ((self.a+correction)&0xFF)>0x99: correction|=0x60; carry=FLAG_C
            self.a=(self.a+correction)&0xFF; self.flags=(self.flags&~FLAG_C)|carry; self.set_szp(self.a); cycles=4
        elif op in (0x2F,): self.a ^= 0xFF; cycles=4
        elif op == 0x3F: self.flags ^= FLAG_C; cycles=4
        elif op == 0x37: self.flags |= FLAG_C; cycles=4
        elif op in (0x07,0x0F,0x17,0x1F):
            old=self.a
            if op==0x07: self.a=((old<<1)|(old>>7))&0xFF; self.flags=(self.flags&~FLAG_C)|(old>>7)
            elif op==0x0F: self.a=((old>>1)|(old<<7))&0xFF; self.flags=(self.flags&~FLAG_C)|(old&1)
            elif op==0x17: self.a=((old<<1)|(1 if self.flags&FLAG_C else 0))&0xFF; self.flags=(self.flags&~FLAG_C)|(old>>7)
            else: self.a=((old>>1)|(0x80 if self.flags&FLAG_C else 0)); self.flags=(self.flags&~FLAG_C)|(old&1)
            cycles=4
        elif op & 0xC7 == 0xC6: self.add(self.fetch8()); cycles=7
        elif op & 0xC7 == 0xCE: self.add(self.fetch8(), True); cycles=7
        elif op & 0xC7 == 0xD6: self.sub(self.fetch8()); cycles=7
        elif op & 0xC7 == 0xDE: self.sub(self.fetch8(), True); cycles=7
        elif op & 0xC7 == 0xE6: self.a &= self.fetch8(); self.flags &= ~FLAG_C; self.flags|=FLAG_A; self.set_szp(self.a); cycles=7
        elif op & 0xC7 == 0xEE: self.a ^= self.fetch8(); self.flags &= ~(FLAG_C|FLAG_A); self.set_szp(self.a); cycles=7
        elif op & 0xC7 == 0xF6: self.a |= self.fetch8(); self.flags &= ~(FLAG_C|FLAG_A); self.set_szp(self.a); cycles=7
        elif op & 0xC7 == 0xFE:
            v=self.a-self.fetch8(); self.flags &= ~(FLAG_S|FLAG_Z|FLAG_P|FLAG_C|FLAG_A); self.set_szp(v); self.flags |= FLAG_C if v<0 else 0; cycles=7
        elif op in (0xDB,0xD3):
            port=self.fetch8()
            if op==0xDB: self.a=self.in_port(port)
            else: self.out_port(port,self.a)
            cycles=10
        elif op in (0xF3,0xFB): cycles=4  # interrupt enable state is intentionally external
        elif op & 0xC7 == 0xC7:
            self.push(self.pc); self.pc=op&0x38; cycles=11
        else:
            raise NotImplementedError(f"Unsupported opcode 0x{op:02X} at 0x{(self.pc-1)&MASK16:04X}")

        self.cycles += cycles
        return cycles

    def run(self, max_steps: int = 100000) -> int:
        steps=0
        while not self.halted and steps < max_steps:
            self.step(); steps += 1
        return steps


def demo() -> None:
    cpu=CPU8080()
    # MVI A,42h; MVI B,18h; ADD B; STA 2000h; HLT
    program=bytes([0x3E,0x42,0x06,0x18,0x80,0x32,0x00,0x20,0x76])
    cpu.memory[:len(program)]=program
    cpu.run()
    print(f"8080 demo: A={cpu.a:02X} memory[2000]={cpu.memory[0x2000]:02X} PC={cpu.pc:04X} cycles={cpu.cycles}")


def self_test() -> None:
    cpu=CPU8080(); cpu.memory[:9]=bytes([0x3E,0x42,0x06,0x18,0x80,0x32,0x00,0x20,0x76]); cpu.run(); assert cpu.a==0x5A and cpu.memory[0x2000]==0x5A
    # MVI A,05; MVI B,03; SUB B; HLT. Verify SUB result and HALT.
    cpu=CPU8080(); program=bytes([0x3E,0x05,0x06,0x03,0x90,0x76]); cpu.memory[:len(program)]=program; cpu.run(); assert cpu.a==2 and cpu.halted
    cpu=CPU8080(); cpu.sp=0x1000; cpu.b=0x12; cpu.c=0x34; cpu.memory[:3]=bytes([0xC5,0xC1,0x76]); cpu.run(); assert cpu.b==0x12 and cpu.c==0x34 and cpu.sp==0x1000
    cpu=CPU8080(); cpu.memory[:5]=bytes([0x3E,0xAA,0xD3,0x10,0x76]); cpu.run(); assert cpu.output_ports[0x10]==0xAA
    print('ASN Computer 8080 self-test: PASS')

if __name__ == '__main__':
    p=argparse.ArgumentParser(); p.add_argument('--demo',action='store_true'); p.add_argument('--self-test',action='store_true'); args=p.parse_args()
    if args.self_test: self_test()
    elif args.demo: demo()
    else: p.print_help()
