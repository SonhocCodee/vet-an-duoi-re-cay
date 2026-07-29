# Vết Ấn Dưới Rễ Cây - Sổ Ý Tưởng & Master Specs

> File ghi chú sống và Master Prompt tích hợp toàn bộ ý tưởng, thiết kế chi tiết, chỉ số cân bằng và prompt lập trình.
> Cập nhật lần cuối: 2026-07-29

---

## 1. Tổng quan dự án

- **Thể loại**: Game pixel fantasy top-down, action RPG, chơi offline singleplayer.
- **Cảm hứng góc nhìn/khám phá**: Stardew Valley (nhịp đời sống/lửa trại); nhưng tone là dark fantasy và chiến đấu hành động sâu sắc.
- **Engine**: Godot 4.x (GDScript typed 2D thuần).
- **Nhân vật chính**: Kael Asterion, mất trí nhớ, bị Giáo Hội Ánh Sáng gắn mác "Ma Vương".
- **Tên dự án**: **Vết Ấn Dưới Rễ Cây**.
- **Tagline**: *"Khi ánh sáng biết nói dối, bóng tối bắt đầu nhớ tên người."*

---

## 2. Cốt truyện canon & Trụ cột nội dung

- **Bản chất cuộc chiến**: Giáo Hội Ánh Sáng rút sinh lực của Cây Thế Giới để duy trì trật tự và quyền lực giả tạo.
- **Bản chất Hư Vô**: Hư Vô là nỗi đau/phản ứng tự vệ của Cây Thế Giới, không phải cái ác vô cớ.
- **Mảnh Vỡ Ánh Sáng**: Là các đinh phong ấn cắm sâu vào rễ Cây Thế Giới; Kael đi thu thập chúng vì tin lời Giáo Hội mà không biết mình đang giúp Giáo Hoàng đâm sâu thêm đinh phong ấn.
- **Thân phận Kael**: Kael từng là "Kẻ Giữ Rễ", bị vu oan thành Ma Vương để hợp thức hóa chiến tranh.
- **3 Companion & 3 Tuyến Tình Cảm / Tư Tưởng**:
  - **Aria**: Hiệp sĩ từng đâm Kael -> Chuộc lỗi và học cách chịu trách nhiệm.
  - **Elysia**: Phù thủy có gia tộc tham gia phong ấn -> Đi tìm sự thật và sự tha thứ.
  - **Cecilia**: Thánh nữ mù, bình chứa kế nhiệm của Giáo Hoàng -> Lòng thương xót, niềm tin tái sinh.
- **Khung nội dung**: 10 Chương chính. Mỗi chương có khu vực riêng, quest, lựa chọn đạo đức, lửa trại/hub sau cao trào và chủ đề thể hiện qua Boss.
- **True Ending**: Kael cứu thế giới trong im lặng; thế giới hồi phục chậm và nhiều người vẫn gọi anh là Ma Vương.

---

## 3. Hệ thống Chỉ số & Thăng tiến v0.1

### Bảng Thăng Tiến Cấp Độ & Chương

| Mốc | Cấp nhân vật | Chương | Giáp bậc | Ghi chú |
| --- | ---: | ---: | --- | --- |
| Mở đầu | 1-3 | 1 | 1 | Tutorial và học né/đánh thường |
| Đầu game | 4-10 | 2-3 | 2-3 | Mở class thứ 2 và miniboss đầu tiên |
| Giữa game | 11-20 | 4-6 | 4-6 | Mở đầy đủ 4 class, có build rõ ràng |
| Cuối game | 21-30 | 7-9 | 7-9 | Dùng trang bị để khắc chế boss |
| Kết game | 31-35 | 10 | 10 | Build hoàn chỉnh và boss cuối |

### Hệ Chỉ Số Cơ Bản

| Chỉ số | Ý nghĩa | Mốc khởi tạo | Giới hạn hướng tới |
| --- | --- | ---: | ---: |
| **HP** | Máu tối đa. Về 0 thì quay lại điểm lưu. | 100 | 850-1,050 |
| **ATK** | Sát thương đánh thường, kiếm và kỹ năng vật lý. | 12 | 95-125 |
| **MAG** | Sát thương phép, Ánh Sáng và một phần kỹ năng Hư Vô. | 8 | 80-115 |
| **DEF** | Giảm sát thương vật lý. | 5 | 75-110 |
| **RES** | Giảm sát thương phép/Hư Vô. | 5 | 70-105 |
| **STA** | Thể lực để né, đỡ đòn và kỹ năng nặng. | 100 | 140-180 |
| **CRIT** | Tỉ lệ chí mạng. 150% sát thương khi kích hoạt. | 5% | 30% |
| **SPD** | Tốc độ di chuyển. 100 là tốc độ chuẩn. | 100 | 125 |
| **HEAL** | Tăng hiệu quả hồi máu và khiên. | 0% | 35% |
| **VOID RES** | Kháng Hư Vô; giảm tích Corruption và debuff. | 0% | 55% |

