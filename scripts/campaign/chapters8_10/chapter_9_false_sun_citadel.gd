class_name Chapter9FalseSunCitadel
extends LateCampaignChapterWrapper

func _ready() -> void:
    definition_resource_path = "res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres"
    chapter_id = &"chapter_9_false_sun_citadel"
    chapter_number = 9
    chapter_title = "Chương 9 — Thành Trì Mặt Trời Giả"
    chapter_objective = "Phá ba thấu kính hút sinh lực Cây Thế Giới và mở cổng vào Thánh Điện."
    boss_id = &"boss_false_sun"
    next_chapter_id = &"chapter_10_world_root"
    super._ready()
