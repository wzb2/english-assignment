extends DamageableRigidBody

class_name Egg

@export var health_component: RigidBodyHealthComponent

func _ready() -> void:
	var level: Level = get_tree().current_scene
	level.egg = self
