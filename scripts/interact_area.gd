extends Area3D

class_name InteractArea

@onready var interact_behavior: InteractBehavior = InteractBehavior.new("interact", on_interact)

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)

func on_interact(_caller: Player) -> void:
	pass
