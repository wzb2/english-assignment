extends Area3D

class_name Bomb

const RAY_MULTIPLIER: float = 1.1

@export var one_shot: bool = true
#@export var explode_on_ready: bool = true

@export var force: float = 12
@export var attenuation: float = 0.15

@export var ray_count: int = 8
@export var ray_spread_degrees: float = 15

@export var ignore: Array[PhysicsBody3D]

@export var fx_scene: PackedScene

#func _ready() -> void:
	#if explode_on_ready:
		#await get_tree().physics_frame
		#explode()

## must be called in physics process
func explode() -> void:
	spawn_fx.rpc()
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = global_position
	params.collision_mask = 1
	
	for i: PhysicsBody3D in ignore:
		params.exclude.append(i.get_rid())
	
	for b: Node3D in get_overlapping_bodies():
		if b is RigidBody3D or b is PhysicalBone3D:
			for i: int in ray_count:
				var vector_to_body: Vector3 = (b.global_position - global_position) * RAY_MULTIPLIER
				var orthagonal_vector: Vector3 = vector_to_body.cross(Vector3.UP).normalized()
				if orthagonal_vector and vector_to_body != Vector3.ZERO:
					var ray_vector: Vector3 = vector_to_body.rotated(orthagonal_vector.rotated(vector_to_body.normalized(), TAU * randf()), deg_to_rad(ray_spread_degrees) * randf())
					params.to = global_position + ray_vector
					
					var hit_dictionary: Dictionary = space_state.intersect_ray(params)
					if hit_dictionary.get("collider") == b:
						b.apply_impulse((ray_vector.normalized() * force / ray_count) / (ray_vector.length() * attenuation), params.to - b.global_position)
					
	if one_shot:
		queue_free()


@rpc("call_local")
func spawn_fx() -> void:
	var fx: BombFX = fx_scene.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = global_position
