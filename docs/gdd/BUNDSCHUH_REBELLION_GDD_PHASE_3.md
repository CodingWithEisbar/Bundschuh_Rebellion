# BUNDSCHUH: REBELLION

## Phase 3 — Historical Campaigns, Maps & Scenario Mechanics

**Phiên bản:** 0.3 — hoàn tất 11/10/2026.  
**Kế thừa:** GDD Phase 1 v0.1 và Phase 2 v0.2.  
**Phạm vi:** hai campaign đơn, mỗi campaign 6 màn; cơ chế trigger; ba cấu hình random map trên bộ.  
**Trạng thái:** thiết kế để dựng greybox. Đã đối chiếu lịch sử và rà logic đặc tả; chưa có scenario chạy được, RMS thực thi hoặc số liệu playtest. Các thời gian, quân số, tài nguyên và chỉ số mới đều là đề xuất gameplay, không phải số liệu lịch sử.

## 1. Quy tắc nền và ranh giới lịch sử

### 1.1. Trải nghiệm cốt lõi

Người chơi vẫn điều Villagers khai thác Food/Wood/Gold/Stone, xây căn cứ, nghiên cứu và phối hợp infantry, ranged, cavalry, siege. Campaign thay điều kiện chiến thắng và đặt thêm áp lực chiến trường; không thay damage classes, giá quân cơ sở hay cây công nghệ Phase 2.

| Nội dung | Campaign | Ranked/skirmish mặc định |
|---|---|---|
| Bốn Ages, bốn tài nguyên, counters và tech tree | Giữ; mỗi màn công bố giới hạn riêng | Giữ hoàn toàn |
| Zeal/Fear, Alert, Printing Press, Mercenary Payroll | Bật theo màn và theo đúng player được chỉ định | Tắt |
| Hero, đoàn dân chạy nạn, xe hậu cần, giao nộp vật phẩm | Scenario objects có nhãn riêng | Không có |
| Wagenburg | Palisade/gate mang hình xe, bộ binh và pháo bố trí bên trong | Đúng cấu kiện Phase 2; không thêm War Wagon |
| Cao độ | Quy tắc LOS chung ở mục 6.2 | Cùng quy tắc; không có buff phe riêng |
| Hải quân | Không bắt buộc; mọi mục tiêu có đường bộ | Không có Dock/naval tree trong bản này |

**Ages là cấp huy động trong trận:** A1 Serfdom, A2 Conspiracy, A3 Insurrection, A4 Reformation. Việc một màn năm 1525 khởi đầu ở A3 rồi lên A4 không có nghĩa súng, máy in hoặc Cải cách chỉ xuất hiện lúc đó.

Mọi đơn vị trên bộ thuộc quyền người chơi, kể cả hero và xe nhiệm vụ, dùng 1 population. Với giới hạn nền P của màn, Bundschuh có P/P/floor(1,1P)/floor(1,2P) theo bốn Ages; League có P. Nhà vẫn cần thiết. Không cộng hệ số dân số lần thứ hai vào con số “trần thực tế” trong bảng campaign.

### 1.2. Những điểm lịch sử quyết định cấu trúc

| Điểm cần giữ | Quyết định thiết kế |
|---|---|
| Các cuộc nổi dậy gồm nhiều địa phương và nhóm xã hội; không phải một quốc gia Bundschuh thống nhất [H1] | “Bundschuh” là tên phe gameplay. Briefing dùng tên từng Haufen và cộng đồng; không gọi mọi người tham gia là nông nô. |
| Müntzer gắn với Allstedt, Mühlhausen và Frankenhausen; không đại diện cho toàn phong trào [H2, H3] | Chọn **Thomas Müntzer** làm nhân vật chính A. Joß Fritz thuộc phần bối cảnh, không bị đưa vào trận Frankenhausen. |
| Twelve Articles gắn với Memmingen, Sebastian Lotzer và Christoph Schappeler [H4] | A2 là chương xen kẽ với người đưa tin hư cấu; không gán văn bản hay cuộc họp Memmingen cho Müntzer. |
| Böblingen: 12/5; League đốt Weinsberg: 21/5/1525 [H5, H6] | B3 diễn ra trước B4. Tên “The Siege of Weinsberg” được điều chỉnh thành **After Weinsberg** để tránh trình bày một cuộc tái chiếm lâu đài nguyên vẹn như sự kiện đã được chứng minh. |
| Frankenhausen: 15/5; Müntzer bị bắt rồi bị hành quyết ngày 27/5 [H2, H7] | A6 thắng bằng cầm chân và cứu người. Không mở nhánh tiêu diệt liên quân để cứu sống Müntzer. |
| Đối phương ở Frankenhausen là quân các thân vương, không phải đạo quân Waldburg [H1, H7] | Dùng roster League làm mẫu cân bằng cho **Princely Host**, với tên, huy hiệu và briefing riêng. Đây không phải phe skirmish thứ ba. |

**Quy ước nội dung:** [H] là bối cảnh có nguồn; [D] là tái dựng phục vụ gameplay. Tất cả tuyến đường chiến thuật, hội thoại, các nhân vật tổng hợp, quân số trên map, hạn giờ, trận đụng độ phụ và thao tác chiếm điểm dưới đây là [D], trừ khi ghi rõ [H]. Bản đồ nén địa lý, không phải bản phục dựng khảo cổ.

Người chơi được chọn đường tiến quân, thành phần quân, hướng vây và số người cứu được. Các mốc lịch sử lớn không đổi. Briefing nói trước mục tiêu thật; không yêu cầu người chơi “thắng trận” rồi bất ngờ tuyên bố họ thua vì cutscene.

## 2. Campaign A — The Shoe of Rebellion

### 2.1. Nhân vật và đường dây kể chuyện

**Nhân vật trung tâm:** Thomas Müntzer, một nhà giảng đạo với niềm tin cải cách quyết liệt và kỳ vọng khải huyền. Trọng tâm kịch bản là sức huy động của đức tin, sự đa dạng của các yêu sách và khoảng cách giữa kỳ vọng với năng lực quân sự.

**Nhân vật nối chương:** Anna, người đưa tin hư cấu, xuất thân từ một gia đình thợ thủ công. Anna không được giới thiệu như nhân vật lịch sử có thật. A2 theo hành trình của cô tại miền nam; A3 quay lại Müntzer ở Thüringen. Màn chuyển cảnh ghi rõ địa điểm và ngày tháng, không ám chỉ hai nơi sát nhau.

**Nhịp toàn campaign:** tổ chức bí mật → truyền bá yêu sách → xây cộng đồng → huy động → hành quân → giữ đường sống.

| ID / Màn | Thời gian và địa điểm | Age / P → trần thực tế | Map / thời lượng dự kiến | Bài học |
|---|---|---|---|---|
| A1 — The Secret Oath | Allstedt và vùng phụ cận, 1524 | A1→A2 / 40→40 | 128×128 / 20–25 phút | Scouting, né tuần tra, tập hợp người |
| A2 — The Twelve Articles | Memmingen và hành lang truyền tin miền nam, đầu 3/1525 | A2→A3 / 100→110 | 160×160 / 30–40 phút | Kinh tế, chiếm điểm, bảo vệ máy in |
| A3 — The Eternal Council | Mühlhausen, 3/1525 | A3 / 120→132 | 160×160 / 30–35 phút | Giữ nhiều khu phố, hậu cần và quân tiếp viện |
| A4 — The Call to Allstedt | Vùng Mühlhausen–Allstedt, cuối 4/1525 | A3 / 140→154 | 192×192 / 30–40 phút | Raid, liên kết Haufen, kiểm soát Fear |
| A5 — The Rainbow Road | Đường tới Frankenhausen, trước/tới 11/5/1525 | A3 / 140→154 | 192×192 / 25–35 phút | Hộ tống, chọn tuyến, bảo toàn pháo |
| A6 — The Martyrdom at Frankenhausen | Frankenhausen, 15/5/1525 | A4 / 160→192 | 192×192 / 21–27 phút | Phòng ngự chiều sâu, rút lui và cứu người |

Thời lượng là mục tiêu cho một lượt chơi Normal đã hiểu điều khiển, không phải deadline trừ khi ghi rõ.

### A1 — The Secret Oath: Lời thề bí mật

**Bối cảnh [H]:** hoạt động tôn giáo và liên kết bảo vệ tín đồ tại Allstedt dẫn tới xung đột với chính quyền; Müntzer rời thành phố trong năm 1524 [H2]. Cuộc tuyển người cụ thể trong màn là hư cấu.

**Khởi đầu [D]:** Müntzer, Anna, 8 Villagers và 2 Militia; một cụm nhà, chưa có căn cứ quân sự lớn. Bản đồ có năm nhóm dân, mỗi nhóm bốn người có thể gia nhập. Có ba địa điểm họp và hai cửa thoát.

- **Thắng:** hoàn thành ba cuộc họp, rồi đưa Müntzer, Anna và ít nhất 12 người được tuyển qua cùng một cửa thoát. Mỗi cuộc họp cần hero và ba người theo đứng trong vùng 30 giây liên tục.
- **Thua:** một hero chết; số người theo còn có thể đưa tới cửa thoát thấp hơn 12; hoặc hết hạn truy bắt khi Alert đã lên 100.
- **Trigger chủ đạo:** lính tuần tra quan sát hành vi khả nghi để tăng Alert; ở mức 100, game công bố một cuộc càn quét sau 120 giây. Vẫn có cơ hội thoát, không game-over ngay vì một lần bị nhìn thấy.
- **Tự do chiến thuật:** đưa từng nhóm nhỏ theo đường vườn; chờ lịch tuần tra; dùng Militia đánh lạc hướng. Không có tàng hình hoặc đi xuyên cây.
- **Tùy chọn:** đưa đủ 20 người ra ngoài, không đạt Alert 60. Thưởng huy chương và đoạn kể bổ sung, không có buff vĩnh viễn.

