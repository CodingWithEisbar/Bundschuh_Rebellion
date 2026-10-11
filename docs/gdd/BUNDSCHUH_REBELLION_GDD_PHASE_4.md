# BUNDSCHUH: REBELLION
## Phase 4 — Visual Art Direction, Audio Design & UI/UX Infrastructure

**Phiên bản:** GDD v0.4 — production guide, 11/10/2026  
**Phụ thuộc:** các luật và roster trong Phase 1–2; campaign, bản đồ và trigger trong Phase 3.  
**Phạm vi:** chỉ đạo nghệ thuật, đặc tả nội dung, giao diện và tiêu chí nghiệm thu. Các chỉ tiêu chất lượng bên dưới là mục tiêu prototype; chưa có asset, bản thu hoặc benchmark thực tế được nghiệm thu.

## 0. Creative brief chung

**Ý tưởng chủ đạo: “Biên niên sử sống” — một thế giới có chất liệu tranh khắc và hội họa đầu thế kỷ XVI, nhưng chiến trường phải đọc được ngay ở quy mô RTS.**

Người chơi cần nhận ra ba điều theo thứ tự: quân làm được gì, thuộc về ai, đang ở trạng thái nào. Chi tiết trang phục và hoa văn phục vụ ba điều đó. Màn hình kể chuyện có thể giàu nét khắc; trận đánh dùng mảng sáng tối lớn, màu có kiểm soát và chuyển động rõ.

| Trụ cột | Chỉ đạo thực hiện | Điều kiện duyệt |
|---|---|---|
| Đọc chiến trường nhanh | Vũ khí, tư thế và khối thân phân biệt vai trò; màu người chơi tách khỏi vật liệu phe | Nhận diện được Flailman, Pike, Ritter và Preacher khi đổi màu người chơi |
| Hai phe bất đối xứng | Bundschuh: vật liệu tái sử dụng, đội hình và trang phục đa dạng. League: trang bị chuẩn bị kỹ, vận tải và hỏa lực có tổ chức | Khác biệt vẫn còn khi ảnh chuyển sang thang xám |
| Một giai đoạn lịch sử hẹp | Bốn Ages biểu thị cấp huy động, tổ chức và quyền tiếp cận trang bị | Nhà A4 vẫn thuộc thế giới 1524–1525 |
| Phản hồi đúng luật | Âm thanh, VFX và HUD lấy trạng thái từ simulation | Hình ảnh không ám chỉ charge, phép thuật, stealth hay bonus chưa tồn tại |
| Cảm xúc qua con người | Lời dẫn, giọng nói, giấy in, chuông và đồ vật đời thường tạo bối cảnh | Cả hai phe có đời sống xã hội và động cơ; không biến một phe thành quái vật |

**Các ràng buộc xuyên suốt:**

- Giữ Food/Wood/Gold/Stone, population, xây nhà, tuyển quân và counter system đã chốt.
- Ranked/skirmish mặc định không có Alert, Zeal/Fear, Printing Press hoặc Mercenary Payroll. Giao diện các cơ chế này chỉ bật khi scenario/ruleset yêu cầu.
- Unique cavalry của League dùng tên **Armoured Ritter** theo Phase 1–2. Landsknecht trong roster là **pikeman**, không tự đổi thành chiến binh Zweihänder.
- Flailman không đánh lan; Ritter không có charge; Preacher không gây damage, không convert và không dùng mana.
- Cao độ level 2 trở lên cho +2 LOS theo Phase 3; không thêm damage hoặc attack range. Rừng không tạo invisibility.
- “Bundschuh” là tên phe gameplay tổng hợp. Huy hiệu, vùng nói và nhân vật trong campaign phải bám từng cộng đồng, không ngụ ý một nhà nước nổi dậy thống nhất.

## 1. Visual Art Direction

### 1.1. Tham chiếu và cách chuyển thành phong cách

| Tham chiếu | Bằng chứng dùng được | Chuyển thành quyết định thiết kế |
|---|---|---|
| Dürer, **Samson Rending the Lion**, khoảng 1497–1498, woodcut [V1] | Nét đen có độ dày biến đổi, hatching tạo khối và nhịp | Tranh mở màn, chân dung, bản đồ và khung chapter dùng nét khắc mạnh; sprite chỉ dùng ít nét trong vùng tối |
| Dürer, **Knight on Horseback and Landsknecht**, niên đại bảo tàng ghi rộng 1485–1528 [V2] | Tương quan người, ngựa, vũ khí và trang phục | Tham khảo hình khối; đây là tranh bút mực và wash, không ghi nhầm là woodcut hoặc tư liệu chính xác năm 1525 |
| Cranach, **Portrait of a Man**, 1522 [V3] | Màu trang phục burgundy/đen, cổ áo sáng và nền xanh trong mô tả bảo tàng | Phát triển bảng màu vải, da và nền có độ tương phản; không sao chép toàn bộ tranh lên texture quân |
| Trang bị, công trình và huy hiệu theo địa phương | Cần hồ sơ tham chiếu riêng cho từng asset lịch sử cụ thể | Mỗi concept ghi nguồn, niên đại và phần được phóng đại để đọc ở camera RTS |

Các bảng màu và pipeline bên dưới là **đề xuất thiết kế rút ra từ tham chiếu**, không phải bảng màu khảo cổ hay bản sao kỹ thuật hội họa của các nghệ sĩ.

**Mức độ stylization:** tỷ lệ người gần thực; bàn tay, vũ khí và vai được phóng đại vừa đủ để đọc vai trò ở camera mặc định. Giữ đường nét rõ ở mũ, vai và vũ khí; giảm họa tiết nhỏ trên thân. Không phủ lớp “giấy cũ” hoặc viền đen dày lên toàn bộ gameplay.

**Ánh sáng:** một hướng sáng chủ đạo ổn định, bóng tiếp xúc đủ thấy chân đứng trên địa hình. Bóng trên vải mềm; thép có mảng sáng nhỏ và kiểm soát. Highlight trên giáp không được trông như đạn đang bay hoặc báo bị tấn công.

**Action cho Art Director:** duyệt một concept sheet chung gồm 4 quân, 4 công trình, một góc rừng và một góc phố trước khi mở rộng toàn bộ roster.

### 1.2. Palette và vật liệu hai phe

| Phe / vai trò | Màu đề xuất | Vật liệu và cách dùng |
|---|---|---|
| Bundschuh — nền | Đất nâu **#6B4B32**; linen **#D7C39A** | Áo len, vải thô, gỗ mòn; tách áo sáng khỏi mặt đất |
| Bundschuh — phụ | Rêu **#687047**; than **#2B2A24** | Mũ, áo khoác, da và phần lõm; không để cả quân hòa thành khối xanh nâu |
| Bundschuh — điểm nhấn | Ochre **#B8893F** | Dây buộc, miếng vá, biển gỗ và một số vải nhuộm |
| League — nền | Crimson **#8E2636**; charcoal **#252B32** | Vải tốt, áo khoác, sơn và nội thất menu |
| League — phụ | Thép **#A8B0B5**; ivory **#E8DFC8** | Giáp, mũ sắt, áo lót và đá sáng |
| League — điểm nhấn | Gold **#C3A25E** | Viền, huy hiệu, dấu sáp và chi tiết cấp chỉ huy; không mạ vàng toàn quân |

**Màu phe không đồng nghĩa màu người chơi.** Những vùng nhận diện chủ sở hữu — khăn, băng tay, tấm vải trên ngựa, cờ và biển công trình — dùng mask thay màu. Crimson là tông nghệ thuật của League, không phải tín hiệu mặc định “quân địch”. Trong trận, mảng nhận diện lớn phải theo player color; giảm màu trang trí dễ gây nhầm khi cần.

Mỗi sprite có ít nhất một mảng owner color nhìn thấy ở mọi hướng. Dùng hai vị trí khi thân hoặc vũ khí thường che nhau. Người chơi có thể bật outline, số player và dấu đồng minh/địch; hình khối phe vẫn giữ nguyên.

**Action cho Texture Artist:** bàn giao albedo và owner-color mask riêng. Kiểm tra cả Bundschuh màu đỏ và League màu xanh, cùng tình huống hai người chơi cùng phe.

