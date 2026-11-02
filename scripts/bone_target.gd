#@tool
extends BoneAttachment3D

class_name BoneTarget

#@export_tool_button("Zero") var zero_action: Callable = zero
## unused
@export var parent_bone_target: BoneTarget
#
#@export var rotation_offset: Vector3 = Vector3.ZERO
#
#func zero() -> void:
	#rotation_offset = -rotation
