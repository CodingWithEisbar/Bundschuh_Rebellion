# BUNDSCHUH: REBELLION

## Phase 1 — Faction Design & Unique Mechanics

**Phiên bản:** 0.1 — đề xuất để dựng prototype và playtest.  
**Ngày:** 10/10/2026.  
**Phạm vi:** hai phe, bốn thời đại, bonus, đơn vị độc quyền, công nghệ độc quyền, team bonus và khung cân bằng ban đầu. Ưu tiên giao chiến trên bộ, 1v1; có quy tắc cho team game.  
**Trạng thái:** đã rà logic và phép tính; chưa có prototype hay kết quả playtest. Mọi chỉ số chiến đấu bên dưới là thiết kế mới, không phải dữ liệu lịch sử hoặc bảng chỉ số chính thức của AoE II.

## 1. Định hướng thiết kế

Bundschuh thắng bằng kinh tế Food/Wood, quân đông, nhiều hướng tấn công và khả năng tái lập lực lượng. Swabian League thắng bằng chất lượng từng đơn vị, đội hình phối hợp, kiểm soát mỏ Gold và hỏa lực được bảo vệ.

Sự bất đối xứng phải tạo ra lựa chọn ở mọi giai đoạn: League có cách phòng thủ đầu trận; Bundschuh vẫn có cách đánh late game. Một trận đấu không được quyết định chỉ bởi việc League đã lên Age 4.

| Trục thiết kế | Bundschuh | Swabian League |
|---|---|---|
| Giá trị chính | Hiệu quả theo chi phí; thay quân nhanh | Hiệu quả trên mỗi population; giữ quân sống |
| Tài nguyên trọng tâm | Food/Wood, Gold cho hỗ trợ và pháo | Food/Gold, Stone cho công sự |
| Cách sử dụng bản đồ | Raid nhiều hướng, cắt tiếp viện, đánh vào điểm yếu | Chiếm điểm quan trọng, che chắn pháo, phản kích bằng kỵ binh |
| Đội hình dễ nhận biết | Flailmen + giáo + Preacher; súng/pháo bổ trợ | Landsknechts + súng + pháo; Ritter đánh sườn |
| Rủi ro chính | Thiệt hại diện rộng, giáp thấp, đông quân bị nghẽn đường | Mất quân đắt tiền, thiếu Gold, pháo bị áp sát |

### 1.1. Giữ nguyên vòng lặp AoE II

- Villagers thu thập **Food, Wood, Gold, Stone**; xây nhà và công trình; giao tài nguyên tại điểm thu nhận.
- Huấn luyện quân tại công trình quân sự; nghiên cứu nâng cấp; tiến qua bốn Ages.
- Giữ fog of war, scouting, địa hình, collision, tường/cổng và hệ khắc chế.
- Cùng điều kiện khởi đầu, công thức tăng giá chợ và quy tắc mua/bán cho hai phe.
- Cùng chi phí và thời gian lên đời ở bản thử nghiệm đầu; chốt bảng chung ở Phase 2.
- Zeal được thể hiện bằng aura của Preacher. Không thêm tài nguyên thứ năm, thanh mana, quân tự sinh hay phí duy trì quân theo thời gian.
- Du kích đến từ scouting, tốc độ, giá quân và nhiều hướng tấn công. Không có tàng hình, teleport hoặc đi xuyên rừng.

**Đơn vị đo:** F = Food; W = Wood; G = Gold; S = Stone; HP = máu; population = suất dân. Thời gian là giây mô phỏng; tốc độ là ô bản đồ/giây. Giáp ghi theo thứ tự **cận chiến/xuyên**. Chỉ số đơn vị là trước bonus phe, Blacksmith, UT và aura, trừ khi ghi khác.

### 1.2. Giới hạn lịch sử cần thể hiện rõ

1. **Bundschuh là tên phe tổng hợp trong game.** Các âm mưu/phong trào Bundschuh trước 1524 và các đội quân nổi dậy năm 1525 không được kể như một quốc gia thống nhất có cùng bộ chỉ huy. Các mốc Bundschuh thường được nghiên cứu gồm 1493, 1502, 1513 và 1517. [H1]
2. **Swabian League là liên minh trong Đế quốc**, có giới quý tộc, các thành thị đế chế và các thân vương; không đồng nhất với một quân đội quốc gia Đức thống nhất. [H2]
3. **Quân nổi dậy có trang bị đa dạng:** nông cụ cải biến, vũ khí quân dụng, lính có kinh nghiệm, súng và pháo. Cho Bundschuh sử dụng hỏa khí cơ bản phù hợp với bằng chứng lịch sử. [H3][H4]
4. **Müntzer gắn với nhánh nổi dậy ở Thüringen**, đặc biệt Mühlhausen/Frankenhausen. Preacher là đơn vị tổng hợp lấy cảm hứng từ vai trò các nhà thuyết giảng; không phải bản sao Müntzer được tuyển hàng loạt. [H5]
5. Nhu cầu về quyền cộng đồng, đất/rừng và tôn giáo có cơ sở trong **Twelve Articles**. Bonus gameplay là cách diễn giải thiết kế, không phải tác dụng lịch sử có thể đo bằng phần trăm. [H6]

