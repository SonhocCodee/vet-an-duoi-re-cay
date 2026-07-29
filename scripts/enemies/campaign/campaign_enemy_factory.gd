class_name CampaignEnemyFactory
extends RefCounted

const GENERIC_ENEMY_SCENE: PackedScene = preload("res://scenes/actors/enemies/campaign/generic_campaign_enemy.tscn")
const DATA_PATH_TEMPLATE: String = "res://resources/enemies/campaign/%s.tres"


static func create(enemy_id: StringName, combat_level: int = 0) -> CampaignEnemyBase:
	var data_path: String = DATA_PATH_TEMPLATE % enemy_id
	var data: CampaignEnemyData = load(data_path) as CampaignEnemyData
	if data == null:
		push_error("Unknown campaign enemy ID: %s" % enemy_id)
		return null
	var enemy: CampaignEnemyBase = GENERIC_ENEMY_SCENE.instantiate() as CampaignEnemyBase
	if enemy == null:
		push_error("Generic campaign enemy scene could not instantiate.")
		return null
	enemy.data = data
	enemy.combat_level = data.base_level if combat_level <= 0 else maxi(combat_level, data.base_level)
	return enemy