**Kết thúc:** mạng lưới và người đưa tin sống sót; lời dẫn chuyển sang giai đoạn Müntzer phải rời Allstedt. Thắng màn không có nghĩa chiếm được toàn thành phố.

### A2 — The Twelve Articles: Mười hai điều khoản

**Bối cảnh [H]:** các yêu sách được soạn tại Memmingen và nhanh chóng được phổ biến bằng bản in [H4]. Anna là nhân vật chơi chính. Lotzer và Schappeler xuất hiện trong briefing/cutscene, không trở thành tướng trận.

**Bản đồ [D]:** một khu đô thị đồng minh, ba cộng đồng ngoài thành và hai xưởng in trên tuyến truyền bá. Xưởng, đường hộ tống và đợt truy quét là tái dựng tổng hợp; không khẳng định đây là một trận vây Memmingen có thật.

- **Thắng:** giành và giữ hai trong ba cộng đồng trong 60 giây; giải phóng và đưa về an toàn 12 Villagers có nhãn nhiệm vụ; giao ba kiện bản in tới ba điểm nhận khác nhau; còn ít nhất một máy in hoạt động khi hoàn tất.
- **Thua:** Anna chết; cả hai máy in bị phá; hoặc tổng số dân đã cứu cộng số dân còn cứu được xuống dưới 12.
- **Trigger chủ đạo:** sau kiện in đầu tiên, AI báo một cuộc tấn công vào xưởng sau 90 giây. Hai xưởng tách nhau đủ xa để một đội phòng thủ duy nhất khó giữ cả hai.
- **Tự do chiến thuật:** thương lượng với một cộng đồng bằng 200F hoặc đánh hạ đồn quân để mở cổng; hộ tống qua đường ngắn nguy hiểm hoặc đường vòng. Hai cách đều mở cùng số dân, không được nhận thưởng hai lần.
- **Tùy chọn:** giữ cả hai máy in và cả ba cộng đồng. Mỗi nơi được giải phóng chỉ cấp Villagers một lần; cần chỗ dân để tiếp nhận, UI báo rõ trước khi xác nhận.

**Thông điệp:** yêu sách được truyền đi dù không có một nhà nước nổi dậy thống nhất. “Giải phóng” là giải thoát người và vô hiệu hóa quyền kiểm soát tại chỗ trong màn, không phải tuyên bố toàn vùng đã xóa chế độ nông nô.

### A3 — The Eternal Council: Hội đồng mới

**Bối cảnh [H]:** Müntzer trở lại Mühlhausen; phong trào gắn với sự hình thành một hội đồng mới và vai trò của Heinrich Pfeiffer [H3]. Không trình bày quá trình chính trị này như một cuộc công thành đã được sử liệu xác nhận.

**Bản đồ [D]:** ba khu phố nối bởi hai cửa thành và tuyến kho lương ngoài tường. Có ba đoàn xe, cần bảo toàn hai. Bắt đầu có Town Center, kinh tế A3 và lực lượng infantry nhỏ; Haufen có thể nghiên cứu theo đúng Phase 1.

- **Thắng:** kiểm soát ba điểm hội họp cùng lúc trong 90 giây; giao 600F vào kho cứu tế một lần; đưa hai đoàn tiếp tế tới khu chợ.
- **Thua:** Müntzer chết; kho cứu tế bị phá trước khi giao đủ; hoặc hai trong ba đoàn xe nhiệm vụ bị mất.
- **Trigger chủ đạo:** kiểm soát một khu phố cấp quyền sử dụng công trình sẵn có, không sinh thêm tiền vô hạn. Đợt phản công bắt đầu sau khi người chơi giành khu thứ hai, có báo trước 60 giây.
- **Tự do chiến thuật:** tập trung đánh nhanh từng khu bằng Flailmen, hoặc dựng tuyến Spearmen/Crossbowmen bảo vệ tiếp tế. Town Center và nhà phải duy trì đủ population cho quân viện.
- **Tùy chọn:** giữ nguyên cả hai cổng thành; bảo toàn dân tại một khu dân cư. Phần thưởng chỉ nằm trong màn và bản ghi thành tích.

**Kết thúc:** người chơi giữ được một trung tâm tổ chức. Cutscene nhấn mạnh tính địa phương của quyền lực mới, không biến Müntzer thành vua của cả cuộc nổi dậy.

### A4 — The Call to Allstedt: Lời hiệu triệu

**Bối cảnh [H]:** lời kêu gọi cuối tháng 4/1525 của Müntzer thúc đẩy việc huy động người ủng hộ [H3]. Các hành lang, đồn chặn và nhiệm vụ cứu viện là hư cấu.

**Bản đồ [D]:** thung lũng chính có đồn quân; hai đường vòng qua rừng và làng mỏ. Ba cộng đồng đưa ra ba yêu cầu khác nhau: hộ tống, cung cấp 300F hoặc giải vây.

- **Thắng:** hoàn thành yêu cầu của hai cộng đồng; đưa hai sứ giả trở lại trại và bảo toàn ít nhất 16 trong 24 quân viện của hai nhóm đã chọn.
- **Thua:** Müntzer chết; hoặc không còn cách hoàn thành hai tuyến tiếp viện do mất các sứ giả/nhóm quân cần thiết. Nếu tuyến thứ ba còn khả thi, nhiệm vụ vẫn tiếp tục.
- **Trigger chủ đạo:** giới thiệu Zeal/Fear đầy đủ. Giải vây và cứu đoàn người tăng Zeal một lần; hy sinh quân chỉ tăng Fear, không tự tạo tài nguyên kích hoạt Frenzy.
- **Tự do chiến thuật:** công kích kho hậu cần làm đợt cavalry đến muộn hai phút; đánh nhiều hướng với bộ binh rẻ; hoặc chiếm một cannon theo sự kiện để phá chốt. Không mở quyền tuyển Heavy Cannon hay cavalry nặng cho Bundschuh.
- **Tùy chọn:** liên kết cả ba cộng đồng. Màn không yêu cầu phá mọi căn cứ đối phương.

**Kết thúc:** mạng lưới huy động rộng hơn, nhưng các Haufen vẫn có mục tiêu và mức cam kết riêng. Số quân được hộ tống là quy mô gameplay, không phải quân số lịch sử.

### A5 — The Rainbow Road: Đường tới Frankenhausen

**Bối cảnh [H]:** Müntzer tới Frankenhausen muộn nhất vào tối 11/5 cùng lực lượng từ Mühlhausen [H8]. Vì vậy không đặt cuộc hành quân của ông sau ngày 11/5.

**Bản đồ [D]:** ba hành lang đi tới một trại cuối bản đồ. Không xây Town Center mới và không lên Age; có Villagers sửa chữa, bộ binh hộ tống, vài ranged units và Field Cannon. Ba xe nhiệm vụ đại diện hậu cần, không phải War Wagon chiến đấu.

- **Thắng:** Müntzer, Anna và ít nhất hai trong ba xe hậu cần tới trại Frankenhausen.
- **Thua:** một hero chết hoặc hai xe bị phá. Có thông báo tức thì khi chỉ còn đúng hai xe để người chơi biết biên độ rủi ro.
- **Trigger chủ đạo:** một đường ngắn bị cavalry tuần tra; đường đồi cần hạ chốt; đường rừng dài nhưng có nơi sửa chữa. Không có con đường bị khóa vĩnh viễn sau khi người chơi đã chọn.
- **Tự do chiến thuật:** chia lực lượng đánh lạc hướng; tiến chậm với Pike; bỏ lại một xe để cứu phần còn lại. Pháo phải pack/unpack đúng Phase 2.
- **Tùy chọn:** đưa cả ba xe và Field Cannon tới nơi. Đây là thành tích, không quyết định A6 có đủ quân để thắng hay không.

**Kết thúc:** cờ cầu vồng xuất hiện tại trại. Màn kế tiếp có đội hình khởi đầu cố định, vì vậy thất bại ở mục tiêu phụ không làm campaign rơi vào thế không thể hoàn thành.

### A6 — The Martyrdom at Frankenhausen: Giữ một đường sống

**Bối cảnh [H]:** trận ngày 15/5 kết thúc bằng thất bại nặng của lực lượng nổi dậy. Müntzer bị bắt, rồi bị hành quyết ngày 27/5 [H2, H7]. Cuộc cầm chân có tổ chức và hành lang sơ tán là phần hư cấu phục vụ gameplay.

**Briefing phải nói rõ:** “Chúng ta không thể quyết định kết cục cả cuộc chiến ở đây. Hãy giữ hiệu kỳ đủ lâu để đưa những người còn có thể cứu ra ngoài.” Tên “Martyrdom” thể hiện góc nhìn nhân vật trong campaign; phần tư liệu không biến cách diễn giải tôn giáo thành kết luận lịch sử khách quan.

**Khởi đầu đề xuất trên Normal:** A4; P=160, trần Bundschuh 192; 72 quân chiến đấu, 18 Villagers, 3 Preachers, Anna, 40 dân sơ tán và 5 couriers; tổng 139 population. Cho sẵn sức chứa nhà 160, 900F/800W/450G/250S, hai Barracks, một Range, một Church, một Workshop, một Blacksmith, các điểm giao Food/Wood/Gold/Stone và khu Wagenburg. Nhóm 72 quân gồm 20 Halberdiers, 20 Elite Flailmen, 16 Crossbowmen, 14 Arquebusiers cơ bản và hai Field Cannons. Gói nghiên cứu cấp sẵn: Haufen, Revolutionary Sermons, hai nâng cấp unit nêu trên, đủ melee attack và hai tier infantry armor; các tech khác theo phần research còn mở của màn. Đây là tài sản scenario đã thanh toán, không phải unlock vĩnh viễn. Không có Stable/cavalry trong màn này; đây là ngoại lệ scenario được báo trong briefing [H7].

