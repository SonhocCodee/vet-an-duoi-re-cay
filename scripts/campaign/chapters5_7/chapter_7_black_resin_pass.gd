class_name Chapter7BlackResinPass
extends "res://scripts/campaign/chapters5_7/mid_campaign_chapter_wrapper.gd"

const DEFINITION_PATH: String = "res://resources/campaign/chapters/chapter_7_black_resin_pass.tres"


func _ready() -> void:
	definition_resource_path = DEFINITION_PATH
	super._ready()
