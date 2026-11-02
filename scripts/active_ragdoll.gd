extends Node3D

class_name ActiveRagdoll


@export var animated_skeleton: Skeleton3D
@export var physics_skeleton: Skeleton3D
@export var physics_skeleton_simulator: PhysicalBoneSimulator3D

@export var default_angular_spring_stiffness: float = 5000
@export var angular_spring_damping: float = 220
@export var max_angular_force: float = 10000

## sine of min normal angle from ground
@export var on_ground_normal_y_threshold: float = 0.7

@export var root_bone: PhysicalBone3D

@export var movement_bones: Array[ActiveRagdollBone] = []
@export var feet_shapecasts: Array[ShapeCast3D] = []

@onready var physics_bones: Array[Node] = physics_skeleton_simulator.get_children().filter(func(c: Node) -> bool: return c is ActiveRagdollBone)
@onready var animated_targets: Array[Node] = animated_skeleton.get_children().filter(func(c: Node) -> bool: return c is BoneTarget)
@onready var physical_targets: Array[Node] = physics_skeleton.get_children().filter(func(c: Node) -> bool: return c is BoneTarget)

@export_category("Multiplayer Synchronized Stuff")
@export var packed_bone_positions: PackedVector3Array
@export var packed_bone_rotations: PackedVector3Array

var pose_interpolator: ArrayMultiplayerPoseInterpolator = ArrayMultiplayerPoseInterpolator.new()

var bones_to_ignore: Array[PhysicalBone3D] = []

var current_angular_spring_stiffness: float = default_angular_spring_stiffness


func _ready() -> void:
	physics_bones.sort_custom(func(b1: PhysicalBone3D, b2: PhysicalBone3D) -> bool: return b1.get_bone_id() < b2.get_bone_id())
	animated_targets.sort_custom(func(t1: BoneTarget, t2: BoneTarget) -> bool: return t1.bone_idx < t2.bone_idx)
	physical_targets.sort_custom(func(t1: BoneTarget, t2: BoneTarget) -> bool: return t1.bone_idx < t2.bone_idx)
	
	physics_skeleton_simulator.physical_bones_start_simulation()
	
	#if multiplayer.is_server():
		#physics_skeleton.skeleton_updated.connect(_on_physics_skeleton_3d_skeleton_updated)
	#else:
	if not multiplayer.is_server():
		for b: PhysicalBone3D in physics_bones:
			b.custom_integrator = true
	

func get_total_mass() -> float:
	var mass: float = 0
	for b: PhysicalBone3D in physics_bones:
		mass += b.mass
	return mass


func add_movement_bone_velocity(velocity: Vector3) -> void:
	for b: PhysicalBone3D in movement_bones:
		b.linear_velocity += velocity
	var feet_on_floor: Array[ShapeCast3D] = feet_shapecasts.filter(func(f: ShapeCast3D) -> bool: return shapecast_is_on_floor(f))
	for i: ShapeCast3D in feet_on_floor:
		var collider: Object = i.get_collider(0)
		if collider is RigidBody3D:
			collider.linear_velocity -= velocity / collider.mass

func multiply_movement_bone_velocity(velocity: Vector3) -> void:
	for b in movement_bones:
		b.linear_velocity *= velocity

func is_own_bone(node: Node3D) -> bool:
	if node:
		return node.get_parent().get_parent() == physics_skeleton
	return false


## collider check func gets collider passed in, should return true if collider is not floor/valid
func is_on_floor(collider_check_func: Callable = Callable()) -> bool:
	for i in feet_shapecasts:
		var foot_on_floor: bool = shapecast_is_on_floor(i, collider_check_func)
		if foot_on_floor:
			return true
	return false

## collider check func gets collider passed in, should return true if collider is not floor/valid
func shapecast_is_on_floor(shapecast: ShapeCast3D, collider_check_func: Callable = Callable()) -> bool:
	if shapecast.is_colliding():
		for i in shapecast.get_collision_count():
			if (shapecast.get_collision_normal(i).y > on_ground_normal_y_threshold and 
			collider_check_func.call(shapecast.get_collider(i)) if collider_check_func.is_valid() else true and
			not is_own_bone(shapecast.get_collider(i))):
				return true
	return false


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		pose_interpolator.update(physics_bones, packed_bone_positions, packed_bone_rotations, delta)
		


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		spring_bones(delta)
		
		# Pack bone poses
		packed_bone_positions.clear()
		packed_bone_rotations.clear()
		for b: PhysicalBone3D in physics_bones:
			packed_bone_positions.append(b.global_position)
			packed_bone_rotations.append(b.global_rotation)
	

