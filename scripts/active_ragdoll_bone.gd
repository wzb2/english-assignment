extends PhysicalBone3D

class_name ActiveRagdollBone

@export var stiffness_multiplier: float = 1
@export var damping_multiplier: float = 1

@onready var simulator: PhysicalBoneSimulator3D = get_parent()
## unused
var parent_bone: ActiveRagdollBone

func _ready() -> void:
	set_parent.call_deferred()

func set_parent() -> void:
	for b: Node in get_parent().get_children():
		if b is ActiveRagdollBone:
			if b.get_bone_id() == simulator.get_skeleton().get_bone_parent(get_bone_id()):
				parent_bone = b
