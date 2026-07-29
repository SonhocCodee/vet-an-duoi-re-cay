class_name CampaignEnemyBase
extends EnemyBase


func _ready() -> void:
	super._ready()
	_apply_campaign_appearance()


func _apply_campaign_appearance() -> void:
	if not data is CampaignEnemyData or not visual is CampaignEnemyVisual:
		return
	var campaign_data: CampaignEnemyData = data as CampaignEnemyData
	var campaign_visual: CampaignEnemyVisual = visual as CampaignEnemyVisual
	campaign_visual.campaign_style = campaign_data.visual_style
	campaign_visual.body_color = campaign_data.body_color
	campaign_visual.accent_color = campaign_data.accent_color
	campaign_visual.size = campaign_data.visual_size
	campaign_visual.queue_redraw()