### 1.3. Pipeline asset được chọn cho prototype

**Hướng sản xuất:** model 3D làm nguồn, render thành sprite 2D theo hướng cố định. Cách này giữ cảm giác sprite RTS và cho phép tái sử dụng rig, trang phục, ánh sáng và pose khi làm biến thể.

| Hạng mục | Đặc tả khởi điểm |
|---|---|
| Camera | Orthographic cố định; lưới đất chiếu dạng kim cương tỷ lệ 2:1; không xoay camera trong scope này |
| Chuẩn đo | Một ô đất hiển thị 64×32 px ở zoom tham chiếu; render nguồn ở 2× rồi đánh giá ở kích thước chơi thật |
| Hướng nhân vật | 8 hướng; xuất riêng từng hướng. Không mirror tùy tiện trang phục, vũ khí hoặc huy hiệu bất đối xứng |
| Điểm neo | Origin tại mặt đất giữa hai chân hoặc điểm tiếp xúc chính; đồng bộ giữa idle, move, attack và death |
| Bộ pass | Sprite màu RGBA, owner-color mask, bóng, dữ liệu pivot và vùng selection; collision/pathing lấy từ gameplay |
| Animation nền | Idle 8, walk 12, attack 12, death 10 frame/hướng làm ngân sách đầu tiên; bổ sung work/heal/pack theo chức năng |
| Kích thước canvas | Theo bounding box động của vũ khí/animation, không ép pike hoặc flail vào một khung làm cụt đầu vũ khí |
| Công trình | Một hướng theo camera; construction/damage/player-color tách lớp khi khả thi |
| Thời điểm đòn đánh | Event từ simulation quyết định hit/projectile. Tốc độ animation theo attack period hiện hành |
| Biến thể | Dùng lại rig; đổi đầu, vải và phụ kiện trong cùng silhouette vai trò. Biến thể không thay stats |

**Ví dụ ngân sách:** bộ bốn animation nền ở trên có 42 frame × 8 hướng = **336 frame cho một bộ ngoại hình**. Đây là lý do chốt số hướng và rig trước khi sản xuất hàng loạt; atlas, độ phân giải và số biến thể cần được đo trong prototype.

Không dùng animation “đánh hai lần” cho một simulation hit. Haufen, Frenzy hoặc reload bonus phải làm nhịp hình/âm khớp với nhịp thực; animation death không kéo dài thời gian một unit còn chiếm ô hoặc gây damage.

**Action cho Technical Artist:** bàn giao một scene chuẩn gồm lưới, camera, ánh sáng, nhân vật đo tỷ lệ và script export. Tất cả artist dùng cùng scene để tránh sai scale hoặc bóng đổ.

### 1.4. Kiến trúc qua bốn Ages

Bốn Ages không phải bốn thế kỷ xây dựng. Các nhà cũ được chiếm dụng, sửa chữa, gia cố hoặc tổ chức lại. Nhà gameplay chưa được mở theo tech tree không được xuất hiện sớm dưới dạng có thể tương tác; landmark cảnh quan phải có nhãn riêng.

| Age | Bundschuh | Swabian League | Dấu hiệu nhìn nhanh |
|---|---|---|---|
| **I — Serfdom** | Nhà gỗ/khung gỗ, mái tranh hoặc ngói tùy vùng; kho nông cụ, sân đất, hàng rào đơn giản | Điền trang được chăm sóc tốt hơn, nhà khung gỗ trên nền xây, kho có mái ngói và sân có tổ chức | Ít cờ, ít rack vũ khí, kinh tế là trọng tâm |
| **II — Conspiracy** | Kho thóc thành nơi tập hợp, rack giáo/nông cụ, vật tư giấu trong xe; palisade và chốt gỗ | Sân luyện tập, kho vũ khí, cổng kiểm soát và biểu hiệu gia tộc rõ hơn | Dấu huy động xuất hiện; footprint và cửa ra quân giữ ổn định |
| **III — Insurrection** | Công trình thị dân hoặc tu viện được chiếm dụng; Rebel Stronghold kết hợp phần đá sẵn có và gia cố gỗ | Castle, gatehouse, guild hall kiên cố; Church mang ngôn ngữ Gothic địa phương | Có trung tâm quân sự, Church và cơ sở pháo theo đúng unlock |
| **IV — Reformation** | Kho hậu cần và smithy có tổ chức, công sự hỗn hợp, Wagenburg bố trí rõ; đồ sửa chữa vẫn hiện diện | Sân pháo, vị trí súng, kho thuốc súng và công sự được gia cố; trang bị đồng bộ hơn | Mức tổ chức và hỏa lực tăng; không đổi toàn bộ thành phố sang kiến trúc của thời kỳ sau |

**Quy tắc theo từng chức năng:**

| Công trình | Silhouette bắt buộc xuyên Ages | Thay đổi được phép |
|---|---|---|
| Town Center | Khối trung tâm và sân giao tài nguyên nhận ra ngay | Biển, mái, phần gỗ/đá và chi tiết tổ chức |
| Barracks | Sân tập và giá vũ khí; cổng ra quân rõ | Vật liệu, loại rack, biểu hiệu |
| Archery Range | Dãy mục tiêu/bãi bắn có hướng rõ | Mái che và thiết bị luyện bắn phù hợp roster |
| Stable | Sân ngựa, chuồng và cửa cao | Trang trí và chất lượng chuồng; Bundschuh vẫn không có elite cavalry |
| Siege Workshop | Cửa rộng, giàn nâng, bánh xe và bàn sửa pháo | Vật tư và thiết bị theo tier |
| Church | Khối thờ phụng và tháp/chuông dễ nhận | Địa phương hóa phong cách và biểu hiệu của lực lượng kiểm soát |
| Stronghold / Castle | Khối phòng thủ lớn, tháp và cổng | Bundschuh dùng đá có sẵn cộng gia cố; League hoàn thiện đồng đều hơn |
| Printing Press | Xưởng dân sự có dấu sách/giấy, biểu tượng scenario | Chỉ hiện chức năng capture/buff khi scenario bật |

- **Gothic cathedral** nên là landmark có sẵn trong đô thị hoặc hình nền campaign. Không thêm một tier nhà thờ có buff mới chỉ để đáp ứng art.
- Wagenburg là diện mạo cart/palisade/gate đã chốt; không gắn pháo tự bắn vào xe trang trí.
- Age skin giữ nguyên footprint, vị trí click, collision và điểm ra quân. Đổi tuổi không làm quân mắc cửa.
- Mức hư hại có thể chia 100–67%, 66–34%, 33–1% HP; bụi, mái vỡ và lửa nằm ở lớp cosmetic. Công trình chỉ bị xóa collision theo đúng sự kiện phá hủy.
- Banner lớn dùng owner color; huy hiệu lịch sử nhỏ hơn được duyệt theo campaign. Lực lượng chư hầu tại Frankenhausen có bộ huy hiệu riêng, dù tái sử dụng roster cân bằng của League.

**Action cho Environment Artist:** làm sheet tám diện mạo Town Center — hai phe × bốn Ages — rồi áp dụng ngôn ngữ đó cho các building khác; dựng ngay cả selection mask và trạng thái hư hại để kiểm tra tính đọc.

### 1.5. Silhouette và animation chiến đấu

