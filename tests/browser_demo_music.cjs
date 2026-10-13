/* Targeted menu-player lifecycle checks. The YouTube iframe response is a
   labelled fixture, not proof that the third-party video/audio stream plays. */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const { pathToFileURL } = require('node:url');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '..');
const file = path.join(root, 'demo/bundschuh_rebellion.html');
const out = path.join(root, 'test-results/browser-demo-music');
fs.mkdirSync(out, { recursive: true });
(async () => {
  const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(fs.readFileSync(file));
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const origin = `http://127.0.0.1:${server.address().port}`;
  const options = { headless: true };
  if (process.env.BROWSER_EXECUTABLE) options.executablePath = process.env.BROWSER_EXECUTABLE;
  if (process.env.BROWSER_SINGLE_PROCESS === '1')
    options.args = [
      '--no-sandbox',
      '--no-zygote',
      '--single-process',
      '--in-process-gpu',
      '--use-gl=angle',
      '--use-angle=swiftshader',
      '--enable-unsafe-swiftshader',
      '--disable-dev-shm-usage',
    ];
  let browser;
  const errors = [],
    embeds = [];
  let checks = 0;
  function check(value, message) {
    assert.ok(value, message);
    checks++;
    console.log('PASS', message);
  }
  try {
    browser = await chromium.launch(options);
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    await context.route('https://www.youtube-nocookie.com/**', async (route) => {
      embeds.push({ url: route.request().url(), referrer: route.request().headers().referer });
      await route.fulfill({
        contentType: 'text/html; charset=utf-8',
        body: '<!doctype html><html><body style="margin:0;background:#14231b;color:#d2be86;display:grid;place-items:center;height:100vh;font:15px Georgia">YouTube player fixture · no audio stream</body></html>',
      });
    });
    const page = await context.newPage();
    page.on('pageerror', (e) => {
      errors.push(String(e));
      console.error('PAGE ERROR', String(e));
    });
    await page.goto(pathToFileURL(file).href);
    check(
      (await page.locator('#menu-music-player iframe').count()) === 0 && embeds.length === 0,
      'no YouTube request or player before opt-in',
    );
    check(
      await page.locator('#menu-music-file-help').isVisible(),
      'file:// has usable YouTube/referrer fallback guidance',
    );
    await context.setOffline(true);
    await page.locator('#menu-music-toggle').click();
    check(
      (await page.locator('#menu-music-status').innerText()).includes('offline'),
      'offline click explains connectivity instead of claiming playback',
    );
    check(
      (await page.locator('#menu-music-player iframe').count()) === 0,
      'offline music never starts a player',
    );
    await page.locator('#play').click();
    check(
      (await page.locator('#start').isHidden()) && (await page.locator('.hud').isVisible()),
      'offline gameplay remains playable without music',
    );
    await context.setOffline(false);
    await page.goto(origin + '/bundschuh_rebellion.html');
    check(
      await page.locator('#menu-music-file-help').isHidden(),
      'served page omits file-only guidance',
    );
    await page.locator('#menu-music-toggle').focus();
    await page.keyboard.press('Space');
    await page.locator('#menu-music-player iframe').waitFor();
    check(
      (await page.locator('#menu-music-toggle').getAttribute('aria-pressed')) === 'true',
      'Space activates accessible menu music control',
    );
    const iframe = page.locator('#menu-music-player iframe');
    const src = new URL(await iframe.getAttribute('src'));
    check(
      src.pathname === '/embed/pMLeQAPhHN8' &&
        src.searchParams.get('playlist') === 'pMLeQAPhHN8' &&
        src.searchParams.get('loop') === '1',
      'requested track is configured to loop with native controls',
    );
    const size = await iframe.boundingBox();
    check(
      size.width >= 200 && size.height >= 200,
      'visible player meets minimum viewport dimensions',
    );
    await page.waitForFunction(
      () => document.querySelector('#menu-music-player iframe')?.contentWindow,
    );
    check(!src.searchParams.has('origin'), 'no forged origin is added to the player');
    await page.screenshot({ path: path.join(out, 'menu-music-1440.png') });
    check(
      embeds.some((r) => r.referrer === origin + '/'),
      'HTTP embed receives the actual local page origin as referrer',
    );
    await page.locator('#menu-music-toggle').click();
    check((await iframe.count()) === 0, 'off destroys the iframe, not just its visibility');
    await page.locator('#menu-music-toggle').click();
    await page.locator('#play').click();
    check(
      (await iframe.count()) === 0 && (await page.locator('#start').isHidden()),
      'entering a match destroys the player even while loading',
    );
    await page.locator('#help').click();
    await page.locator('#new-game').click();
    check(
      (await iframe.count()) === 0 &&
        (await page.locator('#menu-music-toggle').getAttribute('aria-pressed')) === 'false',
      'returning to menu does not create duplicate or unsolicited playback',
    );
    await page.locator('#menu-music-toggle').click();
    await context.setOffline(true);
    await page.waitForFunction(() => !document.querySelector('#menu-music-player iframe'));
    check(
      (await page.locator('#menu-music-status').innerText()).includes('Mất kết nối'),
      'network loss stops the player and preserves a helpful message',
    );
    await context.setOffline(false);
    await page.locator('#menu-music-toggle').click();
    await page.evaluate(() => {
      Object.defineProperty(document, 'hidden', { configurable: true, value: true });
      document.dispatchEvent(new Event('visibilitychange'));
      delete document.hidden;
    });
    check((await iframe.count()) === 0, 'hidden-document lifecycle stops menu playback');
    const small = await context.newPage();
    await small.setViewportSize({ width: 1024, height: 768 });
    small.on('pageerror', (e) => errors.push(String(e)));
    await small.goto(origin + '/bundschuh_rebellion.html');
    await page.close();
    await small.locator('#menu-music-toggle').click();
    const play = await small.locator('#play').boundingBox();
    const music = await small.locator('#menu-music-player iframe').boundingBox();
    check(
      play.x >= 0 && play.x + play.width <= 1024 && play.y >= 0 && play.y + play.height <= 768,
      'play button remains reachable with music open at 1024×768',
    );
    check(
      music.y >= 0 && music.y + music.height <= 768,
      'music player remains visible in small desktop layout',
    );
    await small.screenshot({ path: path.join(out, 'menu-music-1024.png') });
    check(errors.length === 0, 'no page exceptions');
    fs.writeFileSync(
      path.join(out, 'report.json'),
      JSON.stringify(
        {
          passed: true,
          checks,
          stream: 'YouTube response stubbed; live playback not verified',
          embeds,
          errors,
        },
        null,
        2,
      ),
    );
  } finally {
    if (browser) await browser.close();
    server.closeAllConnections();
    await new Promise((resolve) => server.close(resolve));
  }
})().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
