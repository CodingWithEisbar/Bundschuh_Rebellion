# BUNDSCHUH: REBELLION

## Phase 2 — Tech Tree, Unit Counters & Core Building Matrix

**Phiên bản:** 0.2, 10/10/2026.  
**Kế thừa:** GDD Phase 1 v0.1, đã đối chiếu bản hiện tại.  
**Phạm vi:** cây công nghệ đầy đủ cho bộ quân/công trình trên bộ của prototype skirmish, hỗ trợ 1v1 và team game. Hải quân, campaign heroes và chế độ thắng Wonder nằm ngoài phạm vi bộ quân này.  
**Trạng thái:** thiết kế dự kiến; đã kiểm tra phép tính damage và một số giao chiến trong mô hình tĩnh. Chưa có playable prototype hay dữ liệu win rate.

## 1. Những quy ước được chốt

Các chỉ số là thiết kế cho Bundschuh: Rebellion, không phải bản sao bảng cân bằng của một phiên bản AoE II. Bốn Ages biểu thị mức huy động trong trận, không phải thời điểm lịch sử phát minh vũ khí.

- **A1:** Serfdom; **A2:** Conspiracy; **A3:** Insurrection; **A4:** Reformation.
- **F/W/G/S:** Food/Wood/Gold/Stone. **M/P:** melee/pierce. Chu kỳ đòn và thời gian tuyển tính bằng giây mô phỏng; tốc độ và tầm tính bằng ô bản đồ.
- Chỉ số trong bảng quân là **cơ sở**, chưa cộng bonus phe, Blacksmith, UT, Bloodlines, Sanctity hoặc aura. Bảng chỉ số hiệu lực được ghi riêng.
- **Trash unit** trong thiết kế này nghĩa là không tốn Gold khi tuyển. Giáo, skirmisher, scout/light cavalry và Flailman thuộc nhóm này. Swordsmen dùng Gold; “quân phổ thông” không đồng nghĩa “trash”. Nâng cấp một dòng trash vẫn có thể tốn Gold.
- Mọi đơn vị trên bộ, bao gồm dân, support, trade cart, ram và cannon, dùng **1 population**. Công trình không dùng population. Không có bộ binh 0,5 population.
- Lên đời chỉ mở quyền nghiên cứu/tuyển. Những tier có hàng nghiên cứu riêng phải trả tiền nâng cấp; không tự nhận Elite khi lên A4.
- Nâng cấp dòng quân đổi tất cả đơn vị cùng dòng đang sở hữu và mẫu tuyển mới. Heavy Cannon là ngoại lệ được ghi rõ: **một nền tảng riêng được mở khóa**, không tự đổi Field Cannon thành Heavy Cannon.
- Nghiên cứu và tuyển quân dùng cùng một hàng đợi tại công trình đó. Nghiên cứu là toàn người chơi, không mua lại ở mỗi nhà.
- Không có upkeep, mana hay tài nguyên thứ năm. Conversion dùng thời gian hồi kỹ năng; zeal dùng aura như Phase 1.

Phần lớn quân phổ thông có tổng giá 70–150 tài nguyên. Các ngoại lệ có chủ ý là counter rẻ (giáo/skirm), Flailman giá thấp từ Phase 1, Ritter 190 và siege 235–550. HP dưới 45 của một số quân tầm xa/support giữ vai trò mong manh; không ép mọi loại quân vào cùng một khoảng giá hoặc HP.

### 1.1. Hợp đồng tương thích với Phase 1

| Thành phần | Quyết định Phase 2 |
|---|---|
| Bốn bonus Bundschuh | Giữ +10% thu F/W; -15% phần F của militia/spear/Flail từ A2; Salvage 10% W/G với trần 120/60 giây; cap 220/240 ở A3/A4 khi P=200. |
| Bốn bonus League | Giữ +3 sức chứa dân từ A3; +1 melee armor bộ binh/kỵ binh cận chiến từ A3; reload súng/pháo ×0,90 từ A3; +20% HP công sự thuộc danh sách từ A2. |
| UU | Giữ nguyên chỉ số cơ sở, giá, thời gian tuyển, Elite upgrades và năng lực của bốn UU. |
| UT | Giữ cả bốn UT và chi phí/thời gian từ Phase 1. |
| Team bonuses | Bundschuh: +1 LOS melee infantry từ A2. League: thời gian nghiên cứu Blacksmith ×0,85 từ A2. Mỗi loại chỉ áp dụng một lần cho cả đội. |
| Khả năng công thành Bundschuh | Field Cannon tuyển bình thường từ A3; không phụ thuộc bắt pháo của địch. Tầm tối đa ít nhất hơn công sự League 1 ô. |
| Những gì Phase 2 bổ sung | Cây quân phổ thông, Bloodlines/Sanctity và các nâng cấp khác, bảng công trình, giá nghiên cứu, armor classes và cách tính chỉ số hiệu lực. |

Ví dụ Elite Ritter **150 HP cơ sở** của Phase 1 trở thành **170 HP khi có Bloodlines**. Đây là phân biệt base/effective, không phải sửa ngầm chỉ số UU.

Salvage tiếp tục giữ điều kiện của Phase 1: quân sự cùng chủ gây đòn kết liễu; có melee infantry cùng chủ sống trong bán kính 3 ô; chỉ quân địch có chi phí tuyển hợp lệ; không dân/nhà/tự xóa/đồng minh/quân miễn phí/quân từng conversion; mỗi unit ID xét một lần; thưởng dựa trên actual paid cost khi tuyển, không cộng chi phí nâng cấp.

### 1.2. Điều kiện khởi đầu và lên đời

Thiết lập land skirmish chuẩn: mỗi bên 1 Town Center, 3 Villagers, 1 Scout Cavalry khởi đầu; kho 200F/200W/100G/200S; trần chuẩn 200. Scout khởi đầu cùng chỉ số của Scout Cavalry nhưng không tuyển bổ sung trước A2; không tạo Salvage vì được cấp miễn phí.

| Tiến lên | Giá | Thời gian tại Town Center | Điều kiện công trình đã hoàn thành |
|---|---|---|---|
| A2 — Conspiracy | 500F | 130 giây | Hai loại khác nhau trong Mill, Lumber Camp, Mining Camp, Barracks |
| A3 — Insurrection | 800F + 200G | 160 giây | Hai loại khác nhau trong Archery Range, Stable, Blacksmith, Market |
| A4 — Reformation | 1000F + 800G | 190 giây | Hai loại khác nhau trong Church, Siege Workshop, Arsenal, Castle-equivalent |

Không tính nhiều bản sao cùng loại để đạt điều kiện. Age-up chiếm hàng đợi TC, nên cạnh tranh với tuyển dân. Hai phe dùng cùng giá và điều kiện; không giảm giá age-up bằng Village Levies. Với custom population cap P, Bundschuh dùng P/P/floor(1,10P)/floor(1,20P).

## 2. Cây quân Bundschuh

Trong các ma trận, **giữ** nghĩa là vẫn tuyển được tier cao nhất đã nghiên cứu ở đời trước. Đơn vị bị thay thế trong cùng dòng không còn nút tuyển riêng; các dòng khác nhau cùng tồn tại.

| Công trình / dòng | A1 | A2 | A3 | A4 |
|---|---|---|---|---|
| Barracks — kiếm sĩ | Militia | Man-at-Arms | Longswordsman | Giữ Longswordsman; không Professional Swordsman |
| Barracks — giáo | — | Spearman | Pikeman | **Halberdier** |
| Barracks — UU | — | **Peasant Flailman** | Giữ Flailman | **Elite Flailman** |
| Archery Range — cung/nỏ | — | Bowman | Crossbowman | Giữ Crossbowman; không Arbalester |
| Archery Range — khắc chế tầm xa | — | Skirmisher | Elite Skirmisher | Giữ Elite Skirmisher |
| Archery Range — hỏa khí | — | — | Arquebusier, cần Powder Craft | Giữ Arquebusier; không Elite |
| Stable — cavalry nhẹ | Scout cấp đầu trận, không tuyển | Scout Cavalry | Light Cavalry | Giữ Light Cavalry |
| Stable — cavalry nặng | — | — | **Không có** | **Không có** |
| Siege Workshop — ram | — | — | Covered Ram | Reinforced Ram |
| Siege Workshop — pháo | — | — | Field Cannon, cần Powder Craft | Giữ Field Cannon; không Heavy Cannon |
| Church | — | — | **Radical Preacher** | Giữ Preacher, có UT aura A4 |
| Market | — | Trade Cart | Trade Cart + Caravan | Trade Cart + Guilds |

