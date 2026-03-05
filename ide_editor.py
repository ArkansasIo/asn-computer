#!/usr/bin/env python3
"""
INTEGRATED IDE EDITOR - Code editor for ASM, C, and C++
Provides syntax highlighting, code completion, and compilation support
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
import tkinter.font as tkFont
import re
import os

class SyntaxHighlighter:
    """Provides syntax highlighting for different languages"""
    
    # ASM keywords and patterns
    ASM_KEYWORDS = {
        'mov', 'add', 'sub', 'mul', 'div', 'inc', 'dec', 'push', 'pop',
        'call', 'ret', 'jmp', 'je', 'jne', 'jl', 'jle', 'jg', 'jge',
        'cmp', 'test', 'and', 'or', 'xor', 'not', 'shl', 'shr', 'rol', 'ror',
        'lea', 'cli', 'sti', 'nop', 'hlt', 'int', 'iret', 'loop', 'loopz',
        'loopnz', 'movzx', 'movsx', 'bswap', 'imul', 'idiv'
    }
    
    ASM_REGISTERS = {
        'rax', 'rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'rbp', 'rsp',
        'eax', 'ebx', 'ecx', 'edx', 'esi', 'edi', 'ebp', 'esp',
        'ax', 'bx', 'cx', 'dx', 'si', 'di', 'bp', 'sp',
        'al', 'ah', 'bl', 'bh', 'cl', 'ch', 'dl', 'dh'
    }
    
    # C/C++ keywords
    CPP_KEYWORDS = {
        'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
        'return', 'void', 'int', 'char', 'float', 'double', 'long', 'short',
        'unsigned', 'signed', 'struct', 'union', 'enum', 'class', 'public',
        'private', 'protected', 'virtual', 'const', 'static', 'extern',
        'volatile', 'register', 'typedef', 'sizeof', 'new', 'delete',
        'namespace', 'using', 'template', 'try', 'catch', 'throw', 'extern'
    }
    
    @staticmethod
    def get_asm_patterns():
        """Get syntax patterns for ASM"""
        return {
            'keyword': r'\b(' + '|'.join(SyntaxHighlighter.ASM_KEYWORDS) + r')\b',
            'register': r'\b(' + '|'.join(SyntaxHighlighter.ASM_REGISTERS) + r')\b',
            'comment': r';.*',
            'number': r'\b(0x[0-9A-Fa-f]+|[0-9]+)', 
            'string': r'"([^"]*)"',
            'label': r'^[a-zA-Z_][a-zA-Z0-9_]*:',
        }
    
    @staticmethod
    def get_cpp_patterns():
        """Get syntax patterns for C/C++"""
        return {
            'keyword': r'\b(' + '|'.join(SyntaxHighlighter.CPP_KEYWORDS) + r')\b',
            'comment': r'//.*|/\*.*?\*/',
            'string': r'"([^"]*)"',
            'char': r"'([^'])'",
            'number': r'\b(0x[0-9A-Fa-f]+|[0-9]+\.[0-9]*|[0-9]+)',
            'function': r'[a-zA-Z_][a-zA-Z0-9_]*(?=\()',
            'preprocessor': r'#\w+',
        }


class IDEEditor:
    """Integrated Development Environment for multiple languages"""
    
    def __init__(self, root=None):
        """Initialize IDE editor"""
        self.root = root if root else tk.Tk()
        self.root.title("ALTAIR 8800 - Integrated IDE")
        self.root.geometry("1000x700")
        self.root.configure(bg='#1a1a1a')
        
        self.current_language = "asm"
        self.current_file = None
        self.modified = False
        
        self.setup_styles()
        self.create_gui()
        self.setup_bindings()
    
    def setup_styles(self):
        """Configure color schemes"""
        self.colors = {
            'bg': '#1a1a1a',
            'fg': '#00FF00',
            'keyword': '#FF00FF',
            'register': '#00FFFF',
            'comment': '#888888',
            'number': '#FFFF00',
            'string': '#00FF00',
            'selection': '#333333',
        }
    
    def create_gui(self):
        """Create IDE interface"""
        # Menu bar
        menubar = tk.Menu(self.root, bg='#222222', fg='#00FF00')
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New", command=self.new_file)
        file_menu.add_command(label="Open...", command=self.open_file)
        file_menu.add_command(label="Save", command=self.save_file)
        file_menu.add_command(label="Save As...", command=self.save_file_as)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Edit menu
        edit_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Undo", command=self.undo_edit)
        edit_menu.add_command(label="Redo", command=self.redo_edit)
        edit_menu.add_separator()
        edit_menu.add_command(label="Cut", command=self.cut_text)
        edit_menu.add_command(label="Copy", command=self.copy_text)
        edit_menu.add_command(label="Paste", command=self.paste_text)
        
        # Language menu
        lang_menu = tk.Menu(menubar, tearoff=0, bg='#222222', fg='#00FF00')
        menubar.add_cascade(label="Language", menu=lang_menu)
        lang_menu.add_command(label="ASM (x86-64)", command=lambda: self.set_language("asm"))
        lang_menu.add_command(label="C", command=lambda: self.set_language("c"))
        lang_menu.add_command(label="C++", command=lambda: self.set_language("cpp"))
        
        # Toolbar
        toolbar = tk.Frame(self.root, bg='#222222', height=40)
        toolbar.pack(side=tk.TOP, fill=tk.X)
        
        tk.Button(toolbar, text="New", command=self.new_file, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(toolbar, text="Open", command=self.open_file, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        tk.Button(toolbar, text="Save", command=self.save_file, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=5)
        
        tk.Label(toolbar, text="Language:", bg='#222222', fg='#00FF00').pack(side=tk.LEFT, padx=10, pady=5)
        
        self.lang_var = tk.StringVar(value="ASM")
        lang_combo = ttk.Combobox(toolbar, textvariable=self.lang_var, values=["ASM", "C", "C++"], state="readonly", width=10)
        lang_combo.pack(side=tk.LEFT, padx=5, pady=5)
        lang_combo.bind('<<ComboboxSelected>>', lambda e: self.set_language({"ASM": "asm", "C": "c", "C++": "cpp"}[self.lang_var.get()]))
        
        # Editor area
        editor_frame = tk.Frame(self.root, bg='#1a1a1a')
        editor_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Line numbers
        line_num_frame = tk.Frame(editor_frame, bg='#0a0a0a', width=50)
        line_num_frame.pack(side=tk.LEFT, fill=tk.Y)
        
        self.line_numbers = tk.Text(
            line_num_frame, width=5, bg='#0a0a0a', fg='#666666',
            font=("Courier New", 10), state='disabled'
        )
        self.line_numbers.pack(fill=tk.Y, expand=True)
        
        # Main editor
        self.editor = scrolledtext.ScrolledText(
            editor_frame, bg='#1a1a1a', fg='#00FF00',
            font=("Courier New", 11), insertbackground='#00FF00',
            undo=True, maxundo=-1
        )
        self.editor.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Status bar
        status_frame = tk.Frame(self.root, bg='#222222', height=25)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        self.status_label = tk.Label(
            status_frame, text="Ready | ASM | 0:0 | Modified: No",
            bg='#222222', fg='#00FF00', anchor=tk.W
        )
        self.status_label.pack(fill=tk.X, padx=5, pady=2)
        
        # Bind events
        self.editor.bind('<<Change>>', self.on_text_change)
        self.editor.bind('<KeyRelease>', self.on_key_release)
    
    def setup_bindings(self):
        """Setup keyboard bindings"""
        self.root.bind('<Control-n>', lambda e: self.new_file())
        self.root.bind('<Control-o>', lambda e: self.open_file())
        self.root.bind('<Control-s>', lambda e: self.save_file())
        self.root.bind('<Control-h>', lambda e: self.show_help())
    
    def set_language(self, language):
        """Set programming language"""
        self.current_language = language
        self.lang_var.set(language.upper())
        self.apply_syntax_highlighting()
    
    def new_file(self):
        """Create new file"""
        if self.modified:
            if messagebox.askyesno("Unsaved Changes", "Discard changes?"):
                self.editor.delete(1.0, tk.END)
                self.current_file = None
                self.modified = False
                self.update_status()
        else:
            self.editor.delete(1.0, tk.END)
            self.current_file = None
    
    def open_file(self):
        """Open file dialog"""
        filetypes = [("All", "*.*"), ("ASM", "*.asm"), ("C", "*.c"), ("C++", "*.cpp;*.cc;*.cxx")]
        filename = filedialog.askopenfilename(filetypes=filetypes)
        if filename:
            try:
                with open(filename, 'r') as f:
                    self.editor.delete(1.0, tk.END)
                    self.editor.insert(1.0, f.read())
                self.current_file = filename
                self.modified = False
                self.update_status()
            except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {e}")
    
    def save_file(self):
        """Save current file"""
        if not self.current_file:
            self.save_file_as()
            return
        
        try:
            with open(self.current_file, 'w') as f:
                f.write(self.editor.get(1.0, tk.END))
            self.modified = False
            self.update_status()
            messagebox.showinfo("Success", "File saved!")
        except Exception as e:
            messagebox.showerror("Error", f"Could not save file: {e}")
    
    def save_file_as(self):
        """Save file with new name"""
        filename = filedialog.asksaveasfilename(
            defaultextension=".asm",
            filetypes=[("ASM", "*.asm"), ("C", "*.c"), ("C++", "*.cpp")]
        )
        if filename:
            self.current_file = filename
            self.save_file()
    
    def on_text_change(self, event):
        """Handle text changes"""
        self.modified = True
        self.apply_syntax_highlighting()
        self.update_line_numbers()
    
    def on_key_release(self, event):
        """Handle key releases"""
        self.apply_syntax_highlighting()
        self.update_status()
    
    def update_line_numbers(self):
        """Update line number display"""
        line_count = int(self.editor.index(tk.END).split('.')[0])
        line_nums = '\n'.join(str(i) for i in range(1, line_count + 1))
        
        self.line_numbers.config(state='normal')
        self.line_numbers.delete(1.0, tk.END)
        self.line_numbers.insert(1.0, line_nums)
        self.line_numbers.config(state='disabled')
    
    def apply_syntax_highlighting(self):
        """Apply syntax highlighting based on language"""
        if self.current_language == "asm":
            patterns = SyntaxHighlighter.get_asm_patterns()
            self._highlight_asm(patterns)
        else:
            patterns = SyntaxHighlighter.get_cpp_patterns()
            self._highlight_cpp(patterns)
    
    def _highlight_asm(self, patterns):
        """Highlight ASM syntax"""
        self.editor.tag_config('keyword', foreground=self.colors['keyword'])
        self.editor.tag_config('register', foreground=self.colors['register'])
        self.editor.tag_config('comment', foreground=self.colors['comment'])
        
        for tag, pattern in patterns.items():
            idx = 1.0
            while True:
                idx = self.editor.search(pattern, idx, nocase=True, regexp=True, stopindex=tk.END)
                if not idx:
                    break
                end_idx = f"{idx}+{len(self.editor.get(idx, tk.END).split()[0])}c"
                self.editor.tag_add(tag, idx, end_idx)
                idx = end_idx
    
    def _highlight_cpp(self, patterns):
        """Highlight C/C++ syntax"""
        self.editor.tag_config('keyword', foreground=self.colors['keyword'])
        self.editor.tag_config('comment', foreground=self.colors['comment'])
        self.editor.tag_config('string', foreground=self.colors['string'])
        
        for tag, pattern in patterns.items():
            idx = 1.0
            while True:
                idx = self.editor.search(pattern, idx, nocase=True, regexp=True, stopindex=tk.END)
                if not idx:
                    break
                end_idx = f"{idx}+{len(self.editor.get(idx, tk.END).split()[0])}c"
                self.editor.tag_add(tag, idx, end_idx)
                idx = end_idx
    
    def undo_edit(self):
        """Undo last change"""
        try:
            self.editor.edit_undo()
            self.modified = True
        except:
            pass
    
    def redo_edit(self):
        """Redo last change"""
        try:
            self.editor.edit_redo()
            self.modified = True
        except:
            pass
    
    def cut_text(self):
        """Cut selected text"""
        try:
            self.editor.event_generate("<<Cut>>")
        except:
            pass
    
    def copy_text(self):
        """Copy selected text"""
        try:
            self.editor.event_generate("<<Copy>>")
        except:
            pass
    
    def paste_text(self):
        """Paste from clipboard"""
        try:
            self.editor.event_generate("<<Paste>>")
        except:
            pass
    
    def show_help(self):
        """Show help dialog"""
        help_text = """
ALTAIR 8800 IDE - Help

Supported Languages: ASM (x86-64), C, C++

Keyboard Shortcuts:
  Ctrl+N: New File
  Ctrl+O: Open File
  Ctrl+S: Save File
  Ctrl+H: Help

Features:
- Real-time syntax highlighting
- Line numbering
- Multi-language support
- File I/O
- Undo/Redo support
        """
        messagebox.showinfo("Help", help_text)
    
    def update_status(self):
        """Update status bar"""
        line, col = self.editor.index(tk.INSERT).split('.')
        mod_status = "Modified: Yes" if self.modified else "Modified: No"
        filename = os.path.basename(self.current_file) if self.current_file else "Untitled"
        
        self.status_label.config(
            text=f"Ready | {self.current_language.upper()} | {line}:{col} | {filename} | {mod_status}"
        )


if __name__ == "__main__":
    root = tk.Tk()
    ide = IDEEditor(root)
    root.mainloop()
