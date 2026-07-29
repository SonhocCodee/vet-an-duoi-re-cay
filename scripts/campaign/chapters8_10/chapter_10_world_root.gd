class_name Chapter10WorldRoot
extends LateCampaignChapterWrapper

@onready var final_sequence: FinalSequenceDecorator = $FinalSequence
@onready var final_boss_spawn: Marker2D = $EncounterAnchors/FinalBossSpawn

func _ready() -> void:
    definition_resource_path = "res://resources/campaign/chapters/chapter_10_world_root.tres"
    auto_complete_on_boss_defeated = false
    chapter_id = &"chapter_10_world_root"
    chapter_number = 10
    chapter_title = "Chương 10 — Căn Rễ Thế Giới"
    chapter_objective = "Đánh bại Giáo Hoàng Ánh Sáng Giả, đối diện Bóng Asterion Sai Lệch và giải phóng Cây Thế Giới."
    boss_id = &"boss_papal_root_avatar"
    next_chapter_id = &"true_ending"
    super._ready()
    final_sequence.configure(get_campaign_map(), final_boss_spawn)
    final_sequence.sequence_completed.connect(_on_final_sequence_completed)

func notify_boss_defeated(defeated_boss_id: StringName = &"") -> void:
    final_sequence.notify_boss_defeated(defeated_boss_id)

func _on_final_sequence_completed() -> void:
    if campaign_map != null and campaign_map.has_method(&"complete_chapter"):
        campaign_map.call(&"complete_chapter")
    else:
        CampaignDirector.complete_chapter(chapter_number, chapter_id, next_chapter_id)