**Bundschuh không có:** Knight/Ritter, Hussar, Cavalry Archer, Elephant, Camel, Mangonel/Onager, Trebuchet, Siege Ram, Heavy Cannon và pháo cơ động bọc giáp bắn khi chạy.

Stable đóng vai trò trinh sát, raid và đánh vào artillery/support bị lộ. Nó không phải con đường thay thế bộ binh làm quân chủ lực. Light Cavalry không được Bloodlines, Husbandry hoặc Plate Barding Armor.

## 3. Cây quân Swabian League

| Công trình / dòng | A1 | A2 | A3 | A4 |
|---|---|---|---|---|
| Barracks — kiếm sĩ | Militia | Man-at-Arms | Longswordsman | **Professional Swordsman**, Champion-equivalent |
| Barracks — giáo thường | — | Spearman | Pikeman | Giữ Pikeman; **không Halberdier** |
| Barracks — UU | — | — | **Landsknecht Pikeman** | **Elite Landsknecht** |
| Archery Range — cung/nỏ | — | Bowman | Crossbowman | **Arbalester** |
| Archery Range — khắc chế tầm xa | — | Skirmisher | Elite Skirmisher | Giữ Elite Skirmisher |
| Archery Range — hỏa khí | — | — | Arquebusier, cần Powder Craft | **Elite Arquebusier** |
| Stable — cavalry nhẹ | Scout cấp đầu trận, không tuyển | Scout Cavalry | Light Cavalry | Giữ Light Cavalry; không Hussar |
| Stable — UU cavalry nặng | — | — | **Armoured Ritter** | **Elite Ritter** |
| Siege Workshop — ram | — | — | Covered Ram | Reinforced Ram |
| Siege Workshop — pháo | — | — | Field Cannon, cần Powder Craft | Giữ Field Cannon; mở **Heavy Cannon** riêng |
| Church | — | — | Cleric | Cleric + Hospital Practice |
| Market | — | Trade Cart | Trade Cart + Caravan | Trade Cart + Guilds |

Ritter thay nhánh Knight; không nâng Scout thành Ritter. Landsknecht là dòng quân riêng đứng cạnh Pikeman thường: khi thiếu Gold, League vẫn có giáo phòng thủ nhưng phải trả Gold để có tuyến giáo tốt nhất.

Professional Swordsman là tier cuối của dòng kiếm sĩ thông thường, không phải UU thứ ba. League cần lựa chọn này để chống bộ binh đông mà không buộc mọi trận đều đi Ritter.

Hai phe dùng Cannon thay vai trò pháo công thành và sát thương diện rộng của các nhánh Mangonel/Trebuchet trong bộ quân này. Đây là lựa chọn về roster và bối cảnh, không phải khẳng định những loại máy bắn đá đã biến mất hoàn toàn vào năm 1525.

### 3.1. Wagenburg được thể hiện thế nào?

Wagenburg là **bố trí phòng thủ tĩnh**: palisade/gate mang hình xe và rào ghép, bộ binh giữ lối vào, súng/pháo đặt bên trong. Trong bản core, đó là cách bố trí và art variant của các cấu kiện có sẵn, không có một quân War Wagon thứ ba, aura giảm damage hay khả năng vừa di chuyển vừa bắn. Chi phí là tổng các cấu kiện thực xây; không có nút tạo miễn phí cả doanh trại.

Tư liệu của Regionalmuseum Bad Frankenhausen mô tả quân nổi dậy sử dụng wagon fortress và có pháo tại Frankenhausen. Phần hình ảnh/phòng thủ này có cơ sở lịch sử; các thống kê trận đánh không được dùng để suy ra chỉ số game. [H1]

## 4. Bảng chỉ số quân phổ thông

**Mọi giá trong phần này là giá chuẩn trước bonus.** Bundschuh từ A2: Militia-line 60F+20G thành **51F+20G**; spear-line 35F+25W thành **30F+25W**. Giá nghiên cứu không được giảm. Tầm melee 0,5 là tầm vũ khí ngoài bán kính va chạm quy ước của engine.

### 4.1. Barracks

| Quân | Age | Giá | HP | Attack M | Armor M/P | Bonus damage | Tốc độ | Chu kỳ đòn | Tuyển |
|---|---|---|---:|---:|---|---|---:|---:|---:|
| Militia | 1 | 60F 20G | 45 | 4 | 0/0 | — | 0,90 | 2,0 | 21 |
| Man-at-Arms | 2 | 60F 20G | 50 | 6 | 1/0 | +1 Infantry | 0,90 | 2,0 | 21 |
| Longswordsman | 3 | 60F 20G | 60 | 9 | 1/1 | +2 Infantry | 0,90 | 2,0 | 21 |
| Professional Swordsman | 4, League | 60F 20G | 80 | 13 | 1/1 | +3 Infantry | 0,90 | 2,0 | 21 |
| Spearman | 2 | 35F 25W | 45 | 3 | 0/0 | +15 Cavalry | 1,00 | 3,0 | 22 |
| Pikeman | 3 | 35F 25W | 55 | 4 | 0/0 | +22 Cavalry | 1,00 | 3,0 | 22 |
| Halberdier | 4, Bundschuh | 35F 25W | 60 | 6 | 0/0 | +32 Cavalry | 1,00 | 3,0 | 22 |

Tất cả quân bảng này có tầm melee 0,5. Infantry armor class chỉ gồm bộ binh cận chiến; không gán nhầm cho Arquebusier vì tên gọi đời thực “bộ binh súng”.

Longswordsman Bundschuh dù dừng ở tier A3 vẫn nhận Blast Furnace và aura A4. Nó là lựa chọn Gold để đánh bộ binh, có thêm giáp cơ sở so với Flailman; Flailman rẻ hơn, nhanh hơn và chuyên chống dòng giáo.

### 4.2. Archery Range

| Quân | Age | Giá | HP | Attack P | Armor M/P | Range min–max | Bonus | Tốc độ | Chu kỳ | Tuyển |
|---|---|---|---:|---:|---|---|---|---:|---:|---:|
| Bowman | 2 | 25W 45G | 40 | 4 | 0/0 | 0–4 | — | 0,96 | 2,0 | 35 |
| Crossbowman | 3 | 25W 45G | 45 | 5 | 0/0 | 0–5 | — | 0,96 | 2,0 | 27 |
| Arbalester | 4, League | 25W 45G | 50 | 6 | 0/0 | 0–5 | — | 0,96 | 1,8 | 27 |
| Skirmisher | 2 | 25F 35W | 35 | 2 | 0/3 | 1–4 | +3 Archer; +2 Spear | 0,96 | 3,0 | 22 |
| Elite Skirmisher | 3 | 25F 35W | 45 | 3 | 0/4 | 1–5 | +6 Archer; +3 Spear | 0,96 | 3,0 | 22 |
| Arquebusier | 3 | 45F 55G | 45 | 16 | 0/0 | 0–6 | +6 Infantry | 0,85 | 3,5 | 34 |
| Elite Arquebusier | 4, League | 45F 55G | 55 | 18 | 1/0 | 0–7 | +8 Infantry | 0,85 | 3,5 | 34 |

Gunpowder không có “true damage” hay bỏ qua pierce armor. Base damage cao khiến súng hữu ích trước giáp; bonus Infantry giúp chống bộ binh đông. Cavalry vẫn áp sát được và không chịu bonus Infantry.

Arquebusiers mang armor class **Archer** để Skirmisher có đường phản công. Mỗi class chỉ được tính một lần; không đồng thời thêm một bonus Gunpowder khác vào cùng đòn Skirmisher.

