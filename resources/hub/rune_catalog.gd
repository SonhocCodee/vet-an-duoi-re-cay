class_name HubRuneCatalog
extends RefCounted

const RUNE_PATHS: Array[String] = [
    "res://resources/hub/runes/holy_radiance.tres",
    "res://resources/hub/runes/reflective_mirror.tres",
    "res://resources/hub/runes/purification.tres",
    "res://resources/hub/runes/soul_drainer.tres",
    "res://resources/hub/runes/shadow_step.tres",
    "res://resources/hub/runes/blood_moon.tres",
    "res://resources/hub/runes/ignition.tres",
    "res://resources/hub/runes/frost.tres",
    "res://resources/hub/runes/fortitude.tres",
    "res://resources/hub/runes/vengeance.tres",
]

static func all() -> Array[HubRuneData]:
    var runes: Array[HubRuneData] = []
    for path: String in RUNE_PATHS:
        var rune: HubRuneData = load(path) as HubRuneData
        if rune != null:
            runes.append(rune)
    return runes

static func find_by_id(rune_id: StringName) -> HubRuneData:
    for rune: HubRuneData in all():
        if rune.id == rune_id:
            return rune
    return null
