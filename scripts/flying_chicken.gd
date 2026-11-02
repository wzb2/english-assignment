extends DamageableRigidBody

class_name FlyingChicken

const BOMB: PackedScene = preload("uid://bdjcnjewp64a4")

@onready var health_component: RigidBodyHealthComponent = $RigidBodyHealthComponent
@onready var targeting_component: TargetingComponent = $TargetingComponent

@onready var bomb: Bomb = $Bomb

@export var min_wander_time: float = 5
@export var max_wander_time: float = 15

@export var wander_radius: float = 15

@onready var wander_center: Vector3 = global_position
@onready var circle_point_randomizer: CirclePointRandomizer = CirclePointRandomizer.new(wander_radius)
var position_pd: PDController = PDController.new(0.2, 0.5)
var rotation_pd: PDController = PDController.new(7.0, 8.0, true)

enum State {IDLE, CHASING}
var current_state: State = State.IDLE
var time_to_wander: float = 0
var wander_time: float = 0
var wander_pos: Vector3 = Vector3.ZERO


const NOTICE_TIME: float = 0.5
const GIVE_UP_TIME: float = 0.5
const EXPLODE_DIST: float = 2

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if multiplayer.is_server():
		if not health_component.is_alive():
			explode()
		
		match current_state:
			State.IDLE:
				if wander_time >= time_to_wander:
					wander_time = 0
					time_to_wander = min_wander_time + (max_wander_time - min_wander_time) * randf()
					var xz: Vector2 = circle_point_randomizer.get_random_point()
					wander_pos = Vector3(xz.x, 0, xz.y) + wander_center
				else:
					wander_time += delta
					linear_velocity += position_pd.update_with_velocity(global_position, wander_pos, linear_velocity) * delta
					angular_velocity += rotation_pd.update_with_velocity(global_rotation, Basis.looking_at(-global_position.direction_to(wander_pos)).get_euler(), angular_velocity) * delta
				
				if targeting_component.current_target and targeting_component.target_visible:
					if targeting_component.target_visible_time >= NOTICE_TIME:
						current_state = State.CHASING
				else:
					targeting_component.select_target()
				
			State.CHASING:
				linear_velocity += position_pd.update_with_velocity(global_position, targeting_component.current_target_last_seen_pos, linear_velocity) * delta
				angular_velocity += rotation_pd.update_with_velocity(global_rotation, Basis.looking_at(-global_position.direction_to(targeting_component.current_target_last_seen_pos)).get_euler(), angular_velocity) * delta
				
				if global_position.distance_to(targeting_component.current_target_last_seen_pos) < EXPLODE_DIST:
					explode()
				
				if not (targeting_component.target_visible and targeting_component.is_target_alive()):
					if targeting_component.target_invisible_time > GIVE_UP_TIME:
						current_state = State.IDLE


func explode() -> void:
	bomb.explode()
	queue_free()
