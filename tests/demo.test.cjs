const {pathToFileURL}=require('node:url');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
const browser=await chromium.launch({...(process.env.BROWSER_CHANNEL?{channel:process.env.BROWSER_CHANNEL}:{}),headless:true});
const page=await browser.newPage({viewport:{width:1100,height:850}});
let errors=[];page.on('pageerror',e=>errors.push(e.message));
await page.goto(pathToFileURL(path.join(__dirname,'../demo/index.html')).href);
const count=async()=>await page.locator('#demo-count').innerText();
function check(ok,msg){if(!ok)throw Error(msg);}
await page.locator('#demo-step').click();check((await count()).startsWith('1 '),'increment');
await page.locator('#demo-run').uncheck();await page.locator('#demo-step').click();check((await count()).startsWith('1 '),'hold');
await page.locator('#demo-reset').check();check((await count()).startsWith('1 '),'reset must wait for edge');
await page.locator('#demo-step').click();check((await count()).startsWith('0 '),'reset edge');
await page.locator('#demo-reset').uncheck();await page.locator('#demo-run').check();
for(let i=0;i<16;i++)await page.locator('#demo-step').click();check((await count()).startsWith('0 '),'wrap');
await page.locator('#demo-mode').selectOption('trace');
check(await page.locator('#demo-run').isDisabled(),'trace controls');
for(let i=0;i<12;i++)await page.locator('#demo-step').click();
check((await count()).startsWith('6 '),'trace resume at125ns');
await page.locator('#demo-step').click();check((await count()).startsWith('0 '),'trace reset135ns');
for(let i=13;i<52;i++)await page.locator('#demo-step').click();
check((await count()).startsWith('1 '),'trace final count');
await page.locator('#demo-restart').click();await page.locator('#demo-auto').click();await page.waitForTimeout(850);await page.locator('#demo-auto').click();check((await count()).startsWith('1 '),'auto playback');

await page.setViewportSize({width:360,height:850});
check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'mobile overflow');
check(errors.length===0,errors.join('\n'));
console.log('PASS: interactive count/hold/synchronous reset/wrap, actual trace playback, auto clock, mobile layout, no JavaScript errors.');
await browser.close();
})().catch(e=>{console.error(e);process.exitCode=1;});
