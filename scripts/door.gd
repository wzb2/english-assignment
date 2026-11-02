extends RigidBody3D

class_name Door

const START_ANGLE_RANGE: float = 95

func _ready() -> void:
	if randf() > 0.6:
		rotation_degrees.y += randf() * START_ANGLE_RANGE