**Upgrade interaction:** Fletching/Bodkin/Bracer áp dụng cung, nỏ, skirmishers; không tăng attack/range của súng, pháo hoặc công trình. Ranged armor áp dụng cả ba dòng. Chemistry tăng +1 attack cho súng/pháo; không cộng +1 vào bonus Infantry.

### 4.3. Stable

| Quân | Age | Giá | HP | Attack M | Armor M/P | Bonus | Tốc độ | Chu kỳ | Tuyển |
|---|---|---|---:|---:|---|---|---:|---:|---:|
| Scout Cavalry | 2 để tuyển | 80F | 45 | 3 | 0/2 | +6 Clergy | 1,50 | 2,0 | 30 |
| Light Cavalry | 3 | 80F | 80 | 7 | 0/2 | +8 Clergy | 1,50 | 2,0 | 30 |

Tầm 0,5. Bloodlines thêm 20 HP và Husbandry thêm 10% tốc độ cho cavalry League. Bundschuh không có hai tech này. Light Cavalry Bundschuh vẫn nhanh hơn bộ binh và đủ vai trò raid; không bị giới hạn số lượng bằng luật tùy tiện.

### 4.4. Siege Workshop

| Quân | Age | Giá | HP | Attack M | Armor M/P | Range | Bonus Building | Tốc độ | Chu kỳ | Tuyển |
|---|---|---|---:|---:|---|---|---:|---:|---:|---:|
| Covered Ram | 3 | 160W 75G | 175 | 2 | 3/100 | 0,5 | +125 | 0,50 | 5,0 | 45 |
| Reinforced Ram | 4 | 160W 75G | 225 | 2 | 4/100 | 0,5 | +175 | 0,55 | 5,0 | 45 |
| Field Cannon | 3 | 200W 200G | 80 | 30 | 2/6 | 2–10 | +120 | 0,60 | 8,0 | 50 |
| Heavy Cannon | 4, League | 250W 300G | 100 | 45 | 2/8 | 2–10 | +180 | 0,50 | 9,0 | 65 |

- Rams không splash, không bắn, không garrison quân trong core build. Giáp xuyên cao giúp chống tên; melee và cannon dùng damage M đánh chúng hiệu quả.
- Cannon: triển khai **3 giây**, thu pháo **3 giây**; đứng yên mới bắn; range tối thiểu 2. Giai đoạn triển khai/thu pháo vẫn bị tấn công.
- Field Cannon có splash radius **0,80 ô**; Heavy Cannon **1,10 ô**. Đây là đại diện gameplay cho vùng tác động/đạn xuyên và mảnh vỡ, không khẳng định mọi khẩu pháo thời đó dùng đạn nổ hiện đại.
- Direct target nhận full base attack và bonus hợp lệ. Splash lên đơn vị khác dùng base attack giảm tuyến tính theo khoảng cách tâm: hệ số max(0, 1−d/radius); không mang bonus Building từ mục tiêu chính sang quân bên cạnh. Ngoài radius không nhận damage.
- Splash lên quân cùng đội gây **50% damage sau phép tính giáp**, có thể giết quân mình nhưng không cho Salvage. Không tự gây damage lên nguồn bắn. Công trình cùng đội không nhận splash trong core build.
- Pháo dùng melee armor channel cho damage cơ sở; không được ngầm dùng pierce channel chỉ vì có projectile. Siege Workshop không nhận Blacksmith attack hoặc armor.
- Heavy Foundry mở dòng Heavy Cannon riêng; Field Cannon vẫn tuyển được. Giá khác nhau nên không cho nâng hàng loạt Field Cannon rẻ thành Heavy Cannon miễn phí.

**Tầm tối đa A4:** Field Cannon Bundschuh = **10**. League sau Siege Engineers và League Ordnance: Field/Heavy Cannon = **12**. Tower/Castle League tối đa **9**. Bundschuh vẫn có cách công thành, nhưng bất lợi trong đấu pháo trực diện với League đầy đủ nâng cấp.

### 4.5. Hỗ trợ và kinh tế

| Quân | Công trình / Age | Giá / tuyển | HP, armor, tốc độ | Chức năng |
|---|---|---|---|---|
| Villager | TC / A1 | 50F / 25 giây | 25 HP, 0/0, 0,80 | Thu tài nguyên, xây/sửa; attack 3 M, tầm 0,5, chu kỳ 2,0; carry cơ sở 10 |
| Trade Cart | Market / A2 | 100W 50G / 45 giây | 100 HP, 0/0, 1,00 | Trade giữa Market của hai chủ khác nhau cùng đội; không attack |
| Cleric | Church League / A3 | 100G / 40 giây | 35 HP, 0/0, 0,85 | Heal 3 HP/giây ở range 4; mang relic; conversion |

Cleric conversion: range 7, cần channel liên tục 10 giây lên một đơn vị sinh học đối phương nhìn thấy được; không nhắm siege/công trình. Mất tầm, mất LOS, di chuyển, bị hủy lệnh hoặc mất mục tiêu thì reset tiến độ. Không có conversion tức thì hoặc cộng dồn nhiều Clerics vào cùng tiến độ. Sau conversion thành công cooldown 30 giây; không có thanh mana. Faith của mục tiêu tăng thời gian cần channel thành 15 giây. Heal và conversion loại trừ lẫn nhau.

Các con số income theo khoảng cách trade và bản đồ là tham số kinh tế chung, không phải bonus phe; không dùng trade ở 1v1. Relic có income cố định chung cho hai phe, không hưởng +10% F/W hoặc carry bonus. UI kinh tế tách Gold từ mine/trade/relic/Salvage để cân bằng đúng nguồn.

## 5. Stat blocks cho các UU

### 5.1. Chỉ số cơ sở: giữ nguyên Phase 1

| UU / tier | Age | Giá cơ sở | HP | Attack | Armor M/P | Speed | Range | Chu kỳ | Tuyển |
|---|---|---|---:|---|---|---:|---:|---:|---:|
| Peasant Flailman | 2 | 45F 15W | 45 | 7 M | 0/0 | 1,10 | 0,5 | 2,0 | 16 |
| Elite Flailman | 4 | 45F 15W | 60 | 9 M | 0/0 | 1,10 | 0,5 | 2,0 | 16 |
| Radical Preacher | 3 | 100G | 35 | Không attack | 0/0 | 0,85 | Heal 4 | — | 40 |
| Landsknecht Pikeman | 3 | 55F 35G | 65 | 6 M | 1/0 | 0,90 | 1 | 2,0 | 26 |
| Elite Landsknecht | 4 | 55F 35G | 80 | 7 M | 1/0 | 0,90 | 1 | 2,0 | 26 |
| Armoured Ritter | 3 | 90F 100G | 125 | 12 M | 2/2 | 1,30 | 0,5 | 1,8 | 38 |
| Elite Ritter | 4 | 90F 100G | 150 | 14 M | 2/3 | 1,30 | 0,5 | 1,8 | 38 |

**Flailman:** +4 Spear, Elite +5; không splash, không xuyên giáp, không bonus Cavalry. Giá thực trả **39F+15W**. Haufen Organization giảm tuyển từ 16 còn **12 giây**, không giảm thêm giá.

**Preacher:** heal 3 HP/giây một đơn vị sinh học cùng đội ở range 4, đứng yên khi heal; mang relic; không conversion. Aura radius 4: melee infantry cùng chủ +1 base melee attack; sau Revolutionary Sermons đổi thành +2 và speed ×1,10. Không buff đồng minh khác chủ, dân, cavalry, ranged, siege. Nhiều aura không cộng dồn; tắt khi garrison/chết/được vận chuyển. Aura hoạt động khi di chuyển hoặc heal; không tăng bonus damage. Ra khỏi vùng mất hiệu ứng ngay. Aura chỉ xét khoảng cách, không cấp vision xuyên fog hoặc tường.

**Landsknecht:** +24 Cavalry, Elite +28; range 1 để hỗ trợ đội hình sâu nhưng mỗi đòn một mục tiêu. Nhận giáp phe +1 M và Fähnlein Drill +10 HP/+1 M; không có cơ chế khối giáo miễn damage.

