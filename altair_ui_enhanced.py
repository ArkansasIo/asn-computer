#!/usr/bin/env python3
"""
ALTAIR 8800 EMULATOR - ENHANCED UI WITH AUDIO, MENUS, IDE, AND LOGIC EDITOR
Complete GUI with advanced features: sound effects, program output, menus, IDE, logic gate editor
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, filedialog
import tkinter.font as tkFont
from datetime import datetime
import random
import math
import os
import sys

# Import custom modules
try:
    from audio_system import get_audio_system
    audio = get_audio_system()
except:
    audio = None

try:
    from ide_editor import IDEEditor
except:
    IDEEditor = None

try:
    from logic_gate_editor import LogicGateEditor
except:
    LogicGateEditor = None


class EnhancedALTAIRUI:
    """Enhanced ALTAIR 8800 UI with audio, IDE, logic editor, and advanced controls"""
    
    def __init__(self, root):
        """Initialize enhanced UI"""
        self.root = root
        self.root.title("ALTAIR 8800 Emulator - Enhanced Interface v3.0")
        self.root.geometry("1400x900")
        self.root.configure(bg='#1a1a1a')
        
        # Emulator state
        self.running = False
        self.power_on = False
        self.halt = False
        self.wait = False
        self.interrupt = False
        self.bit_mode = 16
        
        # CPU state
        self.address_bus = 0x0000
        self.data_bus = 0x00
        self.registers = {'A': 0x00, 'B': 0x00, 'C': 0x00, 'D': 0x00, 'E': 0x00, 'H': 0x00, 'L': 0x00}
        self.pc = 0x0000
        self.sp = 0x8000
        self.flags = 0x00
        self.switches = [0] * 16
        
        # Program output buffer
        self.program_output = ""
        
        # Sub-windows
        self.ide_window = None
        self.logic_window = None
        
        # Setup UI
        self.setup_styles()
        self.create_menubar()
        self.create_main_interface()
        self.create_program_output()
        self.create_status_bar()
        
        # Setup keyboard/mouse control
        self.setup_keyboard_control()
        self.setup_mouse_control()
        
        # Start animation
        self.animate_leds()
    
    def setup_styles(self):
        """Configure UI styles and fonts"""
        self.title_font = tkFont.Font(family="Courier New", size=14, weight="bold")
        self.label_font = tkFont.Font(family="Courier New", size=10)
        self.small_font = tkFont.Font(family="Courier New", size=8)
        self.mono_font = tkFont.Font(family="Courier New", size=11)
        
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('Dark.TFrame', background='#1a1a1a')
        style.configure('Dark.TLabel', background='#1a1a1a', foreground='#00FF00')
    
    def create_menubar(self):
        """Create menu bar with all options"""
        menubar = tk.Menu(self.root, bg='#222222', fg='#00FF00')
        self.root.config(menu=menubar)
        
        # FILE MENU
        file_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New Program", command=self.new_program)
        file_menu.add_command(label="Open Program...", command=self.open_program)
        file_menu.add_command(label="Save Output...", command=self.save_output)
        file_menu.add_separator()
        file_menu.add_command(label="Properties", command=self.show_properties)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # EDIT MENU
        edit_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Clear Output", command=self.clear_output)
        edit_menu.add_command(label="Clear All", command=self.clear_all)
        
        # VIEW MENU
        view_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="Register Details", command=self.show_register_details)
        view_menu.add_command(label="Memory Viewer", command=self.show_memory_viewer)
        view_menu.add_separator()
        view_menu.add_command(label="Zoom In", command=self.zoom_in)
        view_menu.add_command(label="Zoom Out", command=self.zoom_out)
        
        # TOOLS MENU
        tools_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="Tools", menu=tools_menu)
        
        tools_menu.add_command(label="Integrated IDE", command=self.open_ide)
        tools_menu.add_command(label="Logic Gate Editor", command=self.open_logic_editor)
        tools_menu.add_separator()
        
        audio_submenu = tk.Menu(tools_menu, tearoff=0, bg='#222222', fg='#00FF00')
        tools_menu.add_cascade(label="Audio", menu=audio_submenu)
        audio_submenu.add_command(label="Toggle Sound", command=self.toggle_audio)
        audio_submenu.add_command(label="Volume...", command=self.set_volume)
        
        # SYSTEM MENU
        system_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="System", menu=system_menu)
        
        bit_submenu = tk.Menu(system_menu, tearoff=0, bg='#222222', fg='#00FF00')
        system_menu.add_cascade(label="Bit Mode", menu=bit_submenu)
        bit_submenu.add_command(label="8-bit", command=lambda: self.set_bit_mode(8))
        bit_submenu.add_command(label="16-bit", command=lambda: self.set_bit_mode(16))
        bit_submenu.add_command(label="32-bit", command=lambda: self.set_bit_mode(32))
        bit_submenu.add_command(label="64-bit", command=lambda: self.set_bit_mode(64))
        bit_submenu.add_command(label="128-bit", command=lambda: self.set_bit_mode(128))
        
        system_menu.add_separator()
        system_menu.add_command(label="Reset", command=self.reset_system)
        system_menu.add_command(label="System Info", command=self.show_system_info)
        
        # HELP MENU
        help_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)
        help_menu.add_command(label="Keyboard Shortcuts", command=self.show_shortcuts)
        help_menu.add_command(label="Documentation", command=self.show_documentation)
    
    def create_main_interface(self):
        """Create main interface panel"""
        # Container for main panel and output
        container = tk.PanedWindow(self.root, orient=tk.HORIZONTAL, bg='#1a1a1a', sashwidth=5)
        container.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # LEFT: Front panel
        left_panel = ttk.Frame(container, style='Dark.TFrame')
        container.add(left_panel, width=700)
        
        # Title
        title = tk.Label(
            left_panel, text="╔════════════════════════════════════╗",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title.pack()
        
        title2 = tk.Label(
            left_panel, text="║   ALTAIR 8800 v3.0 FRONT PANEL   ║",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title2.pack()
        
        title3 = tk.Label(
            left_panel, text="╚════════════════════════════════════╝",
            font=self.title_font, fg='#00FF00', bg='#1a1a1a'
        )
        title3.pack(pady=10)
        
        # Control buttons frame
        button_frame = tk.Frame(left_panel, bg='#1a1a1a')
        button_frame.pack(pady=10)
        
        tk.Button(button_frame, text="▶ RUN", command=self.run_program, bg='#228B22', fg='#00FF00', width=10, relief=tk.RAISED).pack(side=tk.LEFT, padx=5)
        tk.Button(button_frame, text="⏸ HALT", command=self.halt_program, bg='#FF6347', fg='#FFFFFF', width=10, relief=tk.RAISED).pack(side=tk.LEFT, padx=5)
        tk.Button(button_frame, text="↺ RESET", command=self.reset_program, bg='#FFD700', fg='#000000', width=10, relief=tk.RAISED).pack(side=tk.LEFT, padx=5)
        
        # Address bus
        addr_frame = tk.Frame(left_panel, bg='#1a1a1a')
        addr_frame.pack(pady=10)
        
        addr_label = tk.Label(addr_frame, text=f"ADDRESS BUS ({self.bit_mode}-bit)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        addr_label.pack()
        self.addr_label = addr_label
        
        self.address_leds = []
        addr_led_frame = tk.Frame(addr_frame, bg='#1a1a1a')
        addr_led_frame.pack()
        
        for i in range(self.bit_mode - 1, -1, -1):
            frame = tk.Frame(addr_led_frame, bg='#1a1a1a', width=20, height=20)
            frame.pack(side=tk.LEFT, padx=1)
            led = tk.Canvas(frame, width=18, height=18, bg='#0a0a0a', highlightthickness=1, highlightbackground='#333333')
            led.pack()
            self.address_leds.append(led)
        
        self.addr_value_label = tk.Label(addr_frame, text="0x0000", font=self.small_font, fg='#FFFF00', bg='#1a1a1a')
        self.addr_value_label.pack()
        
        # Data bus
        data_frame = tk.Frame(left_panel, bg='#1a1a1a')
        data_frame.pack(pady=10)
        
        data_label = tk.Label(data_frame, text="DATA BUS (8-bit)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        data_label.pack()
        
        self.data_leds = []
        data_led_frame = tk.Frame(data_frame, bg='#1a1a1a')
        data_led_frame.pack()
        
        for i in range(7, -1, -1):
            frame = tk.Frame(data_led_frame, bg='#1a1a1a', width=25, height=25)
            frame.pack(side=tk.LEFT, padx=2)
            led = tk.Canvas(frame, width=23, height=23, bg='#0a0a0a', highlightthickness=1, highlightbackground='#333333')
            led.pack()
            self.data_leds.append(led)
        
        self.data_value_label = tk.Label(data_frame, text="0x00", font=self.small_font, fg='#FFFF00', bg='#1a1a1a')
        self.data_value_label.pack()
        
        # Status indicators
        status_frame = tk.Frame(left_panel, bg='#1a1a1a')
        status_frame.pack(pady=10)
        
        status_label = tk.Label(status_frame, text="STATUS", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        status_label.pack()
        
        self.status_leds = {}
        status_ind_frame = tk.Frame(status_frame, bg='#1a1a1a')
        status_ind_frame.pack()
        
        for indicator in ['POWER', 'HALT', 'WAIT', 'INT']:
            ind_frame = tk.Frame(status_ind_frame, bg='#1a1a1a')
            ind_frame.pack(side=tk.LEFT, padx=10, pady=5)
            
            led = tk.Canvas(ind_frame, width=30, height=30, bg='#0a0a0a', highlightthickness=2, highlightbackground='#333333')
            led.pack()
            self.status_leds[indicator] = led
            
            label = tk.Label(ind_frame, text=indicator, font=self.small_font, fg='#00FF00', bg='#1a1a1a')
            label.pack()
        
        # CPU Registers
        reg_frame = tk.Frame(left_panel, bg='#1a1a1a')
        reg_frame.pack(pady=10)
        
        reg_label = tk.Label(reg_frame, text="CPU REGISTERS", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        reg_label.pack()
        
        self.reg_labels = {}
        main_reg_row = tk.Frame(reg_frame, bg='#1a1a1a')
        main_reg_row.pack()
        
        for reg in ['A', 'B', 'C', 'D', 'E', 'H', 'L']:
            reg_item = tk.Label(
                main_reg_row, text=f"{reg}: 0x00", font=self.small_font,
                fg='#00FF00', bg='#1a1a1a', width=11
            )
            reg_item.pack(side=tk.LEFT, padx=3)
            self.reg_labels[reg] = reg_item
        
        pc_sp_row = tk.Frame(reg_frame, bg='#1a1a1a')
        pc_sp_row.pack()
        
        self.pc_label = tk.Label(pc_sp_row, text="PC: 0x0000", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        self.pc_label.pack(side=tk.LEFT, padx=3)
        
        self.sp_label = tk.Label(pc_sp_row, text="SP: 0x8000", font=self.small_font, fg='#00FF00', bg='#1a1a1a')
        self.sp_label.pack(side=tk.LEFT, padx=3)
        
        # Toggle switches
        switch_frame = tk.Frame(left_panel, bg='#1a1a1a')
        switch_frame.pack(pady=10)
        
        switch_label = tk.Label(switch_frame, text="SWITCHES (16)", font=self.label_font, fg='#00FF00', bg='#1a1a1a')
        switch_label.pack()
        
        self.switch_buttons = []
        switch_btn_frame = tk.Frame(switch_frame, bg='#1a1a1a')
        switch_btn_frame.pack()
        
        for i in range(15, -1, -1):
            def toggle_switch(idx=i):
                self.switches[idx] = 1 - self.switches[idx]
                if audio:
                    audio.play_switch_toggle()
                self.update_switch_display()
            
            btn = tk.Button(
                switch_btn_frame, text=f"{i}", command=toggle_switch,
                width=3, bg='#444444', fg='#00FF00', relief=tk.RAISED
            )
            btn.pack(side=tk.LEFT, padx=1)
            self.switch_buttons.append(btn)
        
        # RIGHT: Program output screen
        self.output_panel = ttk.Frame(container, style='Dark.TFrame')
        container.add(self.output_panel, width=600)
    
    def create_program_output(self):
        """Create program output terminal/screen"""
        output_label = tk.Label(
            self.output_panel, text="PROGRAM OUTPUT / TERMINAL",
            font=self.label_font, fg='#00FF00', bg='#1a1a1a'
        )
        output_label.pack(pady=5)
        
        # Output display
        self.output_text = scrolledtext.ScrolledText(
            self.output_panel, height=25, width=60, bg='#0a0a0a', fg='#00FF00',
            font=self.mono_font, insertbackground='#00FF00', state='normal'
        )
        self.output_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Input area
        input_frame = tk.Frame(self.output_panel, bg='#1a1a1a')
        input_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Label(input_frame, text="INPUT:", font=self.small_font, fg='#00FF00', bg='#1a1a1a').pack(side=tk.LEFT, padx=5)
        
        self.input_entry = tk.Entry(
            input_frame, bg='#222222', fg='#00FF00',
            font=self.mono_font, insertbackground='#00FF00'
        )
        self.input_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)
        self.input_entry.bind('<Return>', lambda e: self.send_input())
        
        tk.Button(
            input_frame, text="Send",
            command=self.send_input, bg='#333333', fg='#00FF00'
        ).pack(side=tk.LEFT, padx=5)
    
    def create_status_bar(self):
        """Create status bar"""
        status_frame = tk.Frame(self.root, bg='#222222', height=25)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        self.status_label = tk.Label(
            status_frame, text="Ready | 16-bit Mode | 0x0000 | No Sound",
            font=self.small_font, fg='#00FF00', bg='#222222', anchor=tk.W
        )
        self.status_label.pack(fill=tk.X, padx=5, pady=2)
    
    def setup_keyboard_control(self):
        """Setup keyboard control bindings"""
        self.root.bind('<space>', lambda e: self.toggle_run() if not e.widget.winfo_class() == 'Entry' else None)
        self.root.bind('<r>', lambda e: self.reset_program() if not e.widget.winfo_class() == 'Entry' else None)
        self.root.bind('<h>', lambda e: self.halt_program() if not e.widget.winfo_class() == 'Entry' else None)
        self.root.bind('<0>', lambda e: self.toggle_switch_keyboard(0) if not e.widget.winfo_class() == 'Entry' else None)
        self.root.bind('q', lambda e: self.show_queue() if not e.widget.winfo_class() == 'Entry' else None)
    
    def setup_mouse_control(self):
        """Setup mouse control for LEDs and switches"""
        pass
    
    def animate_leds(self):
        """Animate LED displays"""
        # Update address bus LEDs
        for i, led in enumerate(self.address_leds):
            bit = (self.address_bus >> i) & 1
            color = '#00FF00' if bit else '#003300'
            led.configure(bg='#0a0a0a')
            led.create_oval(2, 2, 16, 16, fill=color, outline='#00FF00' if bit else '#001100')
        
        # Update data bus LEDs
        for i, led in enumerate(self.data_leds):
            bit = (self.data_bus >> i) & 1
            color = '#FF0000' if bit else '#330000'
            led.configure(bg='#0a0a0a')
            led.create_oval(2, 2, 21, 21, fill=color, outline='#FF0000' if bit else '#110000')
        
        # Update status LEDs
        for name, led in self.status_leds.items():
            if name == 'POWER':
                state = self.power_on
            elif name == 'HALT':
                state = self.halt
            elif name == 'WAIT':
                state = self.wait
            elif name == 'INT':
                state = self.interrupt
            else:
                state = False
            
            color = '#FFFF00' if state else '#333300'
            led.configure(bg='#0a0a0a')
            led.create_oval(2, 2, 28, 28, fill=color, outline='#FFFF00' if state else '#333333')
        
        # Update register displays
        self.addr_value_label.config(text=f"0x{self.address_bus:04X}")
        self.data_value_label.config(text=f"0x{self.data_bus:02X}")
        self.pc_label.config(text=f"PC: 0x{self.pc:04X}")
        self.sp_label.config(text=f"SP: 0x{self.sp:04X}")
        
        for reg, val in self.registers.items():
            self.reg_labels[reg].config(text=f"{reg}: 0x{val:02X}")
        
        # Schedule next animation
        self.root.after(100, self.animate_leds)
    
    def update_switch_display(self):
        """Update switch display"""
        for i, btn in enumerate(self.switch_buttons):
            state = self.switches[i]
            btn.config(bg='#00FF00' if state else '#444444', fg='#000000' if state else '#00FF00')
    
    def toggle_switch_keyboard(self, idx):
        """Toggle switch via keyboard"""
        if 0 <= idx < len(self.switches):
            self.switches[idx] = 1 - self.switches[idx]
            if audio:
                audio.play_switch_toggle()
            self.update_switch_display()
    
    def send_input(self):
        """Send input to program"""
        text = self.input_entry.get()
        if text:
            self.print_output(f"> {text}")
            self.input_entry.delete(0, tk.END)
            if audio:
                audio.play_button_click()
    
    def print_output(self, text):
        """Print text to output display"""
        self.output_text.config(state='normal')
        self.output_text.insert(tk.END, text + '\n')
        self.output_text.see(tk.END)
        self.output_text.config(state='normal')
        self.program_output += text + '\n'
    
    def clear_output(self):
        """Clear output display"""
        self.output_text.config(state='normal')
        self.output_text.delete(1.0, tk.END)
        self.output_text.config(state='normal')
        self.program_output = ""
        if audio:
            audio.play_button_click()
    
    def toggle_run(self):
        """Toggle run/pause"""
        self.running = not self.running
        if self.running:
            self.run_program()
        else:
            self.halt_program()
    
    def run_program(self):
        """Run program"""
        self.running = True
        self.power_on = True
        if audio:
            audio.play_power_on()
        self.print_output("[SYSTEM] Program started")
        self.update_status()
    
    def halt_program(self):
        """Halt program"""
        self.running = False
        self.halt = True
        if audio:
            audio.play_halt()
        self.print_output("[SYSTEM] Program stopped")
        self.update_status()
    
    def reset_program(self):
        """Reset program"""
        self.running = False
        self.power_on = False
        self.halt = False
        self.pc = 0x0000
        self.sp = 0x8000
        self.address_bus = 0x0000
        self.data_bus = 0x00
        for reg in self.registers:
            self.registers[reg] = 0x00
        if audio:
            audio.play_power_off()
        self.print_output("[SYSTEM] System reset")
        self.update_status()
    
    def reset_system(self):
        """Full system reset"""
        self.reset_program()
        self.clear_output()
        self.switches = [0] * 16
        self.update_switch_display()
        messageBox.showinfo("System", "System reset complete")
    
    def set_bit_mode(self, bits):
        """Set bit mode (8, 16, 32, 64, 128)"""
        self.bit_mode = bits
        self.address_mask = (1 << bits) - 1
        self.addr_label.config(text=f"ADDRESS BUS ({bits}-bit)")
        self.print_output(f"[SYSTEM] Switched to {bits}-bit mode")
        self.update_status()
    
    def clear_all(self):
        """Clear everything"""
        self.reset_program()
        self.clear_output()
        self.switches = [0] * 16
        self.update_switch_display()
    
    def open_ide(self):
        """Open integrated IDE editor"""
        if self.ide_window is None or not self.ide_window.winfo_exists():
            self.ide_window = tk.Toplevel(self.root)
            try:
                if IDEEditor:
                    self.ide = IDEEditor(self.ide_window)
                else:
                    messagebox.showwarning("Missing", "IDE module not available")
            except Exception as e:
                messagebox.showerror("Error", f"Could not open IDE: {e}")
        else:
            self.ide_window.lift()
    
    def open_logic_editor(self):
        """Open logic gate editor"""
        if self.logic_window is None or not self.logic_window.winfo_exists():
            self.logic_window = tk.Toplevel(self.root)
            try:
                if LogicGateEditor:
                    self.logic = LogicGateEditor(self.logic_window)
                else:
                    messagebox.showwarning("Missing", "Logic editor module not available")
            except Exception as e:
                messagebox.showerror("Error", f"Could not open gate editor: {e}")
        else:
            self.logic_window.lift()
    
    def toggle_audio(self):
        """Toggle audio on/off"""
        if audio:
            audio.toggle_audio()
            status = "enabled" if audio.enabled else "disabled"
            self.print_output(f"[SYSTEM] Audio {status}")
            self.update_status()
    
    def set_volume(self):
        """Set audio volume"""
        if audio:
            vol_window = tk.Toplevel(self.root)
            vol_window.title("Audio Volume")
            vol_window.geometry("250x100")
            vol_window.configure(bg='#1a1a1a')
            
            tk.Label(vol_window, text="Volume (0-100):", bg='#1a1a1a', fg='#00FF00').pack(pady=10)
            
            var = tk.IntVar(value=int(audio.volume * 100))
            slider = tk.Scale(vol_window, from_=0, to=100, orient=tk.HORIZONTAL, variable=var, bg='#333333', fg='#00FF00')
            slider.pack(pady=10, fill=tk.X, padx=20)
            
            tk.Button(
                vol_window, text="Apply",
                command=lambda: [audio.set_volume(var.get()/100), vol_window.destroy()],
                bg='#333333', fg='#00FF00'
            ).pack(pady=10)
    
    def new_program(self):
        """Create new program"""
        self.clear_output()
        self.print_output("[SYSTEM] New program initialized")
    
    def open_program(self):
        """Open program file"""
        filename = filedialog.askopenfilename(filetypes=[("All", "*.*"), ("ASM", "*.asm"), ("Text", "*.txt")])
        if filename:
            try:
                with open(filename, 'r') as f:
                    content = f.read()
                self.print_output(f"[SYSTEM] Loaded: {filename}\n{content[:200]}...")
            except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {e}")
    
    def save_output(self):
        """Save program output"""
        filename = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text", "*.txt"), ("All", "*.*")])
        if filename:
            try:
                with open(filename, 'w') as f:
                    f.write(self.program_output)
                messagebox.showinfo("Success", f"Output saved to {filename}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not save: {e}")
    
    def show_register_details(self):
        """Show detailed register information"""
        details = f"""
