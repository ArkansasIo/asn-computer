const addressEl=document.getElementById('address');
const dataEl=document.getElementById('data');
const switchesEl=document.getElementById('switches');
const canvas=document.getElementById('display');
const ctx=canvas.getContext('2d');
let pc=0, data=0, switches=0, running=false;

function leds(container,count){container.innerHTML='';for(let i=0;i<count;i++){const e=document.createElement('div');e.className='led';container.appendChild(e)}}
function renderLeds(container,value,count){[...container.children].forEach((e,i)=>e.classList.toggle('on',Boolean(value&(1<<(count-1-i)))))}
leds(addressEl,16);leds(dataEl,8);

const grid=document.createElement('div');grid.className='switchgrid';
for(let i=0;i<16;i++){const b=document.createElement('button');b.textContent='SW'+i;b.onclick=()=>{switches^=(1<<i);b.classList.toggle('on',Boolean(switches&(1<<i)))};grid.appendChild(b)}
switchesEl.appendChild(grid);

function draw(){ctx.fillStyle='#020608';ctx.fillRect(0,0,canvas.width,canvas.height);ctx.fillStyle='#7fb7c7';ctx.font='72px monospace';ctx.fillText('ALTAIR 8800 / 2026',180,180);ctx.font='44px monospace';ctx.fillText(`64-BIT  PC ${pc.toString(16).padStart(8,'0').toUpperCase()}`,180,280);ctx.fillText('DDR5  •  NVMe  •  PCIe  •  USB4  •  4K',180,360);ctx.fillText(`SW ${switches.toString(16).padStart(4,'0').toUpperCase()}`,180,440)}
function step(){pc=(pc+1)&0xffff;data=(pc^(switches*257))&0xff;renderLeds(addressEl,pc,16);renderLeds(dataEl,data,8);draw()}
document.getElementById('reset').onclick=()=>{pc=0;data=0;switches=0;[...grid.children].forEach(b=>b.classList.remove('on'));renderLeds(addressEl,0,16);renderLeds(dataEl,0,8);draw()};
document.getElementById('step').onclick=step;
document.getElementById('run').onclick=()=>{running=true};
document.getElementById('halt').onclick=()=>{running=false};
setInterval(()=>{if(running)step()},50);draw();
