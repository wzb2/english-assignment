extends Node3D

class_name BombFX

@export var particles: Array[GPUParticles3D]
@export var light: OmniLight3D
@export var light_fade_time: float = 0.4

var particles_finished: int = 0

func _ready() -> void:
	if light:
		var tween: Tween = create_tween()
		tween.tween_property(light, "light_energy", 0, light_fade_time)
	
	for i: GPUParticles3D in particles:
		i.emitting = true
		i.finished.connect(func() -> void: particles_finished += 1)
	

func _process(_delta: float) -> void:
	if particles_finished == particles.size():
		if light and light.light_energy == 0:
			queue_free()
		