| Unit | Dấu hiệu silhouette chính | Chuyển động và chất liệu | Điều cần tránh |
|---|---|---|---|
| **Peasant Flailman** | Cán dài với đoạn đập gỗ có khớp; vũ khí thường chéo hoặc ngang; áo không tạo vai vuông lớn | Nâng và giáng bằng hai tay; tiếng gỗ và dây nối; tư thế cơ động | Biến thành quả cầu gai khổng lồ; vòng xoáy gây hiểu nhầm splash |
| **Landsknecht Pikeman** | Pike thẳng dài; thân đứng hơn; tay áo cắt xẻ và mũ/mũ sắt tạo vai rộng vừa phải | Đẩy mũi giáo có kiểm soát; hàng quân tạo nhịp pike rõ | Cầm Zweihänder hoặc mặc toàn bộ plate giống Ritter |
| **Generic Spearman/Pikeman** | Giáo thẳng, thân và trang phục đơn giản hơn Landsknecht | Ít chi tiết vải, ít chuyển động phụ | Dùng cùng silhouette hoàn toàn với UU rồi chỉ đổi màu |
| **Armoured Ritter** | Khối ngựa–người lớn, mũ và giáp sáng rõ; trang bị cưỡi ngựa có tổ chức | Nặng và dứt khoát, hit thường một mục tiêu theo luật | VFX charge, sóng xung kích hoặc giáp xuyên giả |
| **Radical Preacher** | Áo dài, sách và một tay cử chỉ; không mang vũ khí lớn | Đọc, hô gọi và chữa trị có nhịp; ít bước giật | Quả cầu phép, tia hồi máu che trận, halo ngụ ý bất tử |
| **Arquebusier** | Súng dài và tư thế ngắm nằm ngang; khác rõ cung/crossbow | Matchlock flash ngắn, khói, thao tác nạp; chu kỳ khớp reload | Tia laser, súng bắn liên thanh, flash dài che mục tiêu |
| **Field / Heavy Cannon** | Bánh xe và nòng; Heavy lớn hơn nhưng cùng gia đình chức năng | Pack/unpack 3 giây, ê-kíp và dụng cụ; chỉ bắn khi sẵn sàng | Bắn lúc đang di chuyển hoặc dùng mọi viên như bom nổ hiện đại |

**Thứ tự ưu tiên:** vũ khí → khối thân/giáp → owner color → trang trí. Ở zoom xa, bỏ chi tiết cúc áo trước khi giảm độ rõ của pike, sách hoặc đầu flail.

Elite upgrade thay tối đa hai dấu hiệu lớn: mũ, phần thân giáp/vải hoặc hình vũ khí. Giữ nhận diện dòng quân. Flailman A4 có thể có áo tốt hơn và mũ bảo vệ; không vì lên Age mà mặc Plate Mail Armor bị khóa.

**Bài test duyệt:** với 5–10 người chưa thuộc roster, mục tiêu ít nhất 90% câu nhận diện vai trò đúng trong hai giây ở zoom mặc định; lặp ở 75% zoom như stress case. Dùng ảnh màu, thang xám, đổi player color và cảnh 120 quân trộn. Đây là mục tiêu kiểm thử, chưa phải kết quả đạt.

### 1.6. VFX, địa hình và chiến trường đông quân

| Thành phần | Chỉ đạo |
|---|---|
| Va chạm melee | Bụi, vải và tia kim loại ngắn theo vật liệu; vị trí gần hit thật |
| Đạn pháo | Đường đạn/điểm chạm rõ, bụi và mảnh vỡ biểu đạt splash đã có; không giả lập bom nổ hiện đại bằng fireball lớn |
| Khói súng | Tách flash đọc sự kiện khỏi đám khói; giảm opacity/độ dày khi nhiều nòng bắn cùng vùng |
| Aura Preacher | Icon trạng thái trên unit được chọn; vòng phạm vi khi chọn/hover. Không đặt quầng sáng liên tục quanh mọi infantry |
| Frenzy / Exhausted | Đổi icon, thanh trạng thái và nhịp tiếng người; không phủ cả đội bằng màu khiến mất owner color |
| Rừng | Tán cây có thể fade cục bộ khi chọn quân đã được nhìn thấy. Fade không tạo LOS và không tiết lộ enemy trong fog |
| Mưa/sương | Có lựa chọn giảm hiệu ứng; không thay pathing, tầm bắn hoặc thông tin ẩn |
| Địa hình cao | Mép dốc, đường lên và vùng đặt nhà đọc rõ; overlay tầm bắn vẫn lấy số thật, không kéo dài theo art |
| Xác quân | Giảm dần hoặc gộp cosmetic khi cần; không giữ marker “quân sống” sau khi simulation đã xóa |
| Công sự | Phân biệt rõ phần có collision và đồ trang trí để người chơi đo đường đi chính xác |

**Ba map palette:**

- **Black Forest Borders:** lá xanh tối, đất nâu ấm, bìa rừng và đường mòn sáng hơn. Cây không phủ kín đường đi đến mức giấu choke point khỏi người chơi đang có tầm nhìn.
- **Rhine Valley Plains:** đất canh tác sáng, bờ lau, mái ngói và dải nước xanh xám. Ford, bridge và bờ không đi được dùng hình dạng khác nhau; tránh phản chiếu lấp lánh giống projectile.
- **Alpine Foothills:** đồng cỏ, đá xám, sườn dốc và rừng theo cao độ; tuyết chỉ là điểm nhấn xa hoặc cục bộ nếu bối cảnh hợp. Ramps và nền phẳng đặt nhà có ngôn ngữ địa hình nhất quán.

**Hiệu năng:** mục tiêu thử nghiệm là 60 fps ở cấu hình tham chiếu sẽ chốt sau vertical slice. Kiểm tra trận 4v4 tối đa 1.920 population nếu cả tám người chơi là Bundschuh A4, cùng cảnh 500–800 đơn vị hiện trên màn hình. Đo frame time, atlas residency, overdraw của khói/bóng và chi phí UI. LOD chỉ giảm chi tiết cosmetic, không bỏ projectile, trạng thái hay thông tin mà người chơi cần để ra quyết định.

## 2. Audio Design & Voice Acting

### 2.1. Music brief

**Chất nhạc:** ensemble nhỏ đến vừa, giọng người và nhạc cụ mang màu sắc đầu thời cận đại; âm nhạc sáng tác mới, dễ nhận giai điệu, không giả danh bản phục dựng một bài được hát trong trận.

Tư liệu Met hỗ trợ vai trò của lute và nhiều nhạc cụ trong bối cảnh Phục hưng [A1, A2]. Hồ sơ crumhorn của KHM là tham chiếu loại nhạc cụ thế kỷ XVI [A3]. Tranh Campagnola có người chơi hurdy-gurdy được Met ghi khoảng 1540: dùng như tham chiếu lân cận về loại nhạc cụ, không ghi thành bằng chứng trực tiếp tại chiến trường Đức năm 1525 [A4].

| Thành phần | Peace / Gathering | Combat / Crisis |
|---|---|---|
| Lute | Câu ngắn, khoảng nghỉ, đối đáp cùng giai điệu chính | Ostinato vừa phải; giảm phần trang trí khi lời cảnh báo cần nổi |
| Hurdy-gurdy | Drone và nhịp bánh quay nhẹ; dùng chọn lọc | Tạo sức ép bằng âm nền, tránh phủ kín low-mid |
| Crumhorn | Giai điệu gỗ/reed rõ, hợp nhóm nhỏ | Nhân đôi câu chủ đề và đối âm ngắn |
| Drums | Tabor/trống da nhẹ, nhịp hành động lao động | Snare/trống hành quân lấy cảm hứng thời kỳ; tăng mật độ chứ không chỉ tăng âm lượng |
| Brass | Natural trumpet, sackbut hoặc màu kèn phù hợp tư vấn lịch sử, dùng tiết chế | Hiệu lệnh ngắn, câu đáp và hợp âm giữ; tránh âm sắc dàn kèn van hiện đại |
| Voices | Unison, đối đáp hoặc hòa âm mỏng; không hát liên tục | Bundschuh dùng chủ đề chorale nổi hơn; League dùng tiếng hô và nhịp chỉ huy rõ hơn |

**Bundschuh theme:** câu giai điệu dễ hát theo, bắt đầu bằng vài giọng và nhạc cụ dây; khi tổ chức và Zeal tăng, thêm tiếng người cùng reed/drum. Cảm giác cộng đồng có thể chuyển sang căng thẳng, không mặc định “cuồng tín” ở mọi trạng thái.

**League theme:** tiết tấu bước quân, câu kèn ngắn, bè trầm vững và khoảng nghỉ có kỷ luật. “Imperial march” ở đây là hướng cảm xúc cho bản nhạc mới, không sao chép phong cách hành khúc của thế kỷ XIX.

Cả hai phía đều có đời sống tôn giáo và dân sự; chorale không là độc quyền văn hóa của một phe. Phân vai trong score là lựa chọn kể chuyện. Nếu sử dụng một giai điệu lịch sử có tên, musicologist phải kiểm tra niên đại, vùng lưu hành và bản lời trước khi đưa vào.

