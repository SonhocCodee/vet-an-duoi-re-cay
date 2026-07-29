class_name Chapter8EmptyMonastery
extends LateCampaignChapterWrapper

func _ready() -> void:
    definition_resource_path = "res://resources/campaign/chapters/chapter_8_empty_monastery.tres"
    chapter_id = &"chapter_8_empty_monastery"
    chapter_number = 8
    chapter_title = "Chương 8 — Tu Viện Trống"
    chapter_objective = "Lắng nghe ký ức của những nữ tu không còn khuôn mặt và tìm lối xuống hầm phong ấn."
    boss_id = &"boss_empty_abbot"
    next_chapter_id = &"chapter_9_false_sun_citadel"
    super._ready()
