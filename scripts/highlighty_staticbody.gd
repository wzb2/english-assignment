extends StaticBody3D

class_name HighlightyStaticbody

@export var mesh_instances: Array[MeshInstance3D]
#@export var interact_area: Area3D

var highlight_material: BaseMaterial3D = preload("res://materials/highlight_material.tres")

func _ready() -> void:
	set_collision_layer_value(2, true)

func _process(_delta: float) -> void:
	var level: Level = get_tree().current_scene
	var local_player: Player = level.local_player
	if local_player:
		if local_player.interact_raycast.get_collider() == self:
			enable_outline()
		else:
			disable_outline()
	


func enable_outline() -> void:
	for i in mesh_instances:
		i.material_overlay = highlight_material
	
func disable_outline() -> void:
	for i in mesh_instances:
		i.material_overlay = null
