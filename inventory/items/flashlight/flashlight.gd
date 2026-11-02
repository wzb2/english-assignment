extends PhysicalItem

@onready var lights: Node3D = %Lights
@onready var inner_light: SpotLight3D = %Lights/Light
@onready var outer_light: SpotLight3D = %Lights/Light2
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

## percent per second
const BATERY_DECAY_RATE: float = 0.007

func _on_use() -> void:
	%Lights.visible = not %Lights.visible
	audio.play(0.1)

func _process(delta: float) -> void:
	super._process(delta)
	if lights.visible:
		var remaining_battery: float = max(item_resource.data.get("battery") - BATERY_DECAY_RATE * delta, 0)
		item_resource.data.set("battery", remaining_battery)
		
		inner_light.light_energy = remaining_battery ** 0.25
		outer_light.light_energy = remaining_battery ** 0.25


func update_hand_spring() -> void:
	if hand_grabbing:
		hand_spring.target_basis = Basis.looking_at(-last_grabbed_by_player.camera.global_basis.z)
	else:
		super.update_hand_spring()
