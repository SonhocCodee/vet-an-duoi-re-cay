extends SceneTree

const SUITE_TIMEOUT_SECONDS: float = 10.0
const CHAPTER_SCENES: PackedStringArray = [
    "res://scenes/maps/campaign/chapter_8_empty_monastery.tscn",
    "res://scenes/maps/campaign/chapter_9_false_sun_citadel.tscn",
    "res://scenes/maps/campaign/chapter_10_world_root.tscn",
]

var _failures: Array[String] = []
var _finished: bool = false
var _stage: String = "initializing"

func _init() -> void:
    var watchdog: SceneTreeTimer = create_timer(SUITE_TIMEOUT_SECONDS, true, false, true)
    watchdog.timeout.connect(_on_suite_timeout)
    call_deferred(&"_run")

func _run() -> void:
    for scene_path: String in CHAPTER_SCENES:
        _stage = "loading %s" % scene_path
        var packed: PackedScene = load(scene_path) as PackedScene
        _expect(packed != null, "Could not load %s." % scene_path)
        if packed == null:
            continue
        var chapter: Node2D = packed.instantiate() as Node2D
        _expect(chapter != null, "%s root is not Node2D." % scene_path)
        if chapter == null:
            continue
        root.add_child(chapter)
        _stage = "waiting for %s ready frame" % scene_path
        await process_frame
        _expect(chapter.get_node_or_null("SpawnPoints/default") is Marker2D, "%s has no runtime default spawn." % scene_path)
        var exposes_definition: bool = chapter.has_method(&"get_chapter_definition")
        _expect(exposes_definition, "%s does not expose ChapterDefinition adapter." % scene_path)
        if exposes_definition:
            var definition: Variant = chapter.call(&"get_chapter_definition")
            _expect(definition is Resource, "%s did not create/load a ChapterDefinition resource." % scene_path)
        chapter.queue_free()
        _stage = "freeing %s" % scene_path
        await process_frame

    _stage = "checking Chapter 10 final sequence"
    await _check_final_sequence_runtime()
    _stage = "checking true ending"
    await _check_ending_runtime()
    _finish()

func _check_final_sequence_runtime() -> void:
    var packed: PackedScene = load(CHAPTER_SCENES[2]) as PackedScene
    _expect(packed != null, "Could not load Chapter 10 for final-sequence checks.")
    if packed == null:
        return
    var chapter: Node2D = packed.instantiate() as Node2D
    _expect(chapter != null, "Chapter 10 root is not Node2D.")
    if chapter == null:
        return
    root.add_child(chapter)
    await process_frame
    var exposes_boss_hook: bool = chapter.has_method(&"notify_boss_defeated")
    _expect(exposes_boss_hook, "Chapter 10 does not expose its final-sequence boss hook.")
    var sequence: Node = chapter.get_node_or_null("FinalSequence")
    _expect(sequence != null, "Chapter 10 final-sequence node is missing.")
    if not exposes_boss_hook or sequence == null:
        chapter.queue_free()
        await process_frame
        return
    chapter.call(&"notify_boss_defeated", &"boss_papal_root_avatar")
    await process_frame
    var second_boss: Node = sequence.call(&"get_second_boss") as Node
    _expect(int(sequence.get(&"phase")) == 1, "Chapter 10 did not enter second-boss phase.")
    _expect(second_boss != null, "Decorator did not spawn the canonical second boss.")
    if second_boss != null:
        chapter.call(&"notify_boss_defeated", &"boss_corrupted_asterion")
        await process_frame
        await process_frame
    _expect(int(sequence.get(&"phase")) == 2, "Chapter 10 final sequence did not complete after second boss.")
    chapter.queue_free()
    await process_frame

func _check_ending_runtime() -> void:
    var state: Node = root.get_node_or_null("GameState")
    if state != null:
        state.call(&"set_flag", &"choice_mercy_abbess", true)
        state.call(&"set_flag", &"choice_reveal_truth", true)
        state.call(&"set_flag", &"choice_world_root_sacrifice", true)
    var packed: PackedScene = load("res://scenes/ending/true_ending.tscn") as PackedScene
    _expect(packed != null, "Could not load the true ending scene.")
    if packed == null:
        return
    var ending: Control = packed.instantiate() as Control
    _expect(ending != null, "True ending root is not Control.")
    if ending == null:
        return
    root.add_child(ending)
    await process_frame
    _expect(ending.get_node_or_null("Margin/Content/Epilogue") is Label, "Ending epilogue label is missing.")
    var exposes_summary: bool = ending.has_method(&"build_moral_summary")
    _expect(exposes_summary, "True ending does not expose moral summary generation.")
    if not exposes_summary:
        ending.queue_free()
        await process_frame
        return
    var summary: String = str(ending.call(&"build_moral_summary"))
    _expect("Lựa chọn đã ghi nhận" in summary, "Ending did not summarize moral choices from GameState.")
    _expect("Lòng trắc ẩn: 1" in summary, "Ending compassion statistic is incorrect.")
    _expect("Bảo vệ sự thật: 1" in summary, "Ending truth statistic is incorrect.")
    _expect("Chấp nhận hy sinh: 1" in summary, "Ending sacrifice statistic is incorrect.")
    ending.queue_free()
    await process_frame

func _finish() -> void:
    if _finished:
        return
    _finished = true
    if _failures.is_empty():
        print("Chapters 8-10 runtime checks passed.")
        quit(0)
        return
    for failure: String in _failures:
        push_error(failure)
    quit(1)

func _on_suite_timeout() -> void:
    if _finished:
        return
    _failures.append("Suite timed out after %.1f seconds while %s." % [SUITE_TIMEOUT_SECONDS, _stage])
    _finish()

func _expect(condition: bool, message: String) -> void:
    if not condition:
        _failures.append(message)