**Action cho Composer:** viết một chủ đề cho mỗi phe, một cue giao chiến dùng chung và một cue hồi tưởng. Mỗi cue có các stem tách được; giữ bản phối ít nhạc cụ để không lấn SFX.

### 2.2. Adaptive music: trạng thái và chuyển tiếp

Music director chỉ nhận dữ liệu người chơi được phép biết: unit của mình bị đánh, đối thủ đã nhìn thấy, mục tiêu scenario đã công bố và các chỉ số campaign đang hiện. Không chuyển nhạc vì một đội cavalry còn nằm hoàn toàn trong fog.

| Trạng thái | Trigger khởi điểm cho prototype | Bản phối |
|---|---|---|
| **Peace** | Không có giao chiến được biết trong 20 giây; không có cảnh báo khẩn đang hiệu lực | Lute, ambience và một phần melody |
| **Tension** | Thấy địch gần lực lượng/công trình của mình, hoặc vừa có cảnh báo tấn công | Thêm drone/reed và percussion nhẹ |
| **Battle** | Ít nhất 8 sự kiện combat được biết trong 5 giây, hoặc unit của mình liên tục giao chiến trên 5 giây | Thêm trống, bass và câu đáp của motif |
| **Crisis** | Cảnh báo mục tiêu bắt buộc nguy cấp, hoặc Fear ≥75 trong campaign có cơ chế này | Giảm phần trang trí, thêm giọng/kèn nhấn và không gian cho announcer |
| **Aftermath** | Giao chiến kết thúc, mục tiêu lớn vừa hoàn tất hoặc lực lượng vừa rút | Rút trống, giữ motif ngắn rồi về Peace |

- Thứ tự ưu tiên: Crisis > Battle > Tension > Peace. Aftermath là đoạn chuyển có thể bị combat mới ngắt.
- Crisis theo Fear là ngưỡng trình bày, không thay các ngưỡng gameplay 60/80. Thoát nhánh Fear khi Fear ≤60 trong 10 giây và không còn cảnh báo khác.
- Giữ trạng thái ít nhất 12 giây trừ cảnh báo cấp cao hơn. Chuyển stem ở đầu ô nhịp; crossfade hai ô nhịp.
- Các stem trong một cue chung tempo/key/độ dài. Có thể thử 96 BPM, cảm giác double-time trong combat, không bắt buộc time-stretch mọi nhạc cụ.
- UI alarm và câu cảnh báo quan trọng phát ngay; không chờ music đến ô nhịp tiếp theo.
- Save/load giữ trạng thái logic; không phát lại toàn bộ câu tuyên bố chiến thắng hoặc cảnh báo đã xử lý.

**Zeal/Fear đổi cảm xúc:** Zeal cao thêm người vào câu hát; Fear cao làm texture thưa và bất ổn hơn. Hai stem có thể cùng hiện vì hai chỉ số độc lập. Không dùng một thanh crossfade duy nhất giả định Zeal cao thì Fear thấp.

### 2.3. Ngôn ngữ và chỉ đạo diễn xuất

**Lựa chọn:** unit response bằng tiếng Đức lấy cảm hứng Frühneuhochdeutsch, ưu tiên hiểu rõ và phát âm tự nhiên. Lời dẫn/cutscene dùng cùng hướng ngôn ngữ nhưng có phụ đề đầy đủ. UI và phụ đề có khóa dịch riêng cho tiếng Việt, Anh và Đức.

FWB-online là công cụ tham khảo từ vựng Early New High German, bao quát khoảng giữa thế kỷ XIV đến giữa thế kỷ XVII [L1]. Khoảng thời gian đó rộng hơn bối cảnh game; tra được một từ không tự chứng minh đúng biến thể địa phương năm 1525.

**Quy trình duyệt thoại:** writer soạn ý nghĩa → cố vấn kiểm tra từ vựng và vùng → voice director chốt phát âm → thu thử → kiểm tra độ hiểu trong tiếng giao chiến → thu toàn bộ. Không tự thêm chữ cổ hoặc đánh vần kỳ lạ rồi gọi là ngôn ngữ đã phục dựng.

- Nông dân: giọng cụ thể của người lao động, có sức nặng và lo lắng; không diễn thành đám đông ngốc nghếch.
- Ritter: câu ngắn, được huấn luyện, không cần mọi câu đều quát giận.
- Landsknecht: đa dạng quê quán và tính cách, chú ý nhiệm vụ và tiền công; không biến tất cả thành tiếng cười phản diện.
- Preacher: rõ lời, sức thuyết phục đến từ nhịp và hơi thở; tránh liên tục la hét.
- Campaign Thüringen và Swabia có hướng giọng khác nhau sau khi cố vấn duyệt; không áp một giọng Swabian cho mọi nhân vật của Müntzer.
- Voice set theo lực lượng trong scenario, không chỉ theo roster được tái sử dụng. Princely Host ở Frankenhausen không dùng câu “Für den Bund!” của Swabian League; dùng câu trung tính hoặc lời gọi đã được duyệt cho lực lượng đó.

### 2.4. Bộ thoại mẫu để casting

**Tất cả câu dưới đây là thoại sáng tác mới với cách viết hiện đại hóa, chưa được chứng nhận là trích dẫn hoặc phục dựng Frühneuhochdeutsch.** Bản dịch Việt thể hiện ý định diễn xuất.

| Người nói / event | 3 lựa chọn tiếng Đức | Ý nghĩa và cách đọc |
|---|---|---|
| Peasant — Move | “Wohlan!” / “Ich geh voran.” / “Dorthin.” | Nào! / Tôi đi trước. / Đến đó. Nhanh và sẵn sàng |
| Peasant — Attack | “Für unser Recht!” / “Haltet zusammen!” / “Weicht nicht!” | Vì quyền của chúng ta! / Giữ cùng nhau! / Đừng lùi! Khẩn nhưng không mất lời |
| Peasant — Gather | “An die Arbeit!” / “Ich schlage Holz.” / “Die Ernte wartet.” | Vào việc! / Tôi đi đốn gỗ. / Mùa gặt đang chờ. Hai câu sau chỉ dùng đúng tài nguyên |
| Ritter — Move | “Wie befohlen.” / “Wir reiten.” / “Vorwärts.” | Theo lệnh. / Chúng ta lên đường. / Tiến lên. Ngắn, chắc |
| Ritter — Attack | “Für den Bund!” / “Mit mir!” / “Auf sie!” | Vì Liên minh! / Theo ta! / Đánh chúng! Chủ động chỉ huy |
| Ritter — Rally / Form up | “Sammelt euch!” / “Haltet die Ordnung!” / “Zu mir!” | Tập hợp! / Giữ đội ngũ! / Về chỗ ta! Đây là lệnh tập hợp quân |
| League Villager — Gather | “An die Arbeit!” / “Ich hole Holz.” / “Das Erz wird gebraucht.” | Vào việc! / Tôi lấy gỗ. / Đang cần quặng. Điều kiện theo loại việc |
| Landsknecht — Pay warning | “Der Sold ist fällig.” / “Wir warten auf den Sold.” / “Erst den Sold.” | Đến kỳ lương. / Chúng tôi chờ tiền công. / Trả lương trước. Biến thể cuối dành cho Refusal |

**Ritter không có Gather resource.** Không nối lệnh chặt cây/đào mỏ với thoại kỵ sĩ. “Sammelt euch!” thuộc Rally, còn Gather của phe League do Villagers đảm nhiệm.

Mỗi event cần ít nhất ba take biến thể về nhịp; không tăng ngân sách bằng cách thu hàng chục câu chỉ khác một từ. Tránh lặp một take trong hai lần kích hoạt gần nhất.

### 2.5. Soundscape và SFX theo hệ thống

