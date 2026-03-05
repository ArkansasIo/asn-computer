#!/usr/bin/env python3
"""
AUDIO SYSTEM - Sound effects and audio feedback for ALTAIR 8800 Emulator
Provides audio for LED indicators, switches, and system events
"""

import platform
import math

class AudioSystem:
    """Audio feedback system for emulator events"""
    
    def __init__(self):
        """Initialize audio system"""
        self.os_type = platform.system()
        self.enabled = True
        self.volume = 0.7  # 0.0 to 1.0
        self.init_audio()
    
    def init_audio(self):
        """Initialize audio system based on OS"""
        try:
            if self.os_type == "Windows":
                import winsound
                self.winsound = winsound
            elif self.os_type == "Darwin":  # macOS
                import os
                self.os = os
            else:  # Linux
                import subprocess
                self.subprocess = subprocess
        except ImportError:
            self.enabled = False
    
    def play_led_on(self):
        """Play sound for LED turning on"""
        self._play_beep(1000, 50)  # 1kHz, 50ms
    
    def play_led_off(self):
        """Play sound for LED turning off"""
        self._play_beep(800, 40)  # 800Hz, 40ms
    
    def play_switch_toggle(self):
        """Play sound for switch toggle"""
        self._play_beep(1500, 80)  # 1.5kHz, 80ms
    
    def play_button_click(self):
        """Play sound for button click"""
        self._play_beep(2000, 60)  # 2kHz, 60ms
    
    def play_power_on(self):
        """Play power-on startup sound"""
        # Ascending tones
        for freq in [800, 1200, 1600]:
            self._play_beep(freq, 100)
    
    def play_power_off(self):
        """Play power-off shutdown sound"""
        # Descending tones
        for freq in [1600, 1200, 800]:
            self._play_beep(freq, 100)
    
    def play_error(self):
        """Play error alert sound"""
        for _ in range(2):
            self._play_beep(600, 100)
            # Small delay between beeps
    
    def play_success(self):
        """Play success confirmation sound"""
        self._play_beep(1200, 100)
        self._play_beep(1600, 100)
    
    def play_halt(self):
        """Play halt/stop sound"""
        self._play_beep(1000, 200)
    
    def play_interrupt(self):
        """Play interrupt alert sound"""
        for _ in range(3):
            self._play_beep(1800, 50)
    
    def _play_beep(self, frequency, duration):
        """
        Play a beep at specified frequency and duration
        
        Args:
            frequency: Frequency in Hz
            duration: Duration in milliseconds
        """
        if not self.enabled:
            return
        
        if self.os_type == "Windows":
            try:
                self.winsound.Beep(int(frequency), int(duration * self.volume))
            except Exception:
                pass
        elif self.os_type == "Darwin":
            # macOS using afplay
            try:
                import subprocess
                # Simple sine wave synthesis
                subprocess.run([
                    "afplay", "-t", "raw", "-r", "44100", "-c", "1", "-b", "16",
                    f"-f", "LEI16@44100", "-d", str(duration/1000)
                ], timeout=1, capture_output=True)
            except Exception:
                pass
        else:
            # Linux using speaker-test or sox
            try:
                import subprocess
                subprocess.run(
                    f"speaker-test -t sine -f {frequency} -l 1".split(),
                    timeout=duration/1000 + 0.1, capture_output=True
                )
            except Exception:
                pass
    
    def set_volume(self, volume):
        """Set volume (0.0 to 1.0)"""
        self.volume = max(0.0, min(1.0, volume))
    
    def toggle_audio(self):
        """Toggle audio on/off"""
        self.enabled = not self.enabled
    
    def play_countdown(self, seconds):
        """Play countdown tones"""
        for i in range(int(seconds)):
            freq = 1000 + (i * 200)
            self._play_beep(freq, 100)


# Global audio system instance
_audio_system = None

def get_audio_system():
    """Get or create global audio system instance"""
    global _audio_system
    if _audio_system is None:
        _audio_system = AudioSystem()
    return _audio_system


if __name__ == "__main__":
    # Test audio system
    audio = get_audio_system()
    print("Testing Audio System...")
    
    print("  LED ON...")
    audio.play_led_on()
    
    print("  LED OFF...")
    audio.play_led_off()
    
    print("  Switch Toggle...")
    audio.play_switch_toggle()
    
    print("  Power ON...")
    audio.play_power_on()
    
    print("  Power OFF...")
    audio.play_power_off()
    
    print("Audio tests complete!")
