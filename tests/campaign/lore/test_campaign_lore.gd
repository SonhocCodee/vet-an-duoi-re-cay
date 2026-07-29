extends SceneTree

const LORE_PATHS: PackedStringArray = [
	"res://resources/campaign/lore/chapter_2/drowned_basilica.tres",
	"res://resources/campaign/lore/chapter_2/bell_warden.tres",
	"res://resources/campaign/lore/chapter_2/last_bell_choice.tres",
	"res://resources/campaign/lore/chapter_3/ash_blind_road.tres",
	"res://resources/campaign/lore/chapter_3/procession_marshal.tres",
	"res://resources/campaign/lore/chapter_3/unveiled_path.tres",
	"res://resources/campaign/lore/chapter_4/erased_archive.tres",
	"res://resources/campaign/lore/chapter_4/name_curator.tres",
	"res://resources/campaign/lore/chapter_4/right_to_remembrance.tres",
	"res://resources/campaign/lore/chapter_5/quartz_wastes.tres",
	"res://resources/campaign/lore/chapter_5/quartz_colossus.tres",
	"res://resources/campaign/lore/chapter_5/last_well_covenant.tres",
	"res://resources/campaign/lore/chapter_6/burning_root_garden.tres",
	"res://resources/campaign/lore/chapter_6/cinder_root_matriarch.tres",
	"res://resources/campaign/lore/chapter_6/pure_flame_dilemma.tres",
	"res://resources/campaign/lore/chapter_7/black_resin_pass.tres",
	"res://resources/campaign/lore/chapter_7/resin_huntsman.tres",
	"res://resources/campaign/lore/chapter_7/prisoners_and_judges.tres",
	"res://resources/campaign/lore/chapter_8/empty_monastery.tres",
	"res://resources/campaign/lore/chapter_8/hollow_abbot.tres",
	"res://resources/campaign/lore/chapter_8/merciful_memory.tres",
	"res://resources/campaign/lore/chapter_9/false_sun_citadel.tres",
	"res://resources/campaign/lore/chapter_9/false_sun_pontiff.tres",
	"res://resources/campaign/lore/chapter_9/truth_before_refuge.tres",
	"res://resources/campaign/lore/chapter_10/world_root.tres",
	"res://resources/campaign/lore/chapter_10/rootbound_pontiff.tres",
	"res://resources/campaign/lore/chapter_10/root_seal_burden.tres",
]

const CHAPTER_PATHS: Dictionary = {
	2: "res://resources/campaign/chapters/chapter_2_drowned_bells.tres",
	3: "res://resources/campaign/chapters/chapter_3_blind_procession.tres",
	4: "res://resources/campaign/chapters/chapter_4_erased_archive.tres",
	5: "res://resources/campaign/chapters/chapter_5_quartz_wastes.tres",
	6: "res://resources/campaign/chapters/chapter_6_burning_root_garden.tres",
	7: "res://resources/campaign/chapters/chapter_7_black_resin_pass.tres",
	8: "res://resources/campaign/chapters/chapter_8_empty_monastery.tres",
	9: "res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres",
	10: "res://resources/campaign/chapters/chapter_10_world_root.tres",
}

const REQUIRED_CATEGORIES: Array[StringName] = [
	&"location",
	&"adversary",
	&"moral_choice",
]

var failures: Array[String] = []
var seen_entry_ids: Dictionary = {}
var chapter_counts: Dictionary = {}
var chapter_category_counts: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(LORE_PATHS.size() >= 27, "Lore codex contains at least three entries for each of nine chapters")
	for lore_path: String in LORE_PATHS:
		_validate_lore_entry(lore_path)
	for chapter_number: int in range(2, 11):
		_expect(int(chapter_counts.get(chapter_number, 0)) >= 3, "Chapter %d has at least three lore entries" % chapter_number)
		for category: StringName in REQUIRED_CATEGORIES:
			var category_key: String = "%d:%s" % [chapter_number, category]
			_expect(int(chapter_category_counts.get(category_key, 0)) >= 1, "Chapter %d has a %s lore entry" % [chapter_number, category])
	if failures.is_empty():
		print("Campaign lore data tests passed")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	quit(1)


func _validate_lore_entry(lore_path: String) -> void:
	var loaded: Resource = ResourceLoader.load(lore_path)
	_expect(loaded is CampaignLoreEntry, "%s loads as CampaignLoreEntry" % lore_path)
	if not loaded is CampaignLoreEntry:
		return
	var entry := loaded as CampaignLoreEntry
	_expect(entry.is_valid_entry(), "%s passes validation: %s" % [lore_path, entry.get_validation_errors()])
	_expect(not seen_entry_ids.has(entry.entry_id), "%s uses a unique entry_id" % lore_path)
	seen_entry_ids[entry.entry_id] = true
	_expect(String(entry.entry_id).begins_with("lore_chapter_%d_" % entry.chapter_number), "%s entry_id matches its chapter" % lore_path)
	_expect(entry.summary.length() >= 40, "%s has a useful summary" % lore_path)
	_expect(entry.body.length() >= 180, "%s has substantial codex body text" % lore_path)
	chapter_counts[entry.chapter_number] = int(chapter_counts.get(entry.chapter_number, 0)) + 1
	var category_key: String = "%d:%s" % [entry.chapter_number, entry.category_id]
	chapter_category_counts[category_key] = int(chapter_category_counts.get(category_key, 0)) + 1
	_validate_against_chapter_definition(entry, lore_path)


func _validate_against_chapter_definition(entry: CampaignLoreEntry, lore_path: String) -> void:
	var chapter_path: String = CHAPTER_PATHS.get(entry.chapter_number, "")
	var loaded: Resource = ResourceLoader.load(chapter_path)
	_expect(loaded is ChapterDefinition, "%s has a canonical ChapterDefinition" % lore_path)
	if not loaded is ChapterDefinition:
		return
	var chapter := loaded as ChapterDefinition
	_expect(entry.chapter_id == chapter.chapter_id, "%s chapter_id matches canon" % lore_path)
	match entry.category_id:
		&"location":
			_expect(entry.related_ids.has(chapter.chapter_id), "%s links its canonical chapter" % lore_path)
		&"adversary":
			_expect(entry.related_ids.has(chapter.boss_enemy_id), "%s links the canonical boss" % lore_path)
		&"moral_choice":
			_expect(entry.related_ids.has(chapter.moral_choice_id), "%s links the canonical moral choice" % lore_path)
			_expect(entry.related_ids.has(chapter.moral_option_a_flag), "%s links moral option A flag" % lore_path)
			_expect(entry.related_ids.has(chapter.moral_option_b_flag), "%s links moral option B flag" % lore_path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