**Mục tiêu thắng đồng thời:**

1. Giữ **Banner Post** sống tới phút chiến đấu 18; trước đó có ba phút chuẩn bị riêng.
2. Đưa ít nhất **24/40 dân** ra khỏi bản đồ qua bất kỳ cửa thoát nào.
3. Đưa ít nhất **3/5 couriers** ra ngoài; Anna cũng phải thoát.

Đủ các điều kiện ở phút 18 thì thắng ngay. Nếu chưa đủ số người, được tiếp tục sơ tán tới phút chiến đấu 24; việc giữ Banner đã hoàn thành không bị thu hồi sau phút 18. Banner Post là objective building 1.200 HP, giáp 2/4, sửa được; không bắn và không cấp aura/Gold.

**Thua:** Banner bị phá trước phút 18; Anna chết; số người còn có thể cứu không đủ ngưỡng; hoặc hết phút 24 mà chưa hoàn tất. Dân mới tuyển không thay được 40 dân/5 couriers mang ID nhiệm vụ.

**Địa hình và nhịp:** Wagenburg trên Hausberg, một vùng phố thấp và hai cửa thoát cách nhau ít nhất 40 ô. Ba phút đầu để dựng rào và phân bổ quân. Các đợt tiến công dự kiến ở phút 3/6/9/12/15/18 của đồng hồ chiến đấu, lần lượt 24/28/32/36/40/44 đơn vị; tăng tỷ trọng guns/cavalry/cannon theo đợt. Tối đa 220 quân đối phương hoạt động cùng lúc; phần dư chờ ngoài map. Đây là ngân sách greybox cần thử, không phải số liệu trận đánh.

**Tự do chiến thuật:** giữ tuyến ngoài rồi lùi về phố; dùng Halberdiers ngăn cavalry, Flailmen đánh infantry hộ pháo; tách nhóm mở cửa thoát; dành Frenzy cho một pha giải vây. Hai cửa thoát luôn có đường đi trên bộ, không bắt buộc một phương án duy nhất.

Müntzer là nhân vật trong lời dẫn/cutscene của A6, không phải một hero bất tử để người chơi dùng đỡ đạn. Khi thắng mục tiêu chiến thuật, màn kết thúc; epilogue kể thất bại và số phận của ông. Không spawn một đạo quân vô hạn chỉ để cưỡng ép người chơi xem game-over. “Cầu vồng” chỉ là hình ảnh/bài giảng, không phải phép chống đạn.

**Chấm điểm:** số người thoát, số couriers còn sống và quân bảo toàn; không thưởng kill count. Giải cứu thêm người tạo khác biệt có ý nghĩa dù kết cục lớn đã cố định.

## 3. Campaign B — The Iron Fist of Swabia

### 3.1. Nhân vật và đường dây kể chuyện

**Nhân vật chính:** Georg, Truchsess von Waldburg. Người chơi chỉ huy đạo quân của một liên minh có lợi ích và nguồn lực riêng, không phải một quân đội đế quốc trung ương thống nhất.

Một thư lại quân nhu hư cấu dẫn chuyện bên cạnh Waldburg: thông báo lương, nhu cầu của các thành viên liên minh và hệ quả của các mệnh lệnh. Câu chuyện cho thấy cả năng lực chỉ huy, các cuộc thương lượng và việc đàn áp, trả đũa; không dùng chiến thắng gameplay để xác nhận mọi hành động của phe là chính đáng.

**Nhịp toàn campaign:** tập trung lực lượng → bảo toàn đạo quân bằng thương lượng → phối hợp binh chủng → kiểm soát đô thị → vượt địa hình → kết thúc chiến dịch vùng Franken.

| ID / Màn | Thời gian và địa điểm | Age / trần dân | Map / thời lượng dự kiến | Bài học |
|---|---|---|---|---|
| B1 — Quenching the Sparks | Leipheim, 4/4/1525 | A3 / 100 | 160×160 / 25–35 phút | Landsknecht, hậu cần, kỳ lương đầu |
| B2 — The Weingarten Accord | Weingarten, 17/4/1525; văn bản 22/4 | A3 / 120 | 160×160 / 25–30 phút | Giữ đường, bảo vệ sứ giả, thương lượng |
| B3 — The Battle of Böblingen | Böblingen, 12/5/1525 | A3→A4 / 140 | 192×192 / 35–45 phút | Pháo ghim quân, cavalry đánh sườn |
| B4 — After Weinsberg | Weinsberg, 21/5/1525 | A3→A4 / 140 | 160×160 / 30–40 phút | Đô thị, kiểm soát máy in, bắt chỉ huy |
| B5 — The Guns of Königshofen | Königshofen, 2/6/1525 | A4 / 160 | 192×192 / 35–45 phút | Vượt sông, chia tuyến, siege |
| B6 — The Last Haufen | Ingolstadt–Sulzdorf, Unterfranken, 4/6/1525 | A4 / 200 | 224×224 / 40–50 phút | Hai mặt trận, tiếp tế Gold, phản công |

### B1 — Quenching the Sparks: Dập lửa đầu mùa

**Bối cảnh [H]:** Leipheim là một trận lớn đầu tháng 4 giữa quân nổi dậy và Swabian League [H9]. Mở đầu này diễn ra khi cuộc xung đột đã thành giao chiến vũ trang, không gọi mọi người đang hội họp là quân địch.

**Bản đồ [D]:** căn cứ League ở một đầu hành lang sông, hai vị trí hỏa lực và vùng trại nổi dậy. Có một đại đội tám Landsknechts, ít Ritter/gunners, Villagers và xe tiếp tế.

- **Thắng:** đưa hai trong ba xe tiếp tế tới trại tiền phương; chiếm hai vị trí hỏa lực; giữ khu cổng thành 60 giây để kích hoạt đầu hàng.
- **Thua:** Waldburg chết; mất hai xe; hoặc không còn đơn vị/công trình nào có thể hoàn tất mục tiêu.
- **Trigger chủ đạo:** hợp đồng đầu tiên được cấp sẵn, kỳ lương đầu bắt đầu sau 120 giây. Tiền tuyển đã được scenario trả; người chơi chịu các kỳ lương tiếp theo.
- **Tự do chiến thuật:** dùng Landsknecht giữ tuyến và ranged tiêu hao; đưa Ritter đánh sườn khi giáo đối phương đã quay hướng. Đánh thẳng cavalry vào Pike vẫn chịu class bonus bình thường.
- **Tùy chọn:** không mất xe, không chậm lương. Không thưởng thêm Gold cho việc đánh dân đã đầu hàng.

**Kết thúc:** thắng quân sự và đầu hàng của địa phương; debrief nhắc tới việc trừng phạt sau trận. Không cần người chơi tiêu diệt toàn bộ dân cư để thắng.

### B2 — The Weingarten Accord: Một chiến thắng bằng thương lượng

**Bối cảnh [H]:** thỏa thuận được thống nhất ngày 17/4 và thành văn ngày 22/4/1525 [H10]. Màn này cho thấy Waldburg không chỉ giải quyết mọi tình huống bằng công kích trực diện.

**Bản đồ [D]:** trại hai bên, tuyến lương dài và khu tiếp xúc trung lập; ba xe tiếp tế đặt sẵn, cần giao hai. Những nhóm tập kích trên đường là lực lượng scenario riêng; không tự động chuyển toàn bộ trại đang thương lượng thành hostile.

- **Thắng:** giữ trạm hậu cần sống trong 15 phút; đưa hai chuyến tiếp tế tới nơi; hộ tống sứ giả đi và về sau cuộc tiếp xúc 60 giây.
- **Thua:** Waldburg hoặc sứ giả chết; trạm hậu cần bị phá; mất hai xe tiếp tế; chủ động tấn công khu đình chiến sau cảnh báo rõ trong briefing. Auto-attack không nhắm quân trung lập; damage splash ngoài ý muốn không được tính thành lệnh chủ động phá đình chiến.
- **Trigger chủ đạo:** thương lượng chỉ bắt đầu khi lối tới bàn đàm phán an toàn. Thời gian cuộc gặp dừng khi có quân thù trong vùng, không reset toàn bộ 15 phút bảo vệ tuyến.
- **Tự do chiến thuật:** dựng chốt, đi tuần cavalry hoặc hộ tống theo từng đoàn. Người chơi không phải tiêu diệt một đại quân đang đứng trong trại để “mở khóa” hòa đàm.
- **Tùy chọn:** không có công ty Landsknecht chậm lương và không mất xe; thưởng thành tích, không đổi văn bản lịch sử.

**Kết thúc:** hiệp định mở đường cho đạo quân tiếp tục chiến dịch. Không tuyên bố mọi Haufen ở miền nam cùng chấp nhận một thỏa thuận.

### B3 — The Battle of Böblingen: Phá thế trận bằng binh chủng

**Bối cảnh [H]:** ngày 12/5, vị trí hỏa lực, pháo và cavalry góp phần quyết định kết quả trận Böblingen [H5]. Quân nổi dậy cũng có vũ khí và pháo; họ không chỉ là đám đông tay không.

**Bản đồ [D]:** vùng đô thị, các cao điểm và hành lang cây thưa; địa hình tham khảo chiến trường nhưng không sao chép tỷ lệ lịch sử. Hai điểm pháo League và ba nhóm địch bảo vệ những hướng khác nhau.

