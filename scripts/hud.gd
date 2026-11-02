extends CanvasLayer

class_name Hud

@onready var red: ColorRect = $Red
@onready var action_progress_bar: TextureProgressBar = $ActionProgressBar
@onready var health_bar: ProgressBar = $HealthBar
@onready var hunger_bar: ProgressBar = $HungerBar

## Set in level local_player setter
var local_player: Player

const WEAK_RED_PERCENTAGE: float = 0.31
const SHOCK_RED_MULTIPLIER: float = 3
const MAX_RED: float = 0.5

func _process(_delta: float) -> void:
	update_bars()
	update_input_prompts()


func update_bars() -> void:
	if local_player:
		health_bar.value = health_bar.max_value * local_player.health_component.hp / local_player.health_component.max_hp
		hunger_bar.value = hunger_bar.max_value * local_player.hunger_component.food / local_player.hunger_component.max_food
		
		if local_player.display_use_button_held_percentage:
			action_progress_bar.value = local_player.display_use_button_held_percentage * action_progress_bar.max_value
		else:
			action_progress_bar.value = 0
		
		var shock_percentage: float = local_player.health_component.get_shock_percentage()
		
		if local_player.health_component.is_alive():
			red.color.a = shock_percentage * SHOCK_RED_MULTIPLIER + min(local_player.health_component.get_weakness_percentage() * WEAK_RED_PERCENTAGE, WEAK_RED_PERCENTAGE)
			red.color.a = min(red.color.a, MAX_RED)
		else:
			red.color.a = 0


@onready var drop_hand_item: RichTextLabel = $BottomInputPrompts/Right/DropHandItem
@onready var use_hand_item: RichTextLabel = $BottomInputPrompts/Right/UseHandItem
@onready var remove_backpack: RichTextLabel = $BottomInputPrompts/Right/RemoveBackpack
@onready var ghost: RichTextLabel = $BottomInputPrompts/Right/Ghost

@onready var interact: RichTextLabel = $InteractInputPrompts/Interact
@onready var equip_backpack: RichTextLabel = $InteractInputPrompts/EquipBackpack

func update_input_prompts() -> void:
	if local_player:
		var looked_at_object: Object = local_player.interact_raycast.get_collider()
		if local_player.backpack_equipped:
			equip_backpack.hide()
			remove_backpack.show()
		else:
			remove_backpack.hide()
			var behavior: InteractBehavior = looked_at_object.get("backpack_interact_behavior") if looked_at_object else null
			if behavior:
				equip_backpack.show()
				equip_backpack.text = get_key_name("backpack") + " to " + behavior.name
			else:
				equip_backpack.hide()
				
		var interact_behavior: InteractBehavior = looked_at_object.get("interact_behavior") if looked_at_object else null
		if interact_behavior:
			interact.show()
			if looked_at_object is ItemInteractArea:
				interact.text = "RMB/LMB + " + get_key_name("interact") + " to " + interact_behavior.name
			else:
				interact.text = get_key_name("interact") + " to " + interact_behavior.name
		else:
			interact.hide()
		
		if local_player.ghost.visible:
			ghost.show()
		else:
			ghost.hide()
		
		if (local_player.right_hand_has_item and local_player.right_grabbing) or (local_player.left_hand_has_item and local_player.left_grabbing):
			use_hand_item.show()
			interact.hide()
			equip_backpack.hide()
		else:
			use_hand_item.hide()
		
		if (local_player.right_hand_grabbing_thing and local_player.right_grabbing) or (local_player.left_hand_grabbing_thing and local_player.left_grabbing):
			drop_hand_item.show()
		else:
			drop_hand_item.hide()
		
	

func get_key_name(input_event: StringName) -> String:
	var interact_event: InputEvent = InputMap.action_get_events(input_event)[0]
	return OS.get_keycode_string(interact_event.physical_keycode) if interact_event is InputEventKey else interact_event.to_string()
	
