extends Node

class_name BaseHealthComponent

@export var max_hp: float = 100

@export var hp: float = max_hp

@export var max_damage: float = 100

func _ready() -> void:
	hp = max_hp


func is_alive() -> bool:
	return hp > 0


func inflict_damage(amount: float) -> void:
	if MultiplayerManager.game_started:
		hp -= min(amount, max_damage)

func heal(amount: float) -> void:
	hp += amount
	if hp > max_hp:
		hp = max_hp