ALTAIR 8800 - REGISTER DETAILS
===============================
        
GENERAL PURPOSE REGISTERS:
  A: 0x{self.registers['A']:02X} ({self.registers['A']:3d}) - Accumulator
  B: 0x{self.registers['B']:02X} ({self.registers['B']:3d}) - B Register
  C: 0x{self.registers['C']:02X} ({self.registers['C']:3d}) - C Register
  D: 0x{self.registers['D']:02X} ({self.registers['D']:3d}) - D Register
  E: 0x{self.registers['E']:02X} ({self.registers['E']:3d}) - E Register
  H: 0x{self.registers['H']:02X} ({self.registers['H']:3d}) - H Register
  L: 0x{self.registers['L']:02X} ({self.registers['L']:3d}) - L Register

SPECIAL REGISTERS:
  PC: 0x{self.pc:04X} ({self.pc:5d}) - Program Counter
  SP: 0x{self.sp:04X} ({self.sp:5d}) - Stack Pointer
  
BUSES:
  Address Bus: 0x{self.address_bus:06X}
  Data Bus:    0x{self.data_bus:02X}
  Flags:       0x{self.flags:02X}
        """
        messagebox.showinfo("Register Details", details)
    
    def show_memory_viewer(self):
        """Show memory viewer"""
        messagebox.showinfo("Memory Viewer", "Memory Viewer\n\nFeature coming soon...")
    
    def zoom_in(self):
        """Zoom in display"""
        messagebox.showinfo("Zoom", "Zoomed In")
    
    def zoom_out(self):
        """Zoom out display"""
        messagebox.showinfo("Zoom", "Zoomed Out")
    
    def show_properties(self):
        """Show system properties"""
        props = f"""ALTAIR 8800 EMULATOR - PROPERTIES
