#!/usr/bin/env python3
"""
ALTAIR 8800 EMULATOR - INTERACTIVE UI INTERFACE
Complete GUI with front panel controls and backplane architecture visualization
"""

import tkinter as tk
from tkinter import ttk, messagebox
import tkinter.font as tkFont
from datetime import datetime
import random
import math

class ALTAIR8800UI:
    def __init__(self, root):
        self.root = root
        self.root.title("ALTAIR 8800 Emulator - Interactive Interface")
        self.root.geometry("1600x900")
        self.root.configure(bg='#1a1a1a')
        
        # Emulator state
        self.running = False
        self.power_on = False
        self.halt = False
        self.wait = False
        self.interrupt = False
        self.bit_mode = 16
        self.address_mask = (1 << self.bit_mode) - 1
        
        # CPU state
        self.address_bus = 0x0000
        self.data_bus = 0x00
        self.registers = {
            'A': 0x00, 'B': 0x00, 'C': 0x00, 'D': 0x00,
            'E': 0x00, 'H': 0x00, 'L': 0x00
        }
        self.pc = 0x0000
        self.sp = 0x8000
        self.flags = 0x00
        
        # Control switches
        self.switches = [0] * 16
        
        # Create main interface
        self.setup_styles()
        self.create_front_panel()
        self.create_backplane_view()
        self.create_status_bar()
        
        # Animation
        self.animate_leds()
    
    def setup_styles(self):
        """Configure UI styles"""
        self.title_font = tkFont.Font(family="Courier New", size=16, weight="bold")
        self.label_font = tkFont.Font(family="Courier New", size=10)
        self.small_font = tkFont.Font(family="Courier New", size=8)
        
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('Dark.TFrame', background='#1a1a1a')
        style.configure('Dark.TLabel', background='#1a1a1a', foreground='#00FF00')
    
    def create_front_panel(self):
        """Create the ALTAIR 8800 front panel"""
        # Main container
        front_panel = ttk.Frame(self.root, style='Dark.TFrame')
        front_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Title
        title = tk.Label(
            front_panel, text="╔══════════════════════════════════════════╗",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title.pack()
        
        title2 = tk.Label(
            front_panel, text="║     ALTAIR 8800 FRONT PANEL v2.0       ║",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title2.pack()
        
        title3 = tk.Label(
            front_panel, text="╚══════════════════════════════════════════╝",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title3.pack(pady=10)
        
        # Address Bus Display (16 LEDs)
        addr_frame = tk.Frame(front_panel, bg='#1a1a1a')
        addr_frame.pack(pady=10)
        
        addr_label = tk.Label(addr_frame, text="ADDRESS BUS (16-bit)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        addr_label.pack()
        
        self.address_leds = []
        addr_led_frame = tk.Frame(addr_frame, bg='#1a1a1a')
        addr_led_frame.pack()
        
        for i in range(15, -1, -1):
            frame = tk.Frame(addr_led_frame, bg='#1a1a1a', width=30, height=30)
            frame.pack(side=tk.LEFT, padx=2)
            
            led = tk.Canvas(frame, width=25, height=25, bg='#0a0a0a', highlightthickness=1, highlightbackground='#333333')
            led.pack()
            self.address_leds.append(led)
        
        addr_value = tk.Label(addr_frame, text="0x0000", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        addr_value.pack()
        self.addr_value_label = addr_value
        
        # Data Bus Display (8 LEDs)
        data_frame = tk.Frame(front_panel, bg='#1a1a1a')
        data_frame.pack(pady=10)
        
        data_label = tk.Label(data_frame, text="DATA BUS (8-bit)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        data_label.pack()
        
        self.data_leds = []
        data_led_frame = tk.Frame(data_frame, bg='#1a1a1a')
        data_led_frame.pack()
        
        for i in range(7, -1, -1):
            frame = tk.Frame(data_led_frame, bg='#1a1a1a', width=35, height=35)
            frame.pack(side=tk.LEFT, padx=3)
            
            led = tk.Canvas(frame, width=30, height=30, bg='#0a0a0a', highlightthickness=1, highlightbackground='#333333')
            led.pack()
            self.data_leds.append(led)
        
        data_value = tk.Label(data_frame, text="0x00", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        data_value.pack()
        self.data_value_label = data_value
        
        # Status LEDs
        status_frame = tk.Frame(front_panel, bg='#1a1a1a')
        status_frame.pack(pady=10)
        
        status_label = tk.Label(status_frame, text="STATUS INDICATORS", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        status_label.pack()
        
        self.status_leds = {}
        status_indicators = ['POWER', 'HALT', 'WAIT', 'INT']
        
        for indicator in status_indicators:
            ind_frame = tk.Frame(status_frame, bg='#1a1a1a')
            ind_frame.pack(side=tk.LEFT, padx=15, pady=5)
            
            led = tk.Canvas(ind_frame, width=40, height=40, bg='#0a0a0a', highlightthickness=2, highlightbackground='#333333')
            led.pack()
            self.status_leds[indicator] = led
            
            label = tk.Label(ind_frame, text=indicator, font=self.small_font, fg='#00FF00', bg='#1a1a1a')
            label.pack()
        
        # CPU Registers Display
        reg_frame = tk.Frame(front_panel, bg='#1a1a1a')
        reg_frame.pack(pady=10)
        
        reg_label = tk.Label(reg_frame, text="CPU REGISTERS", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        reg_label.pack()
        
        self.reg_labels = {}
        reg_display_frame = tk.Frame(reg_frame, bg='#1a1a1a')
        reg_display_frame.pack()
        
        row_frame = tk.Frame(reg_display_frame, bg='#1a1a1a')
        row_frame.pack()
        
        for reg in ['A', 'B', 'C', 'D', 'E', 'H', 'L']:
            reg_item = tk.Label(
                row_frame, text=f"{reg}: 0x00", font=self.small_font,
                fg='#00FF00', bg='#1a1a1a', width=12
            )
            reg_item.pack(side=tk.LEFT, padx=5)
            self.reg_labels[reg] = reg_item
        
        pc_frame = tk.Frame(reg_display_frame, bg='#1a1a1a')
        pc_frame.pack()
        
        self.pc_label = tk.Label(pc_frame, text="PC: 0x0000", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        self.pc_label.pack(side=tk.LEFT, padx=5)
        
        self.sp_label = tk.Label(pc_frame, text="SP: 0x8000", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        self.sp_label.pack(side=tk.LEFT, padx=5)
        
        # Toggle Switches
        switch_frame = tk.Frame(front_panel, bg='#1a1a1a')
        switch_frame.pack(pady=10)
        
        switch_label = tk.Label(switch_frame, text="TOGGLE SWITCHES (16)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        switch_label.pack()
        
        self.switch_buttons = []
        switch_button_frame = tk.Frame(switch_frame, bg='#1a1a1a')
        switch_button_frame.pack()
        
        for i in range(15, -1, -1):
            def toggle_switch(idx=i):
                self.switches[idx] = 1 - self.switches[idx]
            
            btn = tk.Button(
                switch_button_frame, text=f"{i}", width=3, height=1,
                command=toggle_switch, bg='#333333', fg='#00FF00',
                font=self.small_font, activebackground='#00FF00', activeforeground='#000000'
            )
            btn.pack(side=tk.LEFT, padx=2, pady=5)
            self.switch_buttons.append(btn)
        
        # Control Buttons
        button_frame = tk.Frame(front_panel, bg='#1a1a1a')
        button_frame.pack(pady=15)

        # Bit-width selector
        cfg_frame = tk.Frame(front_panel, bg='#1a1a1a')
        cfg_frame.pack(pady=5)
        tk.Label(cfg_frame, text="SYSTEM WIDTH", font=self.small_font, fg='#FFFF00', bg='#1a1a1a').pack(side=tk.LEFT, padx=6)
        self.bit_mode_var = tk.StringVar(value="16")
        bit_selector = tk.OptionMenu(cfg_frame, self.bit_mode_var, "16", "32", "64", "128", command=self.set_bit_mode)
        bit_selector.config(bg='#222222', fg='#00FF00', activebackground='#00FF00', activeforeground='#000000', width=6)
        bit_selector["menu"].config(bg='#111111', fg='#00FF00')
        bit_selector.pack(side=tk.LEFT)
        
        self.power_btn = tk.Button(
            button_frame, text="POWER ON", width=15, height=2,
            command=self.toggle_power, bg='#220000', fg='#FF0000',
            font=self.label_font, activebackground='#00FF00', activeforeground='#000000'
        )
        self.power_btn.pack(side=tk.LEFT, padx=5)
        
        run_btn = tk.Button(
            button_frame, text="RUN", width=15, height=2,
            command=self.run_program, bg='#002200', fg='#00FF00',
            font=self.label_font, activebackground='#00FF00', activeforeground='#000000'
        )
        run_btn.pack(side=tk.LEFT, padx=5)
        
        halt_btn = tk.Button(
            button_frame, text="HALT", width=15, height=2,
            command=self.halt_program, bg='#222200', fg='#FFFF00',
            font=self.label_font, activebackground='#00FF00', activeforeground='#000000'
        )
        halt_btn.pack(side=tk.LEFT, padx=5)
        
        reset_btn = tk.Button(
            button_frame, text="RESET", width=15, height=2,
            command=self.reset_system, bg='#220022', fg='#FF00FF',
            font=self.label_font, activebackground='#00FF00', activeforeground='#000000'
        )
        reset_btn.pack(side=tk.LEFT, padx=5)
    
    def create_backplane_view(self):
        """Create the backplane architecture visualization"""
        backplane = ttk.Frame(self.root, style='Dark.TFrame')
        backplane.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Title
        title = tk.Label(
            backplane, text="╔════════════════════════════════════╗",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title.pack()
        
        title2 = tk.Label(
            backplane, text="║  ALTAIR 8800 BACKPLANE DIAGRAM   ║",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title2.pack()
        
        title3 = tk.Label(
            backplane, text="╚════════════════════════════════════╝",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title3.pack(pady=10)
        
        # Canvas for architecture diagram
        self.backplane_canvas = tk.Canvas(
            backplane, width=500, height=700, bg='#0a0a0a',
            highlightthickness=2, highlightbackground='#333333'
        )
        self.backplane_canvas.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.draw_backplane()
        
        # Component status
        status_frame = tk.Frame(backplane, bg='#1a1a1a')
        status_frame.pack(pady=10, fill=tk.X)
        
        status_label = tk.Label(status_frame, text="COMPONENT STATUS", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        status_label.pack()
        
        # Status text
        self.status_text = tk.Text(status_frame, height=6, width=60, bg='#0a0a0a', fg='#00FF00', font=self.small_font)
        self.status_text.pack(padx=5, pady=5)
        
        self.update_component_status()
    
    def draw_backplane(self):
        """Draw the backplane architecture diagram"""
        canvas = self.backplane_canvas
        canvas.delete("all")
        
        # Set colors
        box_color = '#003300'
        line_color = '#00FF00'
        text_color = '#00FF00'
        active_color = '#FFFF00'
        
        # CPU (center top)
        self.draw_component(canvas, 200, 50, 100, 50, "CPU\nIntel 8080", box_color, line_color, text_color)
        
        # Memory (left)
        self.draw_component(canvas, 30, 150, 90, 60, "RAM\n64 KB", box_color, line_color, text_color)
        
        # ROM (right)
        self.draw_component(canvas, 380, 150, 90, 60, "ROM\n8 KB", box_color, line_color, text_color)
        
        # Bus connections from CPU
        canvas.create_line(250, 100, 75, 150, fill=active_color, width=2, dash=(4, 4))
        canvas.create_line(250, 100, 425, 150, fill=active_color, width=2, dash=(4, 4))
        canvas.create_text(125, 115, text="Address Bus", fill=text_color, font=self.small_font)
        canvas.create_text(350, 115, text="Data Bus", fill=text_color, font=self.small_font)
        
        # Address Bus (bottom left)
        self.draw_component(canvas, 10, 260, 110, 50, "Address\nDecoder", box_color, line_color, text_color)
        
        # Data Bus (bottom right)
        self.draw_component(canvas, 380, 260, 110, 50, "Data\nControl", box_color, line_color, text_color)
        
        # Peripheral devices (bottom)
        devices = [
            (20, 360, "Serial\nI/O"),
            (90, 360, "Parallel\nPort"),
            (160, 360, "Disk\nIO"),
            (230, 360, "Keyboard\nMouse"),
            (300, 360, "Display\nLEDs"),
            (370, 360, "Timer\nIC"),
            (440, 360, "Tape\nReader"),
        ]
        
        for x, y, label in devices:
            self.draw_component(canvas, x, y, 60, 50, label, '#001a33', line_color, text_color)
            # Connect to buses
            canvas.create_line(65, 310, x + 30, y, fill=line_color, width=1)
            canvas.create_line(435, 310, x + 30, y, fill=line_color, width=1)
        
        # Main system bus (horizontal line)
        canvas.create_line(10, 320, 490, 320, fill=line_color, width=2)
        canvas.create_line(10, 330, 490, 330, fill=line_color, width=2)
        canvas.create_text(250, 345, text="SYSTEM BUS (Address + Data)", fill=text_color, font=self.small_font)
        
        # DMA Controller
        self.draw_component(canvas, 100, 450, 100, 50, "DMA\nController", box_color, line_color, text_color)
        
        # Interrupt Controller
        self.draw_component(canvas, 300, 450, 100, 50, "Interrupt\nController", box_color, line_color, text_color)
        
        # Connect DMA and INT to bus
        canvas.create_line(150, 380, 150, 450, fill=line_color, width=1)
        canvas.create_line(350, 380, 350, 450, fill=line_color, width=1)
        
        # Power and Control (bottom)
        self.draw_component(canvas, 60, 560, 80, 40, "Power\nSupply", '#330000', line_color, text_color)
        self.draw_component(canvas, 200, 560, 80, 40, "Clock\nGen", '#330000', line_color, text_color)
        self.draw_component(canvas, 340, 560, 80, 40, "Boot\nROM", '#330000', line_color, text_color)
        
        # Central connections
        canvas.create_line(250, 450, 250, 560, fill=line_color, width=2)
        canvas.create_text(260, 505, text="Control", fill=text_color, font=self.small_font)
        
        # Legend
        legend_y = 650
        canvas.create_text(30, legend_y, text="◆ CPU", fill=active_color, font=self.small_font, anchor="w")
        canvas.create_text(130, legend_y, text="◆ Memory", fill=line_color, font=self.small_font, anchor="w")
        canvas.create_text(230, legend_y, text="◆ Device", fill=line_color, font=self.small_font, anchor="w")
        canvas.create_text(330, legend_y, text="◆ Control", fill=line_color, font=self.small_font, anchor="w")
    
    def draw_component(self, canvas, x, y, width, height, label, fill_color, outline_color, text_color):
        """Draw a component box on the backplane"""
        canvas.create_rectangle(x, y, x + width, y + height, fill=fill_color, outline=outline_color, width=2)
        canvas.create_text(x + width/2, y + height/2, text=label, fill=text_color, font=self.small_font, justify="center")
    
    def update_component_status(self):
        """Update component status display"""
        self.status_text.config(state=tk.NORMAL)
        self.status_text.delete(1.0, tk.END)
        
        status_info = f"""
CPU Status: {"ACTIVE" if self.power_on else "STANDBY"}
    • Config Width:    {self.bit_mode}-bit
  • Program Counter: 0x{self.pc:04X}
  • Stack Pointer:   0x{self.sp:04X}
  • Flags Register:  0x{self.flags:02X}

Memory Status: {"OPERATIONAL" if self.power_on else "OFFLINE"}
  • RAM: 64 KB
  • ROM: 8 KB
  • Cache: 32-entry

Bus Status: {"ACTIVE" if self.running else "IDLE"}
    • Address Bus: 0x{self.address_bus:0{self.bit_mode // 4}X}
  • Data Bus:    0x{self.data_bus:02X}

I/O Status: {"ENABLED" if self.power_on else "DISABLED"}
  • Interrupts: {"ACTIVE" if self.interrupt else "MASKED"}
  • DMA: {"ACTIVE" if self.running else "IDLE"}
        """
        
        self.status_text.insert(1.0, status_info)
        self.status_text.config(state=tk.DISABLED)

    def set_bit_mode(self, value):
        """Set system configuration width to 16/32/64/128 bit."""
        try:
            mode = int(value)
        except ValueError:
            mode = 16
        if mode not in (16, 32, 64, 128):
            mode = 16
        self.bit_mode = mode
        self.address_mask = (1 << self.bit_mode) - 1
        self.address_bus &= self.address_mask
        self.pc &= self.address_mask
    
    def toggle_power(self):
        """Toggle power on/off"""
        self.power_on = not self.power_on
        color = '#00FF00' if self.power_on else '#FF0000'
        text = "POWER OFF" if self.power_on else "POWER ON"
        bg = '#002200' if self.power_on else '#220000'
        
        self.power_btn.config(text=text, bg=bg, fg=color)
        self.status_leds['POWER'].create_oval(5, 5, 35, 35, fill=color if self.power_on else '#330000')
        
        if not self.power_on:
            self.running = False
            self.halt = False
    
    def run_program(self):
        """Run the program"""
        if not self.power_on:
            messagebox.showwarning("Warning", "Power is OFF. Turn on power first!")
            return
        
        self.running = True
        messagebox.showinfo("Running", "Program execution started")
    
    def halt_program(self):
        """Halt the program"""
        self.halt = True
        self.running = False
        self.status_leds['HALT'].create_oval(5, 5, 35, 35, fill='#FF0000')
        messagebox.showinfo("Halted", "Program execution halted")
    
    def reset_system(self):
        """Reset the system"""
        self.running = False
        self.halt = False
        self.wait = False
        self.interrupt = False
        self.address_bus = 0x0000
        self.data_bus = 0x00
        self.pc = 0x0000
        self.sp = 0x8000
        
        for reg in self.registers:
            self.registers[reg] = 0x00
        
        messagebox.showinfo("Reset", "System reset complete")
    
    def animate_leds(self):
        """Animate LED displays"""
        if self.power_on:
            # Simulate address bus
            self.address_bus = (self.address_bus + 1) & self.address_mask if self.running else random.randint(0, self.address_mask)
            
            # Simulate data bus
            self.data_bus = (self.data_bus + 17) & 0xFF if self.running else random.randint(0, 0xFF)
            
            # Update registers
            if self.running:
                for reg in self.registers:
                    self.registers[reg] = (self.registers[reg] + 1) & 0xFF
                self.pc = (self.pc + 1) & self.address_mask
            
            # Update address LEDs
            for i, led in enumerate(self.address_leds):
                bit = ((self.address_bus & 0xFFFF) >> (15 - i)) & 1
                color = '#00FF00' if bit else '#003300'
                led.create_oval(2, 2, 23, 23, fill=color)
            
            # Update data LEDs
            for i, led in enumerate(self.data_leds):
                bit = (self.data_bus >> (7 - i)) & 1
                color = '#00FF00' if bit else '#003300'
                led.create_oval(2, 2, 28, 28, fill=color)
            
            # Update status LEDs
            for status, indicator in [('HALT', self.halt), ('WAIT', self.wait), ('INT', self.interrupt)]:
                color = '#FFFF00' if indicator else '#333300'
                self.status_leds[status].create_oval(5, 5, 35, 35, fill=color)
        
        else:
            # Power off - dim all LEDs
            for led in self.address_leds + self.data_leds:
                led.create_oval(2, 2, 23, 23, fill='#1a1a1a')
            
            for status in ['HALT', 'WAIT', 'INT']:
                self.status_leds[status].create_oval(5, 5, 35, 35, fill='#1a1a1a')
        
        # Update labels
        self.addr_value_label.config(text=f"0x{self.address_bus:0{self.bit_mode // 4}X}")
        self.data_value_label.config(text=f"0x{self.data_bus:02X}")
        self.pc_label.config(text=f"PC: 0x{self.pc:0{self.bit_mode // 4}X}")
        self.sp_label.config(text=f"SP: 0x{self.sp:04X}")
        
        for reg, value in self.registers.items():
            self.reg_labels[reg].config(text=f"{reg}: 0x{value:02X}")
        
        # Update switch buttons visual
        for i, btn in enumerate(self.switch_buttons):
            bg = '#00FF00' if self.switches[i] else '#333333'
            fg = '#000000' if self.switches[i] else '#00FF00'
            btn.config(bg=bg, fg=fg)
        
        # Update component status
        self.update_component_status()
        
        # Schedule next update
        self.root.after(100, self.animate_leds)
    
    def create_status_bar(self):
        """Create status bar at bottom"""
        status_bar = tk.Frame(self.root, bg='#333333', height=30)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        status_text = tk.Label(
            status_bar, 
            text="ALTAIR 8800 Emulator v2.0 | Status: Ready | Components: 17 | Assembly Lines: 13,000+",
            bg='#333333', fg='#00FF00', font=self.small_font, justify=tk.LEFT, padx=10
        )
        status_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)


def main():
    """Main entry point"""
    root = tk.Tk()
    app = ALTAIR8800UI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
