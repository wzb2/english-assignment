extends InteractArea

class_name ContainerArea

@export var inventory: Inventory

@export var action_name: String = "open"

func _ready() -> void:
	super._ready()
	interact_behavior.name = action_name

func on_interact(caller: Player) -> void:
	caller.open_container_inventory = inventory
	caller.call_open_client_inventory_ui_rpc()