- **Thắng:** chiếm và giữ hai vị trí hỏa lực 90 giây; vô hiệu hóa ba khẩu pháo nhiệm vụ của đối phương; đánh bật hoặc khiến hai Haufen rút khỏi vùng tập kết.
- **Thua:** Waldburg chết; đoàn chỉ huy/quân nhu bị phá; hoặc không còn lực lượng và cơ sở sản xuất để giành mục tiêu.
- **Trigger chủ đạo:** nhóm Pike phản ứng theo hướng Ritter xuất hiện. Sau khi một khẩu pháo nổi dậy bị vô hiệu hóa, một Haufen có Fear tăng theo sự kiện một lần, tạo cửa sổ phản công.
- **Tự do chiến thuật:** dùng artillery và Arquebusiers ép bộ binh rời vị trí, rồi đưa Ritter vòng sườn; hoặc dùng Landsknecht ghim trận tuyến trong khi pháo chuyển chỗ. Khoảng cách và minimum range 2 của cannon vẫn có hiệu lực.
- **Tùy chọn:** giữ ít nhất ba trong bốn khẩu pháo xuất phát. Không cần nâng lên A4 để đạt mọi mục tiêu, nhưng A4 cho phương án đầu tư chậm hơn.

**Kết thúc:** trận đánh bị phá vỡ và quân nổi dậy thất bại. Debrief phân biệt giao chiến với cuộc truy sát sau đó; điểm số ưu tiên mục tiêu và bảo toàn quân.

### B4 — After Weinsberg: Chiến thắng và cuộc trả đũa

**Bối cảnh [H]:** quân nổi dậy chiếm thành và lâu đài Weinsberg ngày 16/4; việc xử tử các quý tộc gây phản ứng mạnh. League đốt thành ngày 21/5 [H6]. Phần chơi dưới đây là tái dựng tổng hợp, không phải khẳng định một cuộc vây tái chiếm có diễn biến như bản đồ.

**Thay cho “The Siege of Weinsberg”:** người chơi kiểm soát khu đồi Weibertreu và đô thị đã chịu tàn phá. Công sự còn chống trả là chướng ngại, đồn và barricade dựng trong scenario; không dựng một lâu đài lịch sử nguyên vẹn rồi gọi việc phá nó là sự kiện thật.

- **Thắng:** giữ khu đồi và tòa nhà hành chính cùng lúc trong 60 giây; bắt và đưa cả hai chỉ huy hư cấu về trạm giam; vô hiệu hóa hai máy in hỗ trợ tuyển quân nổi dậy.
- **Thua:** Waldburg chết; hoặc một trong hai tù binh cần thiết chết trước khi được đưa về trạm giam. Mỗi chỉ huy buông vũ khí khi HP sắp xuống dưới 25%, trở thành objective NPC, nên không chết vì đòn cuối vô tình. Đối phương cứu lại tù binh chỉ làm mục tiêu chưa hoàn thành; người chơi còn có thể bắt lại.
- **Trigger chủ đạo:** máy in có thể bị đốt phá hoặc bị chiếm để tịch thu; hai cách đều chặn bonus recruitment. Hai chỉ huy chỉ bị tính “đã bắt” khi người chơi có quân hộ tống trong vùng 30 giây.
- **Tự do chiến thuật:** siege từ đường lớn hoặc chiếm cao điểm rồi đánh xuống; phá nguồn tiếp viện trước hoặc tiến nhanh tới trung tâm. Tù binh cần được hộ tống qua đường còn tranh chấp.
- **Tùy chọn:** sơ tán các nhóm dân được đánh dấu trước khi màn kết thúc. Không có thao tác hành quyết làm nguồn Gold, Zeal hay điểm chiến công.

**Kết thúc:** debrief ghi nhận việc thành phố bị thiêu hủy và trừng phạt tập thể. Việc người chơi cứu một số người không được dùng để phủ nhận cuộc trả đũa lịch sử. Hình phạt đối với các thủ lĩnh thuộc phần kể chuyện, không phải một minigame tra tấn.

### B5 — The Guns of Königshofen: Pháo trên thung lũng Tauber

**Bối cảnh [H]:** quân nổi dậy ở Königshofen bị đánh bại ngày 2/6/1525 [H1]. Các tuyến vượt sông và nhiệm vụ bắn phá dưới đây là thiết kế bản đồ.

**Bản đồ [D]:** sông Tauber, ba lối vượt cố định, cao điểm và doanh trại xe. Không cần tàu; không thể phá mọi cầu để khóa cả trận. Hai mỏ Gold bên mình giúp trả lương ngay cả khi một tuyến viện trợ bị cắt.

- **Thắng:** kiểm soát hai lối vượt, vô hiệu hóa ba trong bốn vị trí pháo đối phương và chiếm khu chỉ huy trên cao điểm.
- **Thua:** Waldburg chết; đại bản doanh bị phá; hoặc toàn bộ lực lượng/cơ sở tái tạo bị mất.
- **Trigger chủ đạo:** crossing đầu bị chiếm sẽ khiến AI chuyển một lực lượng dự bị từ cánh đối diện. Dấu vết scouting và thông báo cho người chơi biết có phản ứng, không spawn sau lưng căn cứ.
- **Tự do chiến thuật:** dùng cavalry đánh vòng, mở trận địa Heavy Cannon ở khoảng cách an toàn, hoặc đưa infantry qua lối phụ rồi quay lại mở đường pháo. Cao độ không tăng range để pháo Bundschuh vẫn có thể gây áp lực theo Phase 2.
- **Tùy chọn:** bảo toàn ít nhất một cầu đầu không để đối phương chiếm lại; giữ đoàn xe lương tới đúng hẹn.

**Kết thúc:** thất bại quân sự của Haufen tại đây; đạo quân League tiếp tục sang vùng Franken.

### B6 — The Last Haufen: Đạo quân cuối trên tuyến tiến công

**Bối cảnh [H]:** trận ngày 4/6 diễn ra tại Ingolstadt ở Unterfranken, gần Sulzdorf; không phải thành phố Ingolstadt trên sông Danube [H1]. Tên màn chỉ phần cuối của chiến dịch này, không khẳng định mọi cuộc nổi dậy trong Đế quốc chấm dứt hôm đó.

**Bản đồ [D]:** hai cụm địch có các tuyến liên lạc và tiếp tế riêng. Người chơi mở từ một đại bản doanh A4, phải phân bổ lực lượng chuyên nghiệp giữa chiến tuyến và con đường nuôi quân.

- **Thắng:** chiếm hai trạm liên lạc trong 90 giây; khiến ba khu trại quân sự buông cờ; giữ đoàn quân nhu chính sống tới khi hoàn tất.
- **Thua:** Waldburg chết; đoàn quân nhu chính bị phá; hoặc mất toàn bộ lực lượng/cơ sở tái tạo.
- **Trigger chủ đạo:** sứ giả địch tới được trại thứ hai sẽ rút ngắn thời gian phản công phối hợp từ sáu xuống hai phút. Giết hoặc chặn sứ giả chỉ đổi thời điểm và thế trận, không tạo một kết thúc lịch sử khác.
- **Tự do chiến thuật:** đánh nhanh một cụm bằng Ritter, tiến chậm với Landsknecht và Heavy Cannon, hoặc phá tuyến liên lạc rồi xử lý từng nhóm. Người chơi luôn còn mines/Market để xoay Gold khi mất một đoàn viện trợ.
- **Tùy chọn:** hoàn tất mà không đại đội nào đào ngũ; giữ ít nhất một tuyến thư tín League hoạt động suốt trận.

**Epilogue:** chiến thắng quân sự và sự phục hồi quyền lực đi cùng trừng phạt, tổn thất và những vấn đề xã hội chưa được giải quyết. Các biến động tại vùng khác còn tiếp diễn; campaign không ép toàn bộ lịch sử 1524–1526 kết thúc trong một trận [H1].

## 4. Các module scenario và trigger

### 4.1. Lớp trigger chung

Mỗi scenario có cấu hình riêng: `age_start`, `age_max`, `population_base`, danh sách tech cấm, hero bắt buộc, các module bật, nhiệm vụ bắt buộc/tùy chọn, budget reinforcement và vùng spawn. Không tự ý thay chỉ số quân cốt lõi qua một trigger khó thấy.

| Sự kiện | Điều kiện | Hành động và chống lỗi |
|---|---|---|
| Capture một điểm quân sự | Ít nhất ba quân chiến đấu của người chơi trong bán kính 4; không có quân chiến đấu địch hoặc công trình có garrison địch trong vùng kiểm soát 8 | Tích lũy 30 giây liên tục; contested thì dừng, bỏ trống thì giảm tiến độ 2 giây/giây. Các mốc giữ 60/90 giây ở nhiệm vụ tính sau khi chiếm. |
| Giải phóng một nhóm | Hoàn tất thương lượng hoặc hạ đồn được đánh dấu | Đổi chủ một lần theo ID nhóm. Hết chỗ dân thì báo cần nhà; nhóm chờ ở nơi trú, không spawn chồng và không thưởng lại khi tái chiếm. |
| Một trại buông cờ | Quân đồn trú ban đầu còn tối đa 25%, rồi cờ trại không contested trong 30 giây | Chuyển nhóm còn lại sang đầu hàng, ngừng nhận lệnh tấn công; chốt `surrendered=true`. Quân viện còn sống vẫn contest cờ. |
| Haufen rút khỏi vùng ở B3 | Đã xảy ra Rout và số quân của nhóm còn trong vùng dưới 25% quân số xuất phát | Chốt mục tiêu của nhóm; không cần tiêu diệt mọi người đang rút. |
| Reinforcement | Đến mốc thời gian hoặc hoàn tất cờ nhiệm vụ | Báo trước ít nhất 45 giây; xuất hiện ở đường biên có thể đi tới. Có budget hữu hạn và giới hạn quân hoạt động. |
| Vật phẩm tới đích | Carrier mang đúng item ID đi vào đúng vùng nhận | Đánh dấu giao một lần; không cộng điểm vì đứng trong vùng mỗi tick. Một điểm nhận không thay được ba địa điểm khác nhau ở A2. |
| Mục tiêu trở nên bất khả thi | Đã hoàn tất + số đối tượng còn có thể hoàn tất < số cần | Thông báo rõ nguyên nhân và thua ngay; không để người chơi mắc kẹt với một nhiệm vụ không thể đạt. |

