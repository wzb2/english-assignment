extends RefCounted

class_name PDController

var kp: float
var kd: float
var is_rotation: bool = false

func _init(p: float, d: float, treat_as_rotation: bool = false) -> void:
	kp = p
	kd = d
	is_rotation = treat_as_rotation

func update_with_velocity(current: Vector3, setpoint: Vector3, velocity: Vector3) -> Vector3:
	var error: Vector3 = setpoint - current
	
	if is_rotation:
		error.x = fposmod(setpoint.x - current.x + PI, TAU) - PI
		error.y = fposmod(setpoint.y - current.y + PI, TAU) - PI
		error.z = fposmod(setpoint.z - current.z + PI, TAU) - PI
		
	return kp * error - kd * velocity
