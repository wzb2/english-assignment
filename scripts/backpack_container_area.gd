extends ContainerArea

class_name BackpackContainerArea

@export var backpack: Backpack

var backpack_interact_behavior: InteractBehavior = InteractBehavior.new("equip", on_equip)

func on_equip(caller: Player) -> void:
	if not backpack.is_equipped:
		backpack.global_transform = caller.backpack_position_marker.global_transform
		caller.backpack_joint.node_a = caller.backpack_joint.get_parent_node_3d().get_path()
		caller.backpack_joint.node_b = backpack.get_path()
		backpack.is_equipped = true