**Ritter:** mạnh nhờ HP/armor/speed; không splash charge, armor piercing hay miễn bonus chống cavalry. Bloodlines cộng 20 HP; Husbandry ×1,10 speed.

### 5.2. Ví dụ chỉ số hiệu lực để triển khai không cộng nhầm

Các hàng dưới đã có toàn bộ nâng cấp áp dụng được ở Age tương ứng; aura được ghi riêng.

| Quân | Age | HP | Base attack sau tech | Armor M/P | Speed | Bonus vẫn tách riêng |
|---|---|---:|---:|---|---|---|
| Flailman Bundschuh | 3 | 45 | 9; 10 trong aura | 2/2 | 1,10 | +4 Spear |
| Elite Flailman Bundschuh | 4 | 60 | 13; **15 trong aura A4** | 2/2 | 1,10; **1,21 trong aura** | +5 Spear |
| Preacher có Sanctity/Fervor | 3–4 | **50** | Không attack | 0/0 | **0,9775** | Aura; heal vẫn 3 HP/giây |
| Landsknecht có Drill | 3 | **75** | 8 | **5/2** | 0,99 | +24 Cavalry |
| Elite Landsknecht có Drill | 4 | **90** | 11 | **6/4** | 0,99 | +28 Cavalry |
| Ritter có Bloodlines | 3 | **145** | 14 | **5/4** | 1,43 | — |
| Elite Ritter có Bloodlines | 4 | **170** | 18 | **6/7** | 1,43 | — |

Squires bị khóa với Bundschuh, nên không nhân thêm một bonus tốc độ bộ binh vào aura. Sanctity không khiến Preacher nhận giáp Blacksmith; mọi attack/armor ở đây dùng đúng nhóm đơn vị.

## 6. Danh mục nâng cấp dòng quân và UT

Nếu có chuỗi, phải nghiên cứu tier trước. Một dòng bị khóa ở một phe không thể nghiên cứu bằng việc xây thêm bản sao công trình. Các thời gian bảng này không chịu team bonus Blacksmith vì nghiên cứu tại nhà quân/Church/Castle.

| Nghiên cứu | Age / nơi | Giá | Giây | Bundschuh | League |
|---|---|---|---:|---|---|
| Man-at-Arms | 2 / Barracks | 100F 50G | 40 | Có | Có |
| Longswordsman | 3 / Barracks | 250F 100G | 50 | Có | Có |
| Professional Swordsman | 4 / Barracks | 500F 300G | 65 | Không | Có |
| Pikeman | 3 / Barracks | 200F 100G | 45 | Có | Có |
| Halberdier | 4 / Barracks | 450F 300G | 60 | Có | Không |
| Elite Flailman | 4 / Barracks | 400F 200G | 50 | Có | Không |
| Elite Landsknecht | 4 / Barracks | 500F 300G | 60 | Không | Có |
| Crossbowman | 3 / Range | 175F 125G | 45 | Có | Có |
| Arbalester | 4 / Range | 400F 350G | 65 | Không | Có |
| Elite Skirmisher | 3 / Range | 200W 100G | 45 | Có | Có |
| Elite Arquebusier | 4 / Range | 600F 400G | 70 | Không | Có |
| Light Cavalry | 3 / Stable | 150F 50G | 45 | Có | Có |
| Elite Ritter | 4 / Stable | 700F 500G | 70 | Không | Có |
| Reinforced Ram | 4 / Siege Workshop | 500F 250W | 60 | Có | Có |
| Heavy Foundry: mở Heavy Cannon | 4 / Siege Workshop; cần Powder Craft | 700W 600G | 80 | Không | Có; không đổi Field Cannon cũ |
| **Haufen Organization** | 3 / Stronghold | **250F 150G** | **45** | Tuyển militia/spear/Flail time ×0,75 | Không |
| **Revolutionary Sermons** | 4 / Stronghold | **500F 350G** | **75** | Aura +1 đổi thành +2 attack và +10% speed | Không |
| **Fähnlein Drill** | 3 / Castle | **400F 300G** | **60** | Không | Landsknecht +10 HP, +1 M armor |
| **League Ordnance** | 4 / Castle | **600W 500G** | **80** | Không | Cannons +1 max range, +25% bonus Building |

Hai UT của cùng phe độc lập ngoài điều kiện Age/công trình; không cần mua UT A3 để nghiên cứu UT A4. Elite Landsknecht/Ritter cũng không yêu cầu mua UT A3.

## 7. Blacksmith: toàn bộ các nhánh trong core build

Giá và thời gian dưới đây là chuẩn. League và đồng minh của League nhân thời gian **×0,85**, không giảm giá. Mỗi nhánh cần mua tier trước; effect là phần tăng thêm của riêng tier đó.

| Tech | Age | Giá | Giây | Hiệu ứng | BND | SWB |
|---|---|---|---:|---|---|---|
| Forging | 2 | 150F | 50 | +1 base attack melee infantry/cavalry | Có | Có |
| Iron Casting | 3 | 200F 100G | 60 | +1 base attack cùng nhóm | Có | Có |
| Blast Furnace | 4 | 275F 225G | 75 | +2 base attack cùng nhóm | Có | Có |
| Scale Mail | 2 | 100F | 45 | Infantry +1 M/+1 P armor | Có | Có |
| Chain Mail | 3 | 200F 100G | 55 | Infantry +1 M/+1 P | Có | Có |
| Plate Mail | 4 | 300F 150G | 70 | Infantry +1 M/+2 P | **Không** | Có |
| Scale Barding | 2 | 150F | 45 | Cavalry +1 M/+1 P | Có | Có |
| Chain Barding | 3 | 250F 100G | 60 | Cavalry +1 M/+1 P | Có | Có |
| Plate Barding | 4 | 350F 200G | 70 | Cavalry +1 M/+2 P | **Không** | Có |
| Fletching | 2 | 100F 50G | 45 | Bow/crossbow/skirm +1 attack/+1 range | Có | Có |
| Bodkin Arrow | 3 | 200F 100G | 55 | Cùng nhóm +1 attack/+1 range | Có | Có |
| Bracer | 4 | 300F 200G | 70 | Cùng nhóm +1 attack/+1 range | **Không** | Có |
| Padded Archer Armor | 2 | 100F | 45 | Foot ranged, gồm súng: +1 M/+1 P | Có | Có |
| Leather Archer Armor | 3 | 150F 100G | 55 | Cùng nhóm +1 M/+1 P | Có | Có |
| Ring Archer Armor | 4 | 250F 150G | 70 | Cùng nhóm +1 M/+2 P | **Không** | Có |

Tổng attack melee từ ba tier là **+4**, không phải +3. Tổng armor từ ba tier là **+3 M/+4 P**. Bundschuh dừng armor ở **+2/+2**, nhưng có toàn bộ nhánh melee attack.

## 8. Công nghệ quân sự, công trình và tôn giáo khác

Arsenal là công trình chức năng University trong bối cảnh game. Các tech dưới đây có giá chuẩn cho hai phe, trừ availability; không tự cộng phụ phí kinh tế cho League.

