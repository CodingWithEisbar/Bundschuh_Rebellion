# Gameplay demo — validation

Kiểm tra ngày 2026-10-12. Đây là kiểm tra bản Canvas độc lập; không nâng phạm vi
cam kết của military navigation, campaign hoặc balance trong Godot.

| Kiểm tra | Kết quả |
|---|---|
| `python3 tools/sync_browser_demo.py --check` | Snapshot 10 units/hash khớp JSON gốc |
| `node tests/browser_demo_model.cjs` | **17 cases passed** |
| `node tests/browser_demo_ui.cjs` với Playwright | **26 checks passed**, Chromium 153.0.8010.0 |
| `python3 tools/verify.py --godot …4.5.2…` | **107 integration cases passed**, Godot Stage 1–5 + Python |

Model tests chạy chính phần mô phỏng lấy từ HTML: seed/corridor connectivity,
A* không cắt góc, tài nguyên hữu hạn/bảo toàn cargo khi đổi lệnh, construction
sau khi đến nơi, housing hoàn tất một lần, placement, chi phí/hoàn tiền/housing
hàng chờ, khóa roster, counters, aura không stack/expire, lethal trade cùng tick,
không reset cooldown bằng lệnh, tiếp cận unit/công trình không mắc ngoài tầm,
giữ vị trí, terminal state và 36 quân có tốc độ khác nhau đi qua rừng.

UI kiểm tra mở bằng `file://` trong browser context **offline**; toàn bộ request
quan sát được đều là file HTML cục bộ. Không có lỗi JavaScript. Đã thao tác kéo
chọn, click phải lấy tài nguyên, H + click xây nhà, chọn trại lính và tuyển quân,
đọc HUD, pause/help, speed, chọn quân đội, camera/minimap/Home, âm báo, reset,
đổi phe/seed và thắng/thua. Hai terminal UI dùng fixture HQ 1 HP, rồi xử lý bằng
combat tick thật; không coi chúng là bằng chứng win rate/cân bằng. Khung nhìn
1440×900 và 1024×768 đã được chụp và kiểm tra trực quan.

File ảnh/report tạm nằm trong `test-results/browser-demo/` và không được commit.
Runner UI cần Playwright và Chromium ở máy phát triển; người chơi chỉ cần HTML.
Các lượt screenshot đầu gặp timeout ở Chromium serverless khi chụp nhiều ảnh
liên tiếp; lượt cuối giảm ảnh dư, giữ kiểm tra hành vi đầy đủ và cả hai kích
thước, hoàn tất toàn bộ 26 checks. Chưa kiểm thử riêng Firefox/Edge, mobile,
multiplayer, save/load hay performance trên máy cấu hình thấp.

## Cập nhật nhạc menu — 2026-10-13

Đã thêm video `pMLeQAPhHN8` qua player YouTube chỉ tải khi người dùng bật.
`tests/browser_demo_music.cjs` đạt **19 checks** trong Chromium: mặc định không
request YouTube, offline vẫn vào trận được, nút dùng được bằng Space, URL/loop
đúng video, player tối thiểu 200×200, referrer HTTP thật, bật/tắt, hủy khi đang
load, trở về menu không phát trùng, dừng khi ẩn trang/mất mạng và bố cục 1440×900,
1024×768. Bộ 17 model cases và 107 Godot/Python integration cases đã chạy lại,
đều đạt.

Lệnh chạy cùng cấu hình Playwright như UI runner:

```sh
node tests/browser_demo_music.cjs
```

Runner dùng response iframe giả được ghi nhãn rõ để kiểm tra adapter/giao diện.
**Chưa xác nhận live audio hoặc quyền nhúng của video trên YouTube.** Báo cáo và
ảnh ở `test-results/browser-demo-music/`; ảnh fixture không phải ảnh video thực.
Không coi trạng thái đã mở iframe là đang phát nhạc. Hướng dẫn có cách chạy HTTP
cho lỗi referrer 153 và liên kết mở video trực tiếp nếu player không phát.
