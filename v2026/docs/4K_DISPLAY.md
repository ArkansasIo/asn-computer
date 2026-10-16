# 4K Display Specification

## Target

- Resolution: 3840 × 2160
- Refresh: 60 Hz baseline
- Color: 8-bit minimum, 10-bit capable preferred
- Internal interface: eDP 1.4 class
- External interfaces: HDMI 2.1 and DisplayPort 2.0 class

## Framebuffer

32-bit RGBA reference format:

`3840 × 2160 × 4 = 33,177,600 bytes` per framebuffer.

Double buffering requires approximately 66.4 MB before additional compositor surfaces.

## Panel selection

The exact LCD/OLED panel must be frozen before PCB layout because connector pinout, power,
backlight, EDID, timing, mechanical dimensions and mounting vary by panel.
