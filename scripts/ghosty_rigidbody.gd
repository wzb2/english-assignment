extends MultiplayerRigidBody

class_name GhostyRigidbody

@export var exists: bool = true
@export var ghosty_distance: float = 10

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var player: Player = get_tree().current_scene.local_player
	if player:
		if player.camera.global_position.distance_to(global_position) > ghosty_distance:
			if -player.camera.global_basis.z.dot(player.camera.global_position.direction_to(global_position)) < 0:
				if randf() > 0.999:
					switch()
		

func switch() -> void:
	#print("switch")
	if exists:
		exists = false
		hide()
		freeze = true
		for c: Node in get_children():
			if c is CollisionShape3D:
				c.disabled = true
	else:
		exists = true
		show()
		freeze = false
		for c: Node in get_children():
			if c is CollisionShape3D:
				c.disabled = false
		
