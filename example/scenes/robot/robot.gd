extends Node3D

@onready var base_to_world: EnhancedHingeJoint3D = $BaseToWorld
@onready var arm_to_base: EnhancedHingeJoint3D = $ArmToBase
@onready var wrist_to_arm: EnhancedHingeJoint3D = $WristToArm
@onready var claw_1_to_wrist: EnhancedHingeJoint3D = $Claw1ToWrist
@onready var claw_2_to_wrist: EnhancedHingeJoint3D = $Claw2ToWrist

var _joints: Array[EnhancedHingeJoint3D] = []
var _target_angles: PackedFloat32Array = []
var _last_angles: PackedFloat32Array = []
var _smoothed_vels: PackedFloat32Array = []

func _ready() -> void:
	_joints.assign(find_children("*", "EnhancedHingeJoint3D"))
	_target_angles.resize(_joints.size())
	_last_angles.resize(_joints.size())
	_smoothed_vels.resize(_joints.size())
	for it: EnhancedHingeJoint3D in _joints:
		_last_angles.append(it.current_angle)
		it.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
		it.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, 0.0)
		it.set_param(HingeJoint3D.PARAM_MOTOR_MAX_IMPULSE, 1.5)
		it.rebuild()

func _physics_process(delta: float) -> void:
	for i: int in _joints.size():
		_update_motor_velocity(i, delta)

func set_target_angle(index: int, radians: float) -> void:
	_target_angles[index] = radians

func _update_motor_velocity(index: int, delta: float) -> void:
	var joint := _joints[index]
	var target_angle := _target_angles[index]
	var _last_angle := _last_angles[index]
	var _smoothed_vel := _smoothed_vels[index]
	var angle := joint.current_angle
	_smoothed_vel = lerpf(_smoothed_vel, (angle - _last_angle) / delta, 0.2)
	_last_angle = angle
	var error := target_angle - angle
	var motor_vel := -clampf(20.0 * error - 1.5 * _smoothed_vel, -15.0, 15.0)
	joint.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, motor_vel)

	if EnhancedHingeJoint3D.is_jolt_physics():
		_check_joint_angle(joint, angle)

static var _disable_checks := false
static func _check_joint_angle(joint: HingeJoint3D, angle: float) -> void:
	if _disable_checks:
		return
	if joint.has_method("get_angle"):
		var native_angle := joint.call("get_angle") as float
		if absf(native_angle - angle) > 0.00001:
			push_error(joint, " - GDScript angle: ", angle, " != Native angle: ", native_angle)
	else:
		push_error("Native 'HingeJoint3D.get_angle()' method not found in this build of Godot.")
		_disable_checks = true
