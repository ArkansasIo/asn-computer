#!/usr/bin/env python3
"""
BACKPLANE INTERFACE - ALTAIR 8800 Computer Backplane Architecture Visualization
Shows the internal bus structure, card slots, and power distribution
"""

import tkinter as tk
from tkinter import ttk
import tkinter.font as tkFont
import math


class BackplaneVisualization:
    """Visualize ALTAIR 8800 backplane architecture"""
    
    def __init__(self, root=None):
        """Initialize backplane visualization"""
        self.root = root if root else tk.Tk()
        self.root.title("ALTAIR 8800 - Backplane Architecture")
        self.root.geometry("1200x800")
        self.root.configure(bg='#1a1a1a')
        
        # Backplane state
        self.cards = {}
        self.selected_card = None
        self.bus_activity = {
            'address': 0,
            'data': 0,
            'control': 0,
        }
        
        self.setup_gui()
        self.animate_backplane()
    
    def setup_gui(self):
        """Setup backplane interface"""
        # Title
        title = tk.Label(
            self.root, text="ALTAIR 8800 BACKPLANE ARCHITECTURE",
            font=("Courier New", 16, "bold"), fg='#00FF00', bg='#1a1a1a'
        )
        title.pack(pady=10)
        
        # Main canvas for backplane
        self.canvas = tk.Canvas(
            self.root, bg='#0a0a0a', highlightthickness=2,
            highlightbackground='#333333', height=500
        )
        self.canvas.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        self.canvas.bind("<Button-1>", self.on_card_click)
        
        # Info panel
        info_frame = tk.Frame(self.root, bg='#222222', height=150)
        info_frame.pack(fill=tk.X, padx=10, pady=5)
        
        info_label = tk.Label(info_frame, text="BACKPLANE INFORMATION", fg='#00FF00', bg='#222222', font=("Courier New", 12, "bold"))
        info_label.pack(anchor=tk.W, padx=10, pady=5)
        
        self.info_text = tk.Text(info_frame, height=6, width=100, bg='#1a1a1a', fg='#00FF00', font=("Courier New", 10))
        self.info_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.update_info()
    
    def draw_backplane(self):
        """Draw backplane with card slots and buses"""
        self.canvas.delete("all")
        
        width = self.canvas.winfo_width()
        height = self.canvas.winfo_height()
        
        if width < 100 or height < 100:
            return
        
        # Draw backplane background
        self.canvas.create_rectangle(0, 0, width, height, fill='#0a0a0a', outline='#333333', width=2)
        
        # Draw power distribution bus (top)
        self.canvas.create_rectangle(20, 20, width-20, 40, fill='#FF0000', outline='#00FF00', width=2)
        self.canvas.create_text(30, 30, text="POWER BUS (+5V, +12V, GND)", fill='#000000', font=("Courier New", 10, "bold"), anchor=tk.W)
        
        # Draw address bus (left side)
        self.canvas.create_rectangle(20, 60, 80, height-60, fill='#004400', outline='#00FF00', width=2)
        for i in range(16):
            y = 80 + i * 35
            self.canvas.create_text(30, y, text=f"A{i}", fill='#00FF00', font=("Courier New", 9))
        
        # Draw data bus (left-center)
        self.canvas.create_rectangle(90, 60, 150, height-60, fill='#004400', outline='#00FF00', width=2)
        for i in range(8):
            y = 100 + i * 50
            self.canvas.create_text(100, y, text=f"D{i}", fill='#00FF00', font=("Courier New", 9))
        
        # Draw control bus (left)
        self.canvas.create_rectangle(160, 60, 220, height-60, fill='#440044', outline='#00FF00', width=2)
        controls = ['CLK', 'RST', 'INT', 'HALT', 'RD', 'WR', 'WAIT']
        for i, ctrl in enumerate(controls):
            y = 80 + i * 30
            self.canvas.create_text(170, y, text=ctrl, fill='#00FF00', font=("Courier New", 9))
        
        # Draw CPU card (main slot)
        cpu_x, cpu_y = 250, 80
        cpu_width, cpu_height = 120, 100
        self.canvas.create_rectangle(cpu_x, cpu_y, cpu_x+cpu_width, cpu_y+cpu_height, fill='#444444', outline='#00FF00', width=2)
        self.canvas.create_text(cpu_x+60, cpu_y+20, text="CPU CARD", fill='#00FF00', font=("Courier New", 11, "bold"))
        self.canvas.create_text(cpu_x+60, cpu_y+45, text="8080A Processor", fill='#FFFF00', font=("Courier New", 9))
        self.canvas.create_text(cpu_x+60, cpu_y+70, text="2MHz Clock", fill='#00FF00', font=("Courier New", 8))
        
        self.cards['CPU'] = (cpu_x, cpu_y, cpu_width, cpu_height)
        
        # Draw RAM cards (memory slots)
        ram_start_x = cpu_x + cpu_width + 20
        ram_configs = [
            ("RAM0", 8, "8KB"),
            ("RAM1", 16, "8KB"),
            ("RAM2", 24, "8KB"),
        ]
        
        for i, (name, offset, size) in enumerate(ram_configs):
            ram_x = ram_start_x + i * 130
            ram_y = 80
            ram_w, ram_h = 110, 100
            self.canvas.create_rectangle(ram_x, ram_y, ram_x+ram_w, ram_y+ram_h, fill='#333366', outline='#00FF00', width=2)
            self.canvas.create_text(ram_x+55, ram_y+20, text=name, fill='#00FF00', font=("Courier New", 11, "bold"))
            self.canvas.create_text(ram_x+55, ram_y+45, text=size, fill='#FFFF00', font=("Courier New", 9))
            self.canvas.create_text(ram_x+55, ram_y+70, text=f"0x{offset:04X}", fill='#00FF00', font=("Courier New", 8))
            
            self.cards[name] = (ram_x, ram_y, ram_w, ram_h)
        
        # Draw ROM card
        rom_x = ram_start_x + 3 * 130
        rom_y = 80
        rom_w, rom_h = 110, 100
        self.canvas.create_rectangle(rom_x, rom_y, rom_x+rom_w, rom_y+rom_h, fill='#663333', outline='#00FF00', width=2)
        self.canvas.create_text(rom_x+55, rom_y+20, text="ROM", fill='#00FF00', font=("Courier New", 11, "bold"))
        self.canvas.create_text(rom_x+55, rom_y+45, text="4KB Monitor", fill='#FFFF00', font=("Courier New", 9))
        self.canvas.create_text(rom_x+55, rom_y+70, text="0xF000", fill='#00FF00', font=("Courier New", 8))
        
        self.cards['ROM'] = (rom_x, rom_y, rom_w, rom_h)
        
        # Draw I/O cards (lower section)
        io_y = cpu_y + cpu_height + 40
        
        io_cards = [
            ("SERIAL", "TTY/Console"),
            ("PARALLEL", "Printer/GPIO"),
            ("FLOPPY", "Disk Controller"),
            ("NETWORK", "Ethernet Card"),
        ]
        
        for i, (name, desc) in enumerate(io_cards):
            io_x = 250 + i * 140
            io_w, io_h = 130, 80
            self.canvas.create_rectangle(io_x, io_y, io_x+io_w, io_y+io_h, fill='#334466', outline='#00FF00', width=2)
            self.canvas.create_text(io_x+65, io_y+15, text=name, fill='#00FF00', font=("Courier New", 10, "bold"))
            self.canvas.create_text(io_x+65, io_y+40, text=desc, fill='#FFFF00', font=("Courier New", 9))
            self.canvas.create_text(io_x+65, io_y+60, text=f"0x{0x20+i:02X}0", fill='#00FF00', font=("Courier New", 8))
            
            self.cards[name] = (io_x, io_y, io_w, io_h)
        
        # Draw bus connectors (right side)
        self.canvas.create_rectangle(width-80, 60, width-20, height-60, fill='#440044', outline='#00FF00', width=2)
        self.canvas.create_text(width-50, height/2, text="EXPANSION\nPORT", fill='#00FF00', font=("Courier New", 10, "bold"), anchor=tk.CENTER)
        
        # Draw bus activity indicators
        activity_y = height - 30
        self.canvas.create_text(250, activity_y, text=f"Address Bus: 0x{self.bus_activity['address']:04X}", fill='#FFFF00', font=("Courier New", 9), anchor=tk.W)
        self.canvas.create_text(550, activity_y, text=f"Data Bus: 0x{self.bus_activity['data']:02X}", fill='#FFFF00', font=("Courier New", 9), anchor=tk.W)
    
    def on_card_click(self, event):
        """Handle card click"""
        for card_name, (x, y, w, h) in self.cards.items():
            if x <= event.x <= x+w and y <= event.y <= y+h:
                self.selected_card = card_name
                self.update_info()
                self.highlight_card(x, y, w, h)
                break
    
    def highlight_card(self, x, y, w, h):
        """Highlight selected card"""
        self.draw_backplane()
        self.canvas.create_rectangle(x-3, y-3, x+w+3, y+h+3, outline='#FF00FF', width=3)
    
    def update_info(self):
        """Update information panel"""
        self.info_text.config(state='normal')
        self.info_text.delete(1.0, tk.END)
        
        info = "ALTAIR 8800 BACKPLANE SYSTEM\n"
        info += "=" * 80 + "\n\n"
        
        if self.selected_card:
            info += f"SELECTED CARD: {self.selected_card}\n\n"
            
            card_info = {
                'CPU': """
Address Space: 64KB (0x0000 - 0xFFFF)
Bus Width: 16-bit address, 8-bit data
Clock Speed: 2 MHz
Microprocessor: Intel 8080A
Features: Interrupt support, Stack pointer, Flags register
Status: RUNNING
                """,
                'RAM0': "Memory Type: Dynamic RAM\nCapacity: 8KB\nAddress: 0x0000 - 0x1FFF\nAccess Time: <1μs\nWrite-Protected: No",
                'RAM1': "Memory Type: Dynamic RAM\nCapacity: 8KB\nAddress: 0x2000 - 0x3FFF\nAccess Time: <1μs\nWrite-Protected: No",
                'RAM2': "Memory Type: Dynamic RAM\nCapacity: 8KB\nAddress: 0x4000 - 0x5FFF\nAccess Time: <1μs\nWrite-Protected: No",
                'ROM': "Memory Type: Static ROM\nCapacity: 4KB Monitor ROM\nAddress: 0xF000 - 0xFFFF\nAccess Time: <2μs\nWrite-Protected: Yes\nContents: Boot loader, Monitor program",
                'SERIAL': """
Interface: RS-232 Serial Port
Baud Rate: 300-9600 bps (configurable)
Status: READY
Devices: Terminal, Modem, Printer
Base Address: 0x00""",
                'PARALLEL': """
Interface: Parallel Port (Centronics)
Width: 8-bit data bus
Status: READY
Device: Printer connected
Base Address: 0x01""",
                'FLOPPY': """
Controller: NEC Floppy Disk Controller
Drives: Up to 4 floppy drives
Media: 8-inch floppy disks
Status: NO DISK
Base Address: 0x02""",
                'NETWORK': "Not installed in base system",
            }
            
            info += card_info.get(self.selected_card, "No information available")
        else:
            info += """
SYSTEM OVERVIEW:

The ALTAIR 8800 backplane is a 100-pin bus system that interconnects:
- CPU Card (main processor with clock generator)
- Memory Cards (RAM and ROM)
- I/O Interface Cards (serial, parallel, floppy)
- Expansion Port (for additional cards)

BUS ARCHITECTURE:
- Address Bus: 16 lines (64KB address space)
- Data Bus: 8 lines (1 byte at a time)
- Control Bus: Clock, Reset, Interrupt, Read/Write signals
- Power Bus: +5V, +12V, -5V, and Ground

STANDARD CARD FORM FACTOR:
- 22 pins per card connector
- Dual-in-line connector arrangement
- Edge card connector type
- Standard mounting bracket
            """
        
        self.info_text.insert(1.0, info)
        self.info_text.config(state='normal')
    
    def animate_backplane(self):
        """Animate backplane activity"""
        import random
        
        self.bus_activity['address'] = random.randint(0, 0xFFFF)
        self.bus_activity['data'] = random.randint(0, 0xFF)
        self.bus_activity['control'] = random.randint(0, 7)
        
        self.draw_backplane()
        self.root.after(500, self.animate_backplane)


if __name__ == "__main__":
    root = tk.Tk()
    backplane = BackplaneVisualization(root)
    root.mainloop()
