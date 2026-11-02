extends Node

class_name SkinManager

const MOUTH_TEXTURES: Array[CompressedTexture2D] = [
	preload("uid://cr6xk1nc4qvv4"), 
	preload("uid://cntnd62c1pe5r"), 
	preload("uid://fpt0bvhgbtw8"), 
	preload("uid://bli5c53oj3cm4"), 
	preload("uid://bm3m7clp7qkdd"), 
	preload("uid://hnembfp7gk1b"), 
	preload("uid://c1s2qsxmw1skn"), 
	preload("uid://bel4e54exeu8m")
]
const EYEBROW_TEXTURES: Array[CompressedTexture2D] = [
	preload("uid://bylwuens7waqc"), 
	preload("uid://8iunqajn7jef"), 
	preload("uid://bdqtexn56fm0k"), 
	preload("uid://ufw2k3ep8l4g"), 
	preload("uid://cbbujp685excp")
]
const OTHER_STUFF_TEXTURES: Array[CompressedTexture2D] = [
	preload("uid://dkfnyhwaxmsan"), 
	preload("uid://lu7s4y0ey7ju")
]
const EYE_TEXTURES: Array[CompressedTexture2D] = [
	preload("uid://d0c7jxu81plgj"), 
	preload("uid://dsvrpbekquyh")
]
const PUPIL_TEXTURES: Array[CompressedTexture2D] = [
	preload("uid://dkn6p7wxt6kgf"), 
	preload("uid://dea8gff0i1j3r"), 
	preload("uid://r6sdp3umsq2w")
]

const HATS: Array[Hat] = [
	preload("uid://c845fsqkum2nw"), 
	preload("uid://vq6jg6ws0q8j")
]


static var SKIN_COLORS: PackedColorArray = [
	Color.from_hsv(0, 0.9, 1),
	Color.from_hsv(0.06, 0.9, 1),
	Color.from_hsv(0.12, 0.8, 1),
	Color.from_hsv(0.3, 0.7, 1),
	Color.from_hsv(0.5, 0.5, 1),
	Color.from_hsv(0.6, 0.9, 1),
	Color.from_hsv(0.7, 0.6, 1),
	Color.from_hsv(0.85, 0.9, 1),
	Color.from_hsv(0.63, 1, 0.8)
]


@export var mouth_decal: Decal
@export var eyebrow_decal: Decal
@export var other_stuff_decal: Decal
@export var right_eye_decal: Decal
@export var left_eye_decal: Decal
@export var left_pupil_decal: Decal
@export var right_pupil_decal: Decal

@export var hat_node: Node3D

@onready var player: Player = get_parent()

var skin_material: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	await player.ready
	if int(player.name) == multiplayer.get_unique_id():
		skin_color_index = 8
		mouth_index = 4
		eyebrow_index = 4
		other_stuff_index = -1
		eyes_index = 0
		pupils_index = 0
		hat_index = -1
		


@export var skin_color_index: int:
	set(index):
		if player:
			skin_color_index = index
			skin_material.albedo_color = SKIN_COLORS[index]
			for m: MeshInstance3D in player.meshes:
				if m.material_override != skin_material:
					m.material_override = skin_material


@export var mouth_index: int:
	set(index):
		if player:
			mouth_index = index
			if index == -1:
				mouth_decal.hide()
			else:
				mouth_decal.show()
				mouth_decal.texture_albedo = MOUTH_TEXTURES[index]

@export var eyebrow_index: int:
	set(index):
		if player:
			eyebrow_index = index
			if index == -1:
				eyebrow_decal.hide()
			else:
				eyebrow_decal.show()
				eyebrow_decal.texture_albedo = EYEBROW_TEXTURES[index]

@export var other_stuff_index: int:
	set(index):
		if player:
			other_stuff_index = index
			if index == -1:
				other_stuff_decal.hide()
			else:
				other_stuff_decal.show()
				other_stuff_decal.texture_albedo = OTHER_STUFF_TEXTURES[index]

@export var eyes_index: int:
	set(index):
		if player:
			eyes_index = index
			if index == -1:
				left_eye_decal.show()
				right_eye_decal.show()
			else:
				left_eye_decal.show()
				right_eye_decal.show()
				left_eye_decal.texture_albedo = EYE_TEXTURES[index]
				right_eye_decal.texture_albedo = EYE_TEXTURES[index]

@export var pupils_index: int:
	set(index):
		if player:
			pupils_index = index
			if index == -1:
				left_pupil_decal.show()
				right_pupil_decal.show()
			else:
				left_pupil_decal.show()
				right_eye_decal.show()
				left_pupil_decal.texture_albedo = PUPIL_TEXTURES[index]
				right_pupil_decal.texture_albedo = PUPIL_TEXTURES[index]

@export var hat_index: int:
	set(index):
		if player:
			hat_index = index
			for c: Node in hat_node.get_children():
				c.queue_free()
				
			if not index == -1:
				hat_node.add_child(HATS[index].scene.instantiate())