Trong campaign, dùng địa danh, lãnh đạo và lực lượng đúng từng kịch bản. Skirmish cho phép phối hợp hai phe theo luật chơi cạnh tranh.

## 2. Bốn thời đại

Giữ tên do người sáng lập chọn. Đây là bốn **mức huy động và tổ chức trong một trận đấu**; không phải bốn thời kỳ công nghệ diễn ra tuần tự trong hai năm. Reformation Age không hàm ý Cải cách tôn giáo chỉ bắt đầu sau năm 1525.

| Age | Tên | Bundschuh: cảm giác tiến triển | League: cảm giác tiến triển |
|---|---|---|---|
| 1 | Serfdom Age | Canh tác, mạng lưới làng, hội họp kín | Điền trang, bộ máy địa phương, trinh sát |
| 2 | Conspiracy Age | Trang bị lực lượng địa phương, Flailmen, raid | Quân đồn trú, giáo/nỏ cơ bản, củng cố phòng thủ |
| 3 | Insurrection Age | Haufen, Preachers, huy động đông quân; súng/pháo cơ bản | Landsknechts, Ritter, quân chuyên nghiệp và hỏa khí |
| 4 | Reformation Age | Huy động rộng hơn, Flailmen tinh nhuệ, thuyết giảng khởi nghĩa | Nâng cấp quân tinh nhuệ, pháo công thành và hậu cần hỏa lực |

Hỏa khí mở theo năng lực trang bị của phe trong trận đấu, không phải vì nhân vật vừa phát minh ra thuốc súng. Chiếm tu viện phù hợp với nhiệm vụ campaign; skirmish không bắt buộc bản đồ phải có tu viện trung lập để phe nổi dậy hoạt động được.

## 3. Phe Bundschuh — Peasant Rebellion

### 3.1. Bốn civilization bonuses

| ID | Bonus | Hiệu ứng chính xác | Ý nghĩa và giới hạn |
|---|---|---|---|
| BND-01 | **Common Lands — Đất chung** | Từ Age 1, Villagers thu thập F và W nhanh hơn **10%**. | Nhân tốc độ làm việc với 1,10; không nhân lượng tài nguyên trong mỏ/cây/ruộng, không tăng sức chứa. Không áp dụng tàu cá, trade, G hoặc S. |
| BND-02 | **Village Levies — Dân quân làng** | Từ Age 2, giảm **15% phần F** trong giá tuyển dòng dân quân cận chiến, dòng giáo và Flailmen. | Giữ nguyên W/G/S. Làm tròn lên từng giá F. Không giảm giá Villagers, Preachers, súng, pháo, nghiên cứu hoặc lên đời. |
| BND-03 | **Battlefield Salvage — Thu hồi chiến cụ** | Từ Age 2, nhận **10% W và 10% G thực trả khi tuyển** của quân địch bị tiêu diệt hợp lệ. | Trần tổng **120 W+G trong bất kỳ 60 giây liên tiếp**, tính riêng mỗi người chơi. Phải có bộ binh cận chiến của mình còn sống trong bán kính 3 ô tại thời điểm đối phương chết. |
| BND-04 | **Popular Mobilization — Tổng huy động** | Trần population bằng **110%** trần chuẩn từ Age 3 và **120%** từ Age 4. | Thay thế theo Age, không cộng hai mức. Vẫn cần đủ Houses; không tặng quân hay tài nguyên. Với P = 200: 200/200/220/240. |

**Ràng buộc Salvage:**

- Người chơi nhận thưởng phải là chủ của đơn vị quân sự gây đòn kết liễu. Tower/Castle và Villager không kích hoạt; đồng minh hỗ trợ không nhận thêm bản thưởng.
- Chỉ áp dụng quân sự của đội đối phương. Không áp dụng dân, nhà, thú, quân trung lập, quân cho miễn phí, quân đã từng bị conversion, tự xóa hoặc thiệt hại do đồng minh.
- Mỗi ID đơn vị chỉ có một lần xét thưởng trong suốt trận.
- Dùng giá thực trả đã lưu khi tuyển; không dùng giá danh nghĩa hoặc cộng phần chi phí nâng cấp sau này. W hoàn lại thành W; G hoàn lại thành G; không trừ kho tài nguyên của đối phương.
- Phần vượt trần 60 giây bị bỏ; không tích thành khoản chờ. Nếu cần cắt thưởng, giảm W/G theo cùng tỷ lệ.
- Đây là thu hồi tự động để giữ nhịp macro quen thuộc. Điều kiện có bộ binh ở gần mô phỏng khả năng thu chiến cụ; không tạo vật thể nhặt trên bản đồ.

Ví dụ: một Ritter tuyển bằng 90F + 100G cho **10G** nếu thỏa điều kiện. Một Flailman không tạo lợi nhuận từ việc hy sinh quân của chính mình.

### 3.2. UU 1 — Peasant Flailman

**Vai trò:** bộ binh rẻ, cơ động, áp sát lính giáo, quấy kinh tế và tràn qua những vị trí thiếu phòng thủ. Không được coi là đơn vị phá giáp đa dụng.

