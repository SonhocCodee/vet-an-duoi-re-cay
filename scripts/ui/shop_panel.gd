class_name ShopPanel
extends HubModalBase

func _ready() -> void:
    %Close.pressed.connect(close)

func refresh() -> void:
    for child: Node in %Items.get_children():
        child.queue_free()
    if station == null:
        return
    var inventory: Array[HubShopItemData] = station.call(&"get_inventory") as Array[HubShopItemData]
    for item: HubShopItemData in inventory:
        var button: Button = Button.new()
        button.text = "%s - %d vàng" % [item.display_name, item.price]
        button.tooltip_text = item.description
        button.pressed.connect(_buy.bind(item.id))
        %Items.add_child(button)

func _buy(item_id: StringName) -> void:
    var result: Dictionary = station.call(&"buy_item", item_id) as Dictionary
    %Status.text = str(result.get("message", ""))
