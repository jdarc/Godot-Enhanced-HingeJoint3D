extends Node3D

@onready var robot: Node3D = $Robot

func _on_ui_slider_changed(index: int, value: float) -> void:
	robot.set_target_angle(index, deg_to_rad(value))