---

## 4. Hệ thống Thăng Cấp, Cộng Điểm & Tiền Tệ

### Đường Cong Kinh Nghiệm (EXP Curve)
- **Cấp tối đa**: 35.
- **Công thức EXP yêu cầu**: `EXP_req(Level) = floor(100 * (Level ^ 2.15))`
  - Cấp 1 -> 2: 100 EXP | Cấp 5 -> 6: 3,180 EXP | Cấp 15 -> 16: 33,600 EXP | Cấp 35: 202,000 EXP.

### Phân Bổ Điểm Tiềm Năng (Stat Allocation)
Mỗi khi lên 1 cấp, Kael nhận được **5 Điểm Tiềm Năng** để tự do nâng chỉ số:
- **STR (Sức Mạnh)**: +2.5 ATK, +1.0 DEF (Ưu tiên Kiếm Vệ)
- **INT (Trí Tuệ)**: +2.8 MAG, +1.0 RES (Ưu tiên Pháp Kiếm Hư Vô)
- **VIT (Thể Lực)**: +18.0 HP, +1.5 DEF (Ưu tiên Hộ Vệ Rễ Cây)
- **DEX (Khéo Léo)**: +0.4% CRIT, +1.2 STA, +0.5 SPD (Lối chơi né lướt/chí mạng)
- **MND (Tinh Thần)**: +0.6% HEAL, +1.5 RES, +0.4% VOID RES (Ưu tiên Tu Sĩ Tro Tàn)
*Tẩy điểm*: Dùng vật phẩm `Nước Nguồn Tái Sinh` tại Bàn Lửa Trại.

### Hệ thống Tiền Tệ
1. **Vàng (Gold)**: Mua bán tiêu hao, cường hóa trang bị, tháo khảm.
2. **Mảnh Hồn Cổ (Soul Shards)**: Rơi từ quái Elite/Miniboss, đổi Cổ Ấn hiếm và Bản Thiết Kế.
3. **Bụi Ánh Sáng / Bụi Hư Vô**: Nguyên liệu rớt từ quái để đập đồ.

---

## 5. Thiết Kế 4 Class & 40 Bộ Giáp

### Khung 4 Class Nhân Vật
| Class | Vai trò | HP | ATK | MAG | DEF | RES | STA | Lối chơi |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| **Kiếm Vệ** | Cân bằng/cận chiến | 115 | 14 | 10 | 8 | 7 | 110 | Combo kiếm, parry và đổi sát thương lấy vị trí |
| **Hộ Vệ Rễ Cây** | Tank/bảo kê | 145 | 11 | 8 | 13 | 10 | 125 | Khiên, khiêu khích và chịu đòn cho đồng đội |
| **Pháp Kiếm Hư Vô** | DPS/khống chế | 90 | 8 | 17 | 4 | 9 | 100 | Phép tầm xa, bẫy, đánh đổi máu để lấy burst |
| **Tu Sĩ Tro Tàn** | Hỗ trợ/thanh tẩy | 105 | 7 | 15 | 6 | 13 | 115 | Hồi máu, khiên, debuff và cứu NPC |

### 10 Bộ Giáp Kiếm Vệ (Bậc 1 đến Bậc 10)
| Bậc | Tên bộ giáp | HP | ATK | DEF | RES | STA | CRIT | Set bonus |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | Dạ Hành Nhân | 20 | 3 | 2 | 1 | 5 | 0% | Đòn đánh thứ 3 tăng 10% sát thương |
| 2 | Sát Sương | 35 | 5 | 4 | 2 | 8 | 1% | Né thành công hồi 8 STA |
| 3 | Đồng Tro | 50 | 7 | 6 | 3 | 10 | 2% | Dính đốt gây thêm 15% sát thương |
| 4 | Vảy Hổ | 70 | 9 | 8 | 5 | 12 | 3% | Parry làm chậm mục tiêu 20% trong 2 giây |
| 5 | Bạc Nguyệt | 90 | 12 | 10 | 7 | 15 | 4% | 10% cơ hội thêm 1 chém nhỏ sau combo |
| 6 | Hắc Rễ | 115 | 15 | 13 | 9 | 18 | 5% | Khi HP dưới 35%, +15% tốc độ đánh |
| 7 | Huyết Phong | 145 | 18 | 16 | 12 | 22 | 7% | Hạ quái hồi 3% HP |
| 8 | Lưu Quang Tàn | 180 | 22 | 20 | 15 | 25 | 9% | Phản Đòn gây choáng 0.5 giây |
| 9 | Kiếm Vệ Cổ | 220 | 27 | 25 | 19 | 30 | 11% | Sau parry, kỹ năng tiếp theo +30% sát thương |
| 10 | Giữ Rễ Asterion | 270 | 33 | 31 | 24 | 36 | 14% | Mỗi 12 giây chắn 1 đòn gây chết người |