Mọi timer dùng **game seconds**, dừng khi pause. Save/load lưu tiến độ, ownership, ID đối tượng, cooldown, lương đã tính, khoản nợ, các đợt reinforcement đã chạy và flags thưởng. Không reset những dữ liệu này khi load hoặc recapture.

Thứ tự xử lý trong cùng tick: cập nhật di chuyển/combat và sự kiện giao vật phẩm → chốt tử vong/đầu hàng → thu nhập và thanh toán đã tới hạn → cập nhật module → đánh giá thất bại bắt buộc → đánh giá thắng → cutscene. Nếu điều kiện bảo vệ một đối tượng còn hiệu lực và đối tượng chết đúng tick đạt hạn, thất bại có ưu tiên; A6 đòi Banner còn sống tại mốc 18:00. Sau khi thắng đã chốt, dừng combat và các trigger gây thua trước khi chuyển cảnh.

Quân sinh theo script chỉ được tính Salvage khi đã trừ đúng giá tuyển từ budget AI và có metadata `paid_recruitment=true`; mọi free gift, hero, civilian, quân đã từng đổi phe vẫn tuân theo loại trừ của Phase 1. Salary, tiền thưởng và giá trị công trình không đi vào Salvage. Không dùng vòng spawn miễn phí để nuôi kinh tế người chơi.

### 4.2. Alert — phát hiện tổ chức bí mật ở A1

Alert là biến 0–100 của A1, bắt đầu ở 0; không phải tàng hình hoặc một chỉ số của faction.

| Hành vi | Thay đổi Alert |
|---|---|
| Tuần tra nhìn thấy cuộc họp đang diễn ra, người mang vật phẩm cấm hoặc nhóm từ bốn quân vũ trang | +2/giây, cap tổng +4/giây dù nhiều patrol cùng thấy |
| Đánh lính/đồn địa phương | +15 cho mỗi giao chiến mới, cooldown 30 giây toàn màn |
| Hoàn thành một cuộc họp | Không tự tăng Alert nếu không bị quan sát |
| Không bị quan sát và không giao chiến 20 giây | Sau đó -1 mỗi 3 giây, thấp nhất 0 |

Mốc 30 mở thêm tuần tra; mốc 60 đóng tuyến đường chính nhưng còn hai đường vòng; mốc 100 phát báo truy bắt 120 giây. Mỗi mốc tăng cường chỉ kích hoạt một lần, không spawn lại khi Alert xuống rồi lên. Khi truy bắt đã bắt đầu, giảm Alert không hủy countdown. Patrol và tầm nhìn được giải thích bằng minimap/đường tuần tra; đối phương không biết người chơi ở đâu nếu chưa phát hiện.

### 4.3. Zeal và Fear — hai thanh riêng, không phải một trục thiện/ác

Module bật cho quân nổi dậy ở A4–A6 và những AI Haufen được chỉ định ở B3–B6. Mỗi lực lượng có **Z=Zeal** và **F=Fear**, đều 0–100. Người chơi có thể vừa rất nhiệt thành vừa hoảng sợ; thương vong không mặc định làm quân mạnh hơn.

**Giá trị xuất phát Normal:** A4 Z=50/F=15; A5 Z=50/F=20; A6 Z=75/F=35. Đặt `R`, quân số tham chiếu cố định của lực lượng, lần lượt 80/60/100. R của mỗi AI Haufen ghi trong dữ liệu scenario, không thay đổi khi người chơi tuyển thêm hoặc giết bớt quân.

| Sự kiện | Zeal | Fear | Giới hạn |
|---|---:|---:|---|
| Mỗi quân chiến đấu của lực lượng chết trong combat | 0 | +100/R | Tối đa +20 Fear từ thương vong trong mỗi cửa sổ trượt 10 giây |
| Preacher của lực lượng chết | -5 | +10 | Tối đa một sự kiện mỗi 30 giây; không cộng thêm như quân chiến đấu thông thường |
| Giải cứu một nhóm hoặc hoàn thành một mục tiêu cộng đồng | +10 | -5 | Một lần cho mỗi objective ID; tối đa +40 Zeal từ loại sự kiện này mỗi màn |
| Mất kho hậu cần/điểm hiệu kỳ được đánh dấu | 0 | +15 | Một lần cho mỗi ID; lấy lại rồi để mất không kích hoạt lại |
| Tập hợp gần Church/điểm rally có Preacher hoạt động, không nhận damage hay có quân địch trong bán kính 8 suốt 20 giây | +1/10 giây, tối đa Z=60 | -2/5 giây | Không stack nhiều Preachers; rời vùng thì dừng hồi |

Quân bị xóa, sơ tán, giải ngũ hay đầu hàng không phải combat death. Villagers và dân sơ tán không nằm trong mẫu quân chiến đấu; mất nhóm dân có thể là sự kiện kịch bản một lần được công bố, không tạo Zeal. Các biến đều clamp trong 0–100.

| Trạng thái | Điều kiện và hiệu ứng |
|---|---|
| Steady | F<60; chiến đấu đúng chỉ số Phase 2. |
| Wavering | F=60–79; cảnh báo âm thanh/UI. Chưa áp dụng debuff ẩn. |
| Frenzy — chủ động | Z≥70, F≥60, có Preacher hoạt động không garrison, cooldown chung đã sẵn sàng. Tiêu 40 Z; F giảm về tối đa 60. Trong 20 giây, bộ binh cận chiến của lực lượng có attack period chia 1,15 và không Rout. Không tăng giáp, HP, class bonus hoặc attack damage. |
| Exhausted | Hết Frenzy: F giảm về tối đa 65; trong 15 giây attack period ×1,20, chưa tái kích hoạt Rout. Sau đó quay lại kiểm tra ngưỡng. Cooldown Frenzy 90 giây tính từ lúc kích hoạt. |
| Rout | F≥80 liên tục 3 giây và không trong Frenzy/Exhausted/cooldown Rout. Bộ binh cận chiến rút về rally đã đặt trong 8 giây, không tấn công. Hết đợt: F=50, cooldown Rout 60 giây. Không đổi phe, xóa quân hoặc tăng tốc miễn phí. |

Scope hiệu ứng là melee infantry có cùng `force_id`, không gồm hero, support, cavalry, ranged, siege, dân hoặc đồng minh khác chủ. Các quân melee tuyển mới được gán đúng force ID; không được tạo lực lượng mới bằng cách đổi control group. Nếu đường rút tới rally không đi được, quân giữ vị trí trong thời gian rối loạn thay vì chạy qua vách; người chơi được đặt lại rally. Ở Story difficulty, Rout đổi thành giữ quyền điều khiển nhưng attack period ×1,25 trong 8 giây.

AI dùng cùng ngưỡng và cooldown: tự bật Frenzy khi đủ điều kiện và đang giao chiến. Người chơi nhận cảnh báo ở F=60, F=75 và khi cửa sổ Frenzy sẵn sàng. UI chỉ số giải thích tác động và thời gian còn lại.

**Kiểm tra stacking:** Flailman có attack period 2 giây trở thành 2/1,15≈1,739 giây khi Frenzy. Aura +1/+2 attack của Preacher vẫn theo Phase 1 và không cộng lặp giữa nhiều Preachers. Sau đó attack period là 2×1,20=2,4 giây trong Exhausted. Bonus attack rate không biến thành bonus movement hoặc armor. Không kích hoạt Zeal/Fear ngoài campaign.

### 4.4. Printing Press — mục tiêu kinh tế quân sự có thể tranh chấp

Máy in là objective building đặt sẵn, **1.000 HP, giáp 1/4**, không bắn, không chứa quân và không phải điểm giao tài nguyên. Không có nút xây thêm từ Villager. Sửa chữa được khi còn sống; phá hủy thì không tái sinh trong màn, trừ sự kiện sửa xưởng được công bố riêng từ briefing.

**Chiếm máy in:** một Villager đứng trong bán kính 2, không có quân địch hay garrison địch trong vùng 6, trong 30 giây. Tiến độ dừng khi contested, giảm 2 giây/giây khi người chiếm rời đi. Đổi chủ không hồi HP. Một công trình có đúng một owner; bonus không chia cho đồng đội.

Bundschuh được kích hoạt tối đa **hai máy in** cùng lúc. Mỗi máy chọn một chế độ, có cooldown đổi mode 30 giây; máy thứ ba chỉ là dự phòng hoặc mục tiêu phủ nhận đối phương.

| Chế độ | Hiệu ứng |
|---|---|
| Recruitment | +15% tốc độ tiến độ tuyển **quân chiến đấu đi bộ** tại Barracks/Range mỗi máy; tối đa +30%. Không áp dụng Villagers, Preachers, hero, cavalry, siege hoặc quân thưởng. |
| Research | +10% tốc độ tiến độ nghiên cứu **military unit upgrades, Blacksmith và UT** mỗi máy; tối đa +20%. Không tăng tốc lên Age hoặc economic upgrades. |
| League confiscation | Máy bị vô hiệu hóa; Bundschuh mất bonus. Không tăng tốc tuyển Ritter, không tạo Gold thụ động cho League. |

Không được tính một máy cho cả Recruitment lẫn Research cùng lúc. Mất máy chỉ giảm tốc độ tiến độ từ thời điểm đó; không hủy quân, không reset research và không hoàn tiền. Công thức với n máy Recruitment là:

`train_time = train_time_base × existing_time_modifiers / (1 + 0,15 × n)`

