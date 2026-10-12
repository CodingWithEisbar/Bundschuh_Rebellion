# Stage 5 — Unit database, balance arena và runtime reload

**Godot 4.5.2 Standard + Python 3.10 trở lên; không cần pip hoặc .NET.**
JSON là nguồn duy nhất cho base stats của combat roster. Python đọc/validate dữ
liệu và điều phối thử nghiệm; Godot chạy **chính CombatWorld/DamageCalculator của
game**. Không có bản sao công thức combat viết riêng bằng Python.

## 1. Dữ liệu Phase 2 được dùng

Nguồn: [GDD Phase 2, mục 4 và 5.1](gdd/BUNDSCHUH_REBELLION_GDD_PHASE_2.md).
Các giá trị là base, chưa Blacksmith, Elite, bonus phe hoặc unique technologies.

| ID trong JSON | Tên | F/W/G/S | HP | Attack M | Giáp M/P | Tốc độ ô/s | Chu kỳ | Tầm vũ khí | Counter |
|---|---|---|---:|---:|---|---:|---:|---:|---|
| `peasant_flailman` | Peasant Flailman | 45/15/0/0 | 45 | 7 | 0/0 | 1.10 | 2.0s | 0.5 | +4 Spear |
| `radical_preacher` | Radical Preacher | 0/0/100/0 | 35 | 0 | 0/0 | 0.85 | 0 — không đánh | 0 | — |
| `landsknecht_pikeman` | Landsknecht Pikeman | 55/0/35/0 | 65 | 6 | 1/0 | 0.90 | 2.0s | 1.0 | +24 Cavalry |
| `heavy_gendarme` | Heavy Gendarme / Armoured Ritter | 90/0/100/0 | 125 | 12 | 2/2 | 1.30 | 1.8s | 0.5 | — |

**Tên Heavy Gendarme trong prompt được ánh xạ rõ sang Armoured Ritter của GDD.**
`armoured_ritter` là alias của `heavy_gendarme`; không tạo quân thứ hai và không
lấy nhầm 150 HP của Elite Ritter hoặc 170 HP sau Bloodlines.

Giá Flailman 45F+15W là **giá cơ sở**. Giá 39F+15W sau bonus phe không được tự
áp vào trận thử. League cũng chưa được +1 melee armor A3. Không tự thêm charge,
splash, armor piercing, heal hoặc conversion vì tên unit gợi ý khả năng đó.

Hai override đã được người dùng chốt ở Stage 2 vẫn giữ nguyên: Pikeman thường
+25 Cavalry; Preacher aura bán kính 6, attack rate/movement rate ×1.15 mỗi giây.
Không khôi phục aura +attack của GDD cũ. Heal/relic của Preacher chưa triển khai.

## 2. JSON và schema

- [units.v1.json](../data/balance/units.v1.json): dữ liệu đầy đủ, 10 quân hiện có;
  bốn UU ở đầu, sáu record còn lại giữ tương thích Stage 2–4.
- [units.schema.json](../data/balance/units.schema.json): JSON Schema 2020-12;
  hai loader dùng chung schema, có thêm cross-field validation.
- [unit_database.gd](../scripts/balance/unit_database.gd): runtime Godot.
- [unit_db.py](../tools/unit_db.py): parser, snapshots và reload bằng Python.

Một record đầy đủ (đặt trong mảng `units` của file thật):

```json
{
  "id": "peasant_flailman",
  "name": "Peasant Flailman",
  "source_name": "Peasant Flailman",
  "aliases": [],
  "kind": "FLAILMAN",
  "faction": "bundschuh",
  "age": 2,
  "economy": {
    "cost": {"food": 45, "wood": 15, "gold": 0, "stone": 0},
    "population": 1,
    "train_seconds": 16
  },
  "combat": {
    "hp": 45,
    "attack": 7,
    "damage_type": "melee",
    "armor": {"melee": 0, "pierce": 0},
    "armor_classes": ["infantry"],
    "bonus_damage": {"spear": 4},
    "bonus_armor": {},
    "attack_period": 2.0,
    "range_tiles": 0.5,
    "minimum_range_tiles": 0,
    "impact_fraction": 0
  },
  "movement": {"speed_tiles_per_second": 1.1, "body_radius_tiles": 0.18},
  "zeal": {
    "enabled": false,
    "radius_tiles": 0,
    "attack_rate_multiplier": 1,
    "movement_rate_multiplier": 1
  },
  "notes": "Base tier; no splash or Cavalry counter."
}
```

