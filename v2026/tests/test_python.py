import unittest
from python.altair2026 import Altair2026

class Altair2026Tests(unittest.TestCase):
    def test_self_test(self):
        self.assertTrue(Altair2026().self_test())

    def test_4k_geometry(self):
        machine = Altair2026()
        self.assertEqual((machine.display_width, machine.display_height), (3840, 2160))

    def test_front_panel_width(self):
        machine = Altair2026()
        machine.switches = 0xA55A
        machine.tick(1)
        self.assertGreaterEqual(machine.address_leds, 0)
        self.assertLessEqual(machine.address_leds, 0xFFFF)

    def test_halt_instruction(self):
        machine = Altair2026()
        machine.memory[0] = 0x76
        machine.tick(1)
        self.assertTrue(machine.cpu.halted)

if __name__ == "__main__":
    unittest.main()
