# Kiến trúc campaign — Chương 2 đến Chương 10

Tài liệu này mô tả contract canonical của campaign nối tiếp ba map MVP. Mọi ID, đường dẫn và chữ ký API bên dưới được đối chiếu với code Godot 4.3 hiện tại trong project.

## Nguồn sự thật

- Map ID: `res://autoload/game_ids.gd`.
- Route map: `res://autoload/scene_router.gd`.
- Điều phối tiến trình: `res://autoload/campaign_director.gd`.
- Trạng thái lưu: `res://autoload/game_state.gd`, save version `2`.
- Signal toàn cục: `res://autoload/game_events.gd`.
- Schema chapter: `res://scripts/campaign/data/chapter_definition.gd`.
- Runtime map dùng chung: `res://scripts/campaign/map/campaign_chapter_map.gd`.

Không dùng lại các tên cũ dạng `chapter_02_*`, `map_chapter_*`, thư mục `ch02_04`, `ch05_07`, `ch08_10` hoặc schema `resources/schema/campaign/chapter_definition.gd`.

## Registry chapter canonical

| Chương | Map ID | Scene | Chapter resource | Boss chính | Boss thứ hai |
| ---: | --- | --- | --- | --- | --- |
| 2 | `chapter_2_drowned_bells` | `res://scenes/maps/campaign/chapter_2_drowned_bells.tscn` | `res://resources/campaign/chapters/chapter_2_drowned_bells.tres` | `boss_drowned_executioner` | — |
| 3 | `chapter_3_blind_procession` | `res://scenes/maps/campaign/chapter_3_blind_procession.tscn` | `res://resources/campaign/chapters/chapter_3_blind_procession.tres` | `boss_hollow_paladin` | — |
| 4 | `chapter_4_erased_archive` | `res://scenes/maps/campaign/chapter_4_erased_archive.tscn` | `res://resources/campaign/chapters/chapter_4_erased_archive.tres` | `boss_blind_archivist` | — |
| 5 | `chapter_5_quartz_wastes` | `res://scenes/maps/campaign/chapter_5_quartz_wastes.tscn` | `res://resources/campaign/chapters/chapter_5_quartz_wastes.tres` | `boss_quartz_matriarch` | — |
| 6 | `chapter_6_burning_root_garden` | `res://scenes/maps/campaign/chapter_6_burning_root_garden.tscn` | `res://resources/campaign/chapters/chapter_6_burning_root_garden.tres` | `boss_burning_root` | — |
| 7 | `chapter_7_black_resin_pass` | `res://scenes/maps/campaign/chapter_7_black_resin_pass.tscn` | `res://resources/campaign/chapters/chapter_7_black_resin_pass.tres` | `boss_betrayer_knight` | — |
| 8 | `chapter_8_empty_monastery` | `res://scenes/maps/campaign/chapter_8_empty_monastery.tscn` | `res://resources/campaign/chapters/chapter_8_empty_monastery.tres` | `boss_empty_abbot` | — |
| 9 | `chapter_9_false_sun_citadel` | `res://scenes/maps/campaign/chapter_9_false_sun_citadel.tscn` | `res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres` | `boss_false_sun` | — |
| 10 | `chapter_10_world_root` | `res://scenes/maps/campaign/chapter_10_world_root.tscn` | `res://resources/campaign/chapters/chapter_10_world_root.tres` | `boss_papal_root_avatar` | `boss_corrupted_asterion` |
| Kết | `true_ending` | `res://scenes/ending/true_ending.tscn` | `res://resources/campaign/endings/true_ending.tres` | — | — |

Các hằng tương ứng là `GameIds.MAP_CHAPTER_2` đến `GameIds.MAP_CHAPTER_10` và `GameIds.MAP_TRUE_ENDING`. `SceneRouter` phải route chính xác các ID trong bảng; không tự thêm tiền tố `map_`.

## Boss catalog

Mỗi boss có một data resource và một scene cùng tên:

