extends HighlightyStaticbody

class_name StaticMenuOpener

@export var menu: GameMenu

@export var action_name: String = "open"

@onready var interact_behavior: InteractBehavior = InteractBehavior.new(action_name, on_interact)

@rpc("call_local")
func open_menu() -> void:
	menu.open()


func on_interact(caller: Player) -> void:
	if multiplayer.get_peers().has(caller.id) or caller.id == 1:
		open_menu.rpc_id(caller.id)
