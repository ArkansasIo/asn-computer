bits 64

%define ALTAIR2026_MMIO_BASE       0x80000000
%define ALTAIR2026_PCIE_ECAM      0x90000000
%define ALTAIR2026_FRAMEBUFFER    0xA0000000
%define ALTAIR2026_S100_BRIDGE    0xB0000000

%define ALTAIR2026_4K_WIDTH       3840
%define ALTAIR2026_4K_HEIGHT      2160
%define ALTAIR2026_4K_STRIDE      (3840*4)

%define S100_ADDRESS_BITS         24
%define S100_DATA_BITS            8
%define S100_SLOT_COUNT           10

%define STATUS_POWER              0x01
%define STATUS_HALT               0x02
%define STATUS_WAIT               0x04
%define STATUS_INTERRUPT          0x08

%define DISPLAY_MODE_4K60         0x4B60
