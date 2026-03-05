# QUICK START - ALTAIR 8800 UI INTERFACES

## 🚀 Get Started in 2 Minutes

---

## Desktop GUI (Recommended for Windows)

### Step 1: Launch
```bash
python altair_ui_interface.py
```

### Step 2: Interact
1. **Click "POWER ON"** button (red → green)
2. **Click "RUN"** button to start execution
3. **Watch LEDs animate** in real-time
4. **Toggle switches** by clicking (0-F)
5. **Click "HALT"** to pause
6. **Click "RESET"** to restart

### That's it! ✅

---

## Web Interface (No Installation)

### Step 1: Open
- **Windows**: Double-click `altair_ui_web.html`
- **Mac**: Right-click → Open With → Browser
- **Linux**: Open file manager, double-click

### Step 2: Interact
Same as desktop GUI - use mouse to click buttons/switches in browser

### That's it! ✅

---

## What You'll See

### LED Displays
- **Green LEDs**: Bits that are ON (1)
- **Dark Green**: Bits that are OFF (0)
- **16 LEDs (top)**: Address Bus (0x0000-0xFFFF)
- **8 LEDs (middle)**: Data Bus (0x00-0xFF)

### Status Indicators
- **Green**: POWER is ON
- **Yellow**: HALT or WAIT status
- **Yellow**: Interrupt (INT)

### Registers (Right side)
- **A-L**: General-purpose registers
- **PC**: Program Counter
- **SP**: Stack Pointer
Built-in updates showing real-time values

### Switches (Bottom)
- 16 switches labeled 0-9, A-F
- Click to toggle ON/OFF
- Visual feedback immediate

### Backplane (Right panel)
- Complete system architecture
- CPU, RAM, ROM, peripherals
- Real-time component status

---

## Control Buttons Explained

| Button | What It Does |
|--------|---|
| **POWER ON** | Turns system on (red → green) |
| **POWER OFF** | Turns system off (green → red) |
| **RUN** | Starts program execution |
| **HALT** | Pauses execution |
| **RESET** | Clears all registers, restarts |

---

## Animation Examples

### What's Normal?
✅ Address bus counting: 0x0000 → 0x0001 → 0x0002...  
✅ Data bus incrementing randomly  
✅ LEDs turning on/off  
✅ Register values changing  

### LED Pattern When Running
```
Address Bus:  ████░░░░░░░░░░░░  (changes every cycle)
Data Bus:     ████████░░░░░░░░  (increments by 17)
Status:       ●○○○ (POWER on, others off)
```

---

## Interactive Exercise

### Try This:
1. **Power On** → POWER LED turns green
2. **Run** → Watch address bus count up
3. **Toggle Switches** → Click any switch (0-F)
4. **Halt** → Everything stops
5. **Run** → Resumes from where you halted
6. **Reset** → All back to 0x0000/0x00

---

## Keyboard Shortcuts

### Desktop GUI (Tkinter)
- Window can be closed anytime (power off)
- All interaction via mouse clicks
- No keyboard shortcuts (click buttons instead)

### Web GUI (Browser)
- All interaction via mouse clicks
- Responsive to window resize
- Works on tablets/phones too

---

## Troubleshooting Quick Fix

| Problem | Solution |
|---------|----------|
| LEDs not moving | Click **Power On** then **Run** |
| Buttons won't work | **Power must be ON first** |
| Program won't start | Python 3 required: `python --version` |
| Desktop GUI won't open | Try: `python -m tkinter` first |
| Web page blank | Clear browser cache & refresh |

---

## What Each Panel Shows

### LEFT PANEL - Front Panel Controls
- **Top**: Address Bus (16 bits)
- **Middle**: Data Bus (8 bits)  
- **Status LED Row**: POWER, HALT, WAIT, INT
- **Middle**: CPU Registers (A-L, PC, SP)
- **Bottom**: 16 Toggle Switches
- **Bottom Buttons**: POWER, RUN, HALT, RESET

### RIGHT PANEL - Backplane Architecture
- **CPU**: Central processor (Intel 8080)
- **Memory**: RAM (64 KB) + ROM (8 KB)
- **Peripherals**: Serial, Parallel, Disk, Keyboard, Display, Timer, Tape
- **Controllers**: DMA, Interrupt Controller
- **Support**: Power Supply, Clock Generator, Boot ROM
- **Status**: Real-time component status

---

## Tips & Tricks

### 💡 Monitor Patterns
- Watch address counter increment smoothly (0x0000 → 0x0001...)
- Data bus shows pattern every 17 cycles
- Different LED patterns indicate different operations

### 💡 Test Features
- **Switch Test**: Toggle each switch, watch state change
- **Register Test**: Run program, watch registers update
- **Bus Test**: Run program, see address bus count up
- **Reset Test**: Click Reset, verify all go to 0x0000

### 💡 Best Results
- Use bright display for best LED visibility
- Fullscreen web interface recommended
- Desktop GUI stays on top of other windows
- Both can run simultaneously

---

## Next Steps

### After trying the UI...

1. **Read full documentation**: `UI_INTERFACES_GUIDE.md`
2. **Explore assembly code**: See `*.asm` files
3. **Run Python simulator**: `python emulator_simulator.py`
4. **Check system components**: See `MANIFEST.md`

---

## System Specifications

```
ALTAIR 8800 EMULATOR
├─ Processor: Intel 8080 (8-bit)
├─ Memory: 64 KB RAM + 8 KB ROM
├─ Address Bus: 16-bit (0x0000-0xFFFF)
├─ Data Bus: 8-bit (0x00-0xFF)
├─ Registers: 7 (A-H) + PC + SP
├─ Interrupts: 256 vectors
├─ DMA: 8 channels
├─ Timer: 1.193 MHz
└─ I/O: Serial, Parallel, Disk, Keyboard, Display, Tape

INTERFACES AVAILABLE
├─ Python Simulator: emulator_simulator.py
├─ Desktop GUI: altair_ui_interface.py (Tkinter)
└─ Web GUI: altair_ui_web.html (HTML/CSS/JS)
```

---

## Success Checklist

- [ ] Desktop or web interface opened
- [ ] Power button works (LED changes color)
- [ ] Run button starts animation
- [ ] Address bus changes
- [ ] Switches can be toggled
- [ ] Halt freezes animation
- [ ] Reset clears display
- [ ] Backplane visible
- [ ] Status displays show updates

**Once all checked**: You've successfully activated the ALTAIR 8800 emulator! 🎉

---

## Support

For detailed information, see:
- `UI_INTERFACES_GUIDE.md` - Complete feature documentation
- `DEVELOPER_GUIDE.md` - Architecture details
- `SYSTEM_COMPONENTS_GUIDE.md` - Component description
- `API_REFERENCE.md` - Assembly API

---

**Status**: ✅ Ready to Use  
**Interfaces**: 2 (Desktop + Web)  
**Learning Curve**: ~2 minutes  
**Fun Factor**: 📈 High

Enjoy your ALTAIR 8800 emulator! 🖥️✨