| Không gian / hành động | Lớp nền | Điểm nhấn có điều kiện |
|---|---|---|
| **Black Forest** | Gió theo tầng cây, chim thưa, cành gỗ, khoảng yên | Bánh xe cọt kẹt trên đường, bước chân trên lá; quạ xuất hiện chọn lọc |
| **Rhine Valley** | Dòng nước, bờ lau, gió đồng và hoạt động làng | Guồng nước, xe qua cầu, chuông nhà thờ; âm thương mại gắn với khu dân cư |
| **Alpine Foothills** | Gió sườn đồi, đồng cỏ, đá và cây thưa | Chuông đàn gia súc, chuông làng xa; không phủ tiếng bão lên toàn bản đồ |
| **Làng/công trình** | Gỗ, việc thủ công, tiếng người nhỏ | Búa smithy, ngựa ở Stable, cơ cấu ép và giấy tại Printing Press đang hoạt động |
| **Infantry** | Bước chân theo bề mặt, vải, da | Flail gỗ khác pike thrust; tiếng thép dựa va chạm phù hợp |
| **Cavalry** | Nhịp vó, hơi ngựa và dây cương | Giáp rung vừa phải; không tạo tiếng “charge skill” riêng |
| **Gunpowder** | Chuyển động ê-kíp, dụng cụ nạp | Flash → report → tail theo bắn thực; impact là event riêng |
| **Siege pack/unpack** | Bánh, giằng, dây, dụng cụ | Chuỗi âm trong đúng ba giây; báo hoàn tất một lần |

Âm cảnh quan trang trí không mô tả quân địch ẩn. Enemy cannon trong fog không được phát positional report chỉ vì mixer thấy một event toàn bản đồ. Audio, music và phụ đề âm thanh đều đi qua bộ lọc thông tin của người chơi. Own unit bị đánh ngoài màn hình có thể báo vì đó là thông tin được phép biết.

### 2.6. Mixing, khả năng tiếp cận và bàn giao audio

**Thứ tự ưu tiên mix:** cảnh báo nhiệm vụ/đang bị đánh → unit acknowledgement → combat SFX quan trọng → music → ambience. Đây là độ ưu tiên khi tranh chấp, không có nghĩa mọi cảnh báo phát cùng lúc.

| Quy tắc | Giá trị khởi điểm |
|---|---|
| Unit acknowledgements | Một câu đại diện cho cả selection; khoảng cách tối thiểu 1 giây; lệnh lặp không xếp thành hàng thoại |
| Announcer | Tối đa một câu đang nói; ngắt bởi cảnh báo cấp cao hơn, gộp cảnh báo lặp cùng nguyên nhân |
| Ducking | Khi announcer nói, hạ music khoảng 5 dB và ambience khoảng 3 dB; release mềm sau câu |
| Combat voices | Nhóm sự kiện theo vị trí/loại; ưu tiên gần camera và unit được chọn. Ngân sách thử 64 voice SFX hoạt động, sau đó profile |
| Loop công trình | Virtualize khi không còn nghe được; vào lại không restart click/impact sai thời điểm |
| Dynamic range | Wide / Headphones / Night, kèm preview; profile không được xóa cảnh báo quan trọng |
| Sliders | Master, Music, Combat SFX, Voices, UI Alerts, Ambience riêng |
| Phụ đề | Speaker + nội dung, nền chỉnh được; caption có icon cho cảnh báo quan trọng không có lời |
| Reduced sensory effects | Giảm âm đỉnh, tắt rung màn hình, giảm flash; tín hiệu chức năng vẫn có bản thay thế |

**Bàn giao:** WAV 48 kHz / 24-bit; VO và nguồn SFX mono trừ nội dung cần stereo; music stem stereo đồng bộ độ dài. Giữ dry master, tail/loop riêng khi cần. Export game được quyết định theo engine sau khi nghe thử, không dùng bản nén mất dữ liệu làm master.

Mỗi asset audio có ID, speaker/unit, event, trạng thái hợp lệ, điều kiện tài nguyên nếu có, cooldown, priority, subtitle key, loop points, provenance/quyền sử dụng bản thu và trạng thái duyệt ngôn ngữ. Các trường này là metadata sản xuất, không hiển thị trong HUD người chơi.

## 3. UI/UX Infrastructure

### 3.1. Nguyên tắc bố cục HUD

**Bố cục giữ nguyên giữa hai phe; theme đổi vật liệu và trang trí.** Bundschuh dùng giấy thô/gỗ; League dùng sắt, da và dấu sáp. Có theme Neutral/Competitive tối giản cho người ưu tiên độ đọc.

| Vùng | Nội dung | Hành vi |
|---|---|---|
| Trên trái | Food, Wood, Gold, Stone | Số hiện có; hover mở gatherers/rate nếu hệ thống thống kê hỗ trợ, không thay tiền thực |
| Trên giữa | Population, Age, tiến độ lên Age | Phân biệt sức chứa nhà và trần phe/scenario |
| Trên phải | Đồng hồ, tốc độ/pause, diplomacy và menu | Trạng thái pause rõ trong replay/campaign |
| Dưới trái | Minimap | Kích thước chỉnh được; filter terrain, military, economy, objectives; click điều hướng |
| Dưới giữa | Selection, stats và trạng thái | Group theo loại, hỗ trợ xem unit đặc biệt; số liệu phản ánh tech/aura hiện tại |
| Dưới phải | Command grid 4×3 và tab khi cần | Hotkey cố định/rebindable; không đảo vị trí nút theo skin phe |
| Sát mép trên vùng dưới | Global production queue | Unit/research đang chạy; nhảy tới building; hủy có preview hoàn tài nguyên |
| Góc trên phải của playfield | Objectives và module campaign | Thu gọn được; chỉ pin mục tiêu chính và tối đa hai mục tiêu phụ |

**Khung tham chiếu 1920×1080:** dải trên khoảng 52 px; dải dưới khoảng 216 px. Các panel nổi cần nhỏ và thu gọn, mục tiêu để khoảng 70% màn hình hoặc hơn đọc được chiến trường ở bố cục mặc định. Đây là kích thước greybox, phải duyệt bằng chơi thử.

UI scale hỗ trợ 80–160% ở bước đầu, có layout compact cho 1280×720 và scale phù hợp 4K. Nếu tăng scale làm thiếu chỗ, chuyển thông tin phụ sang tab/tooltip; không ép chữ chính nhỏ hơn mức đọc được. Ultrawide neo cụm chức năng vào vùng an toàn, không kéo dài dòng tài nguyên hoặc text tới cả chiều ngang.

### 3.2. Theme, typography và contrast

| Token | Giá trị | Công dụng |
|---|---|---|
| Dark surface | **#1E2529** | Nền nội dung HUD, không đổi theo phe |
| Main text | **#F3ECD8** | Chữ trên dark surface; contrast tính toán **13,17:1** |
| Parchment surface / ink | **#E5D6B8 / #27251F** | Briefing, Codex; contrast tính toán **10,68:1** |
| Warning | **#F3C76B** | Đi cùng tam giác và nhãn cảnh báo; **9,76:1** trên dark surface |
| Danger | **#FF9387** | Đi cùng icon/nhãn mất mát hoặc nguy cấp; **7,23:1** trên dark surface |
| Positive | **#A5CF8C** | Đi cùng dấu hoàn thành; **8,81:1** trên dark surface |
| Neutral info | **#A8CBE0** | Thông tin và focus; **9,09:1** trên dark surface |

Các tỷ lệ trên tính cho màu phẳng, opacity 100%; texture, disabled state và nền bán trong suốt vẫn cần đo lại. Áp dụng mục tiêu nội bộ: chữ thường ≥4,5:1; dấu hiệu giao diện thiết yếu ≥3:1 với nền kề. Đây là tham chiếu từ WCAG, không phải tuyên bố chứng nhận accessibility cho game native [U1, U2].

- Ornament chỉ ở mép; grain nhẹ và không chạy xuyên qua số tài nguyên. Cả hai skin dùng cùng vùng nền nội dung ổn định.
- Chữ thân bài dùng font dễ đọc có đầy đủ tiếng Việt và Đức. Chữ mang tính blackletter dành cho logo hoặc tiêu đề chapter ngắn.
- Cỡ chữ thân HUD khởi điểm 16 px ở 1080p, caption 18 px; phải có tùy chỉnh và kiểm tra khoảng cách ngồi thực tế.
- Kiểm tra dấu với “Người nông dân”, “Müntzer”, “Böblingen”, “Joß Fritz”; hỗ trợ dấu tổ hợp, line wrap và tên dịch dài.
- Mọi trạng thái dùng icon/nhãn cùng màu. Người chơi được chỉnh palette đồng minh/địch, player number và outline.
- Focus bàn phím, hover và selected có hình dạng khác nhau; tooltip mở được bằng focus, không phụ thuộc chuột.
- Menu, settings và journal hỗ trợ bàn phím; hotkey remap kiểm tra trùng, có reset và export profile khi engine hỗ trợ.

