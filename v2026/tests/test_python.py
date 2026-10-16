from python.altair2026 import Altair2026

def test_self_test():
    assert Altair2026().self_test()

def test_4k():
    m = Altair2026()
    assert (m.display_width, m.display_height) == (3840, 2160)

def test_front_panel():
    m = Altair2026()
    m.switches = 0xA55A
    m.tick(1)
    assert 0 <= m.address_leds <= 0xFFFF
