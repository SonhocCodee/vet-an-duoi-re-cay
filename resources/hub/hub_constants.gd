class_name HubConstants
extends RefCounted

const MAP_ID: StringName = &"map3_ashen_town_hub"
const SPAWN_DEFAULT: StringName = &"default"
const GROUP_HUB_UI: StringName = &"hub_ui"
const GROUP_HUB_STATION: StringName = &"hub_station"
const GROUP_SPAWN_POINT: StringName = &"spawn_point"

const CLASS_SWORD_WARDEN: StringName = &"blademaster"
const CLASS_ROOT_GUARDIAN: StringName = &"guardian"
const CLASS_SPELLBLADE: StringName = &"spellblade"
const CLASS_ASHEN_MONK: StringName = &"priest"
const CLASSES: Array[StringName] = [CLASS_SWORD_WARDEN, CLASS_ROOT_GUARDIAN, CLASS_SPELLBLADE, CLASS_ASHEN_MONK]
const CLASS_NAMES: Dictionary = {
    CLASS_SWORD_WARDEN: "Kiếm Vệ",
    CLASS_ROOT_GUARDIAN: "Hộ Vệ Rễ Cây",
    CLASS_SPELLBLADE: "Pháp Kiếm Hư Vô",
    CLASS_ASHEN_MONK: "Tu Sĩ Tro Tàn",
}

const STAT_STR: StringName = &"str"
const STAT_INT: StringName = &"int"
const STAT_VIT: StringName = &"vit"
const STAT_DEX: StringName = &"dex"
const STAT_MND: StringName = &"mnd"
const STATS: Array[StringName] = [STAT_STR, STAT_INT, STAT_VIT, STAT_DEX, STAT_MND]
const CURRENCY_GOLD: StringName = &"gold"
const QUEST_STATE_ACTIVE: StringName = &"active"

const EVENT_STATION_INTERACTED: StringName = &"hub_station_interacted"
const EVENT_RESTED: StringName = &"hub_rested"
const EVENT_SAVE_REQUESTED: StringName = &"hub_save_requested"
const EVENT_CLASS_CHANGED: StringName = &"hub_class_changed"
const EVENT_STAT_ALLOCATED: StringName = &"hub_stat_allocated"
const EVENT_ITEM_ENHANCED: StringName = &"hub_item_enhanced"
const EVENT_RUNE_SOCKETED: StringName = &"hub_rune_socketed"
const EVENT_ITEM_PURCHASED: StringName = &"hub_item_purchased"
const EVENT_QUEST_ACCEPTED: StringName = &"hub_quest_accepted"