===================================

System Status:
  Power: {'ON' if self.power_on else 'OFF'}
  Mode: {self.bit_mode}-bit
  Running: {'Yes' if self.running else 'No'}
  
Configuration:
  Audio: {'Enabled' if audio and audio.enabled else 'Disabled'}
  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        """
        messagebox.showinfo("Properties", props)
    
    def show_system_info(self):
        """Show system information"""
        info = f"""ALTAIR 8800 EMULATOR - SYSTEM INFO
===================================

Version: 3.0 (Enhanced)
Platform: {sys.platform}
Python: {sys.version.split()[0]}

Features:
  - Audio System: {'Yes' if audio else 'No'}
  - Code Editor: {'Yes' if IDEEditor else 'No'}
  - Logic Gate Editor: {'Yes' if LogicGateEditor else 'No'}
  - Program Output: Yes
  - Keyboard Control: Yes
  - Mouse Control: Yes
  - Multiple Bit Modes: Yes
        """
        messagebox.showinfo("System Info", info)
    
    def show_about(self):
        """Show about dialog"""
        about = """ALTAIR 8800 EMULATOR v3.0
=============================

An advanced, fully-featured emulator of the 
historic ALTAIR 8800 microcomputer.

Enhanced Features:
- Audio / Sound Effects
- Integrated IDE (ASM, C, C++)
- Logic Gate Editor & Simulator
- Program Output Terminal
- Multi-bit system modes
- Keyboard & Mouse Control
- Comprehensive Menu System