### 10 Bộ Giáp Hộ Vệ Rễ Cây (Bậc 1 đến Bậc 10)
| Bậc | Tên bộ giáp | HP | ATK | DEF | RES | STA | VOID RES | Set bonus |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | Giáp Gỗ | 35 | 1 | 4 | 2 | 8 | 2% | Khiên tốn ít hơn 8% STA |
| 2 | Đá Thô | 55 | 2 | 7 | 3 | 12 | 4% | Đỡ đòn hồi 4 STA mỗi giây |
| 3 | Đồng Trần | 75 | 3 | 10 | 5 | 15 | 6% | Khiêu Khích +1 giây |
| 4 | Hắc Thạch | 100 | 4 | 14 | 7 | 18 | 8% | Giảm 15% knockback |
| 5 | Rễ Đồng | 130 | 5 | 18 | 9 | 22 | 10% | Khi đứng yên 1.5 giây, +10 DEF |
| 6 | Thánh Mẫu | 165 | 7 | 23 | 12 | 26 | 13% | Đồng đội gần bản nhận 8% giảm sát thương |
| 7 | Vỏ Cây Già | 205 | 9 | 29 | 15 | 30 | 17% | Khiên Rễ phản 20% sát thương đã chắn |
| 8 | Nham Sơn | 250 | 11 | 36 | 19 | 35 | 22% | Miễn nhiễm choáng lần đầu mỗi trận |
| 9 | Thánh Rễ Đen | 305 | 14 | 44 | 24 | 40 | 28% | Dưới 30% HP, tạo khiên 20% HP tối đa |
| 10 | Phiến Rễ Thế Giới | 370 | 17 | 54 | 30 | 48 | 35% | Thánh Rễ hồi 10% HP cho cả nhóm khi hết hạn |

### 10 Bộ Giáp Pháp Kiếm Hư Vô (Bậc 1 đến Bậc 10)
| Bậc | Tên bộ giáp | HP | MAG | DEF | RES | STA | CRIT | Set bonus |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | Vải Tím | 10 | 4 | 1 | 2 | 5 | 1% | Gậy Hư Vô +5% tầm đánh |
| 2 | Nhà Thuật Sĩ | 20 | 7 | 2 | 4 | 8 | 2% | Hạ quái bằng phép hồi 3 STA |
| 3 | Tro Tinh Vân | 35 | 10 | 3 | 6 | 10 | 3% | Lửa Tím tốn ít hơn 10% Focus |
| 4 | Kẻo Gai | 50 | 14 | 4 | 8 | 13 | 4% | Kéo Linh Hồn làm chậm 15% |
| 5 | Mặt Trăng Vỡ | 70 | 18 | 6 | 11 | 16 | 6% | Phép trúng mục tiêu đốt +10% sát thương |
| 6 | Đêm Sâu | 95 | 23 | 8 | 14 | 20 | 8% | Chí mạng phép gây 175% thay vi 150% |
| 7 | Đá Tinh Lưu Tày | 125 | 29 | 10 | 18 | 24 | 10% | Đánh quái bị khống chế +20% sát thương |
| 8 | Hư Vô Phản Quang | 160 | 36 | 13 | 23 | 29 | 13% | Mỗi 3 phép trúng, phép sau không tốn Focus |
| 9 | Áo Táng Hồn | 200 | 44 | 17 | 29 | 34 | 16% | Đêm Nở Rễ Đen +1 mục tiêu lớn |
| 10 | Người Nói Ký Ức | 250 | 54 | 22 | 36 | 40 | 20% | Phép Hư Vô +25%, Corruption tăng chậm hơn 25% |

### 10 Bộ Giáp Tu Sĩ Tro Tàn (Bậc 1 đến Bậc 10)
| Bậc | Tên bộ giáp | HP | MAG | DEF | RES | STA | HEAL | Set bonus |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | Áo Hành Lễ | 18 | 3 | 1 | 4 | 7 | 4% | Vùng Ấn rộng hơn 10% |
| 2 | Vải Trắng | 30 | 5 | 2 | 7 | 10 | 7% | Hồi máu thêm 1% HP khi mục tiêu dưới 30% |
| 3 | Nhật Sáng | 45 | 8 | 4 | 10 | 13 | 10% | Khiên Sáng tốn ít hơn 10% Focus |
| 4 | Lệ Cầu Nguyện | 60 | 11 | 5 | 14 | 16 | 13% | Thánh Ca giảm thêm 5% tấn công boss |
| 5 | Bình Minh | 80 | 15 | 7 | 18 | 20 | 17% | Hồi máu xóa 1 debuff nhẹ |
| 6 | Mặt Trời Nhạt | 105 | 19 | 9 | 23 | 24 | 21% | Khiên Sáng tồn tại thêm 1 giây |
| 7 | Thi Ca Rễ Non | 135 | 24 | 12 | 29 | 29 | 25% | Vùng Ấn hồi 1% STA/giây |
| 8 | Thánh Ấn Bóng Tối | 170 | 30 | 15 | 36 | 34 | 30% | Khiên phát nổ, hồi 5% HP cho đồng đội gần đó |
| 9 | Lời Hứa Trắng | 215 | 37 | 19 | 44 | 40 | 35% | Thánh Ca làm chậm boss 10% trong 4 giây |
| 10 | Hóa Trang Tái Sinh | 270 | 46 | 24 | 54 | 48 | 42% | Phục Sinh Non hồi 35% HP thay vì 20% |