**Bối cảnh:** chày đập lúa có gắn đinh và các nông cụ cải biến xuất hiện trong hình tượng/trang bị quân nổi dậy. Việc gom chúng thành một dòng quân có bonus chống giáo là quy ước RTS. [H3]

| Thuộc tính | Flailman |
|---|---|
| Mở khóa / công trình | Age 2 / Barracks |
| Giá cơ sở | 45F + 15W |
| Giá thực trả của Bundschuh | **39F + 15W** sau BND-02 |
| HP / sát thương cơ sở | 45 HP / 7 cận chiến |
| Giáp | 0/0 |
| Chu kỳ đòn / tầm đánh | 2,0 giây / 0,5 ô |
| Tốc độ / thời gian tuyển | 1,10 ô/giây / 16 giây |
| Population | 1 |
| Bonus sát thương | **+4 với dòng giáo**, bao gồm Landsknecht Pikeman |

- Không splash; không bỏ qua giáp; không có bonus chống kỵ binh.
- Lợi thế chống giáo cần được kiểm tra theo **chi phí ngang nhau**, không bắt buộc thắng Landsknecht 1v1.
- Bị nỏ/súng được che chắn, kỵ binh nặng, bộ binh chống bộ binh và pháo diện rộng trừng phạt.
- Từ Age 4 có nâng cấp thường **Elite Flailman**: 400F + 200G, 50 giây tại Barracks; đổi HP thành **60**, attack thành **9**, bonus chống giáo thành **+5**. Các thuộc tính khác giữ nguyên. Đây là nâng cấp dòng quân, không tính vào hai UT.

### 3.3. UU 2 — Radical Preacher

**Vai trò:** đơn vị hỗ trợ mong manh, tạo điểm tập hợp cho lực lượng nổi dậy; giúp đội quân hỗn hợp đánh hiệu quả nếu người chơi bảo vệ được người thuyết giảng.

**Bối cảnh:** lấy cảm hứng từ các nhà thuyết giảng và sự huy động qua tôn giáo. Codex giới thiệu Müntzer như một nhân vật ở bối cảnh Thüringen, không gọi ông là tổng chỉ huy toàn bộ Bundschuh. [H5]

| Thuộc tính | Radical Preacher |
|---|---|
| Mở khóa / công trình | Age 3 / Church, tương đương Monastery |
| Giá | 100G |
| HP / giáp | 35 / 0/0 |
| Tốc độ / thời gian tuyển | 0,85 ô/giây / 40 giây |
| Population | 1 |
| Tấn công | Không có đòn gây sát thương |
| Hồi máu | 3 HP/giây cho một đơn vị sinh học cùng đội, tầm 4 ô; phải đứng yên |
| Khả năng khác | Mang relic theo luật chung; không conversion |

**Aura: Common Cause — Chung một mục tiêu**

- Bán kính **4 ô**, tính theo tâm đơn vị.
- Bộ binh cận chiến cùng chủ sở hữu trong vùng nhận **+1 base melee attack**. Bao gồm Flailmen, dân quân cận chiến và dòng giáo.
- Không áp dụng dân, kỵ binh, quân tầm xa, siege, công trình hoặc quân của đồng minh.
- Nhiều Preachers không cộng dồn aura; mỗi quân chỉ nhận mức mạnh nhất.
- Aura hoạt động khi di chuyển hoặc hồi máu, nhưng tắt khi garrison, trên tàu vận tải hoặc chết. Ra khỏi vùng là mất hiệu ứng ngay.
- Preacher không tự hồi máu; nhiều nguồn hồi máu cùng mục tiêu không cộng tốc độ trong prototype.
- Aura chỉ tăng sát thương cơ sở, không nhân bonus chống kỵ binh/chống giáo.

Bundschuh dùng Preacher thay dòng Monk thông thường trong skirmish. Việc thiếu conversion là một giới hạn có chủ ý; phản công kỵ binh bằng giáo vẫn phải hiệu quả.

### 3.4. Hai unique technologies

Hai UT nghiên cứu tại công trình Castle-equivalent: **Rebel Stronghold**. Giai đoạn đầu dùng cùng chi phí dựng Castle-equivalent cho hai phe; không mặc định giảm giá cho Bundschuh. Nhà này là điểm đầu tư Stone, không phải điều kiện để tuyển hai UU.

| Age | UT | Giá / thời gian | Tác dụng |
|---|---|---|---|
| 3 | **Haufen Organization — Tổ chức nghĩa quân** | 250F + 150G / 45 giây | Giảm **25% thời gian tuyển** dòng dân quân cận chiến, giáo và Flailmen tại Barracks. Flailman: 16 → **12 giây**. |
| 4 | **Revolutionary Sermons — Thuyết giảng khởi nghĩa** | 500F + 350G / 75 giây | Aura Preacher đổi từ **+1 thành +2 base melee attack** và thêm **+10% tốc độ di chuyển** cho các quân hợp lệ trong vùng. Bán kính vẫn 4 ô. |

UT Age 3 tăng công suất tuyển khoảng **33,3%**, không phải 25%. Nó không tạo thêm tài nguyên để nuôi dây chuyền tuyển quân.

