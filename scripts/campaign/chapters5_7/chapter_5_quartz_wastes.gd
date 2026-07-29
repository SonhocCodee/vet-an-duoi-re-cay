class_name Chapter5QuartzWastes
extends "res://scripts/campaign/chapters5_7/mid_campaign_chapter_wrapper.gd"

const DEFINITION_PATH: String = "res://resources/campaign/chapters/chapter_5_quartz_wastes.tres"


func _ready() -> void:
	definition_resource_path = DEFINITION_PATH
	super._ready()
