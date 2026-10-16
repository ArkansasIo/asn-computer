import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from altair8080 import CPU8080


def run(program, limit=1000):
    cpu = CPU8080()
    cpu.memory[:len(program)] = bytes(program)
    cpu.run(limit)
    return cpu


class CPU8080Tests(unittest.TestCase):
    def test_add_and_store(self):
        cpu = run([0x3E,0x42,0x06,0x18,0x80,0x32,0x00,0x20,0x76])
        self.assertEqual(cpu.a, 0x5A)
        self.assertEqual(cpu.memory[0x2000], 0x5A)
        self.assertTrue(cpu.halted)

    def test_subtract_and_zero_jump(self):
        # MVI A,5; SUI 5; JZ 0008; HLT; HLT.
        # The jump target is the second HLT and should execute.
        cpu = run([0x3E,5,0xD6,5,0xCA,8,0,0x76,0x76])
        self.assertEqual(cpu.a, 0)
        self.assertTrue(cpu.halted)
        self.assertEqual(cpu.pc, 9)

    def test_stack_push_pop(self):
        cpu = run([0x01,0x34,0x12,0xC5,0x01,0x00,0x00,0xC1,0x76])
        self.assertEqual((cpu.b, cpu.c), (0x12,0x34))

    def test_in_out(self):
        cpu = run([0x3E,0xAA,0xD3,0x10,0xDB,0x10,0x76])
        self.assertEqual(cpu.output_ports[0x10], 0xAA)
        self.assertEqual(cpu.a, 0)

    def test_call_return(self):
        cpu = run([0xCD,0x06,0x00,0x76,0x00,0x00,0x3E,0x99,0xC9])
        self.assertEqual(cpu.a, 0x99)
        self.assertTrue(cpu.halted)


if __name__ == '__main__':
    unittest.main()