UT Age 4 thay aura cũ, không cộng +1 và +2 thành +3. Flailman không có modifier tốc độ khác di chuyển 1,10 × 1,10 = **1,21 ô/giây**, vẫn chậm hơn Ritter cơ sở 1,30. Tăng attack không làm tăng splash, armor penetration hoặc bonus chống kỵ binh.

### 3.5. Team bonus

**Village Watch — Mạng lưới cảnh giới:** từ Age 2, bộ binh cận chiến của người chơi Bundschuh và đồng minh có **+1 ô tầm nhìn**. Không tăng tầm đánh, không nhìn xuyên fog ngoài tầm, không áp dụng dân, siege hoặc quân tầm xa. Nhiều người chơi Bundschuh cùng đội chỉ cấp hiệu ứng một lần.

### 3.6. Giới hạn cây công nghệ

- Có dòng giáo nâng cấp đầy đủ để duy trì khắc chế kỵ binh nặng.
- Có nỏ, skirmishers, light cavalry, súng hỏa mai và field cannon cơ bản. Súng/pháo cơ bản được tuyển bằng tài nguyên bình thường từ Age 3; “thu được vũ khí” là flavor, không yêu cầu bắt pháo của đối thủ.
- Không có dòng heavy cavalry chuyên nghiệp và nâng cấp pháo hạng nặng của League.
- Không có tier giáp bộ binh cuối cùng, Elite Arquebusier hoặc tier quân nỏ cuối cùng. Vẫn có đủ nâng cấp tấn công cận chiến để lực lượng đông không trở nên vô dụng.
- Có palisades, towers và Stronghold, nhưng không có nâng cấp tường đá/pháo đài cuối cùng của League. Chốt danh sách đầy đủ ở Phase 2.
- Không tự buff tất cả bộ binh thành vừa rẻ, vừa nhiều HP, vừa chống tên. “Fragile” được giữ bằng HP/giáp của dòng quân chính và giới hạn nâng cấp.

## 4. Phe Swabian League — Professional Coalition

### 4.1. Bốn civilization bonuses

| ID | Bonus | Hiệu ứng chính xác | Ý nghĩa và giới hạn |
|---|---|---|---|
| SWB-01 | **Estate Administration — Quản trị điền trang** | Từ Age 3, Villagers **+3 sức chứa tài nguyên** khi làm việc với F/W/G/S. | Giảm số lượt đi giao; không phải +3 tài nguyên mỗi lần thu và không phải +30% tốc độ khai thác. Không áp dụng tàu, trade, relic. |
| SWB-02 | **Professional Armories — Quân khí chuyên nghiệp** | Từ Age 3, bộ binh cận chiến và kỵ binh cận chiến có **+1 melee armor**. | Không thêm pierce armor; không giảm bonus damage theo lớp chống cavalry. Không áp dụng dân, súng, siege. |
| SWB-03 | **Powder Train — Tiếp vận thuốc súng** | Từ Age 3, thời gian nạp lại của **súng bộ binh và pháo thuốc súng** giảm **10%**. | Nhân chu kỳ bắn với 0,90: 10 → 9 giây; DPS lý thuyết tăng 11,1%. Không áp dụng công trình, nỏ hoặc toàn bộ siege phi thuốc súng. |
| SWB-04 | **Master Masons — Thợ xây liên minh** | Từ Age 2, stone walls, stone gates, towers và League Castles có **+20% max HP**. | Không buff Town Centers, nhà kinh tế, palisades; không tăng attack/range hoặc làm rẻ chi phí xây. |

Kinh tế League phát triển chậm hơn **tương đối**: không có bonus thu thập đầu trận của Bundschuh, còn đội quân chủ lực cần Gold và đầu tư lớn. Không giảm tốc độ tuyển dân, tăng giá Villagers hoặc giảm tốc độ thu thập cơ sở ở bản thử đầu. League vẫn có quân giáo/nỏ cơ bản để chống rush.

### 4.2. UU 1 — Landsknecht Pikeman

**Vai trò:** lính giáo chuyên nghiệp, giữ tuyến trước và che cho súng/pháo; hiệu quả chống kỵ binh nhưng không phải bộ binh chống mọi mục tiêu.

**Bối cảnh:** pike là vũ khí chủ đạo của Landsknechte; hình ảnh phổ biến chỉ gắn Landsknecht với đại kiếm sẽ làm hẹp vai trò thực tế của họ. Lính đánh thuê cũng có mặt bên quân nổi dậy; độc quyền dòng quân tuyển chuẩn hóa này là lựa chọn gameplay. [H3][H7]

| Thuộc tính | Landsknecht Pikeman |
|---|---|
| Mở khóa / công trình | Age 3 / Barracks |
| Giá | 55F + 35G |
| HP / sát thương cơ sở | 65 / 6 cận chiến |
| Giáp cơ sở | 1/0; sau riêng SWB-02 là 2/0 |
| Chu kỳ đòn / tầm đánh | 2,0 giây / **1 ô** |
| Tốc độ / thời gian tuyển | 0,90 ô/giây / 26 giây |
| Population | 1 |
| Bonus sát thương | **+24 chống cavalry** |

