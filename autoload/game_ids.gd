extends Node

const MAP_1: StringName = &"map1_awakening_forest"
const MAP_2: StringName = &"map2_tutorial_road"
const MAP_3: StringName = &"map3_ashen_town_hub"
const SPAWN_DEFAULT: StringName = &"default"
const SPAWN_FROM_MAP_1: StringName = &"from_map1"
const SPAWN_FROM_MAP_2: StringName = &"from_map2"

const ACTION_ATTACK: StringName = &"attack"
const ACTION_COMBO_FINISHER: StringName = &"combo_finisher"
const ACTION_DODGE: StringName = &"dodge"
const ACTION_SKILL_1: StringName = &"skill_1"

const CLASS_BLADEMASTER: StringName = &"blademaster"
const CLASS_GUARDIAN: StringName = &"guardian"
const CLASS_SPELLBLADE: StringName = &"spellblade"
const CLASS_PRIEST: StringName = &"priest"
const PLAYABLE_CLASSES: Array[StringName] = [CLASS_BLADEMASTER, CLASS_GUARDIAN, CLASS_SPELLBLADE, CLASS_PRIEST]

const STAT_STR: StringName = &"str"
const STAT_INT: StringName = &"int"
const STAT_VIT: StringName = &"vit"
const STAT_DEX: StringName = &"dex"
const STAT_MND: StringName = &"mnd"
const ALLOCATABLE_STATS: Array[StringName] = [STAT_STR, STAT_INT, STAT_VIT, STAT_DEX, STAT_MND]

const DAMAGE_PHYSICAL: StringName = &"physical"
const DAMAGE_MAGIC: StringName = &"magic"
const DAMAGE_VOID: StringName = &"void"
const DAMAGE_HOLY: StringName = &"holy"

const CURRENCY_GOLD: StringName = &"gold"
const CURRENCY_SOUL_SHARD: StringName = &"soul_shard"
const CURRENCY_WORLD_FRAGMENT: StringName = &"world_fragment"

const ENEMY_MIST_SHADE: StringName = &"mist_shade"
const ENEMY_ROOT_WOLF: StringName = &"root_wolf"
const ENEMY_WEEPING_MUSHROOM: StringName = &"weeping_mushroom"
const ENEMY_ROOT_ANTLER_STAG: StringName = &"root_antler_stag"

const PANEL_CAMPFIRE: StringName = &"campfire"
const PANEL_FORGE: StringName = &"forge"
const PANEL_SHOP: StringName = &"shop"
const PANEL_QUEST_BOARD: StringName = &"quest_board"

const FLAG_WEAPON_UNLOCKED: StringName = &"weapon_unlocked"
const FLAG_MAP_1_COMPLETE: StringName = &"map_1_complete"
const FLAG_TUTORIAL_COMBO: StringName = &"tutorial_combo"
const FLAG_TUTORIAL_DODGE: StringName = &"tutorial_dodge"
const FLAG_TUTORIAL_SKILL: StringName = &"tutorial_skill"
const FLAG_MAP_2_COMPLETE: StringName = &"map_2_complete"
