# Vết Ấn Dưới Rễ Cây — MVP Integration Architecture

Hợp đồng tích hợp cho MVP Godot 4 typed GDScript gồm ba map đầu. Nguồn nội dung là `Y_TUONG_GAME.md`. `Assets.md` đang trống, vì vậy placeholder phải nằm trong write scope của package tạo ra nó.

## Nguyên tắc

- `Main` tồn tại xuyên phiên chơi; chỉ scene trong `MapContainer` được thay.
- Player và HUD không được đặt trực tiếp trong map.
- `GameState` chỉ lưu dữ liệu serialize được, không giữ tham chiếu `Node` runtime.
- Map không gọi `change_scene_to_file()`; mọi chuyển map đi qua `GameEvents` và `SceneRouter`.
- ID gameplay dùng `StringName` từ `GameIds`.
- Integrator không sửa file worker. Adapter tích hợp phải nằm trong `res://scripts/integration/`.

## Runtime scene tree

```text
Main
├── WorldRoot
│   └── MapContainer
│       └── CurrentMap
├── ActorRoot
│   └── Player (CharacterBody2D, group: player)
├── PersistentUI
│   └── HUD
└── TransitionLayer
    └── Fade
```

`SceneRouter` unload map cũ, instantiate map mới, đặt Player vào spawn, rồi mới mở input và fade-in. Player, HUD và autoload không được tạo lại khi chuyển map.

## Canonical paths

```text
res://scenes/maps/map1_awakening_forest.tscn
res://scenes/maps/map2_tutorial_road.tscn
res://scenes/maps/map3_ashen_town_hub.tscn
res://scenes/actors/player/player.tscn
res://scenes/ui/hud.tscn
res://autoload/game_ids.gd
res://autoload/game_events.gd
res://autoload/game_state.gd
res://autoload/save_service.gd
res://autoload/scene_router.gd
```

Autoload bắt buộc mang tên `GameIds`, `GameEvents`, `GameState`, `SaveService`, `SceneRouter`.

## Map contract

Mỗi map là `Node2D`, không chứa Player/HUD, và có cấu trúc tối thiểu:

```text
MapRoot
├── Environment
├── Collision
├── SpawnPoints
│   └── default (Marker2D)
└── Triggers
```

`SpawnPoints/default` phân biệt hoa/thường. Spawn bổ sung là `Marker2D` dưới `SpawnPoints`, tên node bằng `spawn_id`. Trigger chuyển map phát:

```gdscript
GameEvents.map_change_requested.emit(target_map_id, target_spawn_id)
```

`GameIds` tối thiểu có `MAP_1`, `MAP_2`, `MAP_3`, `SPAWN_DEFAULT`.

## Autoload contracts

### GameEvents

```gdscript
signal map_change_requested(map_id: StringName, spawn_id: StringName)
signal dialogue_requested(payload: Dictionary)
signal tutorial_requested(payload: Dictionary)
signal hub_panel_requested(panel_id: StringName)
signal toast_requested(message: String)
```

Dialogue payload có `map_id`, `sequence_id`, `line_index`, `speaker`, `text`, `extra`. Tutorial payload có `map_id`, `tutorial_id`, `text`, `actions: Array[StringName]`.

### GameState

```gdscript
func set_flag(flag_id: StringName, value: bool = true) -> void
func has_flag(flag_id: StringName) -> bool
func add_item(item_id: StringName, quantity: int) -> void
func add_currency(currency_id: StringName, amount: int) -> void
func gain_exp(amount: int) -> void
func allocate_stat(stat_id: StringName, points: int) -> bool
func set_class(class_id: StringName) -> bool
```

State cần save: map/spawn, level/EXP/stat points, allocated stats, class, HP/STA, inventory, currencies, tutorial flags và quest flags.

### SaveService và SceneRouter

```gdscript
func save_game(slot: int = 0) -> Error
func load_game(slot: int = 0) -> Error
func change_map(map_id: StringName, spawn_id: StringName = &default) -> void
```

Save payload phải có `save_version`. Router phải chống transition lặp và báo rõ map/spawn/resource bị thiếu.

## Player contract

Player root là `CharacterBody2D`, thuộc group `player`:

```gdscript
signal action_committed(action_id: StringName)
signal died
func set_input_enabled(enabled: bool) -> void
func grant_weapon(weapon_id: StringName) -> void
func restore_full() -> void
func receive_damage(packet: Variant) -> Variant
```

`play_state_animation(state_id)` là optional. Map 2 theo dõi các action ID `attack`, `combo_finisher`, `dodge`, `skill_1`.

## Flow Map 1 → Map 2 → Map 3

### Map 1

Opening khóa input, phát dialogue, sau đó dạy di chuyển. Rune Pillar gọi `grant_weapon(&rootbound_sword)`, ghi flag `map1_weapon_restored`, mở gate và yêu cầu Map 2. Opening và grant weapon phải idempotent sau load.

### Map 2

1. Hai Bóng Sương Hồn: yêu cầu `combo_finisher`.
2. Hai Sói Rễ Hắc Tín: yêu cầu dodge trong telegraph.
3. Một Nấm Độc Than Thở: yêu cầu `skill_1` và hạ enemy.
4. Aria cùng Player đấu Hươu Sừng Rễ.
5. Boss chết ghi `map2_boss_defeated`; dialogue Aria ghi `aria_met` rồi mở Map 3.

Mỗi encounter phải có completion flag để load game không spawn hoặc khóa sai trạng thái.

### Map 3

Hub cung cấp campfire (rest/save/class/stats), forge, shop và quest board. Feature mở UI bằng `hub_panel_requested`; không tự ghi save file.

## Merge order

1. Project/InputMap/autoload contracts.
2. Player public API.
3. Enemy/loot và combat interoperability.
4. HUD/dialogue/tutorial UI.
5. Map 1 và Map 3.
6. Map 2 encounter flow.
7. Integration adapters, manifest và end-to-end QA.

## Merge checklist

- [ ] Chỉ sửa file trong write scope.
- [ ] Không đổi canonical path hoặc public API âm thầm.
- [ ] `.gd`, `.tscn`, `.tres` load được, không thiếu external resource.
- [ ] Autoload đúng tên trong `/root`.
- [ ] Ba map có `SpawnPoints/default` là `Marker2D`.
- [ ] Player load được, root `CharacterBody2D`, group `player`.
- [ ] HUD load và instantiate được.
- [ ] Map không chứa Player/HUD riêng.
- [ ] InputMap có move, interact, attack, dodge, skill 1 và pause.
- [ ] Save/load giữ tutorial và quest flags.
- [ ] Integration smoke test trả exit code `0`.

## Chạy smoke test

```powershell
godot --headless --path D:\Son\GAME res://tests/integration/smoke_test.tscn
```

Exit code `1` đi kèm log `[SMOKE][FAIL]` chỉ rõ resource, node path, method, signal hoặc autoload bị thiếu.
