@tool
extends EditorPlugin

const EnhancedHingejoint3d := preload("uid://b8t5ci4mpuc6t")
const ICON := preload("res://addons/enhancedhingejoint3d/icon.svg")

func _enter_tree() -> void:
	add_custom_type("EnhancedHingeJoint3D", "HingeJoint3D", EnhancedHingejoint3d, ICON);

func _exit_tree() -> void:
	remove_custom_type("EnhancedHingeJoint3D");
