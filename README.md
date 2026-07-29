# Vết Ấn Dưới Rễ Cây

Game action RPG góc nhìn từ trên xuống, phát triển bằng **Godot 4.3**. Người chơi khám phá một thế giới mục ruỗng quanh Rễ Cây, chiến đấu, chọn hướng phát triển nhân vật và đưa ra các lựa chọn đạo đức ảnh hưởng đến kết cục.

> Đồ họa hiện tại chủ yếu là hình khối, màu sắc và hiệu ứng placeholder dựng trực tiếp trong Godot. Đây chưa phải bộ asset hoàn thiện của bản phát hành.

## Nội dung hiện có

### Phần mở đầu — Map 1–3

1. **Rừng Sương Mù:** thức tỉnh, học di chuyển và nhận lại thanh kiếm.
2. **Con Đường Rừng:** làm quen combo, né, kỹ năng và đối đầu miniboss Hươu Sừng Rễ.
3. **Thị Trấn Gió Than:** mở lửa trại, đổi class, nâng chỉ số, lò rèn, cửa hàng và bảng nhiệm vụ.

### Campaign — Chapter 2–10

- Chín chapter nối tiếp từ **Chuông Chìm** đến **Rễ Thế Giới**.
- 16 loại quái thường và 10 boss campaign với dữ liệu, loot và hành vi chiến đấu riêng.
- Các lựa chọn đạo đức xuất hiện xuyên suốt hành trình; có thể chọn bằng giao diện hoặc phím số.
- Tiến trình chapter, lựa chọn và trạng thái hoàn thành được lưu bằng hệ thống **save version 2**.
- True Ending được mở khi người chơi đáp ứng đủ các điều kiện lựa chọn của campaign.

## Điều khiển

- **Di chuyển:** `WASD`, phím mũi tên hoặc D-pad.
- **Đánh thường:** chuột trái, `J` hoặc nút X.
- **Né:** `Space`, `K` hoặc nút A.
- **Kỹ năng 1:** `Q`, `L` hoặc nút Y.
- **Tương tác:** `E` hoặc nút B.
- **Chọn phương án đạo đức:** phím `1` / `2` hoặc bấm nút trên giao diện.
- **Tạm dừng:** `Esc`.

## Chạy game

Yêu cầu **Godot 4.3**. Mở `project.godot` bằng Godot rồi chạy project, hoặc dùng dòng lệnh:

```powershell
godot --path .
```

Main scene của project là `res://scenes/bootstrap/main.tscn`.

## Chạy kiểm tra

Chạy kiểm tra tổng quát và campaign ở chế độ headless:

```powershell
godot --headless --path . res://tests/integration/smoke_test.tscn
godot --headless --path . res://tests/integration/campaign_smoke_test.tscn
godot --headless --path . res://tests/campaign/progression/campaign_progression_test.tscn
godot --headless --path . res://tests/enemies/campaign/campaign_enemy_load_test.tscn
```

Để kiểm tra parser và toàn bộ resource của project:

```powershell
godot --headless --path . --editor --quit
```
