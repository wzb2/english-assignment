extends BaseHealthComponent

class_name RigidBodyHealthComponent

@export var damage_acceleration_threshold: float = 720#0.05
@export var pointy_thing_damage_force_threshold: float = 0.04
@export var slide_damage_velocity_threshold: float = 4.75
@export var acceleration_damage_multiplier: float = 0.007#100
@export var pointy_damage_multiplier: float = 10
@export var slide_damage_multiplier: float = 0.5

@onready var parent: DamageableRigidBody = get_parent()

#const ACCELERATION_MULTIPLIER: float = (1.0/120.0)**2

var prev_velocity: Vector3 = Vector3.ZERO


func _ready() -> void:
	super._ready()
	prev_velocity = parent.linear_velocity
	
	parent.hit.connect(do_pointy_thing_damage)


func do_pointy_thing_damage(force: float) -> void:
	if force > pointy_thing_damage_force_threshold:
		inflict_damage(force * pointy_damage_multiplier)


func _physics_process(delta: float) -> void:
	if MultiplayerManager.game_started:
		var acceleration: float = calculate_acceleration(delta)
		inflict_damage(calculate_acceleration_damage(acceleration))
		
		inflict_damage(calculate_slide_damage(delta))
		
		prev_velocity = parent.linear_velocity
	

func calculate_slide_damage(delta: float) -> float:
	if parent.linear_velocity.length() > slide_damage_velocity_threshold:
		var collision: KinematicCollision3D = parent.move_and_collide(parent.linear_velocity * delta, true)
		if collision:
			return parent.linear_velocity.length() * slide_damage_multiplier
	return 0


func calculate_acceleration(delta: float) -> float:
	var current_velocity: Vector3 = parent.linear_velocity
	
	return (current_velocity - prev_velocity).length() / delta


func calculate_acceleration_damage(acceleration: float) -> float:
	if acceleration > damage_acceleration_threshold:
		return (acceleration - damage_acceleration_threshold) * acceleration_damage_multiplier
	return 0
	
