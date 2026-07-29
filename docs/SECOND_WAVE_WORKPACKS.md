# Workpack Đợt Hai — Thành Phố Trung Cổ & Hệ Thống Nhân Vật

## Mục Tiêu
Biến Map 3 thành trung tâm thành phố trung cổ có dân cư sống động; bổ sung 20 NPC khác nhau, animation, lịch trình tự di chuyển, side quest, HUD, inventory/equipment, loot pickup, bản đồ và quest journal. Tất cả giữ tương thích campaign Chapter 2–10 và Godot 4.3.

## Danh Sách 20 NPC
| ID | Tên / Nghề | Khu vực | Lịch trình | Side quest |
|---|---|---|---|---|
| alden_blacksmith | Alden — thợ rèn | forge_quarter | lò rèn 06–18, quán trọ 19–21 | Thanh Kiếm Không Tên |
| mira_apothecary | Mira — dược sư | herb_market | chợ 07–17, vườn thuốc 18–20 | Ba Loài Rễ Độc |
| father_oren | Cha Oren — linh mục | old_chapel | lễ đường 05–12, nghĩa trang 16–20 | Tiếng Chuông Không Người Kéo |
| lysa_baker | Lysa — thợ bánh | market_square | lò bánh 05–15, giếng 16–18 | Bột Mì Dính Tro |
| tomas_guard | Tomas — lính gác | west_gate | cổng 06–14, tuần tra 15–18 | Dấu Chân Ngoài Tường |
| neris_cartographer | Neris — người vẽ bản đồ | archive_lane | thư khố 08–17, tháp canh 18–20 | Những Con Đường Bị Xóa |
| gareth_stablemaster | Gareth — quản ngựa | south_stables | chuồng 05–19 | Con Ngựa Không Có Bóng |
| maela_weaver | Maela — thợ dệt | artisan_row | xưởng 08–18, chợ 18–20 | Tấm Vải Ghi Nhớ |
| borin_mason | Borin — thợ xây | ruined_wall | công trường 06–17 | Viên Đá Biết Khóc |
| ivy_orphan | Ivy — trẻ mồ côi | market_square | chợ 09–14, hẻm 15–19 | Búp Bê Dưới Cống |
| cedric_archivist | Cedric — thủ thư | city_archive | thư khố 07–20 | Hồ Sơ Kael Asterion |
| helena_innkeeper | Helena — chủ quán trọ | root_inn | quán trọ 06–24 | Vị Khách Phòng Số Bảy |
| oswin_fisher | Oswin — ngư dân | river_docks | bến 04–12, chợ 13–16 | Cá Trắng Mắt Đen |
| rosalind_midwife | Rosalind — bà đỡ | residential_east | nhà dân 06–18 | Đứa Trẻ Không Khóc |
| silas_gravedigger | Silas — đào huyệt | cemetery | nghĩa trang 07–19 | Ngôi Mộ Trống Thứ Mười Ba |
| yvette_jeweler | Yvette — thợ kim hoàn | noble_arcade | cửa hàng 09–19 | Vương Miện Nứt |
| damian_scribe | Damian — thư lại | council_hall | hội đồng 08–18 | Sắc Lệnh Giả |
| freya_hunter | Freya — thợ săn | north_gate | rừng 05–15, cổng 16–19 | Con Thú Mang Dấu Thánh |
| rowan_watch_captain | Rowan — đội trưởng | watch_barracks | doanh trại 06–20 | Nội Gián Trong Đội Canh |
| elric_beggar_prophet | Elric — hành khất tiên tri | wechselnde | quảng trường/hẻm 09–22 | Lời Tiên Tri Dưới Rễ |

## Animation Contract
Mỗi NPC có 11 SVG 96×96 trong thư mục riêng:
- <id>_idle_down.svg, <id>_idle_up.svg, <id>_idle_side.svg
- <id>_walk_down_0.svg, <id>_walk_down_1.svg
- <id>_walk_up_0.svg, <id>_walk_up_1.svg
- <id>_walk_side_0.svg, <id>_walk_side_1.svg
- <id>_interact.svg, <id>_hurt.svg
Left/right dùng cùng side frame và flip_h. Player dùng cùng naming tại assets/art/player/kael_*.svg.

## Medieval City Asset Contract
- assets/art/city/backgrounds/ashen_city_full.svg, market_square.svg, artisan_row.svg, old_chapel.svg, cemetery.svg, river_docks.svg
- assets/art/city/buildings/: blacksmith.svg, apothecary.svg, bakery.svg, inn.svg, chapel.svg, archive.svg, council_hall.svg, barracks.svg, stable.svg, mason_yard.svg, jeweler.svg, 4 house variants, gate, wall, tower, bridge, dock
- assets/art/city/props/: cart, barrel, crate, well, lamp, sign, stall, bench, fountain, tree_dead, hay, forge, anvil, grave, statue, boat, laundry, notice_board, sewer_grate
- assets/art/ui/: health_frame.svg, stamina_frame.svg, xp_frame.svg, inventory_panel.svg, equipment_panel.svg, quest_panel.svg, map_frame.svg, loot_prompt.svg, marker_player.svg, marker_quest.svg, marker_npc.svg
- assets/art/items/: 24 icons gồm potion, herb, ore, weapons, armor, quest items và currencies.