### 3.3. Population, selection và tooltip đúng simulation

**Hiển thị mẫu:** “139 / 160 · Trần 192” cho khởi đầu A6. Trong đó 139 là population đang dùng, 160 là nhà đang chứa được, 192 là trần của scenario sau bonus phe. Không thay bằng “139/240” hoặc nhân bonus Bundschuh lần nữa.

Khi bị chặn tuyển:

- Nếu thiếu nhà: “Cần thêm chỗ ở: 160/160; trần 192.”
- Nếu chạm trần: “Đã đạt giới hạn quân số của màn: 192.”
- Nếu thiếu tài nguyên: tô và nêu đúng tài nguyên còn thiếu; không dùng một nút đỏ chung không giải thích.

**Selection panel:** tên, tier, HP, attack, armor melee/pierce, range nếu có, tốc độ và icon modifier. Tooltip nâng cao phân rã base + technology + aura. Dùng đúng attack period/reload đã áp dụng; không chỉ đổi số DPS mà để animation sai nhịp.

Preacher có icon aura/heal và vòng phạm vi khi yêu cầu; không có mana bar. Cleric có conversion cooldown theo luật của mình. Đơn vị không có khả năng nào thì không để slot giả gây hiểu nhầm.

Đa selection hiển thị số lượng theo loại; click nhóm con để chọn/lọc. Building placement dùng cả màu lẫn hatch cho ô invalid. Overlay tầm pháo biểu thị cả minimum range 2 và maximum range thực; không lấy hình minh họa tròn trang trí để tính.

### 3.4. Zeal / Fear và Alert

**Zeal và Fear dùng hai thanh độc lập 0–100**, cùng một panel campaign thu gọn. Zeal: icon hiệu kỳ/ngọn nến. Fear: icon khiên nứt. Không ghép thành một thanh kéo hai đầu.

| UI state | Hiển thị | Tương tác/phản hồi |
|---|---|---|
| Fear <60 | “Steady” + số hiện tại | Không nhấp nháy |
| Fear 60–79 | “Wavering”; marker 60/75/80 nhìn được | Cảnh báo khi qua 60 và cảnh báo khẩn hơn khi qua 75; gộp để tránh spam |
| Fear ≥80 đang tích lũy | “Rout imminent” + tiến độ 3 giây | Chỉ khi không trong Frenzy/Exhausted/cooldown Rout; giảm Fear kịp thời thì hủy |
| Rout | Countdown 8 giây và tên nhóm chịu tác động | Kết thúc: Fear=50, cooldown Rout 60 giây có badge; Story mode thể hiện đúng phiên bản còn điều khiển được |
| Frenzy sẵn sàng | Zeal ≥70, Fear ≥60, có Preacher hợp lệ, cooldown xong | Nút sáng; tooltip nêu cost 40 Zeal |
| Frenzy hoạt động | Countdown 20 giây; +15% attack rate cho melee thuộc lực lượng áp dụng | Thể hiện miễn Rout trong thời gian này; không cộng attack damage giả |
| Exhausted | Countdown 15 giây; attack period ×1,2; chưa tái kích hoạt Rout | Không ghi nhầm thành “giảm 20% attack speed” |
| Cooldown | Đếm 90 giây từ lúc kích hoạt Frenzy | Tooltip liệt kê từng điều kiện còn thiếu |

Sau kích hoạt, UI lấy Zeal đã trừ 40 và Fear được clamp tối đa 60 từ simulation; khi hết Frenzy, Fear được clamp tối đa 65 theo Phase 3. Giải thích ngắn trong tooltip nâng cao, không dồn cả công thức lên HUD.

Các marker có giá trị; chạm marker không được trông như nhận tài nguyên thứ năm. Nếu nhiều lực lượng có scope khác nhau, panel ghi tên lực lượng đang áp dụng. Không để ranged, cavalry, siege, heroes, support hay workers hiện icon buff melee sai.

**Alert ở A1:** panel riêng 0–100 với mốc 30/60/100. Những hậu quả đã kích hoạt có badge riêng: tăng tuần tra, tuyến bị đóng, cuộc truy đuổi 120 giây. Alert giảm không làm badge one-shot đã xảy ra tự biến mất. Các badge chỉ báo thông tin scenario đã công bố.

### 3.5. Printing Press

Một panel có **hai slot active press**, mỗi slot hiện location/name, HP, owner, mode, cooldown và cảnh báo đang bị đánh.

| Trường hợp | Cách biểu diễn |
|---|---|
| Đang capture | Vòng/ thanh 30 giây, điều kiện Villager đứng trong bán kính 2 và khu vực an toàn theo Phase 3 |
| Recruitment mode | Icon người + kiếm; **+15% tốc độ tuyển** cho quân bộ đủ điều kiện từ Barracks/Range |
| Research mode | Icon sách; **+10% tốc độ nghiên cứu** cho nhóm tech quân sự đủ điều kiện |
| Hai máy Recruitment | Tổng “Recruitment +30%; Research +0%” |
| Một máy mỗi mode | Tổng “Recruitment +15%; Research +10%” |
| Hai máy Research | Tổng “Recruitment +0%; Research +20%” |
| Sở hữu nhiều hơn hai máy | Ghi “Active 2 / Owned N”; máy ngoài giới hạn có nhãn inactive rõ |
| Đổi mode | Nút khóa theo cooldown 30 giây; progress đang chạy giữ nguyên |
| League tịch thu | Ghi “Confiscated — rebel bonus disabled”; không hiện bonus hoặc thu nhập giả cho League |
| Bị phá | Trạng thái destroyed; không còn buff, không tự hồi lại khi đổi owner |

Tooltip Recruitment nên nói “thời gian Flailman hiện tại: 9,23 giây” khi Haufen và hai máy Recruitment đang hoạt động; số được tính bởi hệ thống hiện hành. Không cộng thẳng 30% giảm thời gian vào Haufen.

Progress giao kiện bản in trong A2 nằm ở objectives, tách khỏi buff máy in. Một kiện không biến thành Food/Gold hoặc một ô tài nguyên mới trên top bar.

### 3.6. Mercenary Contracts

**Panel mặc định:** “Hợp đồng: N công ty · Kỳ tiếp theo mm:ss · Dự kiến X Gold”; mở rộng thành bảng. Chỉ Landsknecht có tag hợp đồng thuộc campaign mới xuất hiện.

| Cột | Nội dung |
|---|---|
| Company | Tên/ID đọc được, số người còn phục vụ, nút chọn nhóm |
| Next invoice | Thời điểm đến hạn và khoản **ước tính** trước khi khóa hóa đơn |
| Debt | Tổng nợ đã phát sinh; không gộp với ước tính kỳ tới |
| Status | Paid, Warning, Arrears, Refusal hoặc Desertion, có nhãn Việt |
| Deadline | Thời gian tới Refusal/Desertion dựa trên hóa đơn chưa trả cũ nhất |
| Actions | Pay debt; Autopay toggle; tooltip Gold hiện có và phần còn thiếu |

- Autopay mặc định bật. UI phản ánh thứ tự trả tiền theo luật Phase 3; toggle không tạo một “ví lương” riêng.
- Báo Warning trước kỳ lương 30 giây. Đến hạn mà thiếu tiền, nêu cả số thiếu và thời gian còn lại trước Refusal.
- Trong 60 giây đầu quá hạn: “Arrears — vẫn nhận lệnh”. Từ giây 60: “Refusal — có thể rút/giữ/tự vệ”. Từ giây 120: “Desertion — đang rời biên chế”.
- Không báo lời hứa “trả sẽ giữ được quân” khi Desertion đã được chốt. Nút và tooltip theo trạng thái thực.
- Company đủ tám người phục vụ trọn 120 giây: **40G**. Nếu bốn người chết giữa kỳ: **30G** theo unit-seconds. Khoản ước tính phải thay đổi theo thời gian phục vụ, không lấy headcount hiện tại ×5 rồi bỏ tiền công đã tích lũy.
- Trả muộn không đẩy lùi kỳ 120 giây kế tiếp. Timer cho khoản quá hạn và timer kỳ mới phải là hai giá trị riêng.
- Màu cảnh báo đi cùng icon túi tiền/giấy hợp đồng và countdown. Không cho mất cả công ty chỉ với một âm nhỏ ngoài màn hình.

