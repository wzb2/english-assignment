extends Area3D

class_name EggDetector9000

const HAD_EGG_TIME_THRESHOLD: float = 2

@onready var level: Level = get_tree().current_scene

var has_egg: bool = false
var had_egg_time: float = 0

func _ready() -> void:
	if multiplayer.is_server():
		# ASSUMES THERE MAY ONLY BE ONE EGG
		body_entered.connect(func(body: Node3D) -> void:
			if body == level.egg and level.egg.health_component.is_alive():
				has_egg = true
		)
		body_exited.connect(func(body: Node3D) -> void:
			if body == level.egg:
				has_egg = false
		)
	else:
		queue_free()

func _process(delta: float) -> void:
	if has_egg:
		had_egg_time += delta
	else:
		had_egg_time = 0
	
	if had_egg_time >= HAD_EGG_TIME_THRESHOLD:
		if not level.end_screen.game_ended:
			level.end_screen.end_game(true)
	
