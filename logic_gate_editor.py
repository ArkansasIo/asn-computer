#!/usr/bin/env python3
"""
LOGIC GATE EDITOR - Visual logic gate designer for ALTAIR 8800 Emulator
Design and simulate digital logic circuits
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import tkinter.font as tkFont
import json
import math


class LogicGate:
    """Base class for logic gates"""
    
    def __init__(self, gate_type, x, y, inputs=2, gate_id=None):
        """Initialize logic gate"""
        self.gate_type = gate_type
        self.x = x
        self.y = y
        self.inputs = inputs
        self.gate_id = gate_id or f"{gate_type}_{id(self)}"
        self.input_values = [0] * inputs
        self.output = 0
        self.width = 60
        self.height = 40
    
    def compute(self, inputs):
        """Compute gate output"""
        self.input_values = inputs[:self.inputs]
        
        if self.gate_type == "AND":
            self.output = 1 if all(self.input_values) else 0
        elif self.gate_type == "OR":
            self.output = 1 if any(self.input_values) else 0
        elif self.gate_type == "NOT":
            self.output = 1 - self.input_values[0] if self.input_values else 0
        elif self.gate_type == "NAND":
            self.output = 0 if all(self.input_values) else 1
        elif self.gate_type == "NOR":
            self.output = 0 if any(self.input_values) else 1
        elif self.gate_type == "XOR":
            self.output = (self.input_values[0] ^ self.input_values[1]) if len(self.input_values) >= 2 else 0
        elif self.gate_type == "XNOR":
            val = (self.input_values[0] ^ self.input_values[1]) if len(self.input_values) >= 2 else 0
            self.output = 1 - val
        
        return self.output


class LogicGateEditor:
    """Visual logic gate circuit editor"""
    
    GATE_TYPES = ["AND", "OR", "NOT", "NAND", "NOR", "XOR", "XNOR", "SWITCH", "LED"]
    GATE_COLORS = {
        "AND": "#FF6B6B",
        "OR": "#4ECDC4",
        "NOT": "#45B7D1",
        "NAND": "#FFA07A",
        "NOR": "#98D8C8",
        "XOR": "#F7DC6F",
        "XNOR": "#BB8FCE",
        "SWITCH": "#52C41A",
        "LED": "#FF4444"
    }
    
    def __init__(self, root=None):
        """Initialize logic gate editor"""
        self.root = root if root else tk.Tk()
        self.root.title("Logic Gate Editor - ALTAIR 8800")
        self.root.geometry("1200x800")
        self.root.configure(bg='#1a1a1a')
        
        self.gates = {}
        self.connections = []
        self.selected_gate = None
        self.drag_data = {"x": 0, "y": 0}
        
        self.setup_gui()
        self.setup_bindings()
    
    def setup_gui(self):
        """Setup editor interface"""
        # Toolbar
        toolbar = tk.Frame(self.root, bg='#222222', height=50)
        toolbar.pack(side=tk.TOP, fill=tk.X)
        
        tk.Label(toolbar, text="Logic Gate Editor", bg='#222222', fg='#00FF00', font=("Courier New", 14, "bold")).pack(side=tk.LEFT, padx=10, pady=8)
        
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=5)
        
        tk.Label(toolbar, text="Add Gate:", bg='#222222', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=8)
        
        self.gate_var = tk.StringVar(value="AND")
        gate_combo = ttk.Combobox(toolbar, textvariable=self.gate_var, values=self.GATE_TYPES, state="readonly", width=10)
        gate_combo.pack(side=tk.LEFT, padx=5, pady=8)
        
        tk.Button(toolbar, text="Add Gate", command=self.add_gate, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=8)
        
        tk.Button(toolbar, text="Clear All", command=self.clear_editor, bg='#333333', fg='#FF0000').pack(side=tk.LEFT, padx=5, pady=8)
        
        tk.Button(toolbar, text="Simulate", command=self.simulate_circuit, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=8)
        
        tk.Button(toolbar, text="Save", command=self.save_circuit, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=8)
        
        tk.Button(toolbar, text="Load", command=self.load_circuit, bg='#333333', fg='#00FF00').pack(side=tk.LEFT, padx=5, pady=8)
        
        # Main canvas
        self.canvas = tk.Canvas(self.root, bg='#0a0a0a', highlightthickness=1, highlightbackground='#333333')
        self.canvas.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Status bar
        status_frame = tk.Frame(self.root, bg='#222222', height=30)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        self.status_label = tk.Label(
            status_frame, text="Ready | No circuit loaded",
            bg='#222222', fg='#00FF00', anchor=tk.W
        )
        self.status_label.pack(fill=tk.X, padx=5, pady=5)
    
    def setup_bindings(self):
        """Setup canvas event bindings"""
        self.canvas.bind("<Button-1>", self.on_canvas_click)
        self.canvas.bind("<B1-Motion>", self.on_canvas_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_canvas_release)
        self.canvas.bind("<Button-3>", self.on_canvas_right_click)
        self.canvas.bind("<Delete>", self.delete_selected)
        self.root.bind("<Control-z>", lambda e: self.undo_action())
    
    def add_gate(self):
        """Add new gate at random position"""
        gate_type = self.gate_var.get()
        x = 200 + (len(self.gates) % 5) * 150
        y = 100 + (len(self.gates) // 5) * 100
        
        gate = LogicGate(gate_type, x, y, inputs=2 if gate_type != "NOT" else 1)
        self.gates[gate.gate_id] = gate
        
        self.redraw_circuit()
        self.update_status(f"Added {gate_type} gate")
    
    def draw_gate(self, gate_id, gate):
        """Draw a logic gate on canvas"""
        x, y = gate.x, gate.y
        width, height = gate.width, gate.height
        
        color = self.GATE_COLORS.get(gate.gate_type, "#FFFFFF")
        
        if gate.gate_type == "NOT":
            # Triangle shape for NOT
            self.canvas.create_polygon(
                x - width//2, y - height//2,
                x - width//2, y + height//2,
                x + width//2, y,
                fill=color, outline="#00FF00", width=2,
                tags=(gate_id, "gate")
            )
        else:
            # Rectangle for other gates
            self.canvas.create_rectangle(
                x - width//2, y - height//2,
                x + width//2, y + height//2,
                fill=color, outline="#00FF00", width=2,
                tags=(gate_id, "gate")
            )
        
        # Gate label
        self.canvas.create_text(
            x, y, text=gate.gate_type,
            fill="#000000", font=("Courier New", 9, "bold"),
            tags=(gate_id, "label")
        )
        
        # Input/Output indicators
        if gate.gate_type != "NOT":
            self.canvas.create_circle(x - width//2 - 5, y - height//4, 3, fill="#00FF00", tags=(gate_id, "input1"))
            self.canvas.create_circle(x - width//2 - 5, y + height//4, 3, fill="#00FF00", tags=(gate_id, "input2"))
        else:
            self.canvas.create_circle(x - width//2 - 5, y, 3, fill="#00FF00", tags=(gate_id, "input1"))
        
        self.canvas.create_circle(x + width//2 + 5, y, 3, fill="#FF0000", tags=(gate_id, "output"))
    
    def redraw_circuit(self):
        """Redraw entire circuit"""
        self.canvas.delete("all")
        
        # Draw connections first (behind gates)
        for conn in self.connections:
            self.draw_connection(conn)
        
        # Draw gates
        for gate_id, gate in self.gates.items():
            self.draw_gate(gate_id, gate)
    
    def draw_connection(self, connection):
        """Draw wire connection"""
        from_gate_id, from_pin, to_gate_id, to_pin = connection
        
        if from_gate_id in self.gates and to_gate_id in self.gates:
            from_gate = self.gates[from_gate_id]
            to_gate = self.gates[to_gate_id]
            
            x1, y1 = from_gate.x + 30, from_gate.y
            x2, y2 = to_gate.x - 30, to_gate.y
            
            self.canvas.create_line(x1, y1, x2, y2, fill="#FFFF00", width=2)
    
    def on_canvas_click(self, event):
        """Handle canvas click"""
        clicked = self.canvas.find_closest(event.x, event.y)
        if clicked:
            tags = self.canvas.gettags(clicked[0])
            for tag in tags:
                if tag in self.gates:
                    self.selected_gate = tag
                    self.drag_data["x"] = event.x
                    self.drag_data["y"] = event.y
    
    def on_canvas_drag(self, event):
        """Handle canvas drag"""
        if self.selected_gate and self.selected_gate in self.gates:
            dx = event.x - self.drag_data["x"]
            dy = event.y - self.drag_data["y"]
            
            self.gates[self.selected_gate].x += dx
            self.gates[self.selected_gate].y += dy
            
            self.drag_data["x"] = event.x
            self.drag_data["y"] = event.y
            
            self.redraw_circuit()
    
    def on_canvas_release(self, event):
        """Handle canvas release"""
        pass
    
    def on_canvas_right_click(self, event):
        """Handle right click - context menu"""
        clicked = self.canvas.find_closest(event.x, event.y)
        if clicked:
            tags = self.canvas.gettags(clicked[0])
            for tag in tags:
                if tag in self.gates:
                    self.selected_gate = tag
                    self.show_gate_menu(event.x_root, event.y_root)
    
    def show_gate_menu(self, x, y):
        """Show context menu for gate"""
        menu = tk.Menu(self.root, tearoff=False, bg='#222222', fg='#00FF00')
        menu.add_command(label="Delete", command=self.delete_selected)
        menu.add_command(label="Properties", command=self.show_properties)
        menu.post(x, y)
    
    def delete_selected(self, event=None):
        """Delete selected gate"""
        if self.selected_gate and self.selected_gate in self.gates:
            del self.gates[self.selected_gate]
            self.connections = [c for c in self.connections if self.selected_gate not in c[:2]]
            self.selected_gate = None
            self.redraw_circuit()
    
    def show_properties(self):
        """Show gate properties dialog"""
        if self.selected_gate and self.selected_gate in self.gates:
            gate = self.gates[self.selected_gate]
            info = f"Gate: {gate.gate_type}\nID: {gate.gate_id}\nOutput: {gate.output}\nPosition: ({gate.x}, {gate.y})"
            messagebox.showinfo("Gate Properties", info)
    
    def clear_editor(self):
        """Clear entire editor"""
        if messagebox.askyesno("Clear", "Clear all gates?"):
            self.gates.clear()
            self.connections.clear()
            self.redraw_circuit()
    
    def simulate_circuit(self):
        """Simulate circuit"""
        if not self.gates:
            messagebox.showwarning("Empty", "No gates to simulate")
            return
        
        # Simple simulation with random inputs
        for gate_id, gate in self.gates.items():
            if gate.gate_type == "SWITCH":
                gate.compute([1])
            else:
                gate.compute([1, 0])
        
        self.redraw_circuit()
        result = ", ".join([f"{g.gate_type}={g.output}" for g in self.gates.values()])
        self.update_status(f"Simulation: {result}")
    
    def save_circuit(self):
        """Save circuit to file"""
        filename = filedialog.asksaveasfilename(defaultextension=".circuit", filetypes=[("Circuit", "*.circuit")])
        if filename:
            data = {
                "gates": {gid: {"type": g.gate_type, "x": g.x, "y": g.y, "inputs": g.inputs} for gid, g in self.gates.items()},
                "connections": self.connections
            }
            with open(filename, 'w') as f:
                json.dump(data, f)
            self.update_status(f"Saved to {filename}")
    
    def load_circuit(self):
        """Load circuit from file"""
        filename = filedialog.askopenfilename(filetypes=[("Circuit", "*.circuit")])
        if filename:
            try:
                with open(filename, 'r') as f:
                    data = json.load(f)
                
                self.gates.clear()
                for gid, gdata in data["gates"].items():
                    gate = LogicGate(gdata["type"], gdata["x"], gdata["y"], gdata["inputs"], gid)
                    self.gates[gid] = gate
                
                self.connections = data["connections"]
                self.redraw_circuit()
                self.update_status(f"Loaded from {filename}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not load circuit: {e}")
    
    def update_status(self, message):
        """Update status bar"""
        gate_count = len(self.gates)
        conn_count = len(self.connections)
        self.status_label.config(text=f"{message} | Gates: {gate_count} | Connections: {conn_count}")


if __name__ == "__main__":
    root = tk.Tk()
    editor = LogicGateEditor(root)
    root.mainloop()