Record ở trên có cùng tuning; `notes` được rút gọn để dễ đọc. File đầy đủ giữ
provenance, chú thích và bốn record chính xác. Root gồm `schema_version = 1`,
`balance_id`, `stat_basis`, `source_document`, `ruleset_notes` và `units`.

| Nhóm | Quy tắc |
|---|---|
| Identity | ID/alias duy nhất; enum kind ổn định; display name đổi được |
| Economy | F/W/G/S là số nguyên không âm; population/train time dương |
| Damage | `melee`/`pierce` chọn kênh giáp; armor classes dùng tên, không lưu enum ordinal |
| Counters | Mỗi class tính một lần; bonus armor chỉ trừ counter cùng class |
| Timing | Chu kỳ ít nhất 0.05s cho quân đánh; support không đánh dùng period/marker 0 |
| Contact | `impact_fraction` trong [0,1); 0 giữ cadence cũ, Stage 4 profile có thể đặt lại lúc spawn |
| Movement | Tốc độ dương; radius 0.18 hiện là tuning prototype, không phải chỉ số lịch sử |
| Zeal | Chỉ Bundschuh Preacher được bật; source có data riêng; nhiều nguồn lấy mức mạnh nhất cho từng stat |
| Extensibility | Field lạ bị từ chối để bắt typo; thêm cơ chế mới cần schema/adapter mới |

V1 cho một base definition trên mỗi engine kind. Đổi HP, cost, armor, damage,
period, range, speed, radius, marker, counter và Zeal không cần sửa/recompile core.
Thêm loại hành vi mới hoặc tier dùng kind mới vẫn cần code/schema thích hợp;
JSON không tự sinh một cơ chế charge hay heal còn thiếu.

Input giới hạn 1 MiB, nesting 32. Syntax guard loại duplicate object keys,
trailing commas, escape sai và number sai; schema loại field thiếu/lạ, NaN,
Infinity, boolean giả số, số lẻ ở HP/cost và armor class không biết. Kiểm tra thêm
ID/alias trùng, min range > max range, ghost attack của support và thiếu core IDs.

## 3. Chạy trận 100 Flailmen vs 20 Gendarmes

Từ thư mục repo, thay đường dẫn Godot bằng executable trên máy bro:

```sh
python tools/balance.py validate
python tools/balance.py simulate --godot /path/to/godot
```

PowerShell:

```powershell
python tools/balance.py simulate --godot "C:\Tools\Godot\Godot_v4.5.2-stable_win64.exe"
```

Mặc định: 100 Flailmen, 20 Gendarmes, seed 1524, speed **10×**, giới hạn 300 game
seconds. Python chuẩn bị class cache trước khi đo; không cần mở editor thủ công.
Đầu ra: `balance-results/arena-1524.json` và `.csv`. Dùng thư mục báo cáo riêng;
launcher ngăn Godot xem CSV kết quả là bảng translation. Báo cáo tạm không vào Git.

```sh
# Năm deployment seed, chạy nhanh nhất CPU cho phép:
python tools/balance.py simulate --godot /path/to/godot --runs 5 --seed 1524 --unpaced

# Đổi vị trí hai đội; giữ identity/cost của team 0 và team 1:
python tools/balance.py simulate --godot /path/to/godot --swap-sides --output balance-results/mirrored

# Đổi quân và số lượng bằng cùng database:
python tools/balance.py simulate --godot /path/to/godot --left landsknecht_pikeman --left-count 30 --right-count 20
```

Đường gọi engine trực tiếp, khi project đã import:

```sh
godot --headless --max-fps 60 --path . --script tools/balance_headless.gd -- --speed=10 --seed=1524
```

Launcher Python dùng `--flag value`; driver Godot dùng `--flag=value` sau `--`.
Tối đa 200 unit trong một arena, tối thiểu một người mỗi bên. Một đội gồm một
loại quân; scenario hỗn hợp cần adapter bổ sung. `--seconds` luôn là **game time**.

### 3.1 10× hoạt động thế nào?

`BalanceClock` cộng `wall_delta × 10` vào accumulator, rồi thực hiện các bước
**0.05s**. Không gọi combat một bước 0.5s, không tăng damage hoặc bỏ tick. Khi CPU
không kịp, tối đa 200 tick được xử lý mỗi pump, phần nợ thời gian giữ lại. Report
phân biệt tốc độ yêu cầu với tốc độ đo thực tế. 1× và 10× cho cùng kết quả fixed
steps. `--unpaced` là chế độ batch nhanh nhất, **không phải lời hứa wall time 10×**.