| Tech | Age / nơi | Giá / giây | Hiệu ứng | BND | SWB |
|---|---|---|---|---|---|
| Powder Craft | 3 / Arsenal | 200F 200G / 75 | Mở Arquebusier tại Range và Field Cannon tại Workshop | Có | Có |
| Chemistry | 4 / Arsenal; cần Powder Craft | 300F 200G / 70 | +1 base attack súng bộ binh/cannon; không tăng bonus damage | Có | Có |
| Ballistics | 3 / Arsenal | 300W 150G / 60 | Dự đoán hướng chuyển động khi bắn của bow/crossbow/skirm và công trình bắn tên | Có | Có |
| Siege Engineers | 4 / Arsenal | 700F 500W / 80 | Cannons +1 max range; ram/cannons +20% bonus Building | **Không** | Có |
| Squires | 3 / Barracks | 100F 100G / 50 | Melee infantry speed ×1,10 | **Không** | Có |
| Bloodlines | 3 / Stable | 150F 100G / 50 | Cavalry +20 max HP | **Không** | Có |
| Husbandry | 3 / Stable | 150F / 40 | Cavalry speed ×1,10 | **Không** | Có |
| Masonry | 3 / Arsenal | 150F 150W / 50 | Non-farm buildings +10% base HP, +1 M/+1 P armor | Có | Có |
| Architecture | 4 / Arsenal; cần Masonry | 300F 250W / 70 | Non-farm buildings thêm +10% base HP, +1 M/+1 P | **Không** | Có |
| Guard Tower | 3 / Arsenal | 200F 100W / 60 | Watch Tower chuyển thành Guard Tower | Có | Có |
| Keep | 4 / Arsenal; cần Guard Tower | 400F 300W / 80 | Guard Tower chuyển thành Keep | **Không** | Có |
| Fortified Walls | 4 / Arsenal | 300F 200W / 60 | Stone Wall/Gate sang tier fortified | **Không** | Có |
| Arrow Slits | 4 / Arsenal | 250F 250W 100G / 60 | Towers/Castles +1 max range; không áp dụng TC | **Không** | Có |
| Murder Holes | 3 / Arsenal | 200F 100S / 60 | Xóa minimum range 1 của towers/castles; không ảnh hưởng cannon | Có | Có |
| Sanctity | 3 / Church | 120G / 50 | Preacher/Cleric +15 max HP | Có | Có |
| Fervor | 3 / Church | 140G / 50 | Preacher/Cleric speed ×1,15 | Có | Có |
| Faith | 4 / Church | 750F 500G / 80 | Quân sinh học chịu conversion cần channel lâu hơn 50% | Có | Có |
| Hospital Practice | 4 / Church | 250F 200G / 60 | Cleric heal 3 → 4 HP/giây một mục tiêu | **Không** | Có |

**Không có trong core tree của cả hai:** Conscription, Supplies, Gambesons, Thumb Ring, Parthian Tactics, Redemption, Block Printing, Bombard Tower. Việc liệt kê này khóa rõ phạm vi; không được mặc định nhập các tech AoE II khác vì tên game lấy cảm hứng từ AoE II.

League thiếu Conscription: Ritter vẫn tuyển 38 giây, Landsknecht 26 giây; bonus reload không làm tăng tốc độ tuyển. Bundschuh cũng không có Conscription để tránh cộng với Haufen thành một bonus thứ hai ngoài Phase 1.

**Quy tắc cộng:** bonus Building của Siege Engineers và League Ordnance cùng một nhóm, cộng tỷ lệ trên bonus gốc: B = B0 × (1 + 0,20 + 0,25). Không nhân liên tiếp thành 1,50B0. HP công trình cộng tỷ lệ trên base HP: League Castle với Masonry và Architecture = base × (1 + 0,20 + 0,10 + 0,10).

## 9. Cây nâng cấp kinh tế

Không có dân đắt hơn hoặc chậm hơn ở League. Bất đối xứng đến từ bonus thu F/W sớm của Bundschuh, đầu tư Gold/Stone của League, và một số tech bị khóa.

| Tech | Age / nơi | Giá / giây | Hiệu ứng | BND | SWB |
|---|---|---|---|---|---|
| Loom | 1 / TC | 50G / 25 | Villagers +15 HP, +1 M/+2 P armor | Có | Có |
| Town Watch | 2 / TC | 75F / 25 | Buildings +3 LOS, không thêm range | Có | Có |
| Town Patrol | 3 / TC; cần Town Watch | 200F 100G / 40 | Buildings thêm +4 LOS | Có | Có |
| Wheelbarrow | 2 / TC | 175F 50W / 75 | Villager speed +10%; carry +25% base | Có | Có |
| Hand Cart | 3 / TC; cần Wheelbarrow | 300F 200W / 100 | Thay mức trên thành speed +20%, carry +75% base | Có | Có |
| Double-Bit Axe | 2 / Lumber Camp | 100F 50W / 40 | Wood gather +15% base | Có | Có |
| Bow Saw | 3 / Lumber Camp; cần Axe | 150F 100W / 60 | Wood gather thêm +15% base | Có | Có |
| Two-Man Saw | 4 / Lumber Camp; cần Bow Saw | 300F 200W / 60 | Wood gather thêm +10% base | Có | **Không** |
| Horse Collar | 2 / Mill | 75F 75W / 20 | Farm capacity +75F | Có | Có |
| Heavy Plow | 3 / Mill; cần Collar | 125F 125W / 40 | Farm capacity thêm +125F | Có | Có |
| Crop Rotation | 4 / Mill; cần Plow | 250F 250W / 70 | Farm capacity thêm +175F | Có | Có |
| Gold Mining | 2 / Mining Camp | 100F 75W / 50 | Gold gather +15% base | Có | Có |
| Gold Shaft Mining | 3 / Mining Camp; cần Gold Mining | 200F 150W / 75 | Gold gather thêm +15% base | Có | Có |
| Stone Mining | 2 / Mining Camp | 75F 75W / 45 | Stone gather +15% base | Có | Có |
| Stone Shaft Mining | 3 / Mining Camp; cần Stone Mining | 150F 100W / 60 | Stone gather thêm +15% base | **Không** | Có |
| Caravan | 3 / Market | 200F 200G / 50 | Trade Cart speed ×1,50 | Có | Có |
| Guilds | 4 / Market | 300F 200G / 60 | Market exchange fee 30% → 15%; không buff Gold từ trade route | Có | Có |

**Cách tính:** các gather tech của cùng tài nguyên cộng vào base; bonus phe nhân một lần sau đó. Wood Bundschuh đầy đủ tech: base × (1 + 0,15 + 0,15 + 0,10) × 1,10 = **1,54 base**. League: **1,30 base** trước tác động đi lại/carry. Đây là tốc độ làm việc, không phải tổng thu nhập đo trên map.

Villager carry = floor(10 × hệ số Wheelbarrow/Hand Cart) + bonus cố định của phe. Hand Cart: Bundschuh floor(17,5) = **17**; League **20**. League +3 không bị nhân thêm với Hand Cart. Tốc độ dân: base 0,80 × 1,20 = 0,96 khi có Hand Cart.

Farm capacity gốc 175F; đầy đủ ba tech thành **550F**. Farm tech chỉ áp dụng cho ruộng xây/tái gieo sau nghiên cứu, không bơm thêm tài nguyên tức thì vào ruộng đang thu hoạch. Không thêm Farm gather-rate tech ngoài bonus +10% F của Bundschuh.

Quy tắc carry/gather tránh nhầm +3 sức chứa thành +30% năng suất hoặc +10% thu thập thành +10% tài nguyên trong ruộng. Gold của League không tự sinh từ “thuế điền trang”.

## 10. Core building matrix

Giá và thời gian dựng chuẩn dùng cho cả hai. Thời gian là một Villager làm việc liên tục; chưa tính đi lại, cản đường hoặc nhiều dân xây. Nhà khởi đầu được cấp sẵn không trả lại tài nguyên khi xóa.

