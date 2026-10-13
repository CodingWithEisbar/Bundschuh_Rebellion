# Bundschuh: Rebellion — demo chơi ngay

**Một file duy nhất:** [bundschuh_rebellion.html](bundschuh_rebellion.html).

Trên GitHub, mở file rồi chọn **Download raw file** ở góc phải. Lưu đúng đuôi
`.html`, sau đó mở bằng Chrome, Edge hoặc Firefox trên máy tính. Hoặc tải cả
repo bằng **Code → Download ZIP**, giải nén và mở file trong `demo/`.
Gameplay không cần Godot, server, Internet, tài khoản, package hay asset ngoài.
Nhạc YouTube ở menu là tùy chọn và cần Internet. Trang xem source của GitHub
không chạy HTML; cần tải file về trước.

Đã kiểm tra thực tế bằng Chromium, mở qua `file://` với network offline.
Firefox/Edge dùng API tiêu chuẩn tương thích nhưng chưa được kiểm thử riêng.

## Nhạc nền menu

Menu có nút **Bật nhạc** cho [bài bro chọn trên YouTube](https://www.youtube.com/watch?v=pMLeQAPhHN8).
Bấm nút rồi bấm **▶** trong trình phát nếu trình duyệt chưa tự phát. Player hiển
thị đầy đủ để chỉnh âm lượng/tạm dừng; video lặp trong menu. **Tắt nhạc**, **Vào
trận**, đổi tab hoặc mất kết nối sẽ gỡ player và dừng nhạc. Khi trở về menu,
bấm Bật nhạc lại. Nút **Âm** trong trận chỉ điều khiển âm báo gameplay riêng.

Không có request YouTube trước khi bấm Bật nhạc; không tải MP3 hoặc nhúng bản
sao bài nhạc vào repo. Gameplay vẫn chạy offline. Khả năng phát phụ thuộc mạng,
trình duyệt và quyền cho phép nhúng của video trên YouTube.

**Nếu mở HTML trực tiếp và YouTube báo lỗi 153**, dùng liên kết **Mở bài nhạc
trên YouTube** ở menu, hoặc chạy HTML qua HTTP để player nhận referrer thực:

1. Mở Terminal/PowerShell trong thư mục `demo/` (hoặc nơi đã lưu file HTML).
2. Nếu máy đã có Python, chạy:

   ```sh
   python -m http.server 8000 --bind 127.0.0.1
   ```

   Trên macOS/Linux có thể dùng `python3` thay cho `python`.
3. Mở [http://localhost:8000/bundschuh_rebellion.html](http://localhost:8000/bundschuh_rebellion.html)
   rồi bấm **Bật nhạc**. Giữ terminal mở trong lúc chơi; Ctrl+C để dừng server.

Bước này chỉ phục vụ nhạc trực tuyến; vẫn có thể mở HTML trực tiếp để chơi game.
Nếu video không cho phép nhúng hoặc cần đăng nhập, dùng liên kết YouTube trong menu.
Player dùng `youtube-nocookie.com`, kích thước ít nhất 200×200, controls hiển thị,
`loop=1` và playlist đúng ID video. Không giả mạo origin/referrer để né lỗi 153.
Tham khảo chính thức: [YouTube player parameters](https://developers.google.com/youtube/player_parameters)
và [mã lỗi player](https://developers.google.com/youtube/iframe_api_reference#Events).

## Trận đầu tiên

1. Chọn **Bundschuh** hoặc **Swabia**, nhập seed nếu muốn, rồi **Vào trận**.
2. Kéo chọn khoảng bốn dân, click phải bụi quả; cho hai dân lấy gỗ và hai dân
   lấy vàng. Chỉ tài nguyên giao về sở chỉ huy/kho mới cộng vào HUD.
3. Chọn một vài dân → **H** → click nền xanh để xây nhà, tăng 5 dân số.
4. Có thể tuyển thêm 2–4 dân tại **Sở chỉ huy** để tăng kinh tế. Chọn **Trại lính** (mái nhà có hai vũ khí bắt chéo), tuyển quân. Hàng chờ
   tính trước vào dân số; click một mục trong hàng chờ để hủy, hoàn toàn bộ giá.
5. Bundschuh nên có giáo chống Gendarme, Flailman đánh giáo và Preacher hỗ trợ.
   Swabia phối hợp Gendarme, Landsknecht và lính nỏ; giáo thường không tốn vàng.
6. Bundschuh nên gom khoảng 15–20 quân và giữ Preacher gần đội hình; thêm một
   trại lính để tận dụng quân rẻ. **Tab** chọn quân đội → **Tiến công** → click đường rừng để vừa đi vừa đánh.
   Quân đang đánh công trình sẽ giao chiến với địch gần đường trước.
   Dùng bản đồ nhỏ nhìn làng địch rồi click phải sở chỉ huy địch để phá hủy.
   Bảo vệ sở chỉ huy của mình: mất nó là thua.

Địch xuất quân lần đầu ở **2:30 thời gian game**. Nút **1×/2×** tăng tốc toàn bộ
trận, bao gồm đối phương. Có thể tạm dừng để ra lệnh hoặc đọc hướng dẫn.

## Điều khiển

| Thao tác | Điều khiển |
|---|---|
| Chọn đơn vị / nhóm | Click trái / kéo khung |
| Thêm hoặc bỏ khỏi nhóm | Shift + click; Shift + kéo để thêm |
| Di chuyển, khai thác, xây tiếp, tấn công | Click phải vào đất / tài nguyên / nền xây / địch |
| Xây nhà / trại lính / kho | Chọn dân rồi H / B / C |
| Hủy đặt công trình hoặc chọn điểm tiến công | Esc hoặc click phải |
| Tuyển dân / quân | Chọn sở chỉ huy / trại lính rồi click loại quân |
| Chọn quân đội / dân đang rảnh | Tab / V |
| Về sở chỉ huy | Home hoặc nút Về làng |
| Camera | WASD, phím mũi tên hoặc kéo chuột giữa |
| Zoom / xem nơi khác | Con lăn / click bản đồ nhỏ |
| Dừng lệnh / tạm dừng | X / Space |
| Hướng dẫn / chọn phe lại | Nút ? |

Rời tab hoặc cửa sổ sẽ tự tạm dừng. Trở lại rồi nhấn Space. Thiết kế cho chuột
và bàn phím, khuyến nghị cửa sổ từ 1024×768. Không có lưu trận; mở lại/reset
bắt đầu trận mới. Âm báo gameplay tắt mặc định, bật bằng nút **Âm**. Nhạc menu
có nút **Bật nhạc** riêng.

## Phạm vi bản demo

Đây là **bản gameplay độc lập bằng Canvas 2D/JavaScript**, không phải Godot Web
export và không thay thế source Godot của Stage 1–5. Một file chứa giao diện,
đồ họa vẽ bằng mã, âm báo tổng hợp và snapshot JSON base stats của repo.

Có hai phe điều khiển được, map rừng có seed, chọn/kéo quân, A* tám hướng không
cắt góc, hàng đợi path budget, tránh va chạm cục bộ, bốn tài nguyên hữu hạn,
cargo, kho giao hàng, placement, construction, recruitment, counters, aura,
AI có kinh tế, thắng/thua và chơi lại. Mô phỏng fixed tick 20 Hz; render không gây
damage. Đòn cùng tick được gộp trước khi xử lý chết. Preacher chỉ buff, không heal.

**Thông số riêng cho trận demo** (không ghi đè JSON/GDD):

| Hạng mục | Thiết lập |
|---|---|
| Bản đồ | 42×30, phẳng, ba đường chính rộng 3 ô; không xây đè đường được bảo vệ |
| Tầm xây | Trong 12 ô quanh công trình hoàn tất cùng phe |
| Tài nguyên người chơi | 450F / 400W / 260G / 100S |
| Tài nguyên AI | 400F / 250W / 250G / 0S; thu và chi thật, không sinh tài nguyên miễn phí |
| Dân xuất phát | 8 mỗi phe, TC + một trại lính; TC cấp 20 housing |
| Quân Bundschuh xuất phát | 3 Flailman, 2 Pikeman, 1 Preacher |
| Quân Swabia xuất phát | 1 Gendarme, 2 Landsknecht, 1 Crossbowman |
| Giới hạn | 100 dân số mỗi bên; hàng chờ tối đa 8 mỗi công trình |
| Kinh tế | 2 tài nguyên/giây làm việc, mang 10; Bundschuh +10% Food/Wood; thời gian đi/giao thật |
| Kho | 100W, 30 giây công, 500 HP; nhận cả bốn loại |
| Nhà | 25W, 25 giây công, 400 HP, +5 housing |
| Trại lính | 175W, 40 giây công, 900 HP |
| Sở chỉ huy | 1800 HP; không xây thêm trong demo |
| Giáp công trình | 2 melee / 4 pierce; không tự bắn |
| Tuyển quân | Giá, thời gian và base combat stats nguyên từ JSON; không có age gate/tech upgrades |
| Nhịp AI | Bắt đầu đặt lệnh tuyển ở giây 35; tối thiểu 30 giây giữa hai lệnh tuyển; vẫn chờ đủ train time |
| Đợt tấn công | Từ giây 150; kiểm tra mỗi 95 giây, gửi tối đa 5 quân chưa có lệnh đánh HQ nếu có ít nhất 3 |

Toàn bộ map được hé lộ. Không có multiplayer, save/load, bốn Age, fog of war,
stealth campaign, payroll, Zeal/Fear, cao độ, LOS đạn qua cây, pháo binh, công
thành hoặc asset/giọng Đức production. Đạn nỏ là hit tức thời với vệt hình ảnh.
Stone có thể khai thác/giao kho để thử vòng economy, chưa có công trình tiêu Stone.
Nhà bị phá hủy mất hàng chờ và chi phí đã trả; tự hủy hàng chờ mới hoàn tiền.
Dân/đơn vị bị hạ mất cargo. Nền xây bắt đầu 0 HP nhưng tồn tại cho tới khi bị đánh.

Tránh va chạm ở đây dùng một bán kính thử nghiệm 0.18 ô cho tất cả quân và
steering tại chỗ, không phải controller quân sự production cho siege/cavalry
khác kích cỡ. Kiểm tra mixed-speed crowd trong demo không thay bộ regression
200 quân của Godot. Đây là scenario thử gameplay, không chứng minh cân bằng ranked.

## Sửa chỉ số và kiểm tra

Nguồn combat stats duy nhất vẫn là `data/balance/units.v1.json`. Sau khi sửa:

```sh
python3 tools/sync_browser_demo.py
python3 tools/sync_browser_demo.py --check
node tests/browser_demo_model.cjs
```

Lệnh sync dùng validator hiện tại và nhúng JSON/hash vào HTML; không sửa tay block
`balance-data`. Refresh/mở lại demo để dùng snapshot mới. Không có hot reload
browser. Thay model/presentation trực tiếp trong HTML, giữ ranh giới `MODEL_END`
để runner Node kiểm tra đúng model nhúng thay vì một bản mô phỏng viết lại.

Kiểm tra UI tùy chọn cần Playwright + Chromium trên máy phát triển:

```sh
# Cài công cụ ở ngoài repo hoặc workspace phát triển; game không phụ thuộc chúng.
# Đặt PLAYWRIGHT_MODULE nếu module không nằm trong Node resolution path.
node tests/browser_demo_ui.cjs
node tests/browser_demo_music.cjs
```

Runner mở file offline, thao tác chuột/phím, kiểm tra HUD, xây/tuyển quân, camera,
audio, pause, đổi phe, thắng/thua và chụp 1440×900 / 1024×768. Chỉ URL có `?test=1`
mới bật hook điều khiển cho kiểm thử. Screenshot/report vào `test-results/`, không
commit. Cấu hình `BROWSER_EXECUTABLE` cho binary Chromium riêng nếu cần.

Bộ kiểm tra Godot vẫn giữ nguyên:

```sh
python3 tools/verify.py --godot /path/to/Godot_v4.5.2-stable_linux.x86_64
```

API tham khảo: [Canvas 2D (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)
và [Playwright configuration](https://playwright.dev/docs/test-use-options).
