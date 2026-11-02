@tool
extends Node

class_name BoneTargetGenerator

@export_tool_button("Generate") var generate_action: Callable = generate

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()

func generate() -> void:
	var skeleton: Skeleton3D = get_parent()
	var bone_targets: Array[BoneTarget] = []
	for i: int in skeleton.get_bone_count():
		var bone_target: BoneTarget = BoneTarget.new()
		bone_targets.append(bone_target)
		add_sibling(bone_target)
		bone_target.owner = get_tree().edited_scene_root
		bone_target.bone_idx = i
		bone_target.bone_name = skeleton.get_bone_name(i)
		bone_target.name = skeleton.get_bone_name(i) + " Target"
	
	for b: BoneTarget in bone_targets:
		if b.bone_idx != 0:
			b.parent_bone_target = bone_targets[skeleton.get_bone_parent(b.bone_idx)]
	
	print("Generated bone targets")
	EditorInterface.mark_scene_as_unsaved()


func _get_configuration_warnings() -> PackedStringArray:
	if not (get_parent() is Skeleton3D):
		return ["Should be parented to Skeleton3D. "]
	return []

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()
		