| Công trình | Age | Giá | Giây | Điều kiện | Chức năng / khác biệt phe |
|---|---|---|---:|---|---|
| Town Center | 1; xây thêm từ 3 | 275W 100S | 150 | Age 3 cho TC mới ngoài TC đầu | Dân, age-up, Loom, carry/vision tech; +5 sức chứa; không hưởng Master Masons |
| House | 1 | 25W | 25 | — | +5 sức chứa; không vượt trần phe |
| Mill | 1 | 100W | 35 | — | Điểm nhận Food; farm tech; mở Farms/Market |
| Lumber Camp | 1 | 100W | 35 | — | Điểm nhận Wood; wood tech |
| Mining Camp | 1 | 100W | 35 | — | Điểm nhận Gold/Stone; mining tech |
| Farm | 1 | 60W | 15 | Mill | 175F cơ sở; mỗi ruộng một người thu hoạch hiệu quả |
| Barracks | 1 | 175W | 50 | — | Militia/spear; Flailman BND, Landsknecht SWB; mở Range/Stable |
| Archery Range | 2 | 175W | 50 | Barracks | Bow/crossbow, skirm, arquebusier |
| Stable | 2 | 200W | 60 | Barracks | Scout/light; Ritter chỉ SWB |
| Blacksmith | 2 | 150W | 40 | — | Attack/armor tech; mở Arsenal/Workshop |
| Market | 2 | 175W | 60 | Mill | Exchange, tribute, Trade Cart, trade tech |
| Church | 3 | 175W | 40 | — | Preacher BND / Cleric SWB, relic, tôn giáo |
| Siege Workshop | 3 | 200W | 60 | Blacksmith | Rams, Field Cannon; Heavy Cannon chỉ SWB |
| Arsenal | 3 | 200W | 60 | Blacksmith | Powder Craft, Chemistry, công nghệ công trình/ballistics/siege |
| Rebel Stronghold / League Castle | 3 | 650S | 200 | — | UT, phòng thủ; không bắt buộc để tuyển UU; +20 sức chứa |
| Outpost | 1 | 25W 5S | 15 | — | Trinh sát; không tấn công; không hưởng Master Masons |
| Palisade Wall | 1 | 3W mỗi ô | 7 | — | Chặn đường; Wagenburg art variant không đổi chỉ số |
| Palisade Gate | 1 | 30W | 30 | — | Cổng gỗ 4 ô; cùng đội được đi qua |
| Stone Wall | 2 | 5S mỗi ô | 8 | — | Phòng thủ; Fortified Walls chỉ SWB ở A4 |
| Stone Gate | 2 | 30S | 30 | — | Cổng đá 4 ô; nâng cùng Fortified Walls |
| Watch Tower | 2 | 50W 125S | 80 | — | BND tối đa Guard Tower; SWB lên Keep |

Town Center ban đầu và Castle-equivalent cung cấp sức chứa như bảng; phá hủy nhà có thể khiến over-cap, ngừng tuyển thêm nhưng không tự giết quân. Giới hạn cap và sức chứa là hai điều kiện riêng.

TC bổ sung chỉ mở từ A3. Nếu người chơi không còn TC nào, được xây lại một TC thay thế ở bất kỳ Age nào với giá chuẩn; không biến việc mất TC đầu thành một khóa công nghệ không thể phục hồi.

### 10.1. Chỉ số phòng thủ cơ sở

| Công trình | HP | Armor M/P | Attack P mỗi mũi | Số mũi nền | Chu kỳ | Range |
|---|---:|---|---:|---:|---:|---|
| TC | 2400 | 3/6 | 5 | 0; cần garrison | 2,0 | 0–6 |
| Watch Tower | 1000 | 1/7 | 5 | 1 | 2,0 | 1–6 |
| Guard Tower | 1500 | 2/8 | 7 | 1 | 2,0 | 1–7 |
| Keep | 2000 | 3/9 | 8 | 1 | 2,0 | 1–8 |
| Stronghold/Castle | 4000 | 8/10 | 10 | 3 | 2,0 | 1–8 |
| Palisade / Gate | 250 / 750 | 0/5 | — | — | — | — |
| Stone Wall / Gate | 1800 / 2700 | 8/12 | — | — | — | — |
| Fortified Wall / Gate | 3000 / 4500 | 10/15 | — | — | — | — |

TC chứa 15 đơn vị, towers chứa 5, castles chứa 20. Đơn vị sinh học đi bộ có thể garrison; cavalry/siege/trade cart không. Garrison không giúp aura hoạt động hoặc hồi máu tự động. TC bắn 1 mũi cho mỗi 2 dân/quân bắn bộ bên trong, tối đa 5; tower/castle thêm 1 mũi mỗi 5 quân bắn bộ, tối đa thêm 1/2 mũi. Quân khác chỉ trú, không thêm tên.

Fletching/Bodkin/Bracer không buff công trình trong ruleset này. Arrow Slits là nguồn duy nhất thêm range phòng thủ, đưa Keep/Castle League lên **9**, TC vẫn 6. Cần khóa quy tắc này để không vô tình làm Field Cannon Bundschuh bị castle bắn trả ở cùng tầm.

Castle League với Masonry + Architecture có **5600 HP**, giáp **10/12**. Stronghold Bundschuh với Masonry có **4400 HP**, giáp **9/11**. Không dùng số base ở một bên so với số fully upgraded ở bên kia.

## 11. Rock–paper–scissors và damage classes

### 11.1. Armor classes tối thiểu

| Class | Thành viên |
|---|---|
| Infantry | Militia-line, Spear-line, Flailmen, Landsknechts |
| Spear | Spearman/Pikeman/Halberdier và Landsknechts |
| Cavalry | Scout, Light Cavalry, Ritter |
| Archer | Bow/crossbow, skirmisher và arquebusier |
| Clergy | Preacher và Cleric |
| Siege | Rams và cannons |
| Building | Công trình, kể cả tường/cổng |

Bonus armor tương ứng các class này bắt đầu bằng 0. Normal M/P armor không trừ vào bonus Cavalry/Spear/Infantry/Building. Không thêm một armor class trùng Cavalry để nhân đôi anti-cavalry damage.

```text
damage_direct = max(1, base_attack_effective − matching_normal_armor)
              + Σ max(0, bonus_attack[class] − bonus_armor[class])
hits_to_kill = ceil(target_HP / damage_direct)
```

Nguyên tắc này áp dụng cho đòn đơn; splash dùng hệ số giảm damage đã khai báo riêng. Aura chỉ tăng base attack. Reload là thời gian giữa hai đòn, không phải thời gian tuyển. Bonus phe reload ×0,90 tương đương DPS lý thuyết ×1,111…, không phải đúng +10% DPS.

### 11.2. Bảng counter thực dụng

| Mục tiêu | Công cụ Bundschuh | Công cụ League | Điều kiện / không nên làm |
|---|---|---|---|
| Heavy cavalry | Pike/Halberd làm lõi, súng phía sau; chặn đường rồi surround | Landsknecht; Cleric khi được che chắn | Không đuổi cavalry khắp map bằng giáo; không lấy Flailmen thay anti-cavalry |
| Horde Flailman | Nỏ/súng, melee screen, pháo | Longsword/Professional Sword + arquebusier; cannon; Ritter đánh sườn | Landsknecht đơn thuần không phải đáp án chống Flailman |
| Pike/Halberd/Landsknecht | Flailmen, nỏ/súng; đánh sườn | Swordsmen, nỏ/súng và pháo | Tránh charge Ritter trực diện |
| Archer/Arquebusier | Elite Skirmisher theo chi phí, Light Cavalry khi có đường áp sát | Skirmisher, Ritter, cannon nếu co cụm | Skirmisher sợ melee; súng được pike che không còn là mục tiêu cavalry miễn phí |
| Preacher/Cleric | Light Cavalry; focus bằng nỏ/súng | Ritter/Light Cavalry; focus tầm xa | Đừng dành toàn bộ volley vào bộ binh đang được aura buff |
| Cannon | Light Cavalry/Flailmen đi vòng, pháo cơ bản phản pháo khi có vị trí | Cavalry; artillery có range ưu thế | Tránh đi thẳng vào minimum-range trap khi tuyến giáo còn nguyên |
| Fortifications | Field Cannon, Reinforced Ram, cắt mỏ ngoài thành | Heavy Cannon/Field Cannon, ram | Đập tường bằng quân melee đại trà thường không hiệu quả |

### 11.3. Bundschuh chống Ritter bằng gì?

1. Dựng **giáo theo từng cụm bảo vệ** Gold, Wood và hướng cavalry có thể đi vào; rào/cổng tạo đường tiếp cận dự đoán được.
2. Dùng Pikeman ở A3 và Halberdier ở A4 làm tuyến khắc chế chính. Preacher tăng hiệu quả nhưng không phải điều kiện để giáo gây bonus damage.
3. Đặt Arquebusiers sau giáo. Base pierce attack cao vẫn gây damage lên Ritter; không kỳ vọng súng tự đứng trống và thắng cavalry.
4. Khi Ritter rút, giữ vị trí và dùng quân nhanh raid nơi khác; không tự tách toàn bộ giáo khỏi artillery/kinh tế.
5. Flailmen đánh vào quân giáo hoặc nền kinh tế của League, tạo tình huống Ritter phải chọn giữa bảo vệ hậu phương và đánh chính diện.

