# Vết Ấn Dưới Rễ Cây

Game action RPG góc nhìn từ trên xuống, phát triển bằng **Godot 4.3**. Kael Asterion khám phá thế giới mục ruỗng quanh Cây Thế Giới, chiến đấu, phát triển nhân vật và đưa ra các lựa chọn đạo đức ảnh hưởng đến kết cục.

## Nội dung hiện có

### Phần mở đầu và campaign

- Map 1–3: Rừng Sương Mù, Con Đường Rừng và Thành Tro.
- Campaign Chapter 2–10, 16 loại quái thường, 10 boss và trận boss kép cuối game.
- Moral choices xuyên suốt campaign và True Ending.
- Save **version 3**, có migration từ save version 2.

### Thành phố trung cổ

- Map 3 được mở rộng thành thành phố 2200×900 với 20 công trình và 20 đạo cụ môi trường.
- 20 NPC khác nhau về tên, nghề nghiệp, diện mạo, lịch trình, thoại và side quest.
- NPC tự tìm đường và di chuyển theo giờ trong ngày bằng NavigationAgent2D.
- Mỗi NPC có animation idle, walk, interact và hurt; Kael có bộ animation tương ứng.

### Hệ thống gameplay

- HUD máu, stamina và kinh nghiệm.
- Inventory, equipment, loot pickup và item icons.
- Quest journal, 20 side quests và dialogue NPC.
- Bản đồ thành phố/thế giới và các marker khám phá.
- Lò rèn, cửa hàng, lửa trại, bảng nhiệm vụ và cổng campaign vẫn hoạt động.

### Đồ họa

Game sử dụng bộ SVG dark-fantasy riêng cho background, nhân vật, NPC, quái, boss, thành phố, công trình, UI và item. Một số hiệu ứng chiến đấu vẫn được vẽ trực tiếp bằng Godot để giữ hiệu năng và khả năng mở rộng.

## Điều khiển

- **Di chuyển:** WASD, phím mũi tên, D-pad hoặc analog trái.
- **Đánh thường:** chuột trái hoặc nút X trên gamepad.
- **Né:** Space, K hoặc nút A.
- **Kỹ năng 1:** Q hoặc nút Y khi profile gamepad hỗ trợ.
- **Tương tác:** E hoặc nút B.
- **Túi đồ:** I.
- **Nhật ký nhiệm vụ:** J.
- **Bản đồ:** M.
- **Lựa chọn đạo đức:** 1 / 2 hoặc nút giao diện.
- **Tạm dừng:** Esc.

## Chạy game

Yêu cầu **Godot 4.3**:

```powershell
godot --path .
```

Main scene: `res://scenes/bootstrap/main.tscn`.

## Kiểm tra

```powershell
godot --headless --path . --editor --quit
godot --headless --path . res://tests/integration/smoke_test.tscn
godot --headless --path . res://tests/integration/main_campaign_boot_test.tscn
godot --headless --path . res://tests/campaign/runtime/campaign_chapters_runtime_test.tscn
godot --headless --path . res://tests/second_wave/code/npc_schedule_test.tscn
godot --headless --path . res://tests/second_wave/code/gameplay_systems_test.tscn
godot --headless --path . res://tests/second_wave/code/save_v3_migration_test.tscn
godot --headless --path . res://tests/second_wave/integration/second_wave_integration_test.tscn
```