Tầm 1 ô hỗ trợ tuyến giáo có chiều sâu, không cho đánh xuyên nhiều mục tiêu. Collision vẫn tồn tại; công cụ đội hình giúp xếp quân chứ không tự cấp thêm buff.

- Bị Flailmen áp sát theo lợi thế chi phí, hỏa lực tầm xa hoặc pháo khắc chế.
- Không splash, charge hoặc giảm damage theo số quân đứng gần; tránh biến khối giáo thành một đơn vị không thể phản công.
- Age 4: **Elite Landsknecht**, 500F + 300G, 60 giây tại Barracks; HP cơ sở thành **80**, attack **7**, bonus cavalry **+28**. Giá tuyển và thuộc tính khác giữ nguyên. HP sau UT Age 3 là 90.
- League giữ Spearman/Pikeman thường, nhưng không có tier giáo phổ thông cuối cùng: Landsknecht là lựa chọn tuyến giáo cao cấp, đổi hiệu quả và độ bền lấy Gold.

### 4.3. UU 2 — Armoured Ritter

**Vai trò:** kỵ binh giáp nặng, đánh bại quân bắn tên không được che chắn, raid sâu và kết liễu pháo/Preacher bị lộ.

Tên hiển thị đề xuất là **Armoured Ritter**; “Heavy Gendarme” mô tả archetype mà người chơi dễ hình dung. Thiết kế hình ảnh bám mounted men-at-arms trong không gian Đức đầu thế kỷ XVI; không mặc định dùng một trung đoàn Gendarmerie Pháp. Tư liệu chuyên khảo về quân League có mô tả các lực lượng mounted men-at-arms, cavalry và artillery. [H8]

| Thuộc tính | Armoured Ritter |
|---|---|
| Mở khóa / công trình | Age 3 / Stable; thay dòng Knight thông thường |
| Giá | **90F + 100G** |
| HP / sát thương cơ sở | 125 / 12 cận chiến |
| Giáp cơ sở | 2/2; sau riêng SWB-02 là 3/2 |
| Chu kỳ đòn / tầm đánh | 1,8 giây / 0,5 ô |
| Tốc độ / thời gian tuyển | 1,30 ô/giây / 38 giây |
| Population | 1 |
| Khả năng đặc biệt | Giá trị đến từ chỉ số; không charge AoE hoặc miễn bonus chống cavalry |

- Đắt và thay thế chậm. Không được dùng giáp thông thường để triệt tiêu sát thương bonus của giáo.
- Đánh hiệu quả vào nỏ/súng mất tuyến che chắn; không mặc định thắng đội hình hỗn hợp chỉ vì là quân đắt tiền.
- Age 4: **Elite Ritter**, 700F + 500G, 70 giây tại Stable; HP cơ sở thành **150**, attack **14**, giáp **2/3**. Các thuộc tính khác giữ nguyên.

### 4.4. Hai unique technologies

Cả hai nghiên cứu tại **League Castle**. Nâng cấp Elite của hai UU là nghiên cứu dòng quân tại công trình tương ứng, không tính là UT.

| Age | UT | Giá / thời gian | Tác dụng |
|---|---|---|---|
| 3 | **Fähnlein Drill — Huấn luyện đội quân** | 400F + 300G / 60 giây | Landsknecht Pikeman và Elite Landsknecht **+10 max HP, +1 melee armor**. Không buff quân giáo thường hoặc Ritter. |
| 4 | **League Ordnance — Pháo binh liên minh** | 600W + 500G / 80 giây | Field Cannons và Heavy Cannons của League **+1 tầm bắn tối đa** và **+25% phần bonus damage chống công trình**. Không thay đổi base attack hoặc sát thương chống quân. |

Ví dụ UT Age 4: khẩu pháo giả định có 30 base attack và +100 chống công trình sẽ có +125 chống công trình sau nghiên cứu; base attack vẫn 30. Phần tăng chỉ có hiệu lực trên mục tiêu mang armor class công trình. Ví dụ này giải thích công thức, không xác định bảng cannon cuối cùng.

UT Age 3 là quyết định đầu tư vào đội hình giáo–súng–pháo. Người chơi chọn tập trung Ritter có thể hoãn nghiên cứu này.

### 4.5. Team bonus

**Shared Armourers — Thợ quân khí liên minh:** từ Age 2, thời gian nghiên cứu các công nghệ tại **Blacksmith** của cả đội giảm **15%**. Giữ nguyên giá; không ảnh hưởng thời gian lên đời, UT tại Castle, huấn luyện quân hoặc nâng cấp Elite tại Barracks/Stable. Nhiều người chơi League không cộng dồn.

### 4.6. Giới hạn cây công nghệ

- Có giáp và tấn công cao cấp cho quân chuyên nghiệp; có Elite Arquebusiers và Heavy Cannons ở Age 4.
- Có tường đá và công sự tốt; phòng thủ vẫn tốn tài nguyên và không tự kiểm soát các mỏ ngoài thành.
- Có Spearman/Pikeman, nỏ và skirmisher cơ bản để phòng thủ đầu trận. Các đơn vị nhập môn giữ giá chuẩn; trọng tâm đắt tiền nằm ở lực lượng chuyên nghiệp.
- Không được bonus trần population, giảm giá giáo/dân quân, tuyển dân nhanh hoặc hoàn lại tiền cho quân chết.
- Thiếu Gold làm giảm mạnh khả năng thay Ritter, Landsknecht và artillery; quan hệ này phải còn tồn tại trong team game có trade.