### 11.4. League chống kinh tế và quân số Bundschuh bằng gì?

1. A2 dùng quân thường và phòng thủ tập trung vừa đủ; không đầu tư tường bao hết bản đồ trước khi có thông tin scout.
2. A3 chuyển sang **súng + tuyến chặn phù hợp**. Swordsmen đối phó Flailmen; Landsknechts đối phó cavalry hoặc bảo vệ pháo. Hai dòng có vai trò khác nhau.
3. Cannon buộc horde tản quân, giảm số quân được aura bảo vệ cùng lúc; tránh friendly fire vào tuyến chặn của mình.
4. Ritter đánh sườn hoặc raid Wood/Food. Giết dân và buộc idle làm giảm khả năng nuôi các Barracks; trao đổi đơn thuần một quân đắt lấy vài quân rẻ có thể chưa đủ.
5. Chiếm Gold ngoài thành, bảo vệ supply route và hạn chế nhận Salvage bằng việc rút được quân đắt. Công sự giữ vị trí; chúng không tự thay thế quyền kiểm soát tài nguyên.

## 12. Các phép kiểm tra bằng số

### 12.1. Pikeman và Ritter ở A3

Điều kiện: nâng cấp Blacksmith A3 của mỗi phe; Ritter có Bloodlines; không aura, không heal, không cao độ. Chi phí nâng cấp xem như đã trả và không tính lại vào giá tuyển biên.

- Pikeman Bundschuh: **55 HP, attack 6, +22 Cavalry, giáp 2/2**, giá **30F+25W = 55**.
- Ritter League: **145 HP, attack 14, giáp 5/4**, giá **90F+100G = 190**.
- Pike → Ritter: max(1, 6−5) + 22 = **23 damage/đòn**; cần 7 đòn nếu một Pike đánh một mình.
- Ritter → Pike: 14−2 = **12 damage/đòn**; cần 5 đòn. Ritter có chu kỳ 1,8 giây so với 3,0 của Pike, nên thắng solo.

Mô hình tĩnh 2 Pike đấu 1 Ritter: Pike thắng ở **9,0 giây**, còn 1 Pike 43 HP. Chi phí quân là **110 so với 190**; phe dùng Pike cũng dùng nhiều population hơn. Kết quả này xác nhận bonus damage làm đúng vai trò, không chứng minh người chơi luôn bắt được Ritter ngoài bản đồ.

### 12.2. Halberdier và Elite Ritter ở A4

- Halberdier: **60 HP, attack 10, +32 Cavalry, giáp 2/2**; không aura.
- Elite Ritter: **170 HP, attack 18, giáp 6/7**.
- Halb → Ritter: (10−6)+32 = **36 damage**.
- Ritter → Halb: 18−2 = **16 damage**.

Một Halberdier vẫn thua solo. Hai Halberdiers đấu một Elite Ritter trong cùng mô hình thắng ở **6,0 giây**, còn một Halberdier đầy HP. Không cần xóa giáp của Ritter hoặc cho Flailman xuyên giáp để tạo counter.

### 12.3. Flailman chống Landsknecht và League chống Flailman

Elite Flailman có aura A4: 15 attack, +5 Spear, 60 HP, giáp 2/2. Elite Landsknecht đầy đủ Drill: 90 HP, 11 attack, giáp 6/4.

- Flail → Landsknecht: (15−6)+5 = **14 damage**; 7 đòn.
- Landsknecht → Flail: 11−2 = **9 damage**; 7 đòn.

Flail rẻ hơn nhưng cần support để đạt attack 15; **100G của Preacher phải được tính vào bài test đội quân có aura**. Không cấp aura miễn phí khi kết luận cost efficiency.

Professional Swordsman đầy đủ tech có attack 17 và +3 Infantry: đánh Elite Flailman giáp 2 gây **18 damage/đòn**, cần 4 đòn. Flail có aura đánh lại giáp 5 gây 10 damage, cần 8 đòn để hạ 80 HP. Đây là lý do League có nhánh swordsman thay vì dùng Landsknecht chống mọi thứ.

### 12.4. Skirmisher chống súng

Elite Skirmisher Bundschuh: 45 HP, attack P 5, +6 Archer, giáp P 6. Elite Arquebusier League: 55 HP, attack P 19 sau Chemistry, giáp P 4, chu kỳ 3,15 giây.

- Skirm → gun: (5−4)+6 = **7 damage**.
- Gun → skirm: 19−6 = **13 damage**; Skirmisher không thuộc Infantry class nên không nhận +8 Infantry.

Skirmisher không thắng solo. Kiểm tra tĩnh **5 Skirmishers vs 3 Elite Arquebusiers**, cùng tổng giá thô 300 tài nguyên, cho nhóm Skirmishers thắng còn 3 quân. Đây chỉ là dấu hiệu counter theo chi phí; cơ cấu F/W/G, đầu tư nâng cấp, range, projectile, micro và tuyến chặn vẫn cần được kiểm tra trong game.

### 12.5. Pháo và công sự

Bundschuh Field Cannon với Chemistry: attack M **31**, bonus Building **120**, range **10**. Castle League tối đa 5600 HP, melee armor 10, range 9.

- Damage direct lên Castle: (31−10)+120 = **141**.
- Một khẩu cần ceil(5600/141) = **40 phát** nếu không sửa thành.
- League Heavy Cannon đầy đủ Chemistry/Engineers/UT: base 46, bonus Building 180×1,45 = **261**, range **12**.

Pháo League công thành mạnh hơn nhưng Bundschuh không bị hết lựa chọn. Phải tính chi phí, khả năng sửa, tuyến che và thời gian đến vị trí khi test trận thật.

### 12.6. Giới hạn của mô hình kiểm tra

Mô hình dùng các chỉ số hiệu lực ở trên: tất cả quân bắt đầu trong tầm, đòn đầu ở t=0, hit 100%, sự kiện cùng thời điểm xử lý đồng thời, focus mục tiêu còn sống có ID thấp nhất. Không có di chuyển, collision, range advantage, thời gian bay, windup, heal, cao độ, garrison hoặc chi phí nghiên cứu. Kết quả mô hình **không phải kết quả playable RTS** và không được dùng làm cam kết win rate.

## 13. Power spikes theo Age

| Age | Bundschuh | League | Tín hiệu đối thủ có thể scout |
|---|---|---|---|
| A1 | +10% F/W bắt đầu tạo lợi thế tích lũy; chưa có quân số vượt cap | Khởi đầu chuẩn; chọn vị trí kinh tế và hướng phòng thủ | Vị trí gỗ/mỏ, Barracks sớm, số dân đi tài nguyên |
| A2 | **Spike raid đầu tiên:** Flailman rẻ + giáo, ép nhiều điểm; cap vẫn 200 | Phòng thủ có tổ chức với quân thường và công sự +20% HP; chưa có Ritter | Số Barracks/Range/Stable, thêm towers, mức đầu tư Gold |
| A3 | **Spike phối hợp:** Pike, Preacher, Haufen nếu đầu tư Stronghold; cap 220; súng/pháo sau Powder Craft | **Spike chất lượng lớn nhất:** Ritter/Landsknecht, +1 melee armor, reload ×0,90 và carry +3 | Stable/Barracks thêm, Castle/Stronghold, Arsenal, Workshop |
| A4 | **Spike tiếp viện:** Elite Flail, Halberd, aura A4 và cap 240; vẫn thiếu giáp/range cuối | **Spike giao chiến đội hình và siege:** Elite Ritter, Elite guns, Heavy Cannon, UT/Engineers | Sản xuất Elite, heavy artillery, nghiên cứu và bảo vệ Gold/trade |

Không ấn định phút mạnh nhất trước khi có build-order benchmark. Haufen không tự có ngay lúc vừa lên A3: người chơi còn phải xây Stronghold 650S và trả UT. Tương tự, League lên A4 chưa đồng nghĩa đã có mọi Elite/UT/Blacksmith.

Nhận định chiến lược ban đầu: Bundschuh có cửa chủ động sớm và quanh các đợt tiếp viện; League có lợi thế giao chiến chính diện khi hoàn thành gói công nghệ. Người chơi có thể đánh lệch nhịp bằng raid, timing attack hoặc hoãn tech để tăng quân.

