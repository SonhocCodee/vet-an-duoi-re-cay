# Pixel NPC Manifest

Gói này chứa 20 NPC nguyên bản theo phong cách pixel RPG top-down 3/4. Các sprite không sao chép, chỉnh sửa hoặc truy vết trực tiếp từ tài sản của Stardew Valley.

## Chuẩn sprite sheet

- Kích thước mỗi frame: `32x48 px`.
- Kích thước mỗi sheet: `96x192 px`.
- Nền: trong suốt.
- Cột từ trái sang phải: `idle`, `walk_a`, `walk_b`.
- Hàng từ trên xuống dưới: `down`, `left`, `right`, `up`.
- Mỗi hướng có một frame đứng yên và hai frame bước chân xen kẽ.
- Mapping máy đọc được: `res://assets/art/pixel/npcs/npc_sprite_map.json`.

## Danh sách NPC

| ID | Tên | Nghề nghiệp | Nhận diện chính | Sprite |
|---|---|---|---|---|
| `alden_blacksmith` | Alden | Thợ rèn | Tóc nâu đen, áo đỏ than, tạp dề đồng, búa | `res://assets/art/pixel/npcs/alden_blacksmith.png` |
| `borin_mason` | Borin | Thợ xây | Tóc xám, mũ thợ, áo xám đá, bay xây | `res://assets/art/pixel/npcs/borin_mason.png` |
| `cedric_archivist` | Cedric | Thủ thư | Tóc nâu, áo xanh mực, sách vàng | `res://assets/art/pixel/npcs/cedric_archivist.png` |
| `damian_scribe` | Damian | Thư lại | Tóc đen, áo tím, cuộn giấy | `res://assets/art/pixel/npcs/damian_scribe.png` |
| `elric_beggar_prophet` | Elric | Hành khất tiên tri | Tóc bạc, áo choàng vá tối, trượng | `res://assets/art/pixel/npcs/elric_beggar_prophet.png` |
| `father_oren` | Cha Oren | Linh mục | Tóc bạc, lễ phục đen đỏ, thánh giá | `res://assets/art/pixel/npcs/father_oren.png` |
| `freya_hunter` | Freya | Thợ săn | Tóc đỏ, áo xanh rừng, cung | `res://assets/art/pixel/npcs/freya_hunter.png` |
| `gareth_stablemaster` | Gareth | Quản ngựa | Tóc nâu cam, áo da, roi ngựa | `res://assets/art/pixel/npcs/gareth_stablemaster.png` |
| `helena_innkeeper` | Helena | Chủ quán trọ | Tóc nâu đỏ, váy đỏ rượu, cốc | `res://assets/art/pixel/npcs/helena_innkeeper.png` |
| `ivy_orphan` | Ivy | Trẻ mồ côi | Tóc vàng, áo xanh cũ, khăn đỏ | `res://assets/art/pixel/npcs/ivy_orphan.png` |
| `lysa_baker` | Lysa | Thợ bánh | Tóc nâu, mũ bếp trắng, ổ bánh | `res://assets/art/pixel/npcs/lysa_baker.png` |
| `maela_weaver` | Maela | Thợ dệt | Tóc đen tím, áo tím lam, con suốt | `res://assets/art/pixel/npcs/maela_weaver.png` |
| `mira_apothecary` | Mira | Dược sư | Tóc xanh rêu, áo xanh tím, lọ thuốc | `res://assets/art/pixel/npcs/mira_apothecary.png` |
| `neris_cartographer` | Neris | Người vẽ bản đồ | Tóc vàng đồng, áo xanh biển, bản đồ | `res://assets/art/pixel/npcs/neris_cartographer.png` |
| `oswin_fisher` | Oswin | Ngư dân | Tóc xám, mũ vàng, áo xanh nước, cần câu | `res://assets/art/pixel/npcs/oswin_fisher.png` |
| `rosalind_midwife` | Rosalind | Bà đỡ | Tóc nâu, áo tím kem, túi y cụ | `res://assets/art/pixel/npcs/rosalind_midwife.png` |
| `rowan_watch_captain` | Rowan | Đội trưởng canh gác | Tóc đen, giáp xanh thép, khiên vàng | `res://assets/art/pixel/npcs/rowan_watch_captain.png` |
| `silas_gravedigger` | Silas | Người đào huyệt | Tóc xám, áo than, xẻng | `res://assets/art/pixel/npcs/silas_gravedigger.png` |
| `tomas_guard` | Tomas | Lính gác | Tóc nâu, giáp xám xanh, giáo đỏ | `res://assets/art/pixel/npcs/tomas_guard.png` |
| `yvette_jeweler` | Yvette | Thợ kim hoàn | Tóc vàng, áo xanh tím, đá quý lam | `res://assets/art/pixel/npcs/yvette_jeweler.png` |

## Mapping Godot

Với `AtlasTexture`, dùng vùng `Rect2(column * 32, row * 48, 32, 48)`. Animation đi bộ lặp giữa `walk_a` và `walk_b`; khi dừng chuyển về `idle` ở cùng hàng hướng hiện tại. Giữ texture filter ở chế độ nearest để pixel không bị nhòe.