Thời gian thực trong report tính từ sau setup tới khi trận kết thúc; không bao
gồm import/startup và ghi file cuối trận. Tổng thời gian CLI vì vậy dài hơn.

### 3.2 Đấu trường và AI

- Sân kín phẳng **40×32 ô**, không vật cản nội bộ, không đường thoát.
- Đội hình lưới ban đầu ở hai bên, jitter nhỏ dùng RNG riêng theo seed.
- Target gần nhất, refresh mỗi 5 tick (0.25s); giữ target đã trong tầm để không
  hủy swing vô ích. Không tự tăng attack range để mọi quân đánh cùng lúc.
- Steering thử hướng tới target và các hướng trượt ±45°/±90°. Circle sweep kiểm
  tra cả đoạn di chuyển với spatial buckets; không xuyên thân/quá mép sân.
- Thứ tự ưu tiên di chuyển xoay mỗi tick. Khi đã trong tầm, unit đứng đánh.
- Vị trí body thật đưa vào `CombatWorld` trước combat tick. Damage, giáp, counters,
  cooldown, wind-up và chết cùng tick dùng chung code Stage 2–4.

Đây là **micro test có geometry**, không phải pathfinding quân sự cho rừng/cầu,
formation AI hoàn chỉnh hoặc dự báo win rate skirmish. Bề rộng mặt trận, cách chọn
target, vị trí ban đầu và radius ảnh hưởng mạnh kết quả. Không lấy controller này
thay cho Stage 1 traffic hoặc tuyên bố đã giải quyết navigation kỵ binh trên mọi map.

## 4. Báo cáo và cách đọc

JSON chứa engine/arena version, seed, hash database, generation, các unit snapshot
đã dùng, điều kiện trận, timeline mỗi giây, outcome, winner, attack count và timing.
CSV có hai hàng, mỗi hàng một đội, giữ F/W/G/S riêng biệt.

```text
survival_rate      = survivors / initial_count
hp_retention_rate  = remaining_hp / initial_total_hp
mean_survivor_hp   = remaining_hp / survivors; 0 nếu hết quân
simulation_seconds = ticks × 0.05
```

`elimination`: một đội hết quân; `draw`: cả hai hết quân cùng tick; `timeout`: hết
thời gian mà hai đội còn người. Timeout không tự chọn đội nhiều HP làm người thắng.
Một lần chạy có outcome, không tự sinh “win rate”. Chạy lại cùng seed/pinned engine
cho cùng logical report; wall timing thay đổi. Đây chưa phải bảo đảm lockstep đa nền tảng.

Mẫu 10× seed 1524: **92.45 game seconds**, 0/100 Flailmen sống và **6/20 Gendarmes**
sống, tổng **190 HP**. Survival League 30%; HP retention 7.6%. File có đầy đủ số
liệu ở [baseline-1524.json](balance_samples/baseline-1524.json) và
[baseline-1524.csv](balance_samples/baseline-1524.csv).

Hai lực lượng không ngang tài nguyên: Flailmen = **4,500F + 1,500W**, Gendarmes =
**1,800F + 2,000G**; không coi 1 Gold luôn tương đương 1 Wood. Flailman chống Spear,
không chống Cavalry; ở base stats một hit Flailman → Gendarme gây 5, chiều ngược
lại gây 12. Một trận này chưa đủ để sửa giá hoặc kết luận cả phe mất cân bằng.

Quy trình designer: giữ seed/arena cố định → đổi **một** tham số trong bản sao JSON
→ chạy lại → so snapshot/hash, survival, HP, time và timeline → chạy nhiều seed,
đổi phía và cuối cùng playtest economy/map. Không ghi đè baseline để “làm đẹp” kết quả.

## 5. Reload khi chương trình đang chạy

```sh
# Dùng một bản sao để không vô tình thay baseline trong Git.
python tools/balance.py watch --godot /path/to/godot --database /path/to/experiment.json
```

Chép `data/balance/units.v1.json` thành `experiment.json` trước. Watch giữ **một
process Godot**, kiểm tra nội dung mỗi real second. Sửa JSON và Save:

