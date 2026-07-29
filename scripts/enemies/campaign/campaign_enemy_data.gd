class_name CampaignEnemyData
extends EnemyData

@export_group("Campaign Appearance")
@export_range(0, 4, 1) var visual_style: int = 0
@export var body_color: Color = Color("544c66")
@export var accent_color: Color = Color("c7c2d8")
@export_range(14.0, 64.0, 1.0) var visual_size: float = 24.0