---

## 6. Đặc Tả Chi Tiết Combat & Bộ Kỹ Năng 4 Class

### KIẾM VỆ (Blademaster)
- **Nội tại**: *Khí Kiếm*: Đánh trúng tích tầng (+4% Atk Speed, +2% Crit/tầng, max 5).
- **Skill 1**: *Chém Chéo & Phong Trảm*: Combo 2 nhịp cận chiến, nhịp 3 phóng sóng gió 5m (1.8x ATK).
- **Skill 2**: *Phản Đòn & Phản Kích*: Đỡ đòn 0.4s, lướt sau lưng chém 2.5x ATK + Choáng 1.2s + Hồi 20 STA.
- **Skill 3**: *Bước Rễ & Luân Trảm*: Lao nhanh 4m, xoay kiếm 360 độ chém 2.0x ATK hất văng quái.
- **Tuyệt kỹ**: *Ván Nguyệt Hư Ảnh*: 6 bóng ma lướt chém **toàn màn hình** (6 x 1.3x ATK), giảm 30% DEF quái.

### HỘ VỆ RỄ CÂY (Tree Root Guardian)
- **Nội tại**: *Vỏ Cây Thần*: Giơ khiên giảm 50% sát thương, phản lại 20% sát thương vật lý.
- **Skill 1**: *Dậm Đất Địa Chấn*: Dậm khiên nứt đất 4m (1.5x ATK + 0.6x DEF), làm chậm 40%.
- **Skill 2**: *Khiêu Khích & Vùng Rễ Trói*: Ép quái 7m đánh mình, mọc rễ trói chân 2.5s.
- **Skill 3**: *Khiên Rễ Cuồng Phong*: Húc càn quét 6m, gom quái và đập gục ngã 1.0s.
- **Tuyệt kỹ**: *Thành Rễ Bất Hoại*: Cắm đại khiên 6s: Miễn khống chế, tạo khiên 30% HP cho team, nổ gai rễ tiêu diệt quái.

### PHÁP KIẾM HƯ VÔ (Void Spellblade)
- **Nội tại**: *Hư Vô Thiêu Đốt*: Tích Corruption tăng sát thương MAG (tối đa +35% MAG).
- **Skill 1**: *Bão Lửa Tím*: Nón lửa tím 70 độ quét 6m (1.8x MAG + Đốt 0.4x MAG/s).
- **Skill 2**: *Kéo Linh Hồn & Bẫy Hắc Tín*: Hố đen gom quái 6m về 1 điểm rồi nổ 2.4x MAG.
- **Skill 3**: *Hư Ảnh Lướt*: Dịch chuyển tức thời 5m, để lại bóng ma nổ 1.5x MAG + Choáng 0.8s.
- **Tuyệt kỹ**: *Đêm Nở Rễ Đen*: Hố đen khổng lồ hút toàn map và phát nổ 4.8x MAG **quét sạch màn hình**.

### TU SĨ TRO TÀN (Ash Priest)
- **Nội tại**: *Lệ Thánh Tẩy*: Hồi máu/buff phát ra vòng sóng Ánh Sáng (0.8x MAG).
- **Skill 1**: *Vùng Thánh Ấn*: Trận hình ánh sáng 4m: Hồi 4% HP/s cho team + Thiêu đốt quái 1.2x MAG/s.
- **Skill 2**: *Khiên Cực Quang*: Chắn 100% 1 đòn đánh, khi vỡ nổ 1.6x MAG & Choáng 1.5s.
- **Skill 3**: *Thánh Ca Suy Giảm*: Hát thánh ca màn hình: Giảm 25% ATK và 20% SPD quái/boss trong 6s.
- **Tuyệt kỹ**: *Bình Minh Tái Sinh*: Cột sáng thiên đàng: **Phục sinh đồng đội**, hồi 100% HP/STA Kael, thiêu rụi quái nhỏ (3.8x MAG Holy Purge).

---