## 5. Khung khắc chế và đường phản công

| Đơn vị/đội hình gây áp lực | Đối tượng nó phải đánh hiệu quả | Cách đối phương phản công |
|---|---|---|
| Flailmen đông | Giáo, quân tầm xa bị áp sát, điểm kinh tế trống | Nỏ/súng có tuyến che; kỵ binh nặng; splash; chokepoint |
| Giáo Bundschuh | Ritter đánh trực diện | Nỏ/súng, bộ binh chống bộ binh, pháo; đổi hướng kỵ binh |
| Preacher + bộ binh | Gia tăng hiệu quả của lực lượng hỗn hợp | Tập trung bắn Preacher; artillery buộc tản quân; kéo quân ra khỏi aura |
| Landsknecht + súng | Cavalry charge và bộ binh đi thẳng vào đội hình | Flailmen bọc sườn, hỏa lực phản pháo, raid dây tiếp viện |
| Ritter | Archer/crossbow trống tuyến trước, pháo và support bị lộ | Giáo, địa hình hẹp, surround phối hợp; tổn thất Gold khi mắc kẹt |
| Pháo League + tuyến che | Công sự và đám đông co cụm | Tách quân, đánh hai hướng, light cavalry/Flailmen áp sát; pháo cơ bản bắn trả |

**Điều kiện bắt buộc đối với cây quân dùng chung ở Phase 2:**

- Pháo cơ bản của Bundschuh phải có tầm bắn lớn hơn công sự phòng thủ tầm xa thông thường ít nhất 1 ô. Không khóa mọi công cụ công thành hiệu quả sau một cơ chế cướp pháo.
- Súng hỏa mai cơ bản là nguồn damage cao để bổ sung cho giáo khi gặp quân giáp; nỏ vẫn hữu ích ở thời điểm xuất hiện và khi micro tốt.
- Artillery có đường đạn quan sát được; triển khai 3 giây, thu pháo 3 giây, tầm bắn tối thiểu 2 ô ở prototype. Không bắn khi đang di chuyển/triển khai.
- Splash artillery gây 100% damage chuẩn lên đối phương và **50% damage tương ứng lên quân cùng đội** trong vùng ảnh hưởng; không gây bounty do friendly fire. Kiểm tra riêng trong team game.
- Không tự cấp các cơ chế đạn nổ/charge/splash cho nhiều dòng quân cùng lúc. Nếu thêm kiểu pháo khác, cần thông số footprint/splash riêng trước khi playtest.

### 5.1. Nhịp trận mong muốn

| Giai đoạn | Bundschuh chủ động làm gì | League chủ động làm gì |
|---|---|---|
| Age 1 | Tận dụng kinh tế F/W và scouting | Dựng nền kinh tế, chọn vị trí phòng thủ |
| Age 2 | Flailmen + giáo quấy nhiều vị trí; quyết định raid hay lên đời | Quân thường giữ kinh tế; đầu tư phòng thủ vừa đủ để lên đời |
| Age 3 | Haufen, aura và 220 population; kiểm soát mỏ ngoài | Lực lượng chuyên nghiệp xuất hiện; chọn Ritter hoặc giáo–súng–pháo |
| Age 4 | 240 population, quân cơ bản hỗn hợp, Preacher và pháo công thành | Quân tinh nhuệ, cải thiện hỏa lực/công sự; giữ nguồn Gold |

Các dòng trên mô tả lựa chọn dự kiến, không khẳng định phe nào mặc định thắng từng Age.

## 6. Quy tắc hệ thống để tránh diễn giải sai

### 6.1. Population và ngân sách

Với trần chuẩn P, Bundschuh có P ở Ages 1–2, floor(1,10P) ở Age 3 và floor(1,20P) ở Age 4. Sức chứa thực tế vẫn bị giới hạn bởi nhà đã dựng. Mỗi Villager và mỗi UU trong tài liệu dùng 1 population; không có bộ binh 0,5 population.

Ở P = 200 và cùng có 100 Villagers:

- League có 100 suất quân/support.
- Bundschuh Age 4 có 140 suất quân/support.
- Chênh lệch sức chứa quân là **40%**. Preachers vẫn tiêu tốn các suất này.

Vì vậy không mặc định nâng trần lên 300 hoặc thêm giảm giá toàn bộ tài nguyên. Engine và UI phải hỗ trợ đúng trần 240 thay vì có một hard cap 200 ở tầng khác.

### 6.2. Sát thương và stacking

```text
damage = max(1, base_attack_after_modifiers - matching_normal_armor)
       + sum(max(0, attack_bonus_for_class - target_bonus_armor_for_class))
```

Aura tăng base attack. Armor cận chiến thông thường không trừ vào bonus chống cavalry. SWB-02 và Fähnlein Drill có thể cùng tăng giáp Landsknecht vì là hai modifier khác ID; nhiều bản sao của cùng aura/team bonus không cộng dồn.

