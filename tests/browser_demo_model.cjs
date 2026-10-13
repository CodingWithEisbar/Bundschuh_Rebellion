/* Run the actual embedded pure model, not a rewritten simulator. No npm deps. */
'use strict';
const assert = require('node:assert/strict'),
  fs = require('node:fs'),
  path = require('node:path'),
  vm = require('node:vm'),
  crypto = require('node:crypto');
const root = path.resolve(__dirname, '..'),
  html = fs.readFileSync(path.join(root, 'demo/bundschuh_rebellion.html'), 'utf8');
const raw = html.match(/<script id="balance-data" type="application\/json">(.*?)<\/script>/s)[1];
const box = { document: { getElementById: () => ({ textContent: raw }) } };
vm.createContext(box);
vm.runInContext(
  html.split('<script>')[1].split('/* MODEL_END */')[0] + '\nthis.model=DEMO_MODEL;',
  box,
);
const { Game, STATS, BALANCE, STEP, W, H } = box.model;
let passed = 0;
function test(name, run) {
  run();
  passed++;
  console.log('PASS', name);
}
function advance(g, seconds) {
  for (let i = 0; i < Math.ceil(seconds / STEP); i++) g.step();
}
function empty() {
  const g = new Game();
  g.units = [];
  g.buildings = [];
  g.resources = [];
  g.byId.clear();
  g.blocks.clear();
  g.terrain.fill(0);
  g.ai = () => {};
  return g;
}
function stock(g, type) {
  return (
    g.players.reduce((n, p) => n + p.bank[type], 0) +
    g.units.reduce((n, u) => n + (u.cargo.type === type ? u.cargo.amount : 0), 0) +
    g.resources.filter((r) => r.type === type).reduce((n, r) => n + r.amount, 0)
  );
}
test('embedded database is exact current JSON with source hash', () => {
  const original = fs.readFileSync(path.join(root, 'data/balance/units.v1.json'));
  assert.equal(BALANCE.source_sha256, crypto.createHash('sha256').update(original).digest('hex'));
  const a = JSON.parse(raw);
  delete a.source_sha256;
  assert.deepEqual(a, JSON.parse(original));
});
test('seed determinism and three traversable forest corridors', () => {
  for (const seed of [0, 1, 1524, 999999]) {
    const a = new Game('bundschuh', seed),
      b = new Game('bundschuh', seed);
    assert.deepEqual([...a.blocks.keys()], [...b.blocks.keys()]);
    for (const y of [8, 15, 23])
      assert.ok(a.path({ x: 16.5, y: y + 0.5 }, { x: 26.5, y: y + 0.5 }));
    assert.ok(a.path({ x: 9.5, y: 18.5 }, { x: 31.5, y: 18.5 }));
  }
});
test('A* never cuts a blocked diagonal corner', () => {
  const g = empty();
  g.resource('wood', 5, 4, 10);
  g.resource('wood', 4, 5, 10);
  const p = g.path({ x: 4.5, y: 4.5 }, { x: 5.5, y: 5.5 });
  assert.ok(p.length > 2);
});
test('finite gathering needs arrival and deposit, conserves all resources', () => {
  const g = empty();
  g.building('town', 0, 3, 3);
  const u = g.spawn('villager', 0, 10.5, 8.5),
    r = g.resource('gold', 11, 8, 17);
  const initial = stock(g, 'gold'),
    bank = g.players[0].bank.gold;
  g.order([u], 'gather', r);
  advance(g, 3);
  assert.equal(g.players[0].bank.gold, bank);
  assert.ok(u.cargo.amount > 0);
  advance(g, 45);
  assert.equal(r.amount, 0);
  assert.equal(u.cargo.amount, 0);
  assert.equal(g.players[0].bank.gold, bank + 17);
  assert.equal(stock(g, 'gold'), initial);
  assert.ok(!g.blocks.has(8 * W + 11));
});
test('changing resource order preserves cargo type and integer amount', () => {
  const g = empty();
  g.building('town', 0, 3, 3);
  const u = g.spawn('villager', 0, 7.5, 8.5),
    a = g.resource('gold', 8, 8, 100),
    b = g.resource('wood', 9, 8, 100);
  const gold = stock(g, 'gold'),
    wood = stock(g, 'wood');
  g.order([u], 'gather', a);
  advance(g, 3);
  assert.ok(u.cargo.amount);
  g.order([u], 'gather', b);
  advance(g, 50);
  assert.equal(stock(g, 'gold'), gold);
  assert.equal(stock(g, 'wood'), wood);
});
test('placement pays once, zero HP, physical work, one housing increment', () => {
  const g = empty();
  g.building('town', 0, 3, 3);
  const u = g.spawn('villager', 0, 5.5, 8.5);
  const before = g.players[0].bank.wood,
    b = g.place('house', 9, 9, [u]);
  assert.ok(b);
  assert.equal(b.hp, 0);
  assert.equal(g.players[0].bank.wood, before - 25);
  assert.equal(g.cap(0), 20);
  advance(g, 1);
  assert.equal(b.hp, 0);
  advance(g, 45);
  assert.ok(b.complete);
  assert.equal(b.hp, b.maxHp);
  assert.equal(g.cap(0), 25);
  advance(g, 5);
  assert.equal(g.cap(0), 25);
  assert.equal(g.metrics.built, 1);
  assert.equal(g.place('house', 9, 9, [u]), null);
});
test('road / occupied / unaffordable footprints are rejected without spending', () => {
  const g = new Game();
  const bank = g.players[0].bank.wood;
  assert.ok(g.placement('house', 19, 15, 0));
  assert.ok(g.placement('house', 5, 14, 0));
  g.players[0].bank.wood = 0;
  assert.ok(g.placement('house', 10, 10, 0));
  assert.equal(bank, 400);
});
test('paid recruitment reserves population, cancel refunds, spawn waits for completion', () => {
  const g = empty();
  const b = g.building('town', 0, 3, 3),
    food = g.players[0].bank.food;
  assert.ok(g.recruit(b, 'villager'));
  assert.equal(g.population(0), 1);
  assert.equal(g.players[0].bank.food, food - 50);
  g.cancelRecruit(b, 0);
  assert.equal(g.players[0].bank.food, food);
  assert.equal(g.population(0), 0);
  g.recruit(b, 'villager');
  advance(g, 24);
  assert.equal(g.units.length, 0);
  advance(g, 2);
  assert.equal(g.units.length, 1);
  assert.equal(g.population(0), 1);
});
test('factions cannot recruit the other roster and cap includes queued units', () => {
  const g = empty(),
    b = g.building('barracks', 0, 3, 3);
  g.building('town', 0, 7, 7);
  assert.equal(g.recruit(b, 'heavy_gendarme'), false);
  for (let i = 0; i < 20; i++) g.spawn('villager', 0, 12 + (i % 5), 12 + Math.floor(i / 5));
  assert.equal(g.recruit(b, 'peasant_flailman'), false);
});
test('base damage / armor / +25 cavalry / spear counter', () => {
  const g = empty(),
    p = g.spawn('pikeman', 0, 2, 2),
    c = g.spawn('heavy_gendarme', 1, 3, 2),
    f = g.spawn('peasant_flailman', 0, 2, 3),
    l = g.spawn('landsknecht_pikeman', 1, 3, 3);
  assert.equal(g.damage(p, c), 27);
  assert.equal(g.damage(f, c), 5);
  assert.equal(g.damage(c, f), 12);
  assert.equal(g.damage(f, l), 10);
});
test('zeal scans at one second, +15%, allied only, nonstacking and expires', () => {
  const g = empty(),
    u = g.spawn('pikeman', 0, 3, 3),
    e = g.spawn('villager', 1, 4, 4);
  u.order.type = 'hold';
  e.order.type = 'hold';
  const a = g.spawn('radical_preacher', 0, 3, 4),
    b = g.spawn('radical_preacher', 0, 4, 3);
  advance(g, 0.95);
  assert.equal(u.buff, 1);
  advance(g, 0.05);
  assert.equal(u.buff, 1.15);
  assert.equal(u.attackRate, 1.15);
  assert.equal(e.buff, 1);
  a.hp = 0;
  b.hp = 0;
  advance(g, 1);
  assert.equal(u.buff, 1);
});
test('lethal hits in same tick trade simultaneously; stop cannot reset cooldown', () => {
  const g = empty(),
    a = g.spawn('peasant_flailman', 0, 4, 4),
    b = g.spawn('peasant_flailman', 1, 4.7, 4);
  a.hp = b.hp = 7;
  g.order([a], 'attack', b);
  g.order([b], 'attack', a);
  g.step();
  assert.equal(a.hp, 0);
  assert.equal(b.hp, 0);
  assert.equal(g.metrics.kills, 1);
  const c = g.spawn('peasant_flailman', 0, 8, 8),
    d = g.spawn('heavy_gendarme', 1, 8.7, 8);
  g.order([c], 'attack', d);
  g.step();
  const hp = d.hp;
  g.order([c], 'idle');
  g.order([c], 'attack', d);
  g.step();
  assert.equal(d.hp, hp);
});
test('infantry and ranged can approach and destroy a building without range deadlock', () => {
  for (const type of ['peasant_flailman', 'crossbowman']) {
    const g = empty(),
      b = g.building('town', 1, 15, 15),
      u = g.spawn(type, 0, 8.5, 14.5);
    b.hp = 10;
    g.order([u], 'attack', b);
    advance(g, 45);
    assert.equal(g.result, 'victory', type);
    assert.ok(b.dead);
    assert.equal(g.blocks.has(15 * W + 15), false);
    const t = g.tick;
    g.step();
    assert.equal(g.tick, t);
  }
});
test('melee closes on a fractional-position unit and lands real hits', () => {
  const g = empty(),
    u = g.spawn('peasant_flailman', 0, 3.5, 10.5),
    t = g.spawn('radical_preacher', 1, 10.3, 10.7);
  g.order([u], 'attack', t);
  advance(g, 30);
  assert.equal(t.hp, 0);
  assert.equal(g.metrics.kills, 1);
});
test('hold position attacks in range but never chases', () => {
  const g = empty(),
    u = g.spawn('peasant_flailman', 0, 6.5, 6.5),
    t = g.spawn('radical_preacher', 1, 10.5, 6.5);
  g.order([u], 'hold');
  advance(g, 5);
  assert.equal(u.x, 6.5);
  assert.equal(t.hp, t.maxHp);
  t.x = 7.2;
  g.step();
  assert.equal(u.x, 6.5);
  assert.equal(t.hp, t.maxHp - 7);
});
test('own HQ loss ends defeat exactly once', () => {
  const g = empty(),
    b = g.building('town', 0, 3, 3),
    u = g.spawn('heavy_gendarme', 1, 2.5, 4.5);
  b.hp = 1;
  g.order([u], 'attack', b);
  advance(g, 1);
  assert.equal(g.result, 'defeat');
});
test('36 mixed-speed bodies traverse the forest without overlaps or wall penetration', () => {
  const g = new Game();
  g.ai = () => {};
  for (const u of g.units) g.byId.delete(u.id);
  g.units = [];
  for (let i = 0; i < 36; i++)
    g.spawn(
      i % 2 ? 'heavy_gendarme' : 'pikeman',
      0,
      2.5 + (i % 4) * 0.65,
      12.5 + Math.floor(i / 4) * 0.65,
    );
  g.order(g.units, 'move', { x: 26, y: 15 });
  advance(g, 65);
  assert.ok(g.units.filter((u) => u.x > 23).length >= 34);
  for (let i = 0; i < g.units.length; i++) {
    const u = g.units[i];
    assert.ok(g.free(Math.floor(u.x), Math.floor(u.y)));
    for (let j = i + 1; j < g.units.length; j++)
      assert.ok(Math.hypot(u.x - g.units[j].x, u.y - g.units[j].y) >= 0.35);
  }
});
console.log(`Browser demo model: ${passed} cases passed`);