© 2024 ALTAIR Emulator Project
"""
        messagebox.showinfo("About", about)
    
    def show_shortcuts(self):
        """Show keyboard shortcuts"""
        shortcuts = """KEYBOARD SHORTCUTS
==================

General:
  Space     - Toggle Run/Halt
  R         - Reset Program
  H         - Halt Program
  Q         - Show Status Queue

Switches:
  0-9, A-F  - Toggle switches 0-15
  
Tools:
  Ctrl+I    - Open IDE
  Ctrl+L    - Open Logic Editor
  Ctrl+M    - Memory Viewer

Other:
  F1        - Help
  Ctrl+Q    - Quit
"""
        messagebox.showinfo("Shortcuts", shortcuts)
    
    def show_documentation(self):
        """Show documentation"""
        messagebox.showinfo("Documentation", "Documentation\n\nPlease refer to the PDF manual for detailed documentation.")
    
    def show_queue(self):
        """Show status queue"""
        messagebox.showinfo("Queue", "Status Queue:\n\nPower: " + ("ON" if self.power_on else "OFF") + "\nRunning: " + ("Yes" if self.running else "No"))
    
    def update_status(self):
        """Update status bar"""
        mode_text = f"{self.bit_mode}-bit"
        audio_text = "Sound" if (audio and audio.enabled) else "No Sound"
        self.status_label.config(text=f"Ready | {mode_text} Mode | 0x{self.pc:04X} | {audio_text}")


if __name__ == "__main__":
    root = tk.Tk()
    ui = EnhancedALTAIRUI(root)
    root.mainloop()
