extends WorldEnvironment

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_page_up"):
		environment.adjustment_brightness += 0.05
	elif Input.is_action_just_pressed("ui_page_down"):
		environment.adjustment_brightness -= 0.05
	