Ví dụ Flailman: 16 giây; có Haufen là 12; thêm hai máy Recruitment là **12/1,30≈9,23 giây**. Chỉ có một máy là **10,43 giây**. Vẫn phải trả 39F/15W và có population; không sinh quân miễn phí. Các modifier research dùng nguyên tắc tiến độ tương tự, không cộng phần trăm tốc độ thành phần trăm giảm thời gian.

**Kiện bản in A2:** 25W/10G, 60 giây tại một máy còn hoạt động. Một máy in một kiện mỗi lần; task này không bị tăng tốc bởi bonus Research. Cần một courier/Villager mang tới điểm nhận, một carrier chỉ mang một kiện. Carrier chết thì kiện rơi tại chỗ; nếu bị hủy có thể in lại. Mỗi nơi chỉ nhận một kiện có tính objective. Kiện không phải tài nguyên thứ năm có thể bán/đổi lấy Gold.

AI League ưu tiên raid máy in bằng cavalry nếu đường mở, hoặc bắn phá từ ngoài tầm chốt. Dàn máy in cạnh quân phòng thủ có nghĩa phải phân bổ lực lượng, không có aura phòng thủ tự thân. Trong B4, phá máy và tịch thu là hai đường hoàn thành cùng một mục tiêu; không cộng thưởng hai lần.

### 4.5. Mercenary Contracts — tiền lương trong campaign League

Payroll áp dụng cho Landsknechts mang tag `mercenary_contract`, gồm các công ty cấp sẵn và quân tuyển mới trong B1–B6. Ritter, Villagers, guns và các đơn vị không mang tag không chịu phí này. Đây là ngoại lệ campaign có UI riêng; Landsknecht trong ranked vẫn không upkeep.

**Tuyển và tổ chức:** dùng Barracks, chi phí 55F/35G và 26 giây của Phase 2. Quân vào các công ty tối đa tám người; công ty đang nợ không nhận quân mới cho tới khi trả nợ. Không mua cả công ty bằng một nút spawn tức thì. Tám Landsknechts tốn tổng **440F/280G**, chưa tính lương; Elite/Drill hoạt động như Phase 2.

**Mức lương đề xuất:** 5G mỗi quân cho mỗi 120 giây phục vụ, tính theo thời gian thực sự còn trong biên chế:

`invoice_G = ceil(5 × total_unit_seconds_during_period / 120)`

Một công ty đủ tám người phục vụ trọn kỳ trả **40G/120 giây = 20G/phút**. Bốn công ty đủ người trả 80G/phút. Nếu bốn trong tám người tử trận giữa kỳ, hóa đơn là 30G; cái chết không xóa tiền công đã tích lũy. Thời gian sống khi garrison, idle hoặc đang giao chiến đều tính; đổi tên/đổi control group không reset hợp đồng.

| Trạng thái | Trigger và tác động |
|---|---|
| Paid | Đúng hạn, tự động trả đủ invoice nếu bật autopay và đủ Gold. Không có buff damage vì trả dư. |
| Warning | Trước kỳ lương 30 giây, UI báo khoản dự kiến và tiền hiện có. |
| Arrears | Hóa đơn quá hạn: lưu nợ, bật cảnh báo; trong 60 giây đầu quân vẫn hoạt động bình thường. |
| Refusal | Quá hạn 60 giây: công ty không nhận lệnh tiến công mới, có thể rút, giữ chỗ và tự vệ; không tự biến thành quân địch. |
| Desertion | Khoản cũ nhất quá hạn 120 giây: quân ngừng chiến đấu, rút về điểm rời quân ngũ rồi bị loại khỏi biên chế, giải phóng population. Sau tối đa 30 giây chúng rời biên chế dù đường bị chặn; garrison cũng không giữ quân lại. Không để lại loot/Salvage và không tính combat death. |

Thanh toán toàn bộ hóa đơn quá hạn phục hồi quyền điều khiển ngay trước khi Desertion đã chốt. Các kỳ vẫn theo lịch 120 giây cố định; trả muộn không kéo dài kỳ tiếp theo. Hóa đơn mới tiếp tục ghi tiền công đã phục vụ, nên không có lợi ích từ việc cố tình trả sát hạn. Nếu cả công ty đã chết/đào ngũ, hợp đồng đóng và không phát sinh kỳ mới; nợ chỉ tồn tại trong màn, không truyền sang campaign tiếp theo.

Autopay mặc định bật, trả các khoản đến hạn theo ID công ty ổn định trước các lệnh chi tiêu mới cùng tick; người chơi có thể tắt. UI hiển thị Gold khả dụng, các khoản đến hạn và đồng hồ. Dự trữ lương là lựa chọn trong ngân sách Gold hiện có, không tạo tài nguyên mới.

**Kinh tế để cơ chế có quyết định:** mỗi màn có ít nhất một nguồn Gold khai thác được và một đường bổ sung như convoy hoặc Market exchange. Mất một đoàn xe làm người chơi thu hẹp lực lượng hoặc đổi nguồn thu, không tức thì mất cả quân đội. Lương mục tiêu chiếm khoảng 10–20% Gold chi tiêu của một lượt Normal thông thường; đo bằng playtest, không coi đây là tỷ lệ đã đạt.

### 4.6. Hero và các đối tượng nhiệm vụ

| Đối tượng | Quy tắc |
|---|---|
| Müntzer | Campaign hero dùng chức năng Preacher: 80 HP cơ sở thay 35, không attack, heal như Phase 2; aura chỉ từ A3. A1 là ngoại lệ cấp sẵn hero trước tuổi, được ghi trong briefing. Sanctity/Fervor áp dụng nếu màn có tech. Không xuất hiện như combat unit ở A6. |
| Waldburg | Campaign hero dùng Ritter: 180 HP cơ sở thay 125; attack, armor, speed và nâng cấp theo Phase 2. Không có splash, invulnerability hoặc charge mới. |
| Anna | 70 HP, giáp 0/0, speed 1,10; không attack, không aura; có thể mang vật phẩm nhiệm vụ. |
| Xe hậu cần | 180 HP, giáp 0/3, speed 0,80; không bắn, không sinh Gold ngoài sự kiện giao hàng; không garrison. |
| Dân sơ tán/courier | Stats và khả năng phòng vệ thấp, ID cố định; chỉ những người có tag nhiệm vụ được tính vào mục tiêu cứu người. Không thay bằng dân mới tuyển. |

Hero không thể tuyển lại, không tự hồi sinh và không bị Cleric chuyển phe. Đối phương có cùng quy tắc khi dùng hero. Tất cả ngoại lệ nằm trong lớp campaign, không chỉnh template unit của skirmish. Không mang quân, Gold hay buff vô hạn từ màn này sang màn khác; chỉ lưu huy chương, codex và kết quả kể chuyện.

## 5. Độ khó, nhịp chơi và mục tiêu kiểm thử campaign

| Tham số | Story | Normal | Hard |
|---|---:|---:|---:|
| Tài nguyên mở màn ở màn có economy | ×1,25 | ×1,00 | ×0,90 |
| Quy mô reinforcement AI | ×0,80, làm tròn theo loại quân | Theo ngân sách màn | ×1,15 |
| Khoảng cách giữa đợt quân | ×1,20 | ×1,00 | ×0,90 |
| Thời gian báo trước đợt lớn | 90 giây | 60 giây | 45 giây |
| Lương mercenary | 4G/120 giây/quân | 5G | 5G |
| Rout của quân người chơi | Giữ điều khiển, attack period ×1,25/8 giây | Rút 8 giây | Như Normal |
| Deadline mục tiêu | Công bố theo màn | Công bố theo màn | Công bố theo màn |

Không đổi giáp hoặc class bonus bí mật theo difficulty. Kích thước các đợt là tham số tuning; không đồng thời tăng cả số quân, HP, damage và thu nhập AI vô hạn.

A6 giữ nguyên mốc giữ Banner 18 phút và cửa sổ tối đa 24 phút trên mọi độ khó; Story giảm áp lực wave, không bắt người chơi chơi lâu hơn để được dễ hơn. Các mốc lịch sử không đổi theo difficulty. Autosave trước giai đoạn mới và trước một quyết định tuyến đường; game lưu đúng module state.

**Mục tiêu cho greybox:** lần đầu chơi Normal có thể hiểu nguyên nhân thất bại; ít nhất hai đội hình/đường đi khả thi ở mỗi màn có combat; không mục tiêu phụ nào là điều kiện bí mật để thắng màn sau. Đo thời gian tới lần cảnh báo đầu, tỷ lệ mất đối tượng bắt buộc, số lần không hiểu objective và số reload tại cùng một trigger.

## 6. Ba random-map archetypes trên bộ

### 6.1. Tham số và luật công bằng dùng chung

Đây là **đặc tả RMS**, chưa phải mã cho một engine cụ thể. Bản 1v1 dùng 160×160 ô; 2v2 dự kiến 224×224; 4v4 320×320. Map team tăng resource budget theo số người và duy trì đường liên lạc nội bộ mỗi đội.

Spawns 1v1 theo hai nửa đối xứng chiến lược, xoay 180 độ; trang trí có thể khác. Mục tiêu khoảng cách TC–TC theo đường bộ 90–125 ô; generator loại seed không đạt sau khi đặt vật cản. Địa hình/resource quan trọng đặt theo cặp, sau đó mới thêm décor không chặn đường.

| Ngân sách gần nhà, mỗi người | Mức khởi đầu đề xuất |
|---|---|
| Food | 2.000 đơn vị trong 2–3 cụm, cách TC 7–18 ô |
| Gold | 4.800, chia mỏ chính 3.200 và mỏ phụ 1.600, cách TC 10–22 ô |
| Stone | 1.400, chia hai cụm 700, cách TC 12–24 ô |
| Wood | Ít nhất 6.000 tổng trữ lượng trong bán kính 24; ít nhất hai mép rừng có thể tiếp cận |
| Khoảng trống xây dựng | Bán kính 6 quanh TC không có cliff, nước, resource hoặc vật cản; thêm vùng xây mở rộng tới bán kính 10 ngoài các cụm Food; đường ra tối thiểu hai hướng |