Nếu nhiều armor class thực sự khớp, chỉ cộng những bonus được khai báo cho từng class; không tạo hai class cavalry trùng nghĩa để giáo nhân đôi bonus. Không sử dụng “sát thương chuẩn” ngầm để sửa một matchup.

### 6.3. Thứ tự áp dụng và thay đổi chủ sở hữu

1. Chọn mẫu cơ sở theo tier đã mở của dòng quân.
2. Áp dụng nâng cấp thường đã nghiên cứu và các modifier cố định của chủ sở hữu hiện tại.
3. Áp dụng các aura hợp lệ, lấy mức mạnh nhất trong cùng nhóm aura.
4. Tính attack/reload/movement từ dữ liệu hiệu lực; không sửa trực tiếp giá trị cơ sở mỗi tick.

Nâng cấp HP giữ nguyên tỷ lệ HP hiện tại để không thành một lần hồi đầy miễn phí. Hạ aura không đổi HP vì hai aura đã thiết kế không có modifier HP.

Khi conversion, giữ tier vật thể đang có; gỡ bonus/UT của chủ cũ, áp dụng những modifier của chủ mới nếu hợp lệ. Preacher bị conversion chỉ buff quân của chủ mới. Cờ từng bị conversion loại đơn vị khỏi Salvage; không biến nó thành nguồn Gold từ việc đổi chủ rồi giết.

Giá tuyển được chốt khi đặt hàng. Tech mới không hoàn tiền cho đơn đang xếp hàng; hủy đơn trả lại đúng giá đã trả theo quy tắc refund chung. Thay đổi tốc độ tuyển/nghiên cứu giữ nguyên phần trăm công việc đã hoàn thành, áp dụng tốc độ mới cho phần còn lại.

### 6.4. Dữ liệu và tính xác định

Các đối tượng cần mô tả bằng dữ liệu: UnitArchetype, UnitTier, FactionModifier, Technology, Aura và DamageClass. Modifier có ID, age gate, target tags, phép tính và stacking group.

Unit instance giữ owner, archetype/tier, ID cố định, actual_paid_cost và ever_converted. Salvage giữ ledger theo người chơi của các khoản W/G đã trả trong 60 giây gần nhất. Cùng một đầu vào phải cho cùng một kết quả trong replay hoặc lockstep.

Quy tắc làm tròn: giá tài nguyên giảm theo phần trăm làm tròn lên khi đặt hàng; số population làm tròn xuống; phần trăm tiến độ và thưởng 0,1 tài nguyên dùng fixed-point xác định. Damage/armor có thể giữ độ chính xác 0,1 trong mô phỏng; UI hiển thị nhất quán.

Hiển thị HUD: trần population hiện tại; badge aura trên đơn vị; aura radius khi chọn Preacher; tooltip giá trước/sau giảm; thông báo W/G nhận từ Salvage và phần trần còn lại. Hình dạng/icon phải phân biệt trạng thái, không chỉ dựa vào màu.

## 7. Kế hoạch cân bằng ban đầu

### 7.1. Những gì cần đo

| Nhóm kiểm tra | Cách tổ chức | Điều cần phát hiện |
|---|---|---|
| Quân khắc chế | Hai bên cùng Age; thử không nâng cấp và có nâng cấp; ngang chi phí, ngang population và ngang thời gian sản xuất | Armor vô hiệu hóa giáo; Flailmen thành quân đa dụng; một phe thiếu phản công |
| Micro/địa hình | Trống trải, choke, đường vòng, cao độ; có/không focus fire | Kết quả chỉ cân bằng trên giấy nhưng hỏng vì collision hoặc range |
| Kinh tế | Cùng số dân, không giao chiến rồi thêm raid; đo theo từng loại tài nguyên | +10% F/W kết hợp giảm giá khiến League không thể sống tới Age 3 |
| Late game | Cùng 100 dân; thử 200 vs 240 cap rồi hoán đổi chiến thuật | Lợi thế 40% suất quân vượt quá sức mạnh từng đơn vị League |
| Gold và bản đồ | Bản đồ mở/đóng; Gold dồi dào/khan hiếm; tài nguyên ngoài thành | Bundschuh không phá nổi thành; League bị buộc chơi một kiểu duy nhất |
| Team game | 2v2 và 4v4; đội thuần và đội hỗn hợp; có trade | Aura/team bonus stack ngoài ý muốn; quân League được đồng đội bù hết điểm yếu |
| Stress và edge cases | Nhiều aura chồng nhau; 240 dân; chết đồng thời; đổi chủ; garrison | Hiệu năng, desync, nhận bounty nhiều lần hoặc buff còn sót |

Không dùng một cuộc đấu 1v1 giữa hai đơn vị để kết luận cả matchup. Cũng không coi 1G luôn ngang 1F ở mọi giai đoạn: lưu riêng tổn thất F/W/G/S, dân-giây khai thác và số giây công trình sản xuất bị chiếm dụng.

### 7.2. Mục tiêu và cách đọc kết quả