## Runtime APIs
- NpcData Resource: npc_id, display_name, profession, home_zone, schedule:Array[Dictionary], dialogue_ids, quest_ids, portrait_path.
- NpcController: configure(data), set_navigation_target(position), pause_for_dialogue(), resume_schedule(); signals npc_interacted(npc_id), schedule_slot_changed(npc_id, slot_id).
- CityScheduleService: register_npc(), resolve_target(npc_id, hour), tick_game_time(delta).
- InventoryService: add_item(), remove_item(), equip_item(), get_quantity(); signal inventory_changed.
- QuestService: start_quest(), advance_objective(), complete_quest(); signal quest_updated.
- LootPickup: item_id, quantity; signal picked_up(item_id, quantity).
- UI signals trên GameEvents: hud_refresh_requested, inventory_toggled, quest_journal_toggled, map_toggled, npc_dialogue_requested, loot_picked_up.
- Save v3: game_time, npc_states, active_quests, completed_side_quests, discovered_map_markers; migration v2 → v3 giữ nguyên campaign.

## Workpack 1 — Artist D: NPC 01–07 + Player
Write scope: assets/art/npcs/set_d/**, assets/art/player/**.
Tạo đủ 11 frame cho alden, mira, father_oren, lysa, tomas, neris, gareth và Kael; portrait 192×192 cho 7 NPC. Silhouette/nghề/màu phải khác nhau.
Acceptance: 95 SVG hợp lệ, đúng kích thước, transparent, không text/watermark.

## Workpack 2 — Artist E: NPC 08–14 + Buildings
Write scope: assets/art/npcs/set_e/**, assets/art/city/buildings/**.
Tạo đủ 11 frame + portrait cho maela, borin, ivy, cedric, helena, oswin, rosalind. Tạo 20 building/city-structure SVG theo contract.
Acceptance: 97 SVG hợp lệ; building có cửa/điểm neo rõ, đọc được top-down 3/4.

## Workpack 3 — Artist F: NPC 15–20 + City/UI/Items
Write scope: assets/art/npcs/set_f/**, assets/art/city/backgrounds/**, assets/art/city/props/**, assets/art/ui/**, assets/art/items/**.
Tạo đủ 11 frame + portrait cho silas, yvette, damian, freya, rowan, elric; 6 city backgrounds; 20 props; 11 UI assets; 24 item icons.
Acceptance: toàn bộ SVG hợp lệ, palette nhất quán, UI đọc tốt ở 1280×720.

## Workpack 4 — Gameplay Coder
Write scope: scripts/npc/**, scripts/systems/**, scripts/ui/gameplay/**, resources/npcs/**, resources/quests/side/**, autoload/game_state.gd, autoload/game_events.gd, project.godot, tests/second_wave/code/**.
Implement NpcData/NpcController/CityScheduleService, 20 data resources và lịch trình, side quest definitions, inventory/equipment, loot pickup, HUD controller, inventory/quest/map controllers, dialogue bridge, save v3 migration. Không sửa scene hoặc art.
Acceptance: parser pass; NPC schedule deterministic; navigation target đổi theo giờ; 20 resources valid; inventory/quest/loot/save tests pass; API cũ không regress.

## Workpack 5 — Asset Integrator
Write scope: scenes/city/**, scenes/npcs/**, scenes/ui/gameplay/**, scenes/maps/map3_ashen_town_hub.tscn, scenes/bootstrap/main.tscn, scenes/actors/player/player.tscn, scripts/visuals/second_wave/**, resources/content/city/**, tests/second_wave/integration/**.
Chờ asset D/E/F và code runtime. Tạo AnimatedSprite2D/SpriteFrames cho player + 20 NPC, city scene với navigation region, 20 NPC spawn, buildings/props, HUD bars, inventory/equipment, quest journal, loot pickup, local/world map và dialogue panel. Giữ cổng campaign, shop/forge/campfire/quest board cũ.
Acceptance: 20 NPC distinct instantiate; NPC tự đi nhưng không xuyên tường; animation idle/walk/interact/hurt; city 1280×720 và 2200×900 bounds; HUD cập nhật; pickup vào inventory; side quest bắt đầu/hoàn thành; save/load v3; main boot và campaign regression pass.

## Dependency
Artist D/E/F và Gameplay Coder chạy song song. Asset Integrator có thể dựng skeleton trước nhưng chỉ hoàn tất sau khi đủ asset và API. Lead tích hợp cuối chạy parser, movement, main boot, campaign runtime, second-wave tests và visual smoke.
