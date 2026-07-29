# Checklist phát hành

## Đích phát hành

- [ ] Nhánh `main` sạch và sẵn sàng đẩy lên `https://github.com/SonhocCodee/vet-an-duoi-re-cay.git`.
- [ ] Chỉ commit mã nguồn, resource, scene, test và tài liệu cần thiết.
- [x] Audit ngày 29/07/2026 chưa thấy file secret/credential hoặc artifact tạm trong `git status`.
- [x] `.gitignore` đã loại `.godot/`, `*.tmp`, `*.bak`, `*.import`.

## Nội dung đã có

- [x] MVP Map 1–3 và luồng rời Map 3 sang campaign.
- [x] Chapter 2–10, mỗi chapter có ba wave, boss, lựa chọn đạo đức và chuyển chương.
- [x] 16 quái thường, 10 boss campaign và chuỗi hai boss ở Chapter 10.
- [x] Save v2, progression Chapter 2–10, chín moral flags và True Ending.
- [x] 27 mục lore/codex, tài liệu kiến trúc, cốt truyện và cân bằng.

## Kiểm tra bắt buộc

- [x] Parser toàn project: `Godot --headless --path D:\Son\GAME --editor --quit` — đạt ngày 29/07/2026.
- [x] Kiểm tra whitespace: `git diff --check` — đạt ngày 29/07/2026.
- [ ] MVP: `tests/integration/smoke_test.tscn`, test Player và contract/runtime Map 1–3.
- [ ] Campaign core: `tests/integration/campaign_smoke_test.tscn`, `tests/campaign/data/test_chapter_definitions.gd`.
- [ ] Enemy/boss: `tests/enemies/campaign/campaign_enemy_load_test.tscn`.
- [ ] Map campaign: contract/runtime Chapter 2–4, Chapter 5–7 và Chapter 8–10.
- [ ] Toàn campaign: `tests/campaign/runtime/campaign_chapters_runtime_test.tscn`.
- [ ] Save/progression/ending: `tests/campaign/progression/campaign_progression_test.tscn`.
- [ ] Moral-choice UI: `tests/integration/ui_event_bridge_campaign_test.tscn`.
- [ ] Lore: `tests/campaign/lore/test_campaign_lore.gd`.
- [ ] Balance: `tests/campaign/balance/campaign_balance_test.tscn` phải trả exit code `0`.
- [ ] Chạy main scene headless đủ lâu để phát hiện lỗi runtime khởi động.

## Blocker và giới hạn

- [ ] Sửa blocker cân bằng: `boss_betrayer_knight` đang level 25, thấp hơn quái Chapter 7 bắt đầu ở level 26; chạy lại balance test.
- [ ] Chạy lại toàn bộ suite vì lượt audit này đã dừng theo yêu cầu, chưa xác nhận pass tổng thể.
- [ ] Xác nhận `git status` chỉ còn các thay đổi dự kiến trước khi commit/push.
- [x] Visual hiện là placeholder (hình khối, màu, SVG và hiệu ứng dựng trong Godot), chưa phải asset hoàn thiện cho bản thương mại.
