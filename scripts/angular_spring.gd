extends Node

class_name AngularSpring

@export var body_to_spring: RigidBody3D

@export var enabled: bool = false

@export var spring_stiffness: float = 1
@export var spring_damping: float = 0.1

@export var target_basis: Basis

static func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)


func _physics_process(_delta: float) -> void:
	if enabled:
		var current_basis: Basis = body_to_spring.global_basis
		
		var rotation_difference: Basis = target_basis * current_basis.inverse()
		
		var torque: Vector3 = hookes_law(
			rotation_difference.get_euler(),
			body_to_spring.angular_velocity,
			spring_stiffness,
			spring_damping
		)
		
		torque = torque
		
		body_to_spring.apply_torque(torque)
		#b.angular_velocity += torque * delta