| Boss ID | Data | Scene |
| --- | --- | --- |
| `boss_drowned_executioner` | `res://resources/enemies/campaign/boss_drowned_executioner.tres` | `res://scenes/actors/enemies/campaign/boss_drowned_executioner.tscn` |
| `boss_hollow_paladin` | `res://resources/enemies/campaign/boss_hollow_paladin.tres` | `res://scenes/actors/enemies/campaign/boss_hollow_paladin.tscn` |
| `boss_blind_archivist` | `res://resources/enemies/campaign/boss_blind_archivist.tres` | `res://scenes/actors/enemies/campaign/boss_blind_archivist.tscn` |
| `boss_quartz_matriarch` | `res://resources/enemies/campaign/boss_quartz_matriarch.tres` | `res://scenes/actors/enemies/campaign/boss_quartz_matriarch.tscn` |
| `boss_burning_root` | `res://resources/enemies/campaign/boss_burning_root.tres` | `res://scenes/actors/enemies/campaign/boss_burning_root.tscn` |
| `boss_betrayer_knight` | `res://resources/enemies/campaign/boss_betrayer_knight.tres` | `res://scenes/actors/enemies/campaign/boss_betrayer_knight.tscn` |
| `boss_empty_abbot` | `res://resources/enemies/campaign/boss_empty_abbot.tres` | `res://scenes/actors/enemies/campaign/boss_empty_abbot.tscn` |
| `boss_false_sun` | `res://resources/enemies/campaign/boss_false_sun.tres` | `res://scenes/actors/enemies/campaign/boss_false_sun.tscn` |
| `boss_papal_root_avatar` | `res://resources/enemies/campaign/boss_papal_root_avatar.tres` | `res://scenes/actors/enemies/campaign/boss_papal_root_avatar.tscn` |
| `boss_corrupted_asterion` | `res://resources/enemies/campaign/boss_corrupted_asterion.tres` | `res://scenes/actors/enemies/campaign/boss_corrupted_asterion.tscn` |

## ChapterDefinition

Schema canonical là `res://scripts/campaign/data/chapter_definition.gd` với `class_name ChapterDefinition`.

```gdscript
@export var chapter_id: StringName
@export_range(2, 10, 1) var chapter_number: int = 2
@export var title: String
@export var subtitle: String

@export var intro_lines: Array[String] = []
@export_multiline var objective: String
@export var companion: StringName
@export var completion_lines: Array[String] = []

@export var encounter_enemy_ids: Array[StringName] = []
@export var boss_enemy_id: StringName

@export var moral_choice_id: StringName
@export_multiline var moral_option_a_text: String
@export var moral_option_a_flag: StringName
@export_multiline var moral_option_b_text: String
@export var moral_option_b_flag: StringName

@export_range(0, 1000000, 1) var reward_exp: int = 0
@export var unlock_class_id: StringName
@export var next_map_id: StringName
@export var spawn_id: StringName = &"chapter_start"

@export var palette_colors: Array[Color] = []
@export var background_color: Color = Color.BLACK
```

Các ràng buộc chính:

- `encounter_enemy_ids` có đúng ba phần tử, tương ứng ba wave tuần tự.
- `boss_enemy_id` bắt đầu bằng `boss_` và phải trùng ID trong boss data/scene.
- Mỗi lựa chọn đạo đức có text và flag riêng; hai flag không được trùng nhau.
- `next_map_id` dùng đúng map ID canonical trong registry; Chương 10 dùng `true_ending`.
- `spawn_id` mặc định của resource là `chapter_start`; route liên chapter hiện chuyển bằng `GameIds.SPAWN_DEFAULT`, tức `default`.
- `palette_colors` có ít nhất ba màu và `reward_exp` phải lớn hơn `0`.

Schema hiện tại không có các field cũ `map_id`, `encounter_ids`, `boss_id`, `completion_flag`, `unlock_ids`, `campfire_dialogue_id` hoặc `next_spawn_id`.

## Runtime map

`CampaignChapterMap` đọc trực tiếp `ChapterDefinition` và chuyển dữ liệu như sau:

- Mỗi phần tử của `encounter_enemy_ids` tạo một encounter tuần tự.
- `boss_enemy_id` tạo boss chính của chapter.
- Lựa chọn A/B được chuẩn hóa thành hai dictionary có `id` lần lượt là `a`, `b`, kèm `text` và `flag`.
- `intro_lines` và `completion_lines` được phát theo trình tự dialogue.
- `reward_exp`, `unlock_class_id`, màu nền và palette được áp dụng từ resource.

Mỗi wrapper map là `Node2D`, có `SpawnPoints/default` và gắn chapter resource tương ứng. Các wrapper có thể thêm backdrop, world bounds, hazard hoặc decorator riêng, nhưng không được đổi map ID hay chapter resource canonical.

## Contract lựa chọn đạo đức

Hai signal toàn cục chỉ có đúng hai tham số:

```gdscript
signal moral_choice_requested(choice_id: StringName, options: Array[Dictionary])
signal moral_choice_resolved(choice_id: StringName, selected_option: StringName)
```

Caller phải emit đúng contract:

```gdscript
GameEvents.moral_choice_requested.emit(choice_id, options)
GameEvents.moral_choice_resolved.emit(choice_id, selected_option)
```

Mỗi phần tử `options` có dạng:

```gdscript
{
    "id": &"a", # hoặc &"b"
    "text": "Nội dung hiển thị",
    "flag": &"chapter_x_choice_flag",
}
```