## 7. Hệ thống Cường Hóa & Khảm Cổ Ấn (Enchantment)

### Cường Hóa Bậc Trang Bị (+1 đến +10)
Tăng +3% chỉ số nền mỗi cấp (max +30% ở +10, kích hoạt Glow Aura).
- **+1 -> +3**: 100% an toàn.
- **+4 -> +6**: Tỉ lệ 75%-55%, hỏng rớt -1 cấp.
- **+7 -> +9**: Tỉ lệ 45%-25%, hỏng **rớt về mốc an toàn +6** (không bao giờ phá hủy đồ).
- **+10**: Tỉ lệ 15% (dùng Mảnh Vỡ Cây Thế Giới).

### 10 Cổ Ấn Khảm Đồ (Sockets)
Mỗi món có 3 ô khảm.
- **Hệ Ánh Sáng**: *Ấn Thánh Quang* (hồi HP khi đánh), *Ấn Gương Phản Chiếu* (phản 20% damage phép), *Ấn Thanh Tẩy* (giảm tích tụ Corruption).
- **Hệ Hư Vô**: *Ấn Hút Hồn* (chí mạng hút STA/Focus), *Ấn Vệt Bóng Tối* (Perfect Dodge thả vệt lửa tím), *Ấn Huyết Nguyệt* (+35% ATK khi HP < 35%).
- **Hệ Nguyên Tố & Chiến Thuật**: *Ấn Thiêu Đốt* (đốt cháy), *Ấn Băng Sương* (làm chậm), *Ấn Kiên Cường* (khiên khi dính chí mạng), *Ấn Báo Thù* (nổ sóng xung kích).
- **Xung đột Hệ tư tưởng**: Mặc giáp Ánh Sáng khảm 3 Ấn Hư Vô làm giảm 10% hiệu suất giáp do xung đột năng lượng.

---

## 8. Chi Tiết 20 Loài Quái Vật & Bảng Rơi Đồ (Loot Tables %)

### Công thức Scaling Quái:
- `HP = Base_HP * (1 + 0.12 * (Lvl - Base_Lvl))^1.18`
- `ATK = Base_ATK * (1 + 0.10 * (Lvl - Base_Lvl))`
- **Elite (15% tỉ lệ)**: Sprite x1.25, HP x1.8, ATK x1.3, thêm aura.

### Danh Sách 20 Quái & Loot Table

#### BẬC 1 (Chương 1-2 | Cấp 1-10)
1. **Bóng Sương Hồn (Lvl 1)**: EXP 25 | Vàng 5-12 (100%)
   - Mảnh Rễ Thô: 65% | Bụi Sương Mù: 40% | Áo Da Hành Nhân: 5% | Ấn Thánh Quang I: 2%
2. **Sói Rễ Hắc Tín (Lvl 3)**: EXP 40 | Vàng 10-18 (100%)
   - Nanh Sói Rễ: 60% | Đá Rễ Thô: 45% | Da Thô: 35% | Nón Sát Sương: 4%
3. **Nấm Độc Than Thở (Lvl 5)**: EXP 60 | Vàng 15-25 (100%)
   - Bào Tử Độc: 70% | Đá Rễ Thô: 50% | Thuốc Hồi Máu Nhỏ: 30% | Ấn Thiêu Đốt I: 3.5%
4. **Quạ Ma Xương (Lvl 7)**: EXP 50 | Vàng 12-22 (100%)
   - Lông Vũ Xương: 65% | Đá Rễ Thô: 50% | Mũi Khoan Rễ: 2.5% | Ấn Vệt Bóng Tối I: 2%

#### BẬC 2 (Chương 3-4 | Cấp 11-18)
5. **Thủy Thi Cầm Rìu (Lvl 11)**: EXP 110 | Vàng 30-50 (100%)
   - Quặng Thép Ngập Nước: 55% | Mảnh Rễ Tinh Khiết: 40% | Giáp Rễ Đồng: 6% | Ấn Kiên Cường I: 4%
6. **Thánh Vệ Vô Hồn (Lvl 13)**: EXP 140 | Vàng 40-65 (100%)
   - Mảnh Khiên Vỡ: 60% | Mảnh Rễ Tinh Khiết: 45% | Mảnh Hồn Cổ: 20% | Giáp Hắc Thạch: 5.5% | Ấn Gương Phản Chiếu I: 3.5%
7. **Pháp Binh Mù (Lvl 15)**: EXP 130 | Vàng 35-60 (100%)
   - Tro Thánh: 65% | Mảnh Rễ Tinh Khiết: 40% | Bình Focus Nhỏ: 35% | Áo Vai Tím: 6% | Ấn Thanh Tẩy I: 4%
8. **Cú Sương Săn Đêm (Lvl 17)**: EXP 150 | Vàng 45-75 (100%)
   - Mắt Cú Dạ Quang: 50% | Bụi Hư Vô: 45% | Mảnh Rễ Tinh Khiết: 40% | Giáp Bạc Nguyệt: 5% | Ấn Hút Hồn I: 3.5%

#### BẬC 3 (Chương 5-6 | Cấp 19-25)
9. **Bò Cạp Cát Trắng (Lvl 19)**: EXP 220 | Vàng 70-110 (100%)
   - Vỏ Cát Thạch Anh: 60% | Lõi Rễ Cổ Thụ: 30% | Kim Độc: 40% | Giáp Kẻo Gai: 5% | Ấn Băng Sương II: 3%
10. **Kỵ Sĩ Mặt Nạ Phản Đồ (Lvl 21)**: EXP 270 | Vàng 90-140 (100%)
    - Mảnh Mặt Nạ Thép: 55% | Lõi Rễ Cổ Thụ: 35% | Mảnh Hồn Cổ: 30% | Kiếm Vệ Cổ: 4.5% | Ấn Huyết Nguyệt II: 2.5%
11. **Xác Ướp Thạch Anh (Lvl 23)**: EXP 290 | Vàng 100-150 (100%)
    - Tinh Thể Thạch Anh: 65% | Lõi Rễ Cổ Thụ: 35% | Bụi Ánh Sáng: 40% | Giáp Mặt Trăng Vỡ: 4% | Ấn Gương Phản Chiếu II: 3%
12. **Hoa Rễ Thiêu Đốt (Lvl 25)**: EXP 300 | Vàng 110-160 (100%)
    - Nhụy Hoa Lửa: 70% | Lõi Rễ Cổ Thụ: 40% | Bình Tẩy Điểm: 1.5% | Giáp Đêm Sâu: 4% | Ấn Thiêu Đốt II: 3.5%

#### BẬC 4 (Chương 7-8 | Cấp 26-30)
13. **Thợ Săn Hắc Tín (Lvl 26)**: EXP 380 | Vàng 140-200 (100%)
    - Nhựa Hắc Tín: 65% | Lõi Rễ Cổ Thụ: 45% | Mảnh Hồn Cổ: 40% | Giáp Hắc Rễ: 4% | Ấn Kháo Thù II: 3%
14. **Cựu Tu Sĩ Rỗng (Lvl 27)**: EXP 420 | Vàng 160-230 (100%)
    - Kinh Sách Rỗng: 60% | Tinh Thể Ánh Sáng: 40% | Mảnh Hồn Cổ: 45% | Giáp Lệ Cầu Nguyện: 4% | Ấn Thanh Tẩy II: 3.5%
15. **Ma Cây Vỏ Trắng (Lvl 28)**: EXP 480 | Vàng 180-260 (100%)
    - Vỏ Cây Bạch Ngân: 70% | Lõi Rễ Cổ Thụ: 50% | Mảnh Vỡ Cây Thế Giới (+10): 2.5% | Giáp Nham Sơn: 3.5% | Ấn Kiên Cường III: 2%
16. **Hắc Điêu Linh Hồn (Lvl 30)**: EXP 520 | Vàng 200-290 (100%)
    - Lông Vũ Hư Vô: 65% | Bụi Hư Vô Thượng Hạng: 45% | Phù Bảo Vệ: 3% | Giáp Hư Vô Phản Quang: 3.5% | Ấn Hút Hồn III: 2%

#### BẬC 5 (Chương 9-10 | Cấp 31-35)
17. **Kỵ Sĩ Mặt Trời Giả (Lvl 31)**: EXP 680 | Vàng 280-400 (100%)
    - Vảy Vàng Cực Quang: 60% | Mảnh Vỡ Cây Thế Giới: 6% | Mảnh Hồn Cổ: 65% | Giáp Lưu Quang Tàn: 3% | Ấn Thánh Quang III: 2.5%
18. **Nữ Tu Không Mặt (Lvl 32)**: EXP 720 | Vàng 300-430 (100%)
    - Chuỗi Hạt Vô Danh: 65% | Mảnh Vỡ Cây Thế Giới: 7% | Nước Nguồn Tái Sinh: 4% | Giáp Áo Táng Hồn: 3% | Ấn Thanh Tẩy III: 2.5%
19. **Rồng Con Loét Sáng (Lvl 33)**: EXP 840 | Vàng 380-550 (100%)
    - Xương Rồng Thối: 75% | Mảnh Vỡ Cây Thế Giới: 10% | Phù Bảo Vệ: 6% | Giáp Phiến Rễ Thế Giới: 2.5% | Ấn Thiêu Đốt III: 3%
20. **Bóng Asterion Sai Lệch (Lvl 35 Ultimate Mimic)**: EXP 1,000 | Vàng 500-800 (100%)
    - Tàn Hồn Asterion (Legendary): 100% | Mảnh Hồn Cổ: 100% (x5-x10) | Mảnh Vỡ Cây Thế Giới: 20% | Giáp Asterion (Bậc 10): 5% | Giáp Người Nói Ký Ức (Bậc 10): 5% | Ấn Huyết Nguyệt III: 5%

---

## 9. Thiết Kế 3 Map Mở Đầu Game & Luồng Tutorial / Hub (Chapter 1 Map Flow)

### MAP 1: Rừng Sương Mù - Nơi Tỉnh Giấc (Awakening Foggy Forest)
- **Bối cảnh & Visual**: Rừng sâu âm u rợp sương mù pixel, rêu phát sáng xanh lam nhẹ. Âm nhạc huyền bí, tĩnh lặng.
- **Luồng Cốt truyện (Story Flow)**:
  - Cutscene mở đầu: Kael Asterion tỉnh dậy trên thảm lá mục với bàn tay phát sáng nhẹ và thanh kiếm gãy.
  - Người chơi học di chuyển cơ bản (WASD / D-Pad), tương tác với Bàn Thạch Rêu Cổ (Rune Pillar) để lấy lại thanh kiếm hoàn chỉnh.
- **Quái vật**: Không có (Khu vực an toàn giới thiệu cốt truyện).

### MAP 2: Con Đường Rừng Đến Thị Trấn (Forest Road to Town) - Khu vực Combat Tutorial
- **Bối cảnh & Visual**: Con đường rừng âm u nối liền Rừng Sương Mù và Thị Trấn Gió Than, có xe ngựa đứt gãy và đống lửa tàn.
- **Luồng Hướng dẫn Chiến đấu (Combat Tutorial Flow)**:
  1. *Bài học 1 (Combo 3 Hit & Aiming)*: Gặp 2 **Bóng Sương Hồn** (Lvl 1). Prompt UI dạy nút Đánh thường (Combo 3 nhịp).
  2. *Bài học 2 (Né lướt & Thể lực)*: Gặp 2 **Sói Rễ Hắc Tín** (Lvl 3). Prompt UI dạy nút Né lướt (Dodge i-frame) khi vòng đỏ báo hiệu xuất hiện.
  3. *Bài học 3 (Dùng Kỹ năng Class)*: Gặp **Nấm Độc Than Thở** (Lvl 5). Prompt UI dạy dùng Kỹ năng *Phong Trảm* hoặc *Bão Lửa Tím* để tiêu diệt từ xa.
  4. *Cuối Map (Mini-boss Encounter)*: Gặp **Aria** đang giao tranh với Mini-boss **Hươu Sừng Rễ**. Kael cùng Aria đánh gục Mini-boss, mở đoạn đối thoại đầu tiên và cùng di chuyển về Thị trấn.

### MAP 3: Thị Trấn Gió Than (Ashen Wind Town - Hub Trung Tâm)
- **Bối cảnh & Visual**: Thị trấn yên bình phủ lá vàng rơi, nhà gỗ pixel cổ kính với lồng đèn phát sáng ấm áp. Âm nhạc lửa trại chữa lành.
- **Các Điểm Chức Năng (Hub Features)**:
  1. **Bàn Lửa Trại Trung Tâm (Central Campfire)**:
     - Điểm Lưu Game (Save Point) & Hồi phục HP/STA.
     - Đổi Class linh hoạt giữa 4 Class.
     - Tẩy điểm / Cộng Điểm Tiềm Năng (STR, INT, VIT, DEX, MND).
     - Trò chuyện phát triển tình cảm với Companion (Aria, Elysia, Cecilia).
  2. **Lò Rèn Rễ Cây (Blacksmith Forge)**: Cường Hóa trang bị (+1 đến +10) và Khảm/Gỡ Cổ Ấn vào Ô Sockets.
  3. **Cửa Hàng Dược Sĩ & Đồ Cổ**: Mua Thuốc HP/STA, Bụi Nguyên Tố và Mũi Khoan Rễ.
  4. **Bảng Cáo Thị (Quest Board)**: Nhận Quest chính chương 2 và các Quest phụ cứu dân làng.

---

## 10. KHỐI MASTER PROMPT TỔNG CHO AI DEV (GODOT 4)

Sao chép toàn bộ khối lệnh dưới đây ném cho AI dev Godot 4 để lập trình tự động toàn bộ game:

