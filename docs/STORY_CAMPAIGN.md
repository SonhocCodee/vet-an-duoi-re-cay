# Story Campaign Data — Chapter 2–10

Tài liệu mô tả contract dữ liệu chiến dịch sau phần mở đầu ba map MVP. Module chỉ cung cấp dữ liệu typed; không tạo map, enemy scene, UI hay campaign runner.

## Resource Contract

Mỗi chapter là một ChapterDefinition tại res://resources/campaign/chapters/.

- chapter_id, chapter_number, title và subtitle định danh chapter.
- intro_lines, objective và completion_lines cung cấp nội dung hiển thị.
- encounter_enemy_ids luôn chứa đúng ba phần tử, tương ứng ba combat wave theo thứ tự.
- boss_enemy_id luôn bắt đầu bằng boss_; boss scene/data sẽ do hệ enemy triển khai sau.
- moral_choice_id có đúng hai lựa chọn, mỗi lựa chọn gồm text và story flag riêng.
- companion là companion trọng tâm; Chapter 10 dùng all_companions.
- reward_exp, unlock_class_id, next_map_id và spawn_id điều khiển tiến trình.
- palette_colors và background_color là gợi ý presentation cho map/UI.

ChapterDefinition.get_validation_errors() kiểm tra contract và is_valid_definition() trả về trạng thái tổng hợp.

## Canonical Enemy IDs

| Bậc | Quái canon | Enemy ID |
| --- | --- | --- |
| 1 | Bóng Sương Hồn | mist_shade |
| 1 | Sói Rễ Hắc Tín | root_wolf |
| 1 | Nấm Độc Than Thở | weeping_mushroom |
| 1 | Quạ Ma Xương | bone_crow |
| 2 | Thủy Thi Cầm Rìu | drowned_axe_corpse |
| 2 | Thánh Vệ Vô Hồn | soulless_holy_guard |
| 2 | Pháp Binh Mù | blind_spell_soldier |
| 2 | Cú Sương Săn Đêm | night_hunting_mist_owl |
| 3 | Bò Cạp Cát Trắng | white_sand_scorpion |
| 3 | Kỵ Sĩ Mặt Nạ Phản Đồ | traitor_mask_knight |
| 3 | Xác Ướp Thạch Anh | quartz_mummy |
| 3 | Hoa Rễ Thiêu Đốt | burning_root_bloom |
| 4 | Thợ Săn Hắc Tín | black_resin_hunter |
| 4 | Cựu Tu Sĩ Rỗng | hollow_ex_monk |
| 4 | Ma Cây Vỏ Trắng | white_bark_treant |
| 4 | Hắc Điêu Linh Hồn | soul_black_eagle |
| 5 | Kỵ Sĩ Mặt Trời Giả | false_sun_knight |
| 5 | Nữ Tu Không Mặt | faceless_nun |
| 5 | Rồng Con Loét Sáng | lightblight_wyrmling |
| 5 | Bóng Asterion Sai Lệch | corrupted_asterion_echo |

## Chapter Matrix

| Ch. | Chapter ID / title | Three waves | Boss ID | Companion | Unlock | Next map |
| ---: | --- | --- | --- | --- | --- | --- |
| 2 | chapter_2_drowned_bells — Chuông Chìm Dưới Nước | mist_shade, root_wolf, bone_crow | boss_drowned_bell_warden | aria | guardian | map_chapter_3_blind_procession |
| 3 | chapter_3_blind_procession — Thánh Lộ Mù | drowned_axe_corpse, soulless_holy_guard, blind_spell_soldier | boss_blind_procession_marshal | cecilia | — | map_chapter_4_erased_archive |
| 4 | chapter_4_erased_archive — Thư Viện Tên Bị Xóa | blind_spell_soldier, night_hunting_mist_owl, soulless_holy_guard | boss_erased_name_curator | elysia | spellblade | map_chapter_5_quartz_wastes |
| 5 | chapter_5_quartz_wastes — Hoang Mạc Thạch Anh | white_sand_scorpion, quartz_mummy, traitor_mask_knight | boss_quartz_mirage_colossus | elysia | — | map_chapter_6_burning_root_garden |
| 6 | chapter_6_burning_root_garden — Vườn Rễ Thiêu | burning_root_bloom, traitor_mask_knight, quartz_mummy | boss_cinder_root_matriarch | aria | priest | map_chapter_7_black_resin_pass |
| 7 | chapter_7_black_resin_pass — Đèo Hắc Tín | black_resin_hunter, white_bark_treant, soul_black_eagle | boss_black_resin_huntsman | aria | — | map_chapter_8_empty_monastery |
| 8 | chapter_8_empty_monastery — Tu Viện Rỗng | hollow_ex_monk, white_bark_treant, soul_black_eagle | boss_hollow_abbot | cecilia | — | map_chapter_9_false_sun_citadel |
| 9 | chapter_9_false_sun_citadel — Thành Mặt Trời Giả | false_sun_knight, faceless_nun, lightblight_wyrmling | boss_false_sun_pontiff | cecilia | — | map_chapter_10_world_root |
| 10 | chapter_10_world_root — Tâm Rễ Asterion | corrupted_asterion_echo, faceless_nun, lightblight_wyrmling | boss_rootbound_pontiff | all_companions | — | map_true_ending_epilogue |

## Moral Choice Flags

| Chapter | Option A flag | Option B flag |
| --- | --- | --- |
| 2 | chapter_2_bells_recovered | chapter_2_spirits_released |
| 3 | chapter_3_procession_awakened | chapter_3_procession_sheltered |
| 4 | chapter_4_names_restored | chapter_4_archive_sealed |
| 5 | chapter_5_well_shared | chapter_5_well_guarded |
| 6 | chapter_6_garden_extinguished | chapter_6_pure_flame_preserved |
| 7 | chapter_7_resin_prisoners_freed | chapter_7_hunters_judged |
| 8 | chapter_8_memories_returned | chapter_8_memories_softened |
| 9 | chapter_9_false_sun_exposed | chapter_9_city_evacuated |
| 10 | chapter_10_root_seals_released | chapter_10_root_seals_shattered |

## True Ending

Resource res://resources/campaign/endings/true_ending.tres chứa dialogue true_ending_silent_rootkeeper.

True ending yêu cầu một cờ lựa chọn giàu lòng trắc ẩn hoặc sự thật từ mỗi Chapter 2–10. Kết thúc giữ đúng canon: Kael cứu Cây Thế Giới trong im lặng, thế giới hồi phục chậm, và nhiều người vẫn gọi anh là Ma Vương.

Campaign runner nên:

1. Lưu một trong hai moral option flag khi người chơi xác nhận lựa chọn.
2. Cộng reward_exp và mở unlock_class_id nếu field không rỗng.
3. Chuyển đến next_map_id tại spawn_id sau completion dialogue.
4. Chỉ phát true ending khi toàn bộ required_choice_flags của ending resource đều tồn tại trong save state.
