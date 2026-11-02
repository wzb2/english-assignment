@tool
extends Control

class_name Seperator

@export var do_constant_updates: bool = true

func _process(_delta: float) -> void:
	if do_constant_updates:
		update()

func update() -> void:
	var parent: Node = get_parent()
	if parent:
		var index: int = get_index()
		var before_index: int = index - 1
		
		var before_node_visible: bool = false
		var is_last_visible_node: bool = true
		
		var before_node: Node
		
		if before_index >= 0:
			before_node = parent.get_child(before_index)
			if before_node is Control:
				before_node_visible = before_node.visible
		
		for i: int in range(index + 1, parent.get_child_count()):
			var child: Node = parent.get_child(i)
			if child is Control:
				if child.visible:
					is_last_visible_node = false
					break
		
		visible = before_node_visible and not is_last_visible_node
		