### 3.7. Objectives và kết thúc lịch sử

**A6 là ca kiểm tra trọng tâm:** HUD tách ba phút chuẩn bị khỏi battle clock; sau chuẩn bị, mục tiêu chính ghi “Giữ Banner đến 18:00”. Ba dòng phụ: “Dân đã thoát: X/24, từ 40 người ban đầu”; “Couriers: Y/3, từ 5”; “Anna: chưa thoát/đã thoát”.

Đến 18:00, mục tiêu Banner khóa trạng thái hoàn thành. Nếu chưa đủ sơ tán, HUD chuyển deadline chính sang 24:00; Banner bị phá sau đó không làm dòng hoàn thành chuyển đỏ. Dân mới tuyển không được cộng vào bộ đếm ID nhiệm vụ.

| Màn hình kết thúc | Nội dung bắt buộc |
|---|---|
| Thắng mục tiêu tactical | “Mục tiêu hoàn thành” và kết quả thực tế: dân, couriers, lực lượng bảo toàn |
| Epilogue A6 | Kết cục lịch sử của trận và Müntzer, được kể riêng; không ghi người chơi đã đảo ngược thất bại Frankenhausen |
| Defeat | Nguyên nhân cụ thể đã xảy ra; nút Load checkpoint / Retry / Review objectives |
| Replay/journal | Briefing, các mục tiêu đã hoàn tất và kết cục có thể đọc lại; thông tin thiết yếu không nằm độc quyền trong cutscene |

Epilogue không reset bàn chơi rồi ép một game-over để phủ nhận thành quả cứu người. Chấm điểm theo mục tiêu đã chốt ở từng màn; art end screen không tự bổ sung điểm thưởng hành quyết hay kill streak.

### 3.8. Main menu, campaign map và progression

**Main menu:** một bàn in dưới ánh cửa sổ; lớp giấy có tranh khắc chiến trường, dấu giày Bundschuh và con dấu quý tộc. Chuyển động nhỏ: giấy, ánh sáng, cơ cấu ép. Reduced Motion đổi thành ảnh tĩnh.

Thứ tự entry: Continue → Campaign → Skirmish/Multiplayer → Learn → Codex → Settings. Settings và lựa chọn phụ đề/audio luôn vào được trước intro.

**Campaign map:** bản đồ minh họa Đế chế La Mã Thần thánh khoảng 1525, thể hiện sông Rhine, Alps, vùng rừng và các lãnh địa qua nhãn, texture và ranh giới khái quát. Không dùng đường biên nước Đức hiện đại như thể đó là biên giới chiến sự. Bản đồ là công cụ điều hướng kể chuyện, không hứa độ chính xác cadastral.

- Campaign A và B có hai tuyến chapter riêng; các điểm cách xa nhau dùng inset hoặc chuyển vùng để địa lý không bị bóp méo.
- A2 Memmingen được ghi là interlude của Anna, không thể hiện Müntzer có mặt ở đó.
- B3 Böblingen đứng trước B4 **After Weinsberg** theo niên biểu Phase 3. Không khôi phục tên “Siege of Weinsberg” theo cách ngụ ý một cuộc vây thành nguyên vẹn đã được xác nhận.
- Frankenhausen không gắn chân dung Waldburg làm chỉ huy bên đối phương.
- Mỗi node có số chapter, tên, thời điểm, trạng thái mở khóa, difficulty và medal. Click mở thẻ location, mục tiêu, giới hạn Age/unit và thời lượng dự kiến.
- Dùng dấu “Bối cảnh có tư liệu” / “Tái dựng gameplay” trong Codex và thẻ thích hợp, không phủ chú giải học thuật lên mọi giây chiến đấu.
- Medal, portrait, Codex và hồi ký được mở theo tiến trình. Không thưởng stat hoặc quân mang sang màn sau trái Phase 3.

**Victory art:** Bundschuh có bản in cộng đồng và hiệu kỳ được giữ lại; League có báo cáo chiến dịch và dấu sáp. **Defeat art:** tờ báo cáo gián đoạn, hiệu kỳ hạ xuống, vật dụng bỏ lại. Cả hai dùng cùng cấu trúc nút và bảng kết quả, tránh phải học lại UI.

### 3.9. Hạ tầng cho UI programmer

**Nguồn sự thật:** simulation → player-visible state → view model → HUD, audio và VFX. Presentation không tự tính thêm một bản morale, payroll hay attack range khác.

| Dữ liệu | Chủ sở hữu logic | Presentation cần nhận |
|---|---|---|
| Faction / age / tech | Gameplay systems | ID ổn định, trạng thái unlock, cost, modifier có hiệu lực |
| Population | Economy/scenario | Used, housing capacity, effective cap, lý do bị chặn |
| Press | Scenario system | Owner, HP, capture progress, active slot, mode, cooldown, eligible effects |
| Zeal/Fear | Scenario force state | Giá trị, scope, Rout/Frenzy/Exhausted state, timers và disabled reasons |
| Contracts | Payroll system | Unit-seconds, invoice estimate/final, debt, oldest due time, next due time, state |
| Objectives | Scenario graph | Progress, deadline, completed/failed/locked flags, điều kiện thông báo |
| Audio/VFX event | Gameplay + visibility filter | ID chống lặp, player permission, vị trí nếu được phép biết, thời điểm thực |
| Localization | String database | Stable keys, biến số có tên, plural/date/number formatting, text expansion |

**Yêu cầu thực thi:**

1. Component tái dùng cho resource, progress, timer, status và cost; faction theme chỉ đổi skin tokens.
2. Tooltip và tech tree dùng cùng dữ liệu với nút research/train. Phân biệt “chưa đủ Age”, “thiếu prerequisite”, “phe không có” và “màn này khóa”.
3. Timer dùng game time; pause, speed change và save/load không tạo thêm invoice hoặc chuyển music sai do đếm wall-clock.
4. Input mapping tách khỏi layout; icon hotkey lấy binding hiện hành. Cho preview và thông báo xung đột khi remap.
5. Multiplayer chỉ nhận dữ liệu được phép thấy; cùng bộ lọc áp dụng minimap, caption, sound và music.
6. UI focus không nuốt mất lệnh đang giữ phím khi đóng panel; mở contracts/journal phải có hành vi pause rõ theo mode.
7. UI widget cho campaign không được chiếm khoảng trống khi ruleset không dùng nó; HUD ranked giữ nhịp quen thuộc.

## 4. Kế hoạch sản xuất và nghiệm thu

### 4.1. Gói bàn giao theo nhóm

| Nhóm | Gói phải bàn giao | Tiêu chí duyệt đầu tiên |
|---|---|---|
| Art Director / historian | Reference board có nguồn và niên đại; palette; sheet giới hạn lịch sử | Phân biệt nguồn gốc lịch sử và phần stylization; không gắn sai phe/nhân vật |
| Character Artist / Animator | Flailman, Landsknecht, Ritter, Preacher, generic Pike và Arquebusier dùng chung chuẩn camera | Silhouette, owner mask, pivot và nhịp hit rõ trong test trộn quân |
| Environment Artist | Town Center hai phe × bốn Ages; Barracks/Range/Stable/Workshop/Church/Stronghold; Press và ba terrain kit | Footprint ổn định; cửa ra quân rõ; đường đi không lẫn đồ trang trí |
| Technical Artist | Scene render chuẩn, exporter, atlas/mask setup, VFX quality settings | Không clipping weapon, alpha fringe hoặc lệch pivot; số liệu profile có thể lặp |
| Composer / music designer | Hai faction themes, combat/aftermath cues, stem và adaptive state definitions | Chuyển mượt; không lộ hidden information; alert vẫn nghe rõ |
| Sound designer | Unit/building/terrain SFX, ambience zones, mix buses, ducking và voice priorities | Trận đông quân không biến thành một khối tiếng; phân biệt súng/pháo/va chạm |
| Writer / VO director | Script có event IDs, bản dịch ý nghĩa, pronunciation notes, take list | Đúng chức năng; kiểm tra riêng Gather/Rally và ngôn ngữ chưa duyệt |
| UI/UX designer | HUD wireframes, hai skins + neutral, menu/map/end screens, focus và responsive states | Người mới đọc được tài nguyên, đối tượng, objective và cảnh báo |
| UI programmer | Data binding, state components, remap/localization, visibility filtering | Save/load/pause hoạt động; không trùng logic gameplay |
| QA / accessibility | Test matrix theo unit, state, resolution, color mode và language | Tất cả thông tin để tránh thua đều có kênh nhìn được, không phụ thuộc màu hoặc âm duy nhất |

