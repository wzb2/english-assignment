extends RefCounted

class_name CirclePointRandomizer

var radius: float = 0

func _init(r: float) -> void:
	radius = r

func get_random_point() -> Vector2:
	var r: float = randf() * radius
	return Vector2(r, 0).rotated(randf() * TAU)