func do_hip_relative_ragdoll() -> bool:
	return false


#func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	#return (stiffness * displacement) - (damping * current_velocity)

func bone_is_ignored(bone: PhysicalBone3D) -> bool:
	return bones_to_ignore.has(bone)

func spring_bones(delta: float) -> void:
	var root_animated_target: BoneTarget = animated_targets[0]
	var root_physical_target: BoneTarget = physical_targets[0]
	for b: int in physics_bones.size():
		var physics_bone: ActiveRagdollBone = physics_bones[b]
		var animated_target: BoneTarget = animated_targets[b]
		var physical_target: BoneTarget = physical_targets[b]
		
		if bone_is_ignored(physics_bone):
			continue
		
		#if b > 0:
		var target_angle: Quaternion = animated_target.global_basis.get_rotation_quaternion()
		var current_angle: Quaternion = physical_target.global_basis.get_rotation_quaternion()
		
		var error: Quaternion
		
		if do_hip_relative_ragdoll():
			animated_skeleton.global_rotation.y = root_bone.global_rotation.y
			var target_hip_angle: Quaternion = root_animated_target.global_basis.get_rotation_quaternion()
			var current_hip_angle: Quaternion = root_physical_target.global_basis.get_rotation_quaternion()
			
			var target_relative_angle: Quaternion = target_hip_angle.inverse() * target_angle
			var current_relative_angle: Quaternion = current_hip_angle.inverse() * current_angle
			
			error = current_relative_angle.inverse() * target_relative_angle
		else:
			error = current_angle.inverse() * target_angle
		
		
		var error_angle: float = error.get_angle()
		#if error_angle > deg_to_rad(1):
		var local_error: Vector3 = error.get_axis().normalized() * (error_angle if error_angle < PI else error_angle - TAU)
		var global_error: Vector3 = physical_target.global_basis * local_error
		
		var torque: Vector3 = AngularSpring.hookes_law(
			global_error,
			physics_bone.angular_velocity,
			current_angular_spring_stiffness * physics_bone.stiffness_multiplier,
			angular_spring_damping * physics_bone.damping_multiplier
		)
		
		torque = torque.limit_length(max_angular_force)
		physics_bone.angular_velocity += torque * delta
		#physics_bone.parent_bone.angular_velocity -= torque * delta * physics_bone.mass / physics_bone.parent_bone.mass
			
		#else:
			#var torque: Vector3 = hookes_law(
				#physics_bone.global_rotation,
				#physics_bone.angular_velocity,
				#current_angular_spring_stiffness * 4,
				#angular_spring_damping
			#)
			#
			#torque = torque.limit_length(max_angular_force)
			#
			#physics_bone.angular_velocity += torque * delta
			#physics_bones[4].linear_velocity += 2 * Vector3.UP
			#physics_bone.linear_velocity += Vector3.UP * 0.1

#func _on_physics_skeleton_3d_skeleton_updated() -> void:
	## springy the thingy
	#for b: PhysicalBone3D in physics_bones:
		#
		#if bone_is_ignored(b):
			#continue
		#
		#var target_transform: Transform3D = animated_skeleton.global_transform * animated_skeleton.get_bone_global_pose(b.get_bone_id())
		#
		#var current_transform: Transform3D = physics_skeleton.global_transform * physics_skeleton.get_bone_global_pose(b.get_bone_id())
		#
		#var rotation_difference: Basis = (target_transform.basis) * current_transform.basis.inverse()
		#
		#var torque: Vector3 = hookes_law(
			#rotation_difference.get_euler(),
			#b.angular_velocity,
			#current_angular_spring_stiffness,
			#angular_spring_damping
		#)
		#
		#torque = torque.limit_length(max_angular_force)
		#
		#b.angular_velocity += torque * _delta
		#