Đây là **trữ lượng trên bản đồ**, không cộng vào tài nguyên mở trận 200F/200W/100G/200S đã chốt ở Phase 2. Các con số trữ lượng phải được quy đổi thành node của engine khi dựng generator. Food/Wood gather bonus của Bundschuh không làm tăng yield của các node.

Ngoài vùng gần nhà, mỗi người có một cụm mở rộng 1.600G + 700S ở khoảng 28–40 ô. Phần tranh chấp chung trong 1v1 là bốn cụm Gold, mỗi cụm 1.600, và hai cụm Stone, mỗi cụm 700. Vị trí thay đổi theo archetype nhưng tổng ngân sách không đổi. Không đặt toàn bộ Gold ngoài nhà sau một cầu duy nhất.

1v1 dùng một relic trung tâm và hai relic đối xứng; team games dùng số lẻ 2N+1 relic với N là số người mỗi đội. Relic không nằm trên đảo cần tàu. Chưa dùng relic count để che một map thiên vị tài nguyên.

Ba archetype không có Printing Press, Alert, Zeal/Fear hoặc payroll trong ranked. Nếu sau này có custom mode với các cơ chế đó, dùng tên/ruleset riêng và bảng thống kê riêng.

### 6.2. Cao độ: một quy tắc chung, không phá range đã cân bằng

Phase 2 chưa chốt height modifier. Trong prototype Phase 3, ô có elevation level 2 trở lên cho đơn vị/công trình trên đó **+2 LOS**, chỉ một lần dù cao thêm. Công trình cần footprint bằng phẳng. Cao độ **không tăng attack range, damage hoặc armor** trong v0.3; như vậy bảng counter và cửa sổ outrange Phase 2 vẫn đúng.

High ground có giá trị nhờ quan sát sớm, các ramp dễ bảo vệ và không gian đặt công sự. Field Cannon Bundschuh vẫn có range tối đa 10; cannon League fully upgraded tối đa 12; castle/tower không được bắn xa hơn chỉ vì ở trên đồi. Đây là quy tắc terrain mới áp dụng đều cho cả hai phe, không phải civ bonus.

Rừng là vật cản di chuyển và định hình đường vòng, không tự cho quân invisibility. Ambush cần nằm ngoài LOS đối phương; không ẩn một đội quân đã được scout chỉ vì đứng cạnh cây. Thiết kế này không yêu cầu thêm mô hình che khuất tầm nhìn bởi từng cây để hoạt động.

### 6.3. Black Forest Borders — Schwarzwald

**Hình dạng:** hai vùng nhà mở đủ chỗ phát triển, nối bằng ba hành lang uốn quanh các khối rừng lớn. Một đường trung tâm rộng 12 ô; hai đường biên rộng tối thiểu 8 ô. Các hành lang mở từ đầu, không bắt buộc chặt cây mới gặp được đối thủ.

| Thuộc tính | Tham số/layout |
|---|---|
| Tỷ lệ rừng | Khoảng 45–55% diện tích, sau khi chừa corridor và vùng nhà |
| Chokepoints | Mỗi hành lang có 1–2 đoạn hẹp; các cửa chốt chính cách nhau ít nhất 32 ô |
| Vùng mở rộng | Hai túi đất bên sườn có hai lối vào mỗi túi; Gold không bị vây kín bởi cây |
| Tài nguyên tranh chấp | Gold phân tán ở bốn clearing; Stone ở hai clearing khác, không gom cùng một pháo đài |
| Tuyến phụ qua chặt cây | Có thể mở một đường ngắn mới bằng 4–8 lớp cây; chỉ là lợi thế thêm, không phải lối đi bắt buộc |

**Bundschuh:** tận dụng Wood dồi dào, nhiều Barracks, tiếp viện và raid vào clearing bên sườn. Flailmen đánh infantry ở chỗ đủ rộng, Pike bảo vệ khỏi Ritter đột kích; cần scout để không đưa cả horde vào một cửa hẹp.

**League:** thủ một trục bằng Landsknechts/Arquebusiers, lấy Gold mở rộng và đưa cannon mở trận địa. Heavy cavalry có tác dụng ở các clearing hoặc đường vòng; không nên tập trung toàn bộ đầu tư vào cavalry rồi đứng nghẽn.

**Rủi ro cần đo:** tường kín quá sớm biến map thành cuộc đọ cannon có lợi quá lớn cho League. Chống bằng ba tuyến độc lập, khoảng cách chốt và resource phân tán; không tăng bí mật tốc độ Flailman xuyên rừng. Nếu các clearing chỉ có một cửa thực sự đi được, seed bị loại.

### 6.4. Rhine Valley Plains — Đồng bằng thung lũng Rhine

**Hình dạng:** sông chạy gần trục giữa, ngăn hai vùng đất rộng. Ba lối vượt cố định: một cầu trung tâm rộng 12 ô và hai ford/cầu biên rộng 8–10 ô. Bờ và đường vượt đủ cho cannon, cavalry và đoàn infantry; không có đảo tài nguyên bắt buộc đi thuyền.

| Thuộc tính | Tham số/layout |
|---|---|
| Lòng sông | Rộng khoảng 14–20 ô ở phần ngăn hai bờ; đi bộ chỉ qua các crossing |
| Khoảng cách crossing | Ít nhất 32 ô giữa tâm các lối vượt; không một castle nào khóa hai đầu crossing khác nhau |
| Không gian cơ động | Mỗi bờ có các dải trống rộng 20–30 ô; khoảng 15–25% map là rừng theo cụm |
| Resource ngoài nhà | Gold/Stone mở rộng nằm hai phía cánh, không chỉ sát cầu trung tâm; lượng hai bên bằng nhau |
| Độ bền tuyến | Bridge/ford là terrain không phá hủy; cấm xây trên phần vượt và dải đệm 2 ô, vẫn được giao chiến/giữ đầu cầu |

**League:** cavalry chuyển cánh nhanh sau khi qua sông; giáp và pháo giúp mở bàn đạp. Thế mạnh phụ thuộc khả năng nuôi quân và giữ Gold, không được tặng thêm Gold vì map này mang tên Rhine.

**Bundschuh:** pháo/ranged giữ một crossing, dùng infantry rẻ và Light Cavalry gây áp lực crossing khác; tận dụng kinh tế Food để bù tổn thất. Ba tuyến buộc đối phương chia công sự.

**Trade:** trong 2v2/4v4, mỗi đội có đường Market liên kết dọc vùng đất của mình, đủ dài và có rủi ro bị flank raid. Trong 1v1 không có Gold tự sinh từ trade với chính mình hoặc với Market trung lập; dùng mines, relic và Market exchange theo Phase 2.

**Rủi ro cần đo:** một phe vừa thủ cả sông vừa boom an toàn. Chống bằng crossing phân tán, vị trí Gold hai cánh và không cho đặt building trực tiếp trên cầu. Những điều này không làm đầu cầu miễn bị phong tỏa quân sự; người chơi vẫn phải mở một đường qua bằng chiến thuật.

### 6.5. Alpine Foothills — Chân dãy Alps

**Hình dạng:** hai thung lũng nhà, các cao nguyên lệch trục và một tuyến thấp vòng ngoài. Bốn mức cao độ 0–3; cliffs tạo mép không đi qua được, ramps là đường lên. Không dùng địa hình có nhiều tầng chồng nhau hoặc cầu vượt vượt khả năng pathfinding của engine.

| Thuộc tính | Tham số/layout |
|---|---|
| Tỷ lệ terrain | Rừng 25–35%; cliffs/đá không đi qua khoảng 15–20%; phần còn lại là thung lũng, sườn và plateau |
| Tuyến chiến lược | Hai đường đèo chính rộng tối thiểu 8 ô và một đường thung lũng phụ rộng 10 ô |
| Plateau then chốt | Hai plateau đối xứng, mỗi plateau tối thiểu 24×24 ô trống và có hai ramp cách nhau ít nhất 32 ô theo đường đi |
| Vị trí resources | Stone mở rộng gần chân đèo; Gold tranh chấp chia ở cả valley và plateau, không buộc phe ít Stone phải công thành ngay để tiếp tục chơi |
| Vùng siege | Có mặt bằng tiếp cận cách vị trí công sự dự kiến 10–12 ô; đủ chỗ unpack và đường lui |

**League:** chiếm một plateau để dựng công sự và kiểm soát lối lên; dùng infantry làm lá chắn khi kéo artillery. Giữ hai cao điểm cùng lúc phải trả thêm Stone, Gold và quân phòng thủ.

**Bundschuh:** mở nhiều tuyến bằng infantry, đánh vào workers đang xây fort, kiểm soát thung lũng và chiếm resource ở sườn khác. Field Cannon còn có cơ hội bắn công sự nếu bảo vệ được vị trí; không bị một height bonus range tùy tiện triệt tiêu vai trò.

**Rủi ro cần đo:** một plateau cao duy nhất quyết định cả trận; ram/cannon không quay đầu được tại ramp; chênh lệch đường đi khiến cùng trữ lượng mà một phe lấy Gold chậm hơn. Mỗi plateau có hai ramp và còn một tuyến thấp độc lập để giảm các rủi ro này.

### 6.6. Các bước generator và tiêu chí nhận seed

