# Bundschuh: Rebellion

**Stage 1 — Core RTS Prototype & Pathfinding**
Engine được ghim: **Godot 4.5.2 Standard**, GDScript có kiểu dữ liệu. Mở project và chạy ngay, không cần .NET, asset pack hoặc plugin trả phí.

Đây là nền prototype có mã nguồn, scene điều khiển và regression tests. Presentation hiện là top-down greybox để kiểm tra gameplay; hướng isometric sprite và art/audio của GDD Phase 4 sẽ được áp dụng ở giai đoạn nội dung.

## Chạy trong 5 bước

1. Tải [Godot 4.5.2 Standard](https://godotengine.org/download/archive/4.5.2-stable/) cho Windows/macOS/Linux.
2. Clone repo hoặc chọn **Code → Download ZIP**, sau đó giải nén.
3. Mở Godot → **Import** → chọn **project.godot** trong thư mục repo.
4. Chờ Godot import scripts rồi nhấn **F5**.
5. Kéo chọn dân và click phải vào tài nguyên; số trên HUD tăng khi dân giao hàng về nhà nhận phù hợp.

Nếu dùng Git:

    git clone https://github.com/CodingWithEisbar/Bundschuh_Rebellion.git
    cd Bundschuh_Rebellion

Không cần export templates để chạy bằng editor. Repo không chứa binary của engine.

## Đã triển khai

| Hệ thống | Chức năng |
|---|---|
| Grid & navigation | Native A*, bốn hướng, không cắt góc; hàng đợi giới hạn số query; cache; cập nhật khi thêm/bỏ vật cản |
| Crowd traffic | Ô đích riêng, quyền chiếm ô độc quyền, hàng đợi có ưu tiên chờ, nhường đường, chuyển động đối đầu phối hợp |
| Economy | Food/Wood/Gold/Stone hữu hạn; cargo; capacity; chuyển tài nguyên vào kho bằng transaction khi giao hàng |
| Villager AI | Idle → MoveToResource → Gather → ReturnToDropoff; trạng thái chờ, xây dựng, đổi nhiệm vụ và xử lý mục tiêu mất |
| Placement | Snap theo grid; xanh BUILD / đỏ BLOCKED; kiểm tra footprint, quân đang đi, tài nguyên, chi phí và đường tiếp cận |
| Construction | Foundation bắt đầu 0 HP; nhiều dân đóng góp công; tăng tới MaxHP; completion phát một lần |
| Drop-offs | Town Center nhận cả bốn loại; Mill nhận Food; Lumber Camp nhận Wood; Mining Camp nhận Gold/Stone |
| HUD & input | Chọn/kéo chọn/Shift, lệnh theo ngữ cảnh, minimap, camera, pause, tốc độ 1×/4×, progress/HP/cargo |
| Verification | Tests chạy bằng Godot thật; kiểm tra 200 quân qua choke một ô, đi ngược chiều, bảo toàn tài nguyên và construction |

## Điều khiển

| Thao tác | Phím / chuột |
|---|---|
| Chọn dân / chọn nhiều | Click trái / kéo khung |
| Thêm hoặc bỏ khỏi selection | Shift + click/kéo |
| Chọn tất cả dân | Ctrl+A hoặc nút Select all |
| Di chuyển / khai thác / xây tiếp | Click phải đất / resource / foundation |
| Giao cargo | Click phải công trình nhận tài nguyên; chọn điểm nhận phù hợp gần nhất |
| Đặt House / Mill / Lumber Camp / Mining Camp | H / J / K / L |
| Xác nhận / hủy preview | Click trái / Esc hoặc click phải |
| Dừng nhiệm vụ, giữ nguyên cargo | X |
| Camera / zoom | WASD hoặc kéo chuột giữa / con lăn |
| Điều hướng qua minimap | Click trái minimap |
| Pause / resume | Space |
| Xem tối đa tám route được chọn | Tab |
| Reset sandbox 16 dân | F6 |
| Reset stress scenario 200 dân | F7 — tự ra lệnh vượt đường rừng |

F6/F7 **reset toàn bộ sandbox hiện tại**. Demo cấp sẵn tài nguyên và housing để thử hệ thống; đây không phải opening skirmish tiêu chuẩn trong GDD. Chưa có lưu game.

## Thử ba vòng gameplay

**Di chuyển đông quân:** nhấn F7, quan sát 200 dân đi qua khe rừng rộng một ô và tập kết ở bên phải. Dùng Tab để xem đường, nút Speed để tăng tốc. Chọn nhóm ở hai phía và ra lệnh đi ngược chiều để quan sát nhường đường.

**Khai thác:** nhấn F6, chọn vài dân rồi click phải resource có chữ F/W/G/S. Chọn riêng một dân để đọc cargo. Cargo đầy hoặc node hết thì dân giao hàng; HUD chỉ tăng khi giao xong. Dân giữ cargo và chờ nếu không có drop-off đã hoàn tất và đi tới được.

**Xây dựng:** chọn dân → H/J/K/L → di chuột trên grid. Xem lý do BUILD/BLOCKED ở HUD. Click vị trí hợp lệ; chi phí được trừ đúng một lần, HP khởi đầu bằng 0. Có thể chọn thêm dân và click phải foundation để xây nhanh hơn. House hoàn tất tăng 5 housing; camp chỉ nhận tài nguyên khi hoàn tất.

## Chạy kiểm thử

Cần Python 3 và Godot 4.5.2; không cần package Python bổ sung.

Windows PowerShell, thay đường dẫn bằng vị trí Godot thực tế:

    python tools/verify.py --godot "C:\Tools\Godot\Godot_v4.5.2-stable_win64.exe"

Linux/macOS:

    python3 tools/verify.py --godot /path/to/godot

Lệnh thực hiện import/compile, regression tests, HUD layout check và main-scene smoke test. Report JSON nằm trong **test-results/stage1.json**; thư mục này được bỏ qua trong Git. Parser/runtime errors làm validation thất bại kể cả khi Godot trả exit code 0.

CI tương ứng: [.github/workflows/godot.yml](.github/workflows/godot.yml). Workflow ghim engine và checksum, chỉ cần quyền đọc nội dung repo.

## Tổ chức source

| Đường dẫn | Trách nhiệm |
|---|---|
| [scripts/core](scripts/core) | Composition root, static grid, demo fixtures |
| [scripts/navigation](scripts/navigation) | A* scheduler và cooperative traffic |
| [scripts/economy](scripts/economy) | Resource types, finite nodes, global bank |
| [scripts/units](scripts/units) | Villager data và state machine |
| [scripts/construction](scripts/construction) | Building catalog, work/HP/completion |
| [scripts/presentation](scripts/presentation) | Input, greybox renderer, minimap, HUD |
| [tests/run_tests.gd](tests/run_tests.gd) | Integration tests dùng chính model của game |
| [docs/STAGE_1_ARCHITECTURE.md](docs/STAGE_1_ARCHITECTURE.md) | Luồng dữ liệu, thuật toán, invariants và extension points |
| [docs/STAGE_1_VALIDATION.md](docs/STAGE_1_VALIDATION.md) | Phạm vi kiểm thử, kết quả và giới hạn |
| [docs/gdd](docs/gdd) | Bốn phase thiết kế làm nền cho các stage tiếp theo |
| [AGENTS.md](AGENTS.md) | Quy tắc thay đổi source cho người và AI agent |

## Giới hạn của Stage 1

- Navigation được kiểm tra cho **tối đa 200 friendly foot units cùng kích thước**. Passing dùng bán kính 0,18 ô; siege/cavalry lớn cần clearance và quy tắc giao thông riêng trước khi thêm.
- Có gather bonus Food/Wood Bundschuh và carry bonus League A3 ở lớp model. Demo đang dùng Bundschuh A1; chưa có màn chọn phe/age-up.
- Chưa có combat, fog of war, tech tree, unit recruitment, campaign triggers, save/load hoặc multiplayer. Housing được theo dõi; giới hạn spawn thường kiểm tra housing, còn fixture cấp quân có nhãn riêng.
- Gather rates, building HP/footprints và công thức nhiều dân xây là tham số prototype được ghi trong architecture; chưa phải kết quả cân bằng cuối.
- Hiệu năng headless của simulation không phải FPS đồ họa. Kiểm tra GPU/rendering và playtest trên máy mục tiêu là bước tiếp theo trước khi gọi đây là bản production hoàn chỉnh.
