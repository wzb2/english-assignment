extends CSGBox3D

class_name CeilingLight

@export var ghosty_distance: float = 10
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	if randf() > 0.75:
		light.hide()

func _physics_process(_delta: float) -> void:
	if randf() > 0.999:
		light.hide()
		var t: Tween = create_tween()
		t.tween_callback(light.show).set_delay(0.05)
	var player: Player = get_tree().current_scene.local_player
	if player:
		if player.camera.global_position.distance_to(global_position) > ghosty_distance:
			if -player.camera.global_basis.z.dot(player.camera.global_position.direction_to(global_position)) < 0:
				if randf() > 0.999:
					#print("switch")
					light.visible = not light.visible
					
		
