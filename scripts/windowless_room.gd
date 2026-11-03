extends Node3D

const STUFF_1: PackedScene = preload("uid://b6pod5sik8736")
const STUFF_2: PackedScene = preload("uid://c2yqe8yxuh6xg")
const STUFF_3: PackedScene = preload("uid://dky34hwl0erar")
const STUFF_4: PackedScene = preload("uid://2micxqdsxsaq")
const STUFF_5: PackedScene = preload("uid://dvsg4gcqvu718")
const STUFF_6: PackedScene = preload("uid://yiq1mfkw8rya")

@export var enabled: bool  = true

@onready var room_layouts: Array[PackedScene] = [STUFF_1, STUFF_2, STUFF_3, STUFF_4, STUFF_5, STUFF_6]

func _ready() -> void:
	if enabled:
		if randf() > 0.4:
			var layout: Node3D = room_layouts[randi_range(0, room_layouts.size() - 1)].instantiate()
			layout.global_transform = global_transform
			get_tree().current_scene.add_child(layout)