## 14. Tech-tree subtractions và cái giá phải trả

| Phe | Thiếu gì | Tác động chiến thuật |
|---|---|---|
| Bundschuh | Professional Swordsman, Arbalester, Elite Arquebusier | Quân tầm xa/chuyên nghiệp không đạt chất lượng cuối của League |
| Bundschuh | Heavy cavalry, Hussar, Bloodlines, Husbandry, Plate Barding | Cavalry chỉ là công cụ phụ; không thay thế được giáo/bộ binh |
| Bundschuh | Plate Mail, Ring Archer Armor, Bracer | Bộ binh vẫn dễ bị hỏa lực tiêu hao; ranged thiếu giáp/range cuối |
| Bundschuh | Squires | Mobility cuối trận phụ thuộc aura và Flailman cơ sở, không stack thêm vô hạn |
| Bundschuh | Heavy Cannon, Siege Engineers | Yếu hơn trong artillery duel; phải đánh sườn/kiểm soát bản đồ |
| Bundschuh | Keep, Fortified Walls, Architecture, Arrow Slits, Stone Shaft Mining | Khó chơi thành lũy lâu dài; vẫn có Guard Tower/Stronghold để giữ vị trí |
| Bundschuh | Conversion, Hospital Practice | Support tập trung aura; không lấy quân đắt của địch bằng conversion |
| League | Halberdier | Tuyến giáo mạnh nhất phải trả Gold cho Landsknecht |
| League | Hussar | Không có tier cavalry trash cuối để raid vô hạn khi cạn Gold |
| League | Conscription, Haufen, Village Levies | Không giảm giá/quá trình tuyển; mất quân chuyên nghiệp khó phục hồi |
| League | Two-Man Saw | Kinh tế Wood cuối trận yếu hơn Bundschuh; vẫn giữ Hand Cart, Crop Rotation và mining tech |
| League | Cap bonus, Salvage, aura Preacher, bonus gather đầu trận | Không được bù toàn bộ điểm yếu kinh tế bằng các cơ chế của Bundschuh |

Không thêm phụ phí mọi economic tech của League vào bản đầu. Các khoản đầu tư hiện hữu đã đắt; vừa phạt dân, vừa tăng giá tech, vừa kéo dài thời gian tuyển dễ khiến phe mất khả năng cạnh tranh trước A3. Nếu dữ liệu sau này yêu cầu điều chỉnh, thay từng biến và ghi version.

## 15. Quy tắc triển khai và nghiệm thu

### 15.1. Thứ tự modifier

1. Chọn archetype/tier; giữ base data bất biến.
2. Áp dụng nâng cấp thường của chủ hiện tại: Blacksmith, Bloodlines, Sanctity, v.v.
3. Áp dụng bonus phe, UT và team bonus đúng target tags/stack group.
4. Áp dụng aura hợp lệ; cùng loại lấy mức mạnh nhất.
5. Tính damage theo armor class; splash và friendly-fire factor theo profile vũ khí.

Giữ fractional values cho thời gian/speed; dùng fixed-point xác định theo simulation tick. Ví dụ 26 giây không được vô tình biến thành 19,5 ở League vì nhập nhầm Haufen. Team Blacksmith ×0,85 không áp dụng nghiên cứu tại Arsenal/Church/Castle.

Giá chốt và tài nguyên trừ ngay khi đặt hàng; phần Food discount làm tròn lên. Chủ động hủy đơn tuyển/nghiên cứu trước khi hoàn thành hoàn lại 100% giá thực trả đã lưu; công trình sản xuất bị phá hủy làm mất đơn và không hoàn tiền. Hủy một nền công trình đang xây chỉ hoàn phần chi phí tương ứng tiến độ chưa xây; xóa công trình hoàn thành không hoàn tiền. Tăng tốc sản xuất khi nghiên cứu xong giữ nguyên phần trăm công việc đã hoàn thành, dùng tốc độ mới cho phần còn lại. Tier/HP upgrade giữ nguyên tỷ lệ HP hiện tại, không hồi đầy miễn phí.

Khi conversion: giữ tier đơn vị, thay owner, gỡ bonus owner cũ và tính lại bonus hợp lệ owner mới. Không cấp quyền tuyển thêm dòng bị khóa. Ghi ever_converted để chặn Salvage. Unit có aura chỉ buff quân owner hiện tại; aura không trở thành team bonus.

Ranged prototype dùng projectile có thời gian bay; không dùng hitscan cho pháo. Ballistics dẫn bắn mục tiêu chuyển động cho đúng nhóm đã khai báo; không tăng range hoặc tự chuyển thành accuracy buff toàn quân. Kiểm tra ranged trong game riêng với mô hình damage tĩnh.

### 15.2. Tiêu chí nghiệm thu trước balance playtest

- Một trận có đủ đường đi từ A1 đến A4 cho cả hai phe, không có dependency cycle hoặc yêu cầu một building bị khóa.
- Mỗi unit/tech có age gate, building, prerequisites, cost, duration, target tags; đủ resource không tự bỏ qua điều kiện nâng tier trước.
- Mỗi unavailable tech hiển thị rõ khóa phe; không âm thầm biến thành nghiên cứu 0 cost.
- Flail giá 39F+15W; giáo giá 30F+25W; không giảm giá nghiên cứu hoặc Gold/Wood ngoài quy định.
- Unit UU trước nâng cấp khớp Phase 1; bảng hiệu lực ở mục 5.2 tính đúng.
- Pike damage bypass phần normal armor bằng bonus class, nhưng không dùng cơ chế “ignore all armor”.
- Gunners chịu anti-Archer bonus và ranged armor; không chịu anti-Infantry bonus chỉ vì có hình người đi bộ.
- Field Cannon BND range 10; castle/keep SWB max 9; Cannon SWB max 12. Không cộng Fletching vào cả súng và công trình.
- Population, houses, Church supports và trade carts đều được tính; 100 dân kinh tế ở A4 cho BND 140 suất còn lại, SWB 100.
- Test cả đội mixed BND/SWB: infantry LOS và Blacksmith speed cấp một lần; aura, bonus cap, Salvage và các UT không tự lan sang đồng minh.

### 15.3. Những gì chưa được coi là chứng minh cân bằng

Kết quả damage, đơn vị solo và mô hình focus-fire chỉ xác nhận logic. Cần playtest bản đồ mở/đóng, nhiều nguồn tài nguyên, thiếu Gold, team trade, các trình độ micro và độ trễ mạng. Theo dõi riêng thời điểm hoàn thành gói nâng cấp, thời gian idle dân, chi phí tổn thất theo F/W/G/S, mức tận dụng Haufen, lượng Salvage, aura coverage và số trận không còn đường phản công.

Ưu tiên chỉnh một biến: giá/tuyển Flailman nếu rush quá mạnh; counter tags nếu giáo không chống được Ritter; splash/deploy/minimum range nếu pháo không thể tiếp cận; availability hoặc tầm pháo nếu turtle bị khóa cứng. Không dùng tăng/giảm toàn bộ chỉ số phe để che một lỗi hệ thống.

## 16. Nguồn và giới hạn dẫn nguồn

- **Nền thiết kế:** BUNDSCHUH_REBELLION_GDD_PHASE_1.md, v0.1, bản hiện tại ngày 10/10/2026. Phase 2 giữ nguyên các quyết định đã liệt kê trong hợp đồng tương thích; các baseline/technology mới là đề xuất của Phase 2.
- **[H1]** Regionalmuseum Bad Frankenhausen, *Battle on 15 May*: https://www.regionalmuseum-bfh.de/battle-on-15-may — hỗ trợ bối cảnh wagon fortress và artillery của quân nổi dậy; không dùng để suy ra giá, HP hoặc damage.

Các tên tech quen thuộc AoE II được sử dụng làm ngôn ngữ thiết kế. Mọi giá/chỉ số mới trong tài liệu là thông số prototype của Bundschuh: Rebellion; không khẳng định chúng trùng với balance patch hiện hành của AoE II.
