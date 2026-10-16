(() => {
  'use strict';

  const $ = (id) => document.getElementById(id);
  const addressLeds = $('addressLeds');
  const dataLeds = $('dataLeds');
  const switches = $('switches');
  const terminal = $('terminal');

  const RAM_SIZE = 0x10000;
  const memory = new Uint8Array(RAM_SIZE);
  const switchState = Array(16).fill(false);
  const addressLedBits = [];
  const dataLedBits = [];
  const switchButtons = [];

  let pc = 0;
  let address = 0;
  let data = 0;
  let accumulator = 0;
  let cycles = 0;
  let running = false;
  let halted = true;
  let mode = 'ADDRESS';
  let interruptEnabled = false;
  let flags = { z: false, s: false, p: false, c: false, a: false };
  let runTimer = null;

  const hex = (value, width) => (value >>> 0).toString(16).toUpperCase().padStart(width, '0');
  const bit = (value, index) => ((value >>> index) & 1) !== 0;
  const switchesToValue = (count) => switchState.slice(0, count).reduce((v, on, i) => v | (on ? (1 << i) : 0), 0);
  const setSwitches = (value, count) => {
    for (let i = 0; i < count; i++) switchState[i] = bit(value, i);
    for (let i = count; i < switchState.length; i++) switchState[i] = false;
  };

  function log(message) {
    terminal.textContent += `\n${message}`;
    terminal.scrollTop = terminal.scrollHeight;
  }

  function clearTerminal() {
    terminal.textContent = 'ASN MONITOR ............. CLEAR\nREADY';
  }

  function buildPanel() {
    for (let i = 0; i < 16; i++) {
      const led = document.createElement('span');
      led.className = 'led';
      led.title = `A${15 - i}`;
      addressLeds.appendChild(led);
      addressLedBits.push(led);

      const button = document.createElement('button');
      button.type = 'button';
      button.textContent = `S${15 - i}`;
      button.setAttribute('aria-label', `Toggle bit ${15 - i}`);
      button.addEventListener('click', () => toggleSwitch(15 - i));
      switches.appendChild(button);
      switchButtons.push(button);
    }

    for (let i = 0; i < 8; i++) {
      const led = document.createElement('span');
      led.className = 'led';
      led.title = `D${7 - i}`;
      dataLeds.appendChild(led);
      dataLedBits.push(led);
    }

    const addressLabels = $('addressLabels');
    for (let i = 15; i >= 0; i--) {
      const label = document.createElement('span');
      label.textContent = `A${i}`;
      addressLabels.appendChild(label);
    }
    const dataLabels = $('dataLabels');
    for (let i = 7; i >= 0; i--) {
      const label = document.createElement('span');
      label.textContent = `D${i}`;
      dataLabels.appendChild(label);
    }
  }

  function toggleSwitch(index) {
    if (mode === 'ADDRESS' && index < 16) switchState[index] = !switchState[index];
    else if (mode === 'DATA' && index < 8) switchState[index] = !switchState[index];
    render();
  }

  function switchValue() {
    return mode === 'ADDRESS' ? switchesToValue(16) : switchesToValue(8);
  }

  function setMode(nextMode) {
    mode = nextMode;
    $('addressMode').classList.toggle('active', mode === 'ADDRESS');
    $('dataMode').classList.toggle('active', mode === 'DATA');
    $('modeReadout').textContent = mode;
    log(`MODE .................. ${mode}`);
    render();
  }

  function loadAddress() {
    address = switchValue() & 0xFFFF;
    data = memory[address];
    halted = true;
    running = false;
    log(`LOAD ADDRESS .......... ${hex(address, 4)}`);
    render();
  }

  function examine() {
    data = memory[address];
    setSwitches(data, 8);
    mode = 'DATA';
    $('addressMode').classList.remove('active');
    $('dataMode').classList.add('active');
    $('modeReadout').textContent = 'DATA';
    log(`EXAMINE ${hex(address, 4)} ........ ${hex(data, 2)}`);
    render();
  }

  function deposit() {
    data = switchValue() & 0xFF;
    memory[address] = data;
    log(`DEPOSIT ${hex(address, 4)} ........ ${hex(data, 2)}`);
    render();
  }

  function examineNext() {
    examine();
    address = (address + 1) & 0xFFFF;
    data = memory[address];
    setSwitches(data, 8);
    log(`EXAMINE NEXT .......... ${hex(address, 4)} = ${hex(data, 2)}`);
    render();
  }

  function depositNext() {
    deposit();
    address = (address + 1) & 0xFFFF;
    data = memory[address];
    log(`DEPOSIT NEXT .......... ${hex(address, 4)}`);
    render();
  }

  function updateFlags(value) {
    const v = value & 0xFF;
    flags.z = v === 0;
    flags.s = (v & 0x80) !== 0;
    flags.p = v.toString(2).split('1').length % 2 === 1;
  }

  function executeCycle() {
    if (halted) return;
    address = pc & 0xFFFF;
    const opcode = memory[address];
    data = opcode;

    // Minimal deterministic reference instruction set for the web console.
    // 00 NOP, 3E MVI A,imm, 32 STA addr, 3A LDA addr, C3 JMP addr, 76 HLT.
    switch (opcode) {
      case 0x00:
        pc = (pc + 1) >>> 0;
        cycles += 1;
        break;
      case 0x3E:
        accumulator = memory[(pc + 1) & 0xFFFF];
        data = accumulator;
        updateFlags(accumulator);
        pc = (pc + 2) >>> 0;
        cycles += 2;
        break;
      case 0x32: {
        const lo = memory[(pc + 1) & 0xFFFF];
        const hi = memory[(pc + 2) & 0xFFFF];
        const target = lo | (hi << 8);
        memory[target] = accumulator;
        address = target;
        data = accumulator;
        pc = (pc + 3) >>> 0;
        cycles += 3;
        break;
      }
      case 0x3A: {
        const lo = memory[(pc + 1) & 0xFFFF];
        const hi = memory[(pc + 2) & 0xFFFF];
        const target = lo | (hi << 8);
        accumulator = memory[target];
        address = target;
        data = accumulator;
        updateFlags(accumulator);
        pc = (pc + 3) >>> 0;
        cycles += 3;
        break;
      }
      case 0xC3: {
        const lo = memory[(pc + 1) & 0xFFFF];
        const hi = memory[(pc + 2) & 0xFFFF];
        pc = (lo | (hi << 8)) >>> 0;
        cycles += 3;
        break;
      }
      case 0x76:
        halted = true;
        running = false;
        pc = (pc + 1) >>> 0;
        cycles += 1;
        log(`HLT .................. PC=${hex(pc, 4)}`);
        break;
      default:
        // Unknown opcode is treated as a safe NOP in the UI reference.
        pc = (pc + 1) >>> 0;
        cycles += 1;
        break;
    }

    address = pc & 0xFFFF;
    data = memory[address];
  }

  function singleStep() {
    if (halted) {
      halted = false;
      running = false;
    }
    executeCycle();
    running = false;
    halted = true;
    log(`STEP .................. PC=${hex(pc, 8)} BUS=${hex(data, 2)}`);
    render();
  }

  function run() {
    halted = false;
    running = true;
    $('lastOperation').textContent = 'RUN';
    log(`RUN ................... START PC=${hex(pc, 8)}`);
    if (runTimer) clearInterval(runTimer);
    runTimer = setInterval(() => {
      if (!running || halted) return;
      for (let i = 0; i < 4; i++) executeCycle();
      render();
    }, 100);
    render();
  }

  function halt() {
    running = false;
    halted = true;
    if (runTimer) clearInterval(runTimer);
    runTimer = null;
    $('lastOperation').textContent = 'HALT';
    log(`HALT .................. PC=${hex(pc, 8)}`);
    render();
  }

  function reset() {
    halt();
    pc = 0;
    address = 0;
    data = 0;
    accumulator = 0;
    cycles = 0;
    flags = { z: false, s: false, p: false, c: false, a: false };
    interruptEnabled = false;
    setSwitches(0, 16);
    memory.fill(0);
    // Small monitor/demo program: MVI A,42 / STA 1000 / LDA 1000 / HLT.
    memory.set([0x3E, 0x42, 0x32, 0x00, 0x10, 0x3A, 0x00, 0x10, 0x76], 0);
    $('lastOperation').textContent = 'RESET';
    log('RESET ................. OK');
    render();
  }

  function render() {
    addressLedBits.forEach((led, i) => led.classList.toggle('on', bit(address, 15 - i)));
    dataLedBits.forEach((led, i) => led.classList.toggle('on', bit(data, 7 - i)));

    switchButtons.forEach((button, i) => {
      const enabled = mode === 'ADDRESS' || i < 8;
      button.disabled = !enabled;
      button.classList.toggle('on', switchState[i]);
      button.classList.toggle('disabled', !enabled);
    });

    $('pc').textContent = hex(pc, 8);
    $('address').textContent = hex(address, 4);
    $('data').textContent = hex(data, 2);
    $('acc').textContent = hex(accumulator, 2);
    $('memoryInfo').textContent = `${hex(address, 4)}: ${hex(memory[address], 2)}`;
    $('cycles').textContent = hex(cycles, 8);
    $('flags').textContent = `${flags.z ? 'Z' : '-'}${flags.s ? 'S' : '-'}${flags.p ? 'P' : '-'}${flags.c ? 'C' : '-'}${flags.a ? 'A' : '-'}`;
    $('status').textContent = running ? 'RUNNING' : (halted ? 'HALTED' : 'READY');
    $('haltReadout').textContent = halted ? 'YES' : 'NO';
    $('interruptReadout').textContent = interruptEnabled ? 'ENABLED' : 'DISABLED';
    $('modeReadout').textContent = mode;
  }

  document.querySelectorAll('[data-action]').forEach((button) => {
    button.addEventListener('click', () => {
      const action = button.dataset.action;
      if (action === 'reset') reset();
      else if (action === 'load') loadAddress();
      else if (action === 'examine') examine();
      else if (action === 'deposit') deposit();
      else if (action === 'examineNext') examineNext();
      else if (action === 'depositNext') depositNext();
      else if (action === 'run') run();
      else if (action === 'step') singleStep();
      else if (action === 'halt') halt();
      else if (action === 'clear') clearTerminal();
    });
  });

  $('addressMode').addEventListener('click', () => setMode('ADDRESS'));
  $('dataMode').addEventListener('click', () => setMode('DATA'));

  document.addEventListener('keydown', (event) => {
    if (event.target.matches('input, textarea, select')) return;
    const key = event.key.toLowerCase();
    if (key === 'r') reset();
    if (key === 's') singleStep();
    if (key === 'h') halt();
    if (key === 'e') examine();
    if (key === 'd') deposit();
    if (key === 'l') loadAddress();
  });

  setInterval(() => {
    $('clock').textContent = new Date().toLocaleTimeString('en-US', { hour12: false });
  }, 250);

  buildPanel();
  reset();
})();
