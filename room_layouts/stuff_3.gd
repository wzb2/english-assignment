extends Node3D

@onready var table: GhostyRigidbody = $Table
@onready var table_3: GhostyRigidbody = $Table3
@onready var table_2: GhostyRigidbody = $Table2
@onready var table_4: GhostyRigidbody = $Table4
@onready var table_5: GhostyRigidbody = $Table5
@onready var table_6: GhostyRigidbody = $Table6
@onready var table_7: GhostyRigidbody = $Table7
@onready var table_8: GhostyRigidbody = $Table8
@onready var table_9: GhostyRigidbody = $Table9

func _ready() -> void:
	var tables: Array[GhostyRigidbody] = [table, table_2, table_3, table_4, table_5, table_6, table_7, table_8, table_9]
	tables[randi_range(0, tables.size() - 1)].switch()