Tên asset theo cấu trúc nhất quán, ví dụ **bnd_unit_flail_a2_walk_NE_v001**. ID gameplay không đổi chỉ vì sửa art. Manifest ghi faction, role, age/tier, animation, direction, pivot, mask, phụ thuộc, người duyệt và phiên bản; không dùng tên file làm nguồn tính stats.

### 4.2. Thứ tự production theo gate

| Gate | Nội dung | Điều kiện sang bước tiếp |
|---|---|---|
| **G1 — Readability slice** | Sáu unit trọng tâm, hai loại đất, hai faction palettes và owner masks | Duyệt role recognition, tỷ lệ, camera và animation timing |
| **G2 — Architecture & HUD greybox** | Tám Town Center skins, các silhouette building, HUD lõi | Age evolution hợp bối cảnh; layout dùng được ở 720p/1080p/4K và nhiều UI scale |
| **G3 — A2 / B3 / A6 vertical slice** | Press; phối hợp cavalry–artillery và contracts; Zeal/Fear và sơ tán | Các module giải thích đúng cơ chế; audio mix và end screens giữ đúng kết cục |
| **G4 — Scale & content expansion** | Đầy đủ roster, ba map kit, campaign map, VO và nhạc mở rộng | Profile trận đông quân ổn định; không phải làm lại pipeline nền |
| **G5 — Final review** | Lịch sử, ngôn ngữ, localization, accessibility và regression | Không còn lỗi sai chức năng/định danh; có hồ sơ nguồn và trạng thái nghiệm thu |

Các gate là thứ tự phụ thuộc, không phải cam kết số tuần khi chưa biết số người, engine và ngân sách. Hoàn thành một slice đủ sâu trước khi nhân toàn bộ animation/công trình ra hai phe.

### 4.3. Checklist kiểm thử có thể giao ngay

| Ca kiểm tra | Kết quả cần đạt |
|---|---|
| Đổi màu hai phe và đặt hai người chơi cùng phe cạnh nhau | Không dựa vào crimson/earth tone để xác định chủ sở hữu |
| 120 quân gồm Flail/Lands/generic Pike, màu và thang xám | Mục tiêu nhận diện vai trò ≥90% ở test mặc định; ghi kết quả, sửa silhouette nếu chưa đạt |
| Flailman chém cạnh nhiều mục tiêu; Ritter đánh Pike | Không có hình/âm gợi splash hoặc charge mà gameplay không thực hiện |
| Age-up khi quân đang ra Barracks | Không đổi footprint/cửa hoặc kẹt path; owner mask giữ đúng |
| Cannon pack/unpack, minimum range và friendly splash | Âm/VFX/timer khớp ba giây và vùng tương tác thực; không bắn “ma” khi chưa sẵn sàng |
| Enemy tiến quân hoàn toàn ngoài tầm nhìn | Music, audio, minimap, caption và tree fade không tiết lộ |
| Ranked mở trận | Không thấy các panel Press, Alert, Zeal/Fear, Payroll |
| Preacher aura A4 + Frenzy | UI tách +2 attack của aura khỏi +15% attack rate; không hiện mana |
| Haufen + hai Press Recruitment | Hiện Flailman 9,23 giây; cost và population không bị sửa |
| Công ty tám người, bốn tử trận ở giữa kỳ | Invoice 30G; không reset kỳ lương hoặc bỏ công đã tích lũy |
| Save/load ngay trước kỳ lương và khi đang Warning | Một invoice đúng; cảnh báo không spam lại vô hạn |
| Fear dao động 59/60 hoặc 79/80 | Nhãn và countdown đúng; music không đảo trạng thái liên tục |
| A6 bắt đầu; Banner mất sau battle 18:00 | Pop 139/160, cap192; Banner objective vẫn complete sau thời điểm giữ đủ |
| Lệnh Gather với Villager; chọn Ritter cùng resource node | Chỉ Villager có gather response; Ritter không bị gán hành vi lao động |
| Tắt toàn bộ audio | Vẫn thấy thiếu Gold, Refusal/Desertion, objective risk và bị tấn công |
| Theme parchment/iron/neutral ở các scale | Số, contrast, hotkeys và vị trí không thay nghĩa; tooltip không bị cắt |
| Tiếng Việt/Đức và tên dài | Không mất dấu, tràn nút, sai số ít/nhiều hoặc lỗi line wrap |
| Hoàn thành A6 | Có chiến thắng mục tiêu cứu người và epilogue lịch sử riêng; không có stat carryover trái luật |

## 5. Nguồn tham chiếu và phạm vi sử dụng

Các nguồn hỗ trợ vật liệu tham khảo lịch sử hoặc tiêu chí giao diện; chúng không xác nhận palette, giá trị trigger, lời thoại sáng tác, pipeline và chỉ tiêu hiệu năng của game.

### Visual

- **[V1]** [The Metropolitan Museum of Art — Albrecht Dürer, Samson Rending the Lion](https://www.metmuseum.org/art/collection/search/336212). Woodcut, khoảng 1497–1498; tham khảo nét khắc và tạo khối.
- **[V2]** [The Metropolitan Museum of Art — Albrecht Dürer, Knight on Horseback and Landsknecht](https://www.metmuseum.org/art/collection/search/335327). Tranh bút mực/wash, niên đại được ghi rộng; tham khảo hình khối và trang phục, không gán thành cảnh cụ thể năm 1525.
- **[V3]** [National Gallery of Art — Lucas Cranach the Elder, Portrait of a Man](https://www.nga.gov/artworks/45886-portrait-man). 1522, oil on panel; tham khảo tương phản vải, da và nền.

### Audio và ngôn ngữ

- **[A1]** [The Metropolitan Museum of Art — The Lute](https://www.metmuseum.org/essays/the-lute). Tham chiếu loại nhạc cụ và phát triển của lute.
- **[A2]** [The Metropolitan Museum of Art — Music in the Renaissance](https://www.metmuseum.org/essays/music-in-the-renaissance). Bối cảnh nhạc cụ và thực hành âm nhạc Phục hưng.
- **[A3]** [Kunsthistorisches Museum Wien — Crumhorn (tenor)](https://www.khm.at/en/artworks/crumhorn-tenor-84923). Metadata bộ sưu tập ghi thế kỷ XVI; không dùng làm xác nhận một quân nhạc cụ thể tại trận đánh.
- **[A4]** [The Metropolitan Museum of Art — Domenico Campagnola, Landscape with a woman seated next to a man playing a hurdy-gurdy](https://www.metmuseum.org/art/collection/search/372188). Khoảng 1540; tham khảo lân cận, muộn hơn chiến tranh trong game.
- **[L1]** [Frühneuhochdeutsches Wörterbuch — FWB-online](https://fwb-online.de/). Công cụ từ vựng cho cố vấn; không bảo đảm các câu draft trong guide đã được thẩm định.

### UI

- **[U1]** [W3C — Understanding WCAG 2.2: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html). Cơ sở tham chiếu contrast chữ.
- **[U2]** [W3C — Understanding WCAG 2.2: Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html). Cơ sở tham chiếu dấu hiệu UI thiết yếu.

Các quyết định niên biểu, địa điểm, protagonist, giới hạn tái dựng Frankenhausen/Weinsberg và scope gameplay kế thừa hồ sơ nguồn của **BUNDSCHUH_REBELLION_GDD_PHASE_3.md**. Khi thêm một huy hiệu, bài hát có tên hoặc bản dựng công trình cụ thể, bổ sung nguồn cho chính asset đó vào reference board trước khi duyệt sản xuất.

