/* Real embedded-MP3 decoding, autoplay/fallback and menu-player lifecycle checks.
   Install Playwright outside the repo; no media responses are stubbed. */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '..');
const file = path.join(root, 'demo/bundschuh_rebellion.html');
const out = path.join(root, 'test-results/browser-demo-music');
fs.mkdirSync(out, { recursive: true });
const url = pathToFileURL(file).href;
const selector = '#menu-music-player audio';
const errors = [], requests = [];
let checks = 0;
function check(value, message) {
  assert.ok(value, message);
  checks++;
  console.log('PASS', message);
}
function observe(page) {
  page.on('pageerror', (error) => errors.push(String(error)));
  page.on('request', (request) => requests.push(request.url().split(',')[0]));
}
async function playing(page) {
  await page.waitForFunction(() => {
    const player = document.querySelector('#menu-music-player audio');
    return player && !player.paused && player.currentTime > 0 && player.readyState >= 2;
  });
}
async function rememberPlayer(page) {
  await page.evaluate(() => { window.previousMenuPlayer = document.querySelector('#menu-music-player audio'); });
}
async function released(page) {
  return page.evaluate(() => {
    const player = window.previousMenuPlayer;
    return player && player.paused && !player.isConnected && !player.hasAttribute('src');
  });
}
async function returnToMenu(page) {
  await page.locator('#help').click();
  await page.locator('#new-game').click();
}
async function visibility(page, hidden) {
  await page.evaluate((value) => {
    if (value) Object.defineProperty(document, 'hidden', { configurable: true, value: true });
    else delete document.hidden;
    document.dispatchEvent(new Event('visibilitychange'));
  }, hidden);
}
function launchOptions(policy) {
  const options = { headless: true, args: ['--autoplay-policy=' + policy] };
  if (process.env.BROWSER_EXECUTABLE) options.executablePath = process.env.BROWSER_EXECUTABLE;
  if (process.env.BROWSER_SINGLE_PROCESS === '1')
    options.args.push('--no-sandbox', '--no-zygote', '--single-process', '--in-process-gpu',
      '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
      '--disable-dev-shm-usage');
  return options;
}
(async () => {
  const html = fs.readFileSync(file, 'utf8');
  const embedded = html.match(/<script id="menu-music-data" type="audio\/mpeg">(.*?)<\/script>/s);
  check(embedded && Buffer.from(embedded[1], 'base64').equals(
    fs.readFileSync(path.join(root, 'sources/Wir sind des Geyers schwarzer Haufen.mp3'))),
  'HTML embeds the exact supplied MP3 bytes');

  let browser;
  let browserVersion;
  try {
    // Test permitted autoplay with a fresh, offline page and no user interaction.
    browser = await chromium.launch(launchOptions('no-user-gesture-required'));
    browserVersion = await browser.version();
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, offline: true });
    const page = await context.newPage();
    observe(page);
    await page.goto(url);
    await playing(page);
    check(await page.locator('#start').isVisible(), 'opening file:// offline shows the menu');
    check(await page.locator(selector).count() === 1, 'one player starts without a click when autoplay is permitted');
    check(await page.locator(selector).evaluate((player) =>
      player.controls && player.autoplay && player.loop && !player.muted && player.volume > 0 &&
      player.src.startsWith('data:audio/mpeg;base64,') && Number.isFinite(player.duration) && player.duration > 0),
    'real MP3 decodes offline with audible, looping native controls');
    check((await page.locator('#menu-music-status').innerText()).includes('Đang phát'),
      'status reflects actual playback');
    await page.screenshot({ path: path.join(out, 'menu-music-1440.png') });

    await context.setOffline(false);
    await page.waitForFunction(() => navigator.onLine);
    await context.setOffline(true);
    await page.waitForFunction(() => !navigator.onLine);
    await playing(page);
    check(await page.locator(selector).count() === 1, 'network transitions keep embedded music playing');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    check(await page.locator(selector).count() === 1, 'repeated lifecycle events do not duplicate the player');

    await rememberPlayer(page);
    await page.locator('#play').click();
    check(await released(page) && await page.locator(selector).count() === 0 &&
      await page.locator('.hud').isVisible(), 'entering gameplay stops and releases the actual playing audio');
    await page.evaluate(() => {
      window.dispatchEvent(new Event('pageshow'));
      window.dispatchEvent(new Event('online'));
    });
    check(await page.locator(selector).count() === 0, 'gameplay remains silent across lifecycle events');
    await returnToMenu(page);
    await playing(page);
    check(await page.locator(selector).count() === 1, 'returning to the menu restores enabled music');

    await rememberPlayer(page);
    await visibility(page, true);
    check(await released(page) && await page.locator(selector).count() === 0,
      'hidden menu pauses and releases audio');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    check(await page.locator(selector).count() === 0, 'hidden pages remain silent');
    await visibility(page, false);
    await playing(page);
    check(await page.locator(selector).count() === 1, 'visible menu restores music');

    await rememberPlayer(page);
    await page.locator('#menu-music-toggle').focus();
    await page.keyboard.press('Space');
    check(await released(page) &&
      await page.locator('#menu-music-toggle').getAttribute('aria-pressed') === 'false',
    'keyboard toggle turns music off and releases audio');
    await visibility(page, true);
    await visibility(page, false);
    await context.setOffline(false);
    await page.waitForFunction(() => navigator.onLine);
    await context.setOffline(true);
    await page.waitForFunction(() => !navigator.onLine);
    check(await page.locator(selector).count() === 0, 'Off survives visibility and network transitions');
    await page.locator('#play').click();
    await returnToMenu(page);
    check(await page.locator(selector).count() === 0 &&
      await page.locator('#menu-music-toggle').getAttribute('aria-pressed') === 'false',
    'Off survives returning from a match');
    await page.locator('#menu-music-toggle').click();
    await playing(page);
    await rememberPlayer(page);
    await page.evaluate(() => window.dispatchEvent(new Event('pagehide')));
    check(await released(page), 'pagehide stops and releases music');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    await playing(page);
    check(await page.locator(selector).count() === 1, 'pageshow restores enabled music');

    // Enter a match immediately after player creation to cover pending play/load.
    await page.evaluate(() => {
      document.querySelector('#menu-music-toggle').click();
      document.querySelector('#menu-music-toggle').click();
      window.previousMenuPlayer = document.querySelector('#menu-music-player audio');
      document.querySelector('#play').click();
    });
    check(await released(page) && await page.locator(selector).count() === 0,
      'starting immediately cancels pending playback without leaking audio');

    const small = await context.newPage();
    observe(small);
    await small.setViewportSize({ width: 1024, height: 768 });
    await small.goto(url);
    await page.close();
    await playing(small);
    for (const [id, label] of [['#play', 'match button'], [selector, 'audio controls']]) {
      const box = await small.locator(id).boundingBox();
      check(box && box.x >= 0 && box.y >= 0 && box.x + box.width <= 1024 && box.y + box.height <= 768,
        label + ' remains visible at 1024×768');
    }
    await small.screenshot({ path: path.join(out, 'menu-music-1024.png') });
    await browser.close();
    browser = null;

    // Force the browser's real autoplay restriction; native Play must still work.
    browser = await chromium.launch(launchOptions('document-user-activation-required'));
    const blockedContext = await browser.newContext({ offline: true });
    const blocked = await blockedContext.newPage();
    observe(blocked);
    await blocked.goto(url);
    await blocked.waitForFunction(() =>
      document.querySelector('#menu-music-status').textContent.includes('chặn tự phát'));
    check(await blocked.locator(selector).isVisible() &&
      await blocked.locator(selector).evaluate((player) => player.paused),
    'blocked autoplay shows native Play and an accurate fallback message');
    const controls = await blocked.locator(selector).boundingBox();
    await blocked.mouse.click(controls.x + 25, controls.y + controls.height / 2);
    await playing(blocked);
    check((await blocked.locator('#menu-music-status').innerText()).includes('Đang phát'),
      'native Play starts the actual MP3 after blocked autoplay');
    await rememberPlayer(blocked);
    await blocked.locator('#play').click();
    check(await released(blocked), 'gameplay also stops audio started through native Play');

    check(errors.length === 0, 'no page exceptions or unhandled playback rejections');
    check(requests.every((request) => request.startsWith('file:') || request.startsWith('data:')),
      'no remote media, CDN, font or fetch requests');
    fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({
      passed: true, checks, browser: browserVersion, stream: 'real embedded MP3 decoded and playing offline',
      errors, requests,
    }, null, 2));
    console.log('Browser menu music: ' + checks + ' checks passed');
  } finally {
    if (browser) await browser.close();
  }
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
