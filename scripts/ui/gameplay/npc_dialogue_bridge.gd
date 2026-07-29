class_name NpcDialogueBridge
extends Node

signal dialogue_payload_ready(payload: Dictionary)

var _bound_npcs: Dictionary = {}


func bind_npc(npc: NpcController) -> bool:
	if npc == null or _bound_npcs.has(npc.get_instance_id()):
		return false
	_bound_npcs[npc.get_instance_id()] = npc
	npc.interaction_requested.connect(_on_npc_interaction_requested)
	npc.tree_exiting.connect(_on_npc_tree_exiting.bind(npc.get_instance_id()))
	return true


func request_dialogue(npc: NpcController, _actor: Node = null) -> Dictionary:
	if npc == null:
		return {}
	var payload: Dictionary = npc.get_dialogue_payload()
	if payload.is_empty():
		return payload
	dialogue_payload_ready.emit(payload.duplicate(true))
	GameEvents.npc_dialogue_requested.emit(
		StringName(payload.get(&"npc_id", &"")),
		StringName(payload.get(&"dialogue_id", &"")),
		StringName(payload.get(&"quest_id", &""))
	)
	GameEvents.dialogue_requested.emit(StringName(payload.get(&"dialogue_id", &"")))
	return payload


func accept_side_quest(quest_id: StringName) -> bool:
	var quest_service: Node = get_node_or_null(^"/root/QuestService")
	return bool(quest_service.call(&"start_quest", quest_id)) if quest_service != null else false


func _on_npc_interaction_requested(npc: NpcController, actor: Node) -> void:
	request_dialogue(npc, actor)


func _on_npc_tree_exiting(instance_id: int) -> void:
	_bound_npcs.erase(instance_id)
