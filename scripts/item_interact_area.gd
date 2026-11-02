extends InteractArea

class_name ItemInteractArea

@export var item: PhysicalItem

@export var action_name: String = "pick up"

func _ready() -> void:
	super._ready()
	interact_behavior.name = action_name


func get_item() -> PhysicalItem:
	if item:
		return item
	else:
		assert(get_parent() is PhysicalItem, "Item interact area must have item assigned or a PhysicalItem as parent. ")
		return get_parent()

func on_interact(caller: Player) -> void:
	caller.pickup_items_to_hand(get_item())
