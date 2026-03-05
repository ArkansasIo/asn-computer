#!/usr/bin/env python3
"""
ALTAIR 8800 SCREEN INTERFACE - Terminal and Graphics Display
Provides character display, graphics mode, and cursor control
"""

import tkinter as tk
from tkinter import scrolledtext
import tkinter.font as tkFont
import random


class ScreenInterface:
    """ALTAIR 8800 Screen/Display Interface"""
    
    # Display modes
    MODE_TEXT = 0
    MODE_GRAPHICS = 1
    MODE_MIXED = 2
    
    # Screen dimensions
    COLS_DEFAULT = 80
    ROWS_DEFAULT = 24
    
    def __init__(self, root=None, cols=80, rows=24):
        """Initialize screen interface"""
        self.root = root if root else tk.Tk()
        self.root.title("ALTAIR 8800 - Screen Display")
        self.root.configure(bg='#0a0a0a')
        
        self.cols = cols
        self.rows = rows
        self.mode = self.MODE_TEXT
        self.cursor_x = 0
        self.cursor_y = 0
        self.cursor_visible = True
        self.fg_color = '#00FF00'
        self.bg_color = '#0a0a0a'
        
        # Screen buffer (character grid)
        self.screen_buffer = [[' ' for _ in range(cols)] for _ in range(rows)]
        self.color_buffer = [[('#00FF00', '#0a0a0a') for _ in range(cols)] for _ in range(rows)]
        
        # Graphics buffer (pixel data)
        self.graphics_buffer = [[0 for _ in range(320)] for _ in range(192)]
        
        self.setup_gui()
        self.animate_cursor()
    
    def setup_gui(self):
        """Setup screen display interface"""
        # Top control bar
        control_frame = tk.Frame(self.root, bg='#222222', height=40)
        control_frame.pack(side=tk.TOP, fill=tk.X)
        
        tk.Label(control_frame, text="DISPLAY CONTROL:", fg='#00FF00', bg='#222222', font=("Courier New", 10, "bold")).pack(side=tk.LEFT, padx=10, pady=5)
        
        tk.Button(control_frame, text="Clear Screen", command=self.clear_screen, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(control_frame, text="Text Mode", command=lambda: self.set_mode(self.MODE_TEXT), bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(control_frame, text="Graphics Mode", command=lambda: self.set_mode(self.MODE_GRAPHICS), bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(control_frame, text="Save Screen", command=self.save_screen, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        
        # Mode indicator
        self.mode_label = tk.Label(control_frame, text="Mode: TEXT", fg='#FFFF00', bg='#222222', font=("Courier New", 10))
        self.mode_label.pack(side=tk.RIGHT, padx=10, pady=5)
        
        # Main display canvas
        if self.mode == self.MODE_TEXT:
            self.create_text_display()
        else:
            self.create_graphics_display()
    
    def create_text_display(self):
        """Create text mode display"""
        # Character display using text widget
        display_frame = tk.Frame(self.root, bg='#0a0a0a')
        display_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Fixed-width font for terminal
        self.terminal_font = tkFont.Font(family="Courier New", size=11)
        
        self.text_display = tk.Text(
            display_frame,
            width=self.cols,
            height=self.rows,
            bg='#0a0a0a',
            fg='#00FF00',
            font=self.terminal_font,
            insertbackground='#00FF00',
            state='disabled',
            relief=tk.SUNKEN,
            borderwidth=2
        )
        self.text_display.pack(fill=tk.BOTH, expand=True)
        
        # Render initial screen
        self.render_text_screen()
    
    def create_graphics_display(self):
        """Create graphics mode display"""
        display_frame = tk.Frame(self.root, bg='#0a0a0a')
        display_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Canvas for graphics
        self.graphics_canvas = tk.Canvas(
            display_frame,
            width=640,
            height=384,
            bg='#0a0a0a',
            highlightthickness=2,
            highlightbackground='#333333'
        )
        self.graphics_canvas.pack(fill=tk.BOTH, expand=True)
        
        self.render_graphics_screen()
    
    def set_mode(self, mode):
        """Switch display mode"""
        self.mode = mode
        
        # Clear existing widgets
        for widget in self.root.winfo_children():
            if widget.winfo_class() not in ['Frame', 'Label', 'Button']:
                widget.destroy()
        
        # Recreate display
        if mode == self.MODE_TEXT:
            self.create_text_display()
            self.mode_label.config(text="Mode: TEXT")
        elif mode == self.MODE_GRAPHICS:
            self.create_graphics_display()
            self.mode_label.config(text="Mode: GRAPHICS")
        else:
            self.create_text_display()
            self.mode_label.config(text="Mode: MIXED")
    
    def render_text_screen(self):
        """Render text mode screen"""
        self.text_display.config(state='normal')
        self.text_display.delete(1.0, tk.END)
        
        for row in self.screen_buffer:
            self.text_display.insert(tk.END, ''.join(row) + '\n')
        
        self.text_display.config(state='disabled')
    
    def render_graphics_screen(self):
        """Render graphics mode screen"""
        self.graphics_canvas.delete("all")
        
        # Draw pixel grid
        pixel_width = 2  # Scale up pixels for visibility
        
        for y in range(192):
            for x in range(320):
                if self.graphics_buffer[y][x]:
                    color = '#00FF00'
                else:
                    color = '#0a0a0a'
                
                self.graphics_canvas.create_rectangle(
                    x * pixel_width, y * pixel_width,
                    (x + 1) * pixel_width, (y + 1) * pixel_width,
                    fill=color, outline=color
                )
    
    def putchar(self, char, x=None, y=None):
        """Put character at cursor position or specified position"""
        if x is None:
            x = self.cursor_x
        if y is None:
            y = self.cursor_y
        
        if 0 <= y < self.rows and 0 <= x < self.cols:
            self.screen_buffer[y][x] = char
            self.cursor_x += 1
            
            if self.cursor_x >= self.cols:
                self.cursor_x = 0
                self.cursor_y += 1
                
                if self.cursor_y >= self.rows:
                    self.scroll_up()
                    self.cursor_y = self.rows - 1
            
            self.render_text_screen()
    
    def putstr(self, text):
        """Put string on screen"""
        for char in text:
            if char == '\n':
                self.cursor_x = 0
                self.cursor_y += 1
                if self.cursor_y >= self.rows:
                    self.scroll_up()
                    self.cursor_y = self.rows - 1
            elif char == '\t':
                self.cursor_x = (self.cursor_x + 8) & ~7
                if self.cursor_x >= self.cols:
                    self.cursor_x = 0
                    self.cursor_y += 1
                    if self.cursor_y >= self.rows:
                        self.scroll_up()
                        self.cursor_y = self.rows - 1
            else:
                self.putchar(char)
    
    def gotoxy(self, x, y):
        """Move cursor to position"""
        if 0 <= x < self.cols and 0 <= y < self.rows:
            self.cursor_x = x
            self.cursor_y = y
    
    def clear_screen(self):
        """Clear entire screen"""
        self.screen_buffer = [[' ' for _ in range(self.cols)] for _ in range(self.rows)]
        self.color_buffer = [[('#00FF00', '#0a0a0a') for _ in range(self.cols)] for _ in range(self.rows)]
        self.cursor_x = 0
        self.cursor_y = 0
        self.render_text_screen()
    
    def clear_line(self):
        """Clear current line"""
        self.screen_buffer[self.cursor_y] = [' ' for _ in range(self.cols)]
        self.render_text_screen()
    
    def scroll_up(self):
        """Scroll screen up one line"""
        self.screen_buffer = self.screen_buffer[1:] + [[' ' for _ in range(self.cols)]]
        self.color_buffer = self.color_buffer[1:] + [[('#00FF00', '#0a0a0a') for _ in range(self.cols)]]
        self.render_text_screen()
    
    def scroll_down(self):
        """Scroll screen down one line"""
        self.screen_buffer = [[' ' for _ in range(self.cols)]] + self.screen_buffer[:-1]
        self.color_buffer = [[('#00FF00', '#0a0a0a') for _ in range(self.cols)]] + self.color_buffer[:-1]
        self.render_text_screen()
    
    def set_color(self, fg='#00FF00', bg='#0a0a0a'):
        """Set foreground and background colors"""
        self.fg_color = fg
        self.bg_color = bg
    
    def set_attribute(self, x, y, fg, bg):
        """Set color attributes at position"""
        if 0 <= y < self.rows and 0 <= x < self.cols:
            self.color_buffer[y][x] = (fg, bg)
    
    def putpixel(self, x, y, color=1):
        """Put pixel in graphics mode"""
        if 0 <= y < 192 and 0 <= x < 320:
            self.graphics_buffer[y][x] = color
    
    def line(self, x1, y1, x2, y2, color=1):
        """Draw line in graphics mode (Bresenham algorithm)"""
        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        sx = 1 if x1 < x2 else -1
        sy = 1 if y1 < y2 else -1
        err = dx - dy
        
        x, y = x1, y1
        while True:
            self.putpixel(x, y, color)
            if x == x2 and y == y2:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x += sx
            if e2 < dx:
                err += dx
                y += sy
    
    def rectangle(self, x1, y1, x2, y2, color=1, filled=False):
        """Draw rectangle in graphics mode"""
        if filled:
            for y in range(y1, y2 + 1):
                self.line(x1, y, x2, y, color)
        else:
            self.line(x1, y1, x2, y1, color)
            self.line(x2, y1, x2, y2, color)
            self.line(x2, y2, x1, y2, color)
            self.line(x1, y2, x1, y1, color)
    
    def circle(self, cx, cy, radius, color=1, filled=False):
        """Draw circle in graphics mode (Midpoint circle algorithm)"""
        x = 0
        y = radius
        d = 3 - 2 * radius
        
        while x <= y:
            if filled:
                self.line(cx - x, cy + y, cx + x, cy + y, color)
                self.line(cx - x, cy - y, cx + x, cy - y, color)
                self.line(cx - y, cy + x, cx + y, cy + x, color)
                self.line(cx - y, cy - x, cx + y, cy - x, color)
            else:
                self.putpixel(cx + x, cy + y, color)
                self.putpixel(cx - x, cy + y, color)
                self.putpixel(cx + x, cy - y, color)
                self.putpixel(cx - x, cy - y, color)
                self.putpixel(cx + y, cy + x, color)
                self.putpixel(cx - y, cy + x, color)
                self.putpixel(cx + y, cy - x, color)
                self.putpixel(cx - y, cy - x, color)
            
            if d < 0:
                d = d + 4 * x + 6
            else:
                d = d + 4 * (x - y) + 10
                y -= 1
            x += 1
    
    def animate_cursor(self):
        """Animate cursor blinking"""
        if self.mode == self.MODE_TEXT and hasattr(self, 'text_display'):
            if self.cursor_visible:
                self.text_display.config(insertbackground='#00FF00')
            else:
                self.text_display.config(insertbackground='#0a0a0a')
            
            self.cursor_visible = not self.cursor_visible
        
        self.root.after(500, self.animate_cursor)
    
    def save_screen(self):
        """Save screen contents to file"""
        try:
            with open('screen_dump.txt', 'w') as f:
                for row in self.screen_buffer:
                    f.write(''.join(row) + '\n')
            print("Screen saved to screen_dump.txt")
        except Exception as e:
            print(f"Error saving screen: {e}")
    
    def load_screen(self, filename):
        """Load screen contents from file"""
        try:
            with open(filename, 'r') as f:
                lines = f.readlines()
            
            self.clear_screen()
            for y, line in enumerate(lines):
                if y >= self.rows:
                    break
                for x, char in enumerate(line):
                    if x >= self.cols:
                        break
                    if char != '\n':
                        self.screen_buffer[y][x] = char
            
            self.render_text_screen()
        except Exception as e:
            print(f"Error loading screen: {e}")
    
    def demo_text_mode(self):
        """Demonstrate text mode capabilities"""
        self.clear_screen()
        self.putstr("╔════════════════════════════════════════════╗\n")
        self.putstr("║   ALTAIR 8800 - TEXT MODE DEMONSTRATION   ║\n")
        self.putstr("╚════════════════════════════════════════════╝\n\n")
        
        self.putstr("Character Output:\n")
        for i in range(32, 127):
            self.putstr(chr(i))
            if (i - 32) % 16 == 15:
                self.putstr("\n")
        
        self.render_text_screen()
    
    def demo_graphics_mode(self):
        """Demonstrate graphics mode capabilities"""
        self.set_mode(self.MODE_GRAPHICS)
        
        # Clear graphics buffer
        self.graphics_buffer = [[0 for _ in range(320)] for _ in range(192)]
        
        # Draw borders
        self.rectangle(10, 10, 310, 182, color=1)
        
        # Draw some shapes
        self.rectangle(50, 50, 150, 150, color=1, filled=True)
        self.circle(200, 100, 40, color=1)
        self.line(20, 20, 300, 170, color=1)
        
        self.render_graphics_screen()


if __name__ == "__main__":
    root = tk.Tk()
    screen = ScreenInterface(root, cols=80, rows=24)
    screen.demo_text_mode()
    root.mainloop()
