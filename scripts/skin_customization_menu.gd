extends GameMenu


const BLANK_TEXTURE: CompressedTexture2D = preload("uid://suw04r3n4uka")

const BUTTON_MINIMUM_SIZE: Vector2 = Vector2(50, 50)
const WIDE_MINIMUM_SIZE: Vector2 = BUTTON_MINIMUM_SIZE * Vector2(2, 1)


var local_player: Player:
	get():
		return get_tree().current_scene.local_player


func _ready() -> void:
	close()
	
	generate_color_buttons()
	generate_hat_buttons()
	generate_decal_buttons(
		$Control/Panel/VBoxContainer/EyebrowSelection/Panel/ScrollContainer/EyebrowButtonContainer,
		SkinManager.EYEBROW_TEXTURES,
		func(i: int) -> void: local_player.skin_manager.eyebrow_index = i,
		false,
		WIDE_MINIMUM_SIZE
	)
	generate_decal_buttons(
		$Control/Panel/VBoxContainer/EyeSelection/Panel/ScrollContainer/EyeButtonContainer,
		SkinManager.EYE_TEXTURES,
		func(i: int) -> void: local_player.skin_manager.eyes_index = i
	)
	generate_decal_buttons(
		$Control/Panel/VBoxContainer/PupilSelection/Panel/ScrollContainer/PupilButtonContainer,
		SkinManager.PUPIL_TEXTURES,
		func(i: int) -> void: local_player.skin_manager.pupils_index = i
	)
	generate_decal_buttons(
		$Control/Panel/VBoxContainer/MouthSelection/Panel/ScrollContainer/MouthButtonContainer,
		SkinManager.MOUTH_TEXTURES,
		func(i: int) -> void: local_player.skin_manager.mouth_index = i,
		true
	)
	generate_decal_buttons(
		$Control/Panel/VBoxContainer/OtherStuffSelection/Panel/ScrollContainer/OtherStuffButtonContainer,
		SkinManager.OTHER_STUFF_TEXTURES,
		func(i: int) -> void: local_player.skin_manager.other_stuff_index = i,
		true,
		WIDE_MINIMUM_SIZE
	)
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		close()
	


func generate_color_buttons() -> void:
	var color_button_container: HBoxContainer = $Control/Panel/VBoxContainer/ColorSelection/Panel/ScrollContainer/ColorButtonContainer
	for i: int in len(SkinManager.SKIN_COLORS):
		var button: Button = Button.new()
		button.custom_minimum_size = BUTTON_MINIMUM_SIZE
		color_button_container.add_child(button)
		
	for i: int in len(SkinManager.SKIN_COLORS):
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.bg_color = SkinManager.SKIN_COLORS[i]
		var button: Button = color_button_container.get_child(i)
		button.add_theme_stylebox_override("normal", style_box)
		button.add_theme_stylebox_override("pressed", style_box)
		button.add_theme_stylebox_override("focus", style_box)
		button.add_theme_stylebox_override("hover", style_box)
		
		button.pressed.connect(func() -> void: local_player.skin_manager.skin_color_index = i)


func generate_hat_buttons() -> void:
	var hat_button_container: HBoxContainer = $Control/Panel/VBoxContainer/HatSelection/Panel/ScrollContainer/HatButtonContainer
	for i: int in len(SkinManager.HATS) + 1:
		hat_button_container.add_child(generate_texture_button())
		
	for i: int in hat_button_container.get_child_count():
		var button: TextureButton = hat_button_container.get_child(i)
		
		if i == 0:
			button.texture_normal = BLANK_TEXTURE
		else:
			button.texture_normal = SkinManager.HATS[i - 1].icon
		
		button.pressed.connect(func() -> void: local_player.skin_manager.hat_index = i - 1)


func generate_decal_buttons(container: HBoxContainer, texture_array: Array[CompressedTexture2D], on_pressed_func: Callable, empty_option: bool = false, size: Vector2 = BUTTON_MINIMUM_SIZE) -> void:
	for i: int in len(texture_array) + int(empty_option): # int(empty_option) is equal to (0 if not empty_option else 1):
		container.add_child(generate_texture_button(size))
		
	for i: int in container.get_child_count():
		var button: TextureButton = container.get_child(i)
		
		if empty_option:
			if i == 0:
				button.texture_normal = BLANK_TEXTURE
				button.custom_minimum_size = BUTTON_MINIMUM_SIZE
			else:
				button.texture_normal = texture_array[i - 1]
			
			button.pressed.connect(on_pressed_func.bind(i - 1))
		else:
			button.texture_normal = texture_array[i]
			
			button.pressed.connect(on_pressed_func.bind(i))


func generate_texture_button(size: Vector2 = BUTTON_MINIMUM_SIZE) -> TextureButton:
	var button: TextureButton = TextureButton.new()
	button.custom_minimum_size = size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	return button
	