```text
Bạn là Lead Technical Director kiêm Engine Developer chuyên về Godot 4 (GDScript typed). Hãy lập trình toàn bộ hệ thống Gameplay Cốt Lõi cho dự án game 2D Top-down Action RPG "Vết Ấn Dưới Rễ Cây" dựa trên Master Specs dưới đây:

MỤC TIÊU LẬP TRÌNH:
1. HỆ THỐNG MAP & SCENE ROUTER (SceneRouter.gd, Map Files):
   - Xây dựng 3 Map đầu game:
     * `res://scenes/maps/map1_awakening_forest.tscn`: Map tĩnh cutscene tỉnh giấc, di chuyển & tương tác.
     * `res://scenes/maps/map2_tutorial_road.tscn`: Map đường rừng chứa 3 bước Tutorial Combat (Combo, Dodge i-frame, Skill) + Trigger gặp Aria & Mini-boss Hươu Sừng Rễ.
     * `res://scenes/maps/map3_ashen_town_hub.tscn`: Hub thị trấn trung tâm chứa Bàn Lửa Trại (Save/Rest/Change Class), Lò Rèn (Đập đồ/Khảm Ấn), Shop NPC & Quest Board.
   - Manager `SceneRouter.gd` xử lý chuyển map với hiệu ứng Fade In/Fade Out, Spawn Point chuẩn xác và giữ nguyên GameState.

2. HỆ THỐNG QUÁI VẬT & SCALING (EnemyBase.gd, EnemyData.gd):
   - Quản lý 20 loài quái vật chuẩn hóa (từ Frost-Mist Shade đến Corrupted Asterion Echo).
   - Tự động scale HP, ATK, DEF, RES theo Cấp độ map: `HP = Base_HP * pow(1.0 + 0.12 * (Lvl - Base_Lvl), 1.18)`.
   - Roll 15% biến thể Elite (Sprite x1.25, HP x1.8, ATK x1.3, hiệu ứng aura).
   - State Machine: IDLE -> CHASE -> TELEGRAPH (báo hiệu đỏ/vàng 0.4s-1.0s) -> ATTACK -> STAGGER -> DEAD.

3. HỆ THỐNG THĂNG CẤP & CỘNG ĐIỂM (LevelManager.gd):
   - Quản lý Level (1-35), EXP công thức `floor(100 * pow(level, 2.15))`.
   - Lên cấp thưởng +5 Điểm Tiềm Năng để người chơi tự do cộng vào: STR (+ATK/DEF), INT (+MAG/RES), VIT (+HP/DEF), DEX (+CRIT/STA/SPD), MND (+HEAL/RES/VOID_RES). Recalculate stats ngay lập tức.

4. HỆ THỐNG LOOT TABLE & MẶT ĐẤT PICKUP (LootTable.gd, LootItemPickup.gd):
   - Duyệt mảng `loot_entries` theo tỉ lệ % ngẫu nhiên `randf() <= drop_chance`.
   - Khi quái chết, sinh ra `LootItemPickup` rải rác mặt đất, có hiệu ứng particle phát sáng theo phẩm chất (Trắng, Xanh, Vàng).
   - Lực hút nam châm (Tween) kéo item bay về Kael khi vào vùng 100px.

5. HỆ THỐNG ĐẬP ĐỒ & KHẢM CỔ ẤN (EnchantManager.gd, RuneData.gd):
   - Cường hóa +1 đến +10 (+3% stats/cấp, max +30% tại +10 có Glow Aura). Mốc +7..+9 thất bại rớt về +6 an toàn.
   - Khảm 10 loại Cổ Ấn vào 3 Ô Sockets (Holy Radiance, Reflective Mirror, Soul Drainer, Shadow Step, Blood Moon Covenant, etc.). Check xung đột Alignment Synergy nếu giáp Ánh Sáng khảm 3 Hư Vô Runes -> giảm 10% efficiency.

6. HỆ THỐNG COMBAT & BỘ KỸ NĂNG 4 CLASS (SkillManager.gd, ClassSkillsHandler.gd):
   - Lập trình bộ kỹ năng 4 Class: Kiếm Vệ (Phong Trảm, Parry phản đòn, Crescent Eclipse quét màn hình), Hộ Vệ (Earthquake Slam, Root Bind, Root Citadel), Pháp Kiếm (Purple Tempest, Void Pull, Black Root Supernova), Tu Sĩ (Sanctuary Zone, Aurora Aegis, Debuff Hymn, Dawn of Resurrection).
   - Tích hợp hiệu ứng Camera Shake, Hit-stop (0.05s) và giao tiếp với CombatResolver.

YÊU CẦU ĐẦU RA:
- Cung cấp kiến trúc folder Godot 4 sạch sẽ (`autoload/`, `resources/`, `scenes/`, `scripts/`).
- Viết mã GDScript typed 100% không chứa magic strings, không lỗi type-checking.
```

---

## Nhật ký thay đổi

- 2026-07-29: Thêm Thiết kế 3 Map mở đầu game (Map 1 Rừng Sương Mù tỉnh giấc, Map 2 Con đường rừng Tutorial Combat, Map 3 Thị Trấn Gió Than Hub trung tâm) và cập nhật Mega-Prompt Godot 4 điều khiển SceneRouter chuyển map.
