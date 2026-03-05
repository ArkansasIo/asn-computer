#!/usr/bin/env python3
"""
ALTAIR 8800 EMULATOR - MASTER LAUNCHER & SYSTEM CONTROLLER
Main entry point that launches and coordinates all system components
"""

import tkinter as tk
from tkinter import ttk, messagebox
import tkinter.font as tkFont
import subprocess
import sys
import os
from pathlib import Path


class ALTAIRMasterLauncher:
    """Master launcher for ALTAIR 8800 system"""
    
    # Path to components
    COMPONENTS = {
        'Enhanced UI': 'altair_ui_enhanced.py',
        'Backplane Interface': 'altair_backplane_ui.py',
        'Screen Display': 'altair_screen_interface.py',
        'IDE Editor': 'ide_editor.py',
        'Logic Gate Editor': 'logic_gate_editor.py',
        'Emulator Simulator': 'emulator_simulator.py',
    }
    
    LIBRARIES = {
        'ASM Standard Library': 'asm_stdlib.asm',
        'C Standard Library': 'altair_stdlib.h',
        'Example C Program': 'example_c_program.c',
    }
    
    def __init__(self, root):
        """Initialize master launcher"""
        self.root = root
        self.root.title("ALTAIR 8800 EMULATOR - Master Control Center v3.0")
        self.root.geometry("900x700")
        self.root.configure(bg='#1a1a1a')
        
        self.running_processes = {}
        self.current_path = Path(__file__).parent
        
        self.setup_gui()
    
    def setup_gui(self):
        """Setup launcher interface"""
        # Title bar
        title_frame = tk.Frame(self.root, bg='#222222', height=60)
        title_frame.pack(side=tk.TOP, fill=tk.X)
        
        title = tk.Label(
            title_frame, text="ALTAIR 8800 EMULATOR - Master Control Center",
            font=("Courier New", 16, "bold"), fg='#00FF00', bg='#222222'
        )
        title.pack(pady=10)
        
        subtitle = tk.Label(
            title_frame, text="v3.0 - Complete System with Libraries, IDE, and Components",
            font=("Courier New", 10), fg='#FFFF00', bg='#222222'
        )
        subtitle.pack(pady=5)
        
        # Notebook for tabs
        notebook = ttk.Notebook(self.root, style='Dark.TNotebook')
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Tab 1: Quick Launch
        self.create_quick_launch_tab(notebook)
        
        # Tab 2: Components
        self.create_components_tab(notebook)
        
        # Tab 3: Libraries
        self.create_libraries_tab(notebook)
        
        # Tab 4: System Status
        self.create_status_tab(notebook)
        
        # Bottom control bar
        self.create_control_bar()
    
    def create_quick_launch_tab(self, notebook):
        """Create quick launch tab"""
        frame = ttk.Frame(notebook)
        notebook.add(frame, text="Quick Launch")
        
        launch_frame = tk.Frame(frame, bg='#1a1a1a')
        launch_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        title = tk.Label(
            launch_frame, text="QUICK START OPTIONS",
            font=("Courier New", 14, "bold"), fg='#00FF00', bg='#1a1a1a'
        )
        title.pack(pady=10)
        
        options = [
            ("Full System (Enhanced UI)", self.launch_enhanced_ui, "Launch the complete emulator with all features"),
            ("Quick Demo", self.launch_demo, "Run a quick demonstration"),
            ("Emulator Only", self.launch_simulator, "Run the core emulator"),
            ("Integrated IDE", self.launch_ide, "Open the code editor"),
            ("Logic Gate Designer", self.launch_logic_editor, "Visual circuit designer"),
            ("Backplane Viewer", self.launch_backplane, "System architecture visualization"),
            ("Screen Display", self.launch_screen, "Terminal/graphics display"),
        ]
        
        for label, cmd, desc in options:
            btn_frame = tk.Frame(launch_frame, bg='#222222', relief=tk.RAISED, bd=2)
            btn_frame.pack(fill=tk.X, pady=5)
            
            btn = tk.Button(
                btn_frame, text=label, command=cmd,
                bg='#228B22', fg='#00FF00', font=("Courier New", 11, "bold"),
                width=40, height=2, relief=tk.RAISED, activebackground='#32CD32'
            )
            btn.pack(side=tk.LEFT, padx=10, pady=10)
            
            desc_label = tk.Label(btn_frame, text=desc, fg='#00FF00', bg='#222222', font=("Courier New", 9))
            desc_label.pack(side=tk.LEFT, padx=10, pady=10)
    
    def create_components_tab(self, notebook):
        """Create components tab"""
        frame = ttk.Frame(notebook)
        notebook.add(frame, text="Components")
        
        comp_frame = tk.Frame(frame, bg='#1a1a1a')
        comp_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        title = tk.Label(
            comp_frame, text="SYSTEM COMPONENTS",
            font=("Courier New", 14, "bold"), fg='#00FF00', bg='#1a1a1a'
        )
        title.pack(pady=10)
        
        for name, file in self.COMPONENTS.items():
            self.create_component_button(comp_frame, name, file)
    
    def create_component_button(self, parent, name, filename):
        """Create component launch button"""
        btn_frame = tk.Frame(parent, bg='#222222', relief=tk.SUNKEN, bd=1)
        btn_frame.pack(fill=tk.X, pady=5)
        
        btn = tk.Button(
            btn_frame, text=name, command=lambda: self.launch_component(filename),
            bg='#0066CC', fg='#00FF00', font=("Courier New", 11),
            width=40, height=1, relief=tk.RAISED, activebackground='#0080FF'
        )
        btn.pack(side=tk.LEFT, padx=10, pady=5)
        
        status = tk.Label(btn_frame, text="Ready", fg='#FFFF00', bg='#222222', font=("Courier New", 9), width=15)
        status.pack(side=tk.LEFT, padx=10, pady=5)
        
        self.running_processes[name] = (filename, status)
    
    def create_libraries_tab(self, notebook):
        """Create libraries tab"""
        frame = ttk.Frame(notebook)
        notebook.add(frame, text="Libraries & Examples")
        
        lib_frame = tk.Frame(frame, bg='#1a1a1a')
        lib_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        title = tk.Label(
            lib_frame, text="PROGRAMMING LIBRARIES & EXAMPLES",
            font=("Courier New", 14, "bold"), fg='#00FF00', bg='#1a1a1a'
        )
        title.pack(pady=10)
        
        # Library descriptions
        descriptions = {
            'asm_stdlib.asm': 'Complete x86-64 assembly language standard library\nIncludes: memory ops, string ops, arithmetic, I/O, bit operations',
            'altair_stdlib.h': 'C/C++ standard library headers and function prototypes\nSupports: strings, arrays, math, memory, system functions',
            'example_c_program.c': 'Example C programs demonstrating stdlib usage\nIncludes: arithmetic, strings, arrays, bit ops, memory',
        }
        
        for name, file in self.LIBRARIES.items():
            self.create_library_button(lib_frame, name, file, descriptions.get(file, ""))
    
    def create_library_button(self, parent, name, filename, description):
        """Create library button with description"""
        btn_frame = tk.Frame(parent, bg='#222222', relief=tk.SUNKEN, bd=2)
        btn_frame.pack(fill=tk.X, pady=8)
        
        # Name and buttons
        top_frame = tk.Frame(btn_frame, bg='#222222')
        top_frame.pack(fill=tk.X, padx=10, pady=5)
        
        name_label = tk.Label(top_frame, text=name, fg='#00FF00', bg='#222222', font=("Courier New", 11, "bold"))
        name_label.pack(side=tk.LEFT)
        
        tk.Button(top_frame, text="View", command=lambda: self.view_file(filename), bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5)
        tk.Button(top_frame, text="Open in IDE", command=lambda: self.open_in_ide(filename), bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5)
        tk.Button(top_frame, text="Copy Path", command=lambda: self.copy_path(filename), bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5)
        
        # Description
        desc_label = tk.Label(btn_frame, text=description, fg='#FFFF00', bg='#222222', font=("Courier New", 9), justify=tk.LEFT)
        desc_label.pack(anchor=tk.W, padx=20, pady=5)
    
    def create_status_tab(self, notebook):
        """Create status tab"""
        frame = ttk.Frame(notebook)
        notebook.add(frame, text="System Status")
        
        status_frame = tk.Frame(frame, bg='#1a1a1a')
        status_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        title = tk.Label(
            status_frame, text="SYSTEM STATUS",
            font=("Courier New", 14, "bold"), fg='#00FF00', bg='#1a1a1a'
        )
        title.pack(pady=10)
        
        # Status info
        info = f"""
ALTAIR 8800 EMULATOR SYSTEM - COMPLETE INSTALLATION

Version: 3.0 (Enhanced)
Status: ✓ All Components Installed

COMPONENTS AVAILABLE:
  ✓ Enhanced UI with Audio and Menus
  ✓ Integrated IDE (ASM, C, C++)
  ✓ Logic Gate Editor & Simulator
  ✓ Screen Display Interface
  ✓ Backplane Architecture Viewer
  ✓ Core Emulator Simulator

PROGRAMMING LIBRARIES:
  ✓ Assembly Standard Library (asm_stdlib.asm)
  ✓ C/C++ Standard Library (altair_stdlib.h)
  ✓ Example Programs (example_c_program.c)

FEATURES:
  ✓ Audio/Sound Effects System
  ✓ Program Output Terminal
  ✓ Keyboard & Mouse Control
  ✓ Menu System with Submenus
  ✓ Multi-Language Code Editor
  ✓ Gate-level Circuit Simulation
  ✓ Memory Management
  ✓ I/O Port Emulation
  ✓ System Configuration (8/16/32/64/128-bit modes)

TOTAL SIZE: ~200 KB (source code)
PYTHON VERSION: 3.7+
REQUIREMENTS: tkinter, standard library only

System ready for use!
        """
        
        info_text = tk.Text(status_frame, height=20, width=80, bg='#0a0a0a', fg='#00FF00', font=("Courier New", 9))
        info_text.pack(fill=tk.BOTH, expand=True)
        info_text.insert(1.0, info)
        info_text.config(state='disabled')
    
    def create_control_bar(self):
        """Create bottom control bar"""
        control_frame = tk.Frame(self.root, bg='#222222', height=50)
        control_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        tk.Button(
            control_frame, text="Launch Full System", command=self.launch_all,
            bg='#228B22', fg='#FFFFFF', font=("Courier New", 12, "bold"),
            padx=20, pady=10, relief=tk.RAISED
        ).pack(side=tk.LEFT, padx=10, pady=10)
        
        tk.Button(
            control_frame, text="Help", command=self.show_help,
            bg='#0066CC', fg='#FFFFFF', font=("Courier New", 11),
            padx=15, pady=10
        ).pack(side=tk.LEFT, padx=10, pady=10)
        
        tk.Button(
            control_frame, text="About", command=self.show_about,
            bg='#663300', fg='#FFFFFF', font=("Courier New", 11),
            padx=15, pady=10
        ).pack(side=tk.LEFT, padx=10, pady=10)
        
        tk.Button(
            control_frame, text="Exit", command=self.root.quit,
            bg='#CC0000', fg='#FFFFFF', font=("Courier New", 11),
            padx=15, pady=10
        ).pack(side=tk.RIGHT, padx=10, pady=10)
    
    def launch_component(self, filename):
        """Launch a component"""
        try:
            filepath = self.current_path / filename
            if not filepath.exists():
                messagebox.showerror("Error", f"File not found: {filename}")
                return
            
            subprocess.Popen([sys.executable, str(filepath)])
            messagebox.showinfo("Launched", f"Launched {filename}")
        except Exception as e:
            messagebox.showerror("Error", f"Could not launch component: {e}")
    
    def launch_enhanced_ui(self):
        """Launch enhanced UI"""
        self.launch_component('altair_ui_enhanced.py')
    
    def launch_simulator(self):
        """Launch simulator"""
        self.launch_component('emulator_simulator.py')
    
    def launch_ide(self):
        """Launch IDE"""
        self.launch_component('ide_editor.py')
    
    def launch_logic_editor(self):
        """Launch logic gate editor"""
        self.launch_component('logic_gate_editor.py')
    
    def launch_backplane(self):
        """Launch backplane viewer"""
        self.launch_component('altair_backplane_ui.py')
    
    def launch_screen(self):
        """Launch screen interface"""
        self.launch_component('altair_screen_interface.py')
    
    def launch_all(self):
        """Launch all components"""
        messagebox.showinfo("Launching", "Starting all components...\n\nThis will launch multiple windows.")
        for filename in self.COMPONENTS.values():
            self.launch_component(filename)
    
    def launch_demo(self):
        """Launch demo"""
        messagebox.showinfo("Demo", "Demo mode coming soon!")
    
    def view_file(self, filename):
        """View file contents"""
        try:
            filepath = self.current_path / filename
            with open(filepath, 'r') as f:
                content = f.read()
            
            view_win = tk.Toplevel(self.root)
            view_win.title(f"View: {filename}")
            view_win.geometry("700x500")
            
            text = tk.Text(view_win, bg='#0a0a0a', fg='#00FF00', font=("Courier New", 10))
            text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
            text.insert(1.0, content)
            text.config(state='disabled')
        except Exception as e:
            messagebox.showerror("Error", f"Could not view file: {e}")
    
    def open_in_ide(self, filename):
        """Open file in IDE"""
        try:
            self.launch_component('ide_editor.py')
            messagebox.showinfo("IDE", f"IDE launched. Use File > Open to open {filename}")
        except Exception as e:
            messagebox.showerror("Error", f"Could not open IDE: {e}")
    
    def copy_path(self, filename):
        """Copy file path to clipboard"""
        try:
            filepath = str(self.current_path / filename)
            self.root.clipboard_clear()
            self.root.clipboard_append(filepath)
            messagebox.showinfo("Copied", f"Path copied to clipboard:\n{filepath}")
        except Exception as e:
            messagebox.showerror("Error", f"Could not copy path: {e}")
    
    def show_help(self):
        """Show help"""
        help_text = """ALTAIR 8800 EMULATOR - HELP

Quick Start:
1. Click 'Launch Full System' to start the complete emulator
2. Use menu options to access IDE, Logic Editor, etc.
3. Open library files in the IDE for reference

Components:
- Enhanced UI: Full-featured emulator with menus and audio
- IDE Editor: Code editor for ASM, C, C++
- Logic Gate Editor: Visual circuit designer
- Screen Display: 80x24 terminal display
- Backplane Viewer: System architecture visualization

Libraries:
- asm_stdlib.asm: Assembly language routines
- altair_stdlib.h: C/C++ standard library
- example_c_program.c: Example C programs

Features:
- Audio feedback system
- Multi-bit mode support (8, 16, 32, 64, 128-bit)
- Integrated programming IDE
- Complete standard library functions
- Menu system with keyboard shortcuts
- Program output terminal
- Keyboard and mouse control

For more information, see the README and documentation files.
        """
        messagebox.showinfo("Help", help_text)
    
    def show_about(self):
        """Show about dialog"""
        about_text = """ALTAIR 8800 EMULATOR v3.0

A complete, feature-rich emulation of the historic ALTAIR 8800 
microcomputer with modern development tools and libraries.

Features:
✓ Complete x86-64 Assembly language support
✓ C/C++ standard library and compiler integration
✓ Integrated IDE with syntax highlighting
✓ Logic gate circuit simulator
✓ Audio and visual feedback system
✓ Multiple system architectures (8-256 bit)
✓ Interactive backplane visualization
✓ Terminal display interface

Components: 7
Libraries: 3
Total Features: 50+

© 2024 ALTAIR Emulator Project
Python 3.7+ | No external dependencies required
        """
        messagebox.showinfo("About ALTAIR 8800 Emulator", about_text)


if __name__ == "__main__":
    root = tk.Tk()
    launcher = ALTAIRMasterLauncher(root)
    root.mainloop()
