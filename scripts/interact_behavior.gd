extends RefCounted

class_name InteractBehavior

var name: String
var action: Callable

func _init(action_name: String, on_interact_action: Callable) -> void:
	assert(on_interact_action.is_valid(), "Interact action must be valid. ")
	assert(on_interact_action.get_argument_count() == 1, "Interact action must have player passed in. ")
	name = action_name
	action = on_interact_action

func on_interact(player: Player) -> void:
	action.call(player)