1. Parse/validate/compile một candidate tách biệt, tính SHA-256 từ nội dung đọc.
2. Lỗi: in `BALANCE_RELOAD_REJECTED`, giữ nguyên generation, hash và dữ liệu tốt.
3. Hợp lệ: publish nguyên revision và emit `reloaded`; cùng nội dung thì no-op.
4. Lượt đang đánh giữ snapshot cũ tới kết thúc. Revision mới dùng cho **lượt kế
   tiếp**; không thay stat/HP giữa trận rồi trộn hai tuning vào cùng kết quả.
5. File `watch.r001.json`, `watch.r002.json`… lưu từng lượt. Ctrl+C dừng session.

Watch xuất JSON; lệnh simulate xuất cả JSON/CSV. Nếu sửa nhiều lần khi đang đánh,
chỉ revision hợp lệ mới nhất được dùng cho lượt sau. Lưu file theo cách atomic
(temp file → replace) giúp tránh bắt gặp nửa file; nếu bắt gặp thì loader chỉ reject.

### 5.1 Tích hợp vào runtime Godot

```gdscript
var data := UnitDatabase.new()
if not data.reload_file("user://balance/experiment.json"):
    print(data.errors)
    return
var world := CombatWorld.new(data)
world.add_player(0, 0, CombatTypes.Faction.BUNDSCHUH, ResourceBank.new())
var old_unit := world.spawn_by_id("peasant_flailman", 0, Vector2(2, 2))

# Gọi tại safe point sau advance(), tốt nhất khi designer pause thử nghiệm.
# reload_file đọc lại raw JSON, không dùng ResourceLoader cache.
if data.reload_file("user://balance/experiment.json"):
    var new_unit := world.spawn_by_id("peasant_flailman", 0, Vector2(4, 2))
```

Xem `BalanceArena.setup()` để có ví dụ chạy đầy đủ với hai đội và navigation.
`old_unit` giữ max HP, current HP, cooldown, cost và hash của lúc spawn;
`new_unit` lấy revision mới. Muốn áp lên tất cả quân trong playtest, **reset trận**
như watch; không âm thầm heal/rescale quân sống. Dùng `data.fork()` để pin cả world,
kể cả reinforcements. Không gọi reload từ damage callback trong transaction.

`CombatUnitCatalog` là facade tương thích, load JSON mặc định một lần; Stage 2–4
vẫn gọi enum như trước. F5/F9 **không tự watch file**. Unit database quản lý combat
model; record Villager không tự đổi tốc độ/cargo của worker controller Stage 1.

Khi export game, giữ raw `data/balance/*.json` trong export filter hoặc Keep File;
FileAccess cần cả data và schema thật. Packed `res://` thường không sửa được:
chép bản experiment ra `user://` hoặc đường dẫn ngoài, rồi reload đường dẫn đó.
Load mặc định/compile ngoài vòng combat; chỉ reload theo yêu cầu designer hoặc
poll thấp tần, không đọc đĩa mỗi frame hay mỗi unit.

### 5.2 Python đọc dữ liệu trực tiếp

Từ repo root:

```python
from tools.unit_db import UnitDatabase, BalanceError

db = UnitDatabase("data/balance/units.v1.json")
unit = db.snapshot.unit("heavy_gendarme")
print(unit["combat"]["hp"], unit["economy"]["cost"])
old = db.snapshot
try:
    changed = db.reload()
except BalanceError as error:
    print("Giữ revision cũ:", error)
assert old.unit("heavy_gendarme")["combat"]["hp"] == unit["combat"]["hp"]
```

`snapshot.unit()` và `.document()` trả defensive copies. Tool Python chỉ phục vụ
đọc/validate/report/điều phối. Chỉnh `_data` trực tiếp hoặc tự viết lại combat trong
Python sẽ phá hợp đồng; không dùng thuộc tính nội bộ đó làm API designer.

## 6. Kiểm thử và giới hạn

```sh
python tools/verify.py --godot /path/to/godot
```

Verifier chạy lại năm stage, Python parser/CSV và live reload thật, trận 100-vs-20
10×, các demo cũ, HUD và scene smoke. Xem [STAGE_5_VALIDATION.md](STAGE_5_VALIDATION.md)
cho số liệu, năm seed và phạm vi đã kiểm tra. Không có art/render/audio trong arena;
kết quả thời gian headless không phải FPS gameplay. Cần benchmark với final assets
và playtest map/economy trước khi chốt faction balance.

Tham khảo API chính thức: [Godot JSON](https://docs.godotengine.org/en/4.5/classes/class_json.html),
[FileAccess](https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html),
[Python json](https://docs.python.org/3/library/json.html).
