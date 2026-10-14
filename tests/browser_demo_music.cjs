/* Real embedded-M4A playback, hidden menu lifecycle and introduction reveal.
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
    return player && (player.error || (!player.paused && player.currentTime > 0 && player.readyState >= 2));
  });
  const failure = await page.locator(selector).evaluate((player) =>
    player.error && { code: player.error.code, message: player.error.message });
  assert.equal(failure, null, 'embedded audio must decode: ' + JSON.stringify(failure));
}
async function rememberPlayer(page) {
  await page.evaluate(() => {
    window.previousMenuPlayer = document.querySelector('#menu-music-player audio');
  });
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
  const embedded = html.match(/<script id="menu-music-data" type="audio\/mp4">(.*?)<\/script>/s);
  check(embedded && Buffer.from(embedded[1], 'base64').equals(
    fs.readFileSync(path.join(root, 'sources/Wir sind des Geyers schwarzer Haufen.m4a'))),
  'HTML embeds the exact supplied M4A bytes with audio/mp4 MIME');
  const compatible = html.match(/<script id="menu-music-fallback-data" type="audio\/mp4">(.*?)<\/script>/s);
  const compatibleBytes = compatible && Buffer.from(compatible[1], 'base64');
  check(compatibleBytes && compatibleBytes.includes(Buffer.from('mp4a')),
    'HTML also embeds a browser-compatible AAC copy');
  let browser;
  let browserVersion;
  try {
    browser = await chromium.launch(launchOptions('no-user-gesture-required'));
    browserVersion = await browser.version();
    const context = await browser.newContext({
      viewport: { width: 1440, height: 900 }, offline: true, reducedMotion: 'no-preference',
    });
    const page = await context.newPage();
    observe(page);
    await page.addInitScript(() => {
      document.addEventListener('DOMContentLoaded', () => {
        requestAnimationFrame(() => {
          const menu = document.querySelector('#start');
          window.firstMenuFrame = { entered: menu.classList.contains('intro-enter'), visible: !menu.hidden };
        });
      });
    });
    await page.goto(url);
    await page.waitForFunction(() => {
      const animation = document.querySelector('.intro-copy')?.getAnimations()[0];
      return animation && animation.playState === 'running' &&
        animation.currentTime >= animation.effect.getTiming().delay;
    });
    const flight = await page.evaluate(async () => {
      const block = document.querySelector('.intro-copy');
      const animation = block.getAnimations()[0];
      window.previousMenuAnimation = animation;
      const sample = () => {
        const style = getComputedStyle(block);
        const matrix = new DOMMatrixReadOnly(style.transform);
        return { x: matrix.m41, y: matrix.m42, opacity: Number(style.opacity) };
      };
      const first = sample();
      const firstTime = animation.currentTime;
      await new Promise((resolve) => {
        const observe = () => {
          if (animation.currentTime >= firstTime + 300) resolve();
          else requestAnimationFrame(observe);
        };
        requestAnimationFrame(observe);
      });
      return { name: animation.animationName, first, later: sample(), firstFrame: window.firstMenuFrame };
    });
    check(flight.firstFrame.visible && !flight.firstFrame.entered,
      'menu is painted before the entrance animation starts');
    check(flight.name === 'menu-fly-in' && flight.first.x < -30 && flight.first.y === 0,
      'whole introduction starts visibly to the left on normal file opening');
    check(flight.later.x > flight.first.x && flight.later.x < 0 &&
      flight.later.y === 0 && flight.later.opacity > flight.first.opacity,
    'unmodified animation moves smoothly to the right and fades in over real frames');
    await page.screenshot({ path: path.join(out, 'menu-fly-in-midpoint.png') });
    await page.evaluate(() => window.previousMenuAnimation.finished);
    check(await page.locator('.intro-copy').evaluate((block) => {
      const style = getComputedStyle(block);
      const matrix = new DOMMatrixReadOnly(style.transform);
      return style.opacity === '1' && matrix.m41 === 0 && matrix.m42 === 0;
    }), 'introduction settles at its original position, fully visible');
    await playing(page);
    check(await page.locator('#start').isVisible(), 'opening file:// offline shows the menu');
    check(await page.locator(selector).count() === 1, 'menu starts one player without a click when autoplay is permitted');
    check(await page.locator(selector).evaluate((player) =>
      player.autoplay && player.loop && !player.muted && player.volume > 0 &&
      player.src.startsWith('data:audio/mp4;base64,') && Number.isFinite(player.duration) && player.duration > 0),
    'real M4A decodes and plays offline with looping enabled');
    check(await page.locator('#menu-music-player').isHidden() &&
      await page.locator(selector).isHidden() &&
      await page.locator(selector).evaluate((player) => !player.controls) &&
      await page.locator('#menu-music-toggle, #menu-music-status, .menu-music').count() === 0,
    'all music text, buttons and controls are absent from the screen');

    await page.screenshot({ path: path.join(out, 'menu-music-1440.png') });

    await rememberPlayer(page);
    await context.setOffline(false);
    await page.waitForFunction(() => navigator.onLine);
    await context.setOffline(true);
    await page.waitForFunction(() => !navigator.onLine);
    await playing(page);
    check(await page.locator(selector).evaluate((player) => player === window.previousMenuPlayer),
      'network transitions do not restart embedded music');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    check(await page.locator(selector).count() === 1, 'repeated lifecycle events do not duplicate the player');

    await page.locator('#play').click();
    check(await released(page) && await page.locator(selector).count() === 0 &&
      await page.locator('.hud').isVisible(), 'entering gameplay stops and releases playing audio');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    check(await page.locator(selector).count() === 0, 'gameplay remains silent across lifecycle events');
    await returnToMenu(page);
    await page.waitForFunction(() => document.querySelector('.intro-copy').getAnimations().length > 0);
    check(await page.locator('.intro-copy').evaluate((block) =>
      block.getAnimations()[0] !== window.previousMenuAnimation),
    'returning to the menu starts a new introduction animation');
    await playing(page);
    check(await page.locator(selector).count() === 1, 'returning to the menu restarts hidden music');

    await rememberPlayer(page);
    await visibility(page, true);
    check(await released(page) && await page.locator(selector).count() === 0,
      'hidden document stops and releases audio');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    check(await page.locator(selector).count() === 0, 'hidden pages remain silent');
    await visibility(page, false);
    await playing(page);
    check(await page.locator(selector).count() === 1, 'visible menu restores hidden music');
    await rememberPlayer(page);
    await page.evaluate(() => window.dispatchEvent(new Event('pagehide')));
    check(await released(page), 'pagehide stops and releases music');
    await page.evaluate(() => window.dispatchEvent(new Event('pageshow')));
    await playing(page);

    // Start during a newly created player's load/play request in the same task.
    await page.evaluate(() => {
      Object.defineProperty(document, 'hidden', { configurable: true, value: true });
      document.dispatchEvent(new Event('visibilitychange'));
      delete document.hidden;
      document.dispatchEvent(new Event('visibilitychange'));
      window.previousMenuPlayer = document.querySelector('#menu-music-player audio');
      document.querySelector('#play').click();
    });
    check(await released(page) && await page.locator(selector).count() === 0,
      'starting immediately cancels pending playback without leaking audio');

    const reduced = await browser.newContext({
      viewport: { width: 1024, height: 768 }, offline: true, reducedMotion: 'reduce',
    });
    const small = await reduced.newPage();
    observe(small);
    await small.goto(url);
    await page.close();
    await playing(small);
    check(await small.locator('.intro-copy').evaluateAll((nodes) =>
      nodes.every((node) => node.getAnimations().length === 0 && getComputedStyle(node).opacity === '1')),
    'reduced motion shows introduction text immediately without animation');
    const box = await small.locator('#play').boundingBox();
    check(box && box.x >= 0 && box.y >= 0 && box.x + box.width <= 1024 && box.y + box.height <= 768,
      'match button remains visible at 1024×768');
    check(await small.locator(selector).isHidden(), 'music remains hidden in the small desktop layout');
    await small.screenshot({ path: path.join(out, 'menu-music-1024.png') });
    await browser.close();
    browser = null;

    browser = await chromium.launch(launchOptions('document-user-activation-required'));
    const blockedContext = await browser.newContext({ offline: true });
    const blocked = await blockedContext.newPage();
    observe(blocked);
    await blocked.goto(url);
    await blocked.waitForFunction(() =>
      document.querySelector('#menu-music-player audio')?.dataset.playback === 'blocked');
    check(await blocked.locator(selector).isHidden() &&
      await blocked.locator(selector).evaluate((player) => player.paused),
    'blocked autoplay stays hidden without throwing a page error');
    await blocked.locator('[data-faction="swabian_league"]').click();
    await playing(blocked);
    check(await blocked.locator(selector).isHidden(), 'menu interaction retries blocked playback without showing controls');
    await rememberPlayer(blocked);
    await blocked.locator('#play').click();
    check(await released(blocked), 'gameplay stops music started after a menu interaction');

    check(errors.length === 0, 'no page exceptions or unhandled playback rejections');
    check(requests.every((request) => request.startsWith('file:') || request.startsWith('data:')),
      'no remote media, CDN, font or fetch requests');
    fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({
      passed: true, checks, browser: browserVersion,
      stream: 'real embedded M4A decoded and playing offline; controls hidden',
      errors, requests,
    }, null, 2));
    console.log('Browser menu music and reveal: ' + checks + ' checks passed');
  } finally {
    if (browser) await browser.close();
  }
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