UI đọc `options[*].id` và `options[*].text`; nút hoặc phím `1`/`2` phải phát lại đúng `selected_option`. `GameState.record_choice(choice_id, selected_option)` lưu option đã chọn, còn map đặt moral flag tương ứng từ dictionary.

Không emit contract cũ bốn tham số `(choice_id, chapter_title, option_a, option_b)`.

## GameState và CampaignDirector

API tiến trình canonical:

```gdscript
# GameState
func record_choice(choice_id: StringName, selected_option: StringName) -> bool
func complete_chapter(chapter_number: int, map_id: StringName) -> bool
func is_chapter_complete(chapter_number: int) -> bool

# CampaignDirector
func start_from_hub() -> void
func go_to_chapter(chapter_number: int) -> bool
func complete_chapter(
    chapter_number: int,
    map_id: StringName,
    next_map_id: StringName = &"",
) -> void
func get_chapter_map(chapter_number: int) -> StringName
```

Luồng hoàn thành qua `CampaignDirector.complete_chapter(...)`:

1. Gọi `GameState.complete_chapter(chapter_number, map_id)` để ghi `completed_chapters`, cập nhật `current_chapter` và flag `<map_id>_complete`.
2. Nếu chapter vừa được ghi lần đầu, phát `GameEvents.chapter_completed(chapter_number, map_id)`.
3. Với Chương 2–9, chuyển đến `next_map_id`; nếu bỏ trống thì lấy map của chương kế tiếp từ `CampaignDirector.CHAPTER_MAPS`.
4. Với Chương 10, bỏ qua destination truyền vào, phát `GameEvents.campaign_completed()` và route đến `GameIds.MAP_TRUE_ENDING` tại spawn `default`.

`GameState.complete_chapter(...)` trả `false` khi chapter đã hoàn tất trước đó, giúp tránh ghi trùng. `CampaignDirector` vẫn thực hiện route tiếp theo để người chơi không bị kẹt khi một completion event được gọi lại.

## Chương 10: chuỗi hai boss

Chương 10 không hoàn thành ngay khi boss trong `ChapterDefinition` chết.

- Boss thứ nhất: `boss_papal_root_avatar` từ `chapter_10_world_root.tres`.
- Decorator: `res://scripts/campaign/chapters8_10/final_sequence_decorator.gd`.
- Boss thứ hai: `boss_corrupted_asterion`, spawn tại `EncounterAnchors/FinalBossSpawn`.
- Scene khai báo cả hai ID tại `res://scenes/maps/campaign/chapter_10_world_root.tscn`.
- Wrapper `res://scripts/campaign/chapters8_10/chapter_10_world_root.gd` đặt `auto_complete_on_boss_defeated = false`.

State machine của `FinalSequenceDecorator`:

```text
WAITING_FIRST_BOSS
  -> boss_papal_root_avatar bị hạ
SECOND_BOSS_ACTIVE
  -> spawn và hạ boss_corrupted_asterion
COMPLETED
  -> sequence_completed
  -> hoàn thành Chương 10
  -> campaign_completed
  -> true_ending
```

Không được route tới True Ending sau boss thứ nhất.

## Lệnh kiểm tra

Chạy bằng Godot console 4.3 đã đặt tại `D:\Temp\godot-4.3-console\Godot_v4.3-stable_win64_console.exe`:

```powershell
$godot = 'D:\Temp\godot-4.3-console\Godot_v4.3-stable_win64_console.exe'
$project = 'D:\Son\GAME'

# Parse toàn project
& $godot --headless --path $project --editor --quit

# Contract tổng campaign
& $godot --headless --path $project 'res://tests/integration/campaign_smoke_test.tscn'

# Data, enemy và cân bằng
& $godot --headless --path $project 'res://tests/enemies/campaign/campaign_enemy_load_test.tscn'
& $godot --headless --path $project 'res://tests/campaign/balance/campaign_balance_test.tscn'

# Runtime map và chuỗi boss Chương 10
& $godot --headless --path $project 'res://tests/campaign/maps/chapter2_4/test_campaign_chapter_map_runtime.tscn'
& $godot --headless --path $project 'res://tests/campaign/runtime/campaign_chapters_runtime_test.tscn'

# Save/load, progression, route True Ending và UI moral choice
& $godot --headless --path $project 'res://tests/campaign/progression/campaign_progression_test.tscn'
& $godot --headless --path $project 'res://tests/integration/ui_event_bridge_campaign_test.tscn'
```

Mỗi test scene tự thoát với exit code `0` khi đạt và `1` khi có lỗi. Sau khi sửa campaign data, route, UI hoặc boss sequence, tối thiểu phải chạy parser, smoke test, runtime test và progression test.