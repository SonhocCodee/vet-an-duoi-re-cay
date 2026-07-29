class_name ShopStation
extends HubStation

const ITEM_PATHS: Array[String] = [
    "res://resources/items/hub/hp_potion.tres",
    "res://resources/items/hub/stamina_potion.tres",
    "res://resources/items/hub/elemental_dust.tres",
    "res://resources/items/hub/root_drill.tres",
]

func _ready() -> void:
    station_id = &"shop"
    prompt_text = "Giao dịch với Dược Sĩ"
    super._ready()

func get_inventory() -> Array[HubShopItemData]:
    var inventory: Array[HubShopItemData] = []
    for path: String in ITEM_PATHS:
        var item: HubShopItemData = load(path) as HubShopItemData
        if item != null:
            inventory.append(item)
    return inventory

func buy_item(item_id: StringName) -> Dictionary:
    var item: HubShopItemData = _find_item(item_id)
    if item == null:
        return {"ok": false, "message": "Vật phẩm không tồn tại."}
    var result: Variant = HubServices.call_game_state(
        [&"purchase_item", &"buy_item"],
        [item.id, item.price, 1]
    )
    if result == false or (result is Dictionary and not bool((result as Dictionary).get("ok", true))):
        return {"ok": false, "message": "Không đủ vàng hoặc túi đã đầy."}
    HubServices.emit_event(HubConstants.EVENT_ITEM_PURCHASED, {
        "item_id": item.id,
        "price": item.price,
        "quantity": 1,
    })
    return {"ok": true, "message": "Đã mua %s." % item.display_name}

func _find_item(item_id: StringName) -> HubShopItemData:
    for item: HubShopItemData in get_inventory():
        if item.id == item_id:
            return item
    return null