1. Đặt spawn, vùng nhà và khoảng trống xây dựng; tạo các hành lang chiến lược.
2. Đặt sông/cliff/rừng theo archetype, giữ phần đường đã dành trước.
3. Đặt resources thành cặp theo ngân sách; kiểm tra đường Villager tới từng cụm.
4. Đặt crossings/ramps, relic và các plateau đủ footprint xây dựng.
5. Chạy kiểm tra đường đi cho Villager, cavalry và cannon; kiểm tra độ rộng thật sau décor.
6. Kiểm tra khoảng cách, tài nguyên và vị trí quân sự; seed hỏng bị loại và tạo lại có giới hạn số lần thử.

| Kiểm tra | Tiêu chí ban đầu |
|---|---|
| Kết nối | TC hai bên có đường bộ; có ít nhất ba hành lang chiến lược độc lập ở miền tranh chấp. Mọi node Gold/Stone/relic đều tới được bằng bộ. |
| Độ rộng | Cannon đi và quay được ở corridor/ramp; không tính một ô décor hẹp là một “đường thứ ba”. Chừa tối thiểu bề rộng đã định cho từng archetype. |
| Resource parity | Tổng trữ lượng từng loại bằng nhau theo cặp; khoảng cách đường đi tới mỏ chính chênh tối đa 2 ô, tới mỏ phụ tối đa 10%. |
| Tầm công sự | Không vị trí castle hợp lệ nào khống chế mọi tuyến; plateau/crossing khác nhau không cùng nằm trong một vùng phủ bắn 9 ô. |
| Tầm siege | Có chỗ triển khai pháo và đường tiếp cận bằng bộ; không đặt mục tiêu sau một mép cliff hoàn toàn bất khả công kích. |
| Team economy | Đường trade không bị nút cổ chai một ô; độ dài tuyến tiềm năng của hai đội chênh không quá 10%. Không có trade nội bộ một player ở 1v1. |

Các kiểm tra trên là yêu cầu cho generator tương lai, chưa được chạy trên một tập seed. Đối xứng tài nguyên không tự chứng minh matchup cân bằng; terrain vẫn tạo lợi thế khác nhau cần đo.

## 7. Rà soát và kế hoạch dựng prototype

### 7.1. Những điều phải giữ khi triển khai

- Không đưa Müntzer tới Memmingen để viết Twelve Articles; A2 là interlude với nhân vật hư cấu.
- Không cho Waldburg chỉ huy tại Frankenhausen; Princely Host chỉ tái sử dụng mẫu balance League.
- Weinsberg được đặt sau Böblingen theo ngày xảy ra cuộc trả đũa; phần siege là tái dựng được gắn nhãn.
- Kết thúc A6 không giết một hero bất tử để phủ nhận chiến thắng. Người chơi thắng mục tiêu sơ tán, còn kết cục lịch sử được kể riêng.
- Bundschuh không được mở cavalry nặng, Heavy Cannon hoặc armor tier bị khóa chỉ vì campaign lên Age 4.
- Printing Press không tự tạo quân và không buff lên Age; payroll không lọt vào ranked.
- Fear từ thương vong không tạo Zeal; không có loop hy sinh quân để buff vô hạn.
- Heroes, dân cứu, xe, support và siege đều được tính population; cap hiển thị không nhân bonus phe hai lần.
- Cả ba random maps đều thắng được bằng bộ, với siege và counters hiện có.

### 7.2. Ba lát cắt prototype ưu tiên

| Prototype | Câu hỏi cần giải quyết | Dữ liệu cần ghi |
|---|---|---|
| A2, bản nhỏ | Máy in có tạo quyết định chia quân, hay chỉ là bonus đặt ở góc an toàn? | Uptime của từng máy, số lần đổi chủ, Flail throughput, tỷ lệ thiệt hại courier, thời gian phản ứng trước raid |
| B3 | Cavalry và artillery có tạo lợi thế phối hợp mà Pike vẫn phản công được? | Thiệt hại theo loại quân, số đòn anti-cavalry nhận, thời gian cannon bắn/di chuyển, Gold dành cho lương |
| A6 | Người chơi thấy thất bại là do quyết định có thể sửa, hay do scenario cưỡng ép? | Tỷ lệ sơ tán theo cửa, giờ mất Banner, Fear/Frenzy events, số reload, số trận mục tiêu trở nên bất khả thi |

Sau đó mới dựng toàn bộ 12 màn và một tập seed đủ đa dạng cho ba archetype. Với skirmish, so matchup hai chiều cùng seed, đổi spawn, theo dõi thời điểm lên Age, resource control, siege uptime và kết quả theo trình độ. Không đặt mục tiêu ba map phải có cùng cảm giác hoặc một con số win rate được coi là đã chứng minh.

### 7.3. Các ca kiểm tra cụ thể trước khi duyệt greybox

| Ca | Kết quả cần đạt |
|---|---|
| Đủ mục tiêu thắng và hero chết cùng tick | Theo thứ tự đã công bố: thua nếu hero là đối tượng bắt buộc còn hiệu lực. |
| Mất Banner sau khi A6 đã giữ được tới 18:00 | Mục tiêu giữ Banner vẫn hoàn thành; còn thời gian tới 24:00 cho sơ tán. |
| 17/40 dân A6 chết khi chưa đủ người đã thoát | Báo bất khả thi và thua; tuyển dân mới không sửa được ID nhiệm vụ. |
| B4 tù binh bị đối phương cứu, sau đó bắt lại | Có thể hoàn thành; không được cộng hai lần điểm bắt. Tù binh chết thì thua vì cần cả hai. |
| Press đổi chủ trong lúc đang nghiên cứu | Progress giữ nguyên; chỉ đổi rate tương lai, HP không hồi đầy. |
| Haufen + hai Press Recruitment | Flailman 9,23 giây; vẫn 39F/15W và 1 population. |
| Nhiều Preachers, Frenzy và aura A4 | Aura attack chỉ +2; attack period đúng 2/1,15; hết hiệu ứng trả đúng modifier. |
| Contract chết nửa quân giữa kỳ, hoặc trả sát hạn | Unit-seconds và lịch kỳ lương không reset; không có tiền công âm/miễn phí ngoài quy tắc. |
| Save/load ở 119 giây của một kỳ lương | Chỉ xuất một hóa đơn; không lặp paycheck, convoy reward hay wave. |
| Spawn viện trợ khi đang đầy population | Chờ tại reserve/off-map cho tới có chỗ; không mất quân, không vượt cap. Đối tượng nhiệm vụ xuất phát đã được tính trước. |
| Cả ba crossing Rhine bị công sự giữ | Còn đường bộ vật lý, units/siege có thể đánh mở; không đòi một unit hải quân không tồn tại. |

## 8. Nguồn lịch sử và giới hạn tái dựng

Các nguồn dưới đây hỗ trợ **bối cảnh, địa điểm, nhân vật và kết cục**. Chúng không xác nhận chỉ số gameplay, bản đồ nén, các cuộc cứu dân cụ thể, máy in bị raid hoặc thủ tục hợp đồng đã thiết kế. Không chuyển các ước lượng quân số/thương vong khác nhau trong sử liệu thành số tuyệt đối trên UI.

- **[H1]** [Barbara Schratzenstaller, Historisches Lexikon Bayerns — Bauernkrieg, 1524–1526.](https://www.historisches-lexikon-bayerns.de/Lexikon/Bauernkrieg,_1524-1526) Phạm vi phong trào, các nhóm tham gia, Franken và niên biểu chiến sự.
- **[H2]** [Thomas-Müntzer-Gesellschaft — Zur Person Thomas Müntzer.](https://thomas-muentzer.de/vita/) Hành trình, Allstedt, việc bị bắt và ngày hành quyết.
- **[H3]** [Svenja Galla, LEO-BW — Thomas Müntzer.](https://www.leo-bw.de/themenmodul/bauernkrieg/personen/thomas-muentzer) Vai trò ở Mühlhausen, lời kêu gọi tháng 4 và giới hạn ảnh hưởng vùng.
- **[H4]** [German History in Documents and Images — The Twelve Articles of the Swabian Peasants.](https://germanhistorydocs.org/en/from-the-reformations-to-the-thirty-years-war-1500-1648/ghdi:document-4323) Bản dịch tư liệu và giới thiệu về tác giả, thời điểm soạn, lưu hành.
- **[H5]** [Leo Böhnisch, LEO-BW — Die Schlacht bei Böblingen.](https://www.leo-bw.de/themenmodul/bauernkrieg/militaerische-aspekte/boeblingen) Ngày trận đánh, vai trò của vị trí hỏa lực, artillery và cavalry.
- **[H6]** [Stadt Weinsberg — Historischer Hintergrund.](https://www.weinsberg.de/freizeit-und-kultur/500-jahre-bauernkrieg-weinsberger-blutostern/historischer-hintergrund/) Sự kiện 16/4 và cuộc trả đũa 21/5/1525.
- **[H7]** [Regionalmuseum Bad Frankenhausen — Battle on 15 May.](https://www.regionalmuseum-bfh.de/battle-on-15-may) Phe tham chiến, Wagenburg, kết cục và sự không chắc chắn trong tái dựng.
- **[H8]** [Regionalmuseum Bad Frankenhausen — Thomas Müntzer, Fateful Figure.](https://www.regionalmuseum-bfh.de/thomas-muentzer-fateful-figure) Việc đến Frankenhausen muộn nhất vào tối 11/5.
- **[H9]** [Magnus Haußmann, LEO-BW — Die Schlacht bei Leipheim.](https://www.leo-bw.de/themenmodul/bauernkrieg/militaerische-aspekte/leipheim) Trận ngày 4/4/1525 và việc đầu hàng.
- **[H10]** [LEO-BW — Weingartener Vertrag.](https://www.leo-bw.de/themenmodul/bauernkrieg/vertraege/weingartener-vertrag) Thỏa thuận miệng ngày 17/4 và văn bản ngày 22/4/1525.