- Mục tiêu ban đầu cho matchup người chơi ngang kỹ năng: khoảng **48–52%** trên tập bản đồ chính, đồng thời kiểm tra riêng từng loại map và bracket. Đây là mục tiêu, không phải kết quả đã đo.
- Chia trận theo phiên bản build, map, trình độ và chiến lược mở đầu. Dùng hoán đổi phe, spawn và nhiều seed để tránh lợi thế người chơi/bản đồ.
- 400 trận độc lập gần mức 50% chỉ cho sai số xấp xỉ ±4,9 điểm phần trăm ở mức tin cậy 95%; không đủ để tuyên bố đã chứng minh dải 48–52%. Người chơi lặp lại còn làm các quan sát phụ thuộc nhau.
- Theo dõi chiến lược thắng, thời điểm quân chủ lực xuất hiện, thiệt hại kinh tế, lượng Salvage, tỷ lệ quân hưởng aura, tổn thất Gold và những trận không còn phương án phản công.
- Kiểm tra khả năng vận hành ở nhóm kỹ năng thấp: League cần micro bảo vệ pháo; Bundschuh cần quản lý nhiều quân. Win rate tổng có thể che khác biệt rất lớn giữa hai nhóm.

### 7.3. Thứ tự điều chỉnh

| Triệu chứng đã quan sát | Thử thay đổi đầu tiên | Chưa nên làm ngay |
|---|---|---|
| Bundschuh rush áp đảo Age 2 | Giảm BND-02 từ 15% xuống 10%, hoặc tăng tuyển Flailman 16 → 18 giây; thử riêng từng biến | Nerf mọi HP/attack của phe |
| Thắng một trận nhỏ rồi snowball quá mạnh | Giảm Salvage 10% → 7% hoặc trần 120 → 90; đo nguồn gây lợi thế trước | Xóa toàn bộ bonus kinh tế |
| Horde late game quá đông | Giảm bonus cap Age 4 từ 20% → 15% | Tăng splash mọi vũ khí, làm trận chiến khó đọc |
| Preacher thành quân bắt buộc quá mạnh | Thử radius 4 → 3,5 hoặc bỏ phần tốc độ của UT Age 4 | Thêm aura hồi máu diện rộng/giảm damage |
| League không trụ nổi đầu trận | Điều chỉnh hiệu quả quân thường, thời điểm/chi phí phòng thủ trên map | Thêm đồng thời bonus tuyển dân và bonus tài nguyên |
| Ritter vượt qua cả quân khắc chế | Kiểm tra cavalry armor class và damage bonus trước; sau đó cân giá/HP | Cho mọi bộ binh bỏ qua giáp |
| League khóa thắng bằng công sự | Kiểm tra tầm/giá pháo Bundschuh, tài nguyên ngoài thành và khả năng raid | Thêm siege chỉ có thể lấy bằng may mắn/capture |
| Khối pháo League không thể áp sát | Điều chỉnh triển khai, minimum range, độ cơ động và footprint splash | Bù thêm sức mạnh chống quân cho tất cả đơn vị Bundschuh |

Mỗi bản build thay ít biến và giữ changelog. Sau Phase 1, ưu tiên hoàn thiện baseline unit tree, Blacksmith, armor classes và cannon profiles; sau đó mới xác nhận bằng playable prototype. Các đề xuất bên trên chưa chứng minh rằng hai phe đã cân bằng.

## 8. Nguồn lịch sử

Các nguồn hỗ trợ bối cảnh và cách đặt tên; mọi bonus, giá, chỉ số và quy tắc game do bản thiết kế này đề xuất. Truy cập ngày 10/10/2026.

- **[H1]** Horst Buszello, *Joß Fritz und der Bundschuh zu Lehen 1513* (2013), Badische Landesbibliothek, metadata và abstract: https://regionalia.blb-karlsruhe.de/frontdoor/index/index/docId/17688
- **[H2]** Alois Niederstätter, *Schwäbischer Bund*, Historisches Lexikon der Schweiz: https://hls-dhs-dss.ch/de/articles/017169/2013-01-17/
- **[H3]** Regionalmuseum Bad Frankenhausen, *Armament of the Peasants*: https://www.regionalmuseum-bfh.de/armament-peasants
- **[H4]** Landesmuseum Württemberg, *UFFRUR! — Resistance in the Peasants’ War of 1524/25*, đặc biệt phần Well Armed: https://artsandculture.google.com/story/awVRj8ljJmaKiA
- **[H5]** Regionalmuseum Bad Frankenhausen, giới thiệu triển lãm *500 years of the Battle of Frankenhausen*: https://www.regionalmuseum-bfh.de/introduction
- **[H6]** German History in Documents and Images, bản dịch *The Twelve Articles of the Swabian Peasants* (1525): https://germanhistorydocs.org/en/from-the-reformations-to-the-thirty-years-war-1500-1648/ghdi:document-4323
- **[H7]** Regionalmuseum Bad Frankenhausen, *Armament of the Landsknechts*: https://www.regionalmuseum-bfh.de/armament-landsknechts
- **[H8]** Douglas Miller, *The Army of the Swabian League 1525*, bibliographic record/index preview; dùng cho định hướng nghiên cứu lực lượng, không suy ra chỉ số chiến đấu: https://books.google.com/books/about/The_Army_of_the_Swabian_League_1525.html?id=JCIzEQAAQBAJ
