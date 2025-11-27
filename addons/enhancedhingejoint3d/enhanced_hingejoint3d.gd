@tool
class_name EnhancedHingeJoint3D extends HingeJoint3D

static var _fixed_to_world: Object = RigidBody3D.new()

static func is_jolt_physics() -> bool:
	return ProjectSettings.get_setting("physics/3d/physics_engine").to_lower().begins_with("jolt")

var _body_a: Node3D
var _body_b: Node3D
var _local_space_hinge_axis: Vector3
var _inv_initial_orientation: Quaternion

## Computes and returns the current angle of a hinge joint.
## The rebuild function must have been called once after the joint is setup for this to work.
var current_angle: float:
	get(): return _compute_current_angle()

## Rebuilds the internal state that is used to compute the current angle.
## Must be called once after a joint is configured with bodies, limits, etc.
## This code was hacked together from the Godot C++ source code.
func rebuild() -> void:
	var body_a: PhysicsBody3D = get_node_or_null(node_a)
	var body_b: PhysicsBody3D = get_node_or_null(node_b)

	var local_ref_a := body_a.global_transform.affine_inverse() if body_a else Transform3D.IDENTITY
	var local_ref_b := body_b.global_transform.affine_inverse() if body_b else Transform3D.IDENTITY
	local_ref_a = (local_ref_a * global_transform).orthonormalized()
	local_ref_b = (local_ref_b * global_transform).orthonormalized()

	if EnhancedHingeJoint3D.is_jolt_physics() && body_b == null:
		var tmp1 := body_a; body_a = body_b; body_b = tmp1
		var tmp2 := local_ref_a; local_ref_a = local_ref_b; local_ref_b = tmp2

	if body_a == null: body_a = _fixed_to_world
	if body_b == null: body_b = _fixed_to_world

	var ref_shift := 0.0
	var limits_enabled := get_flag(HingeJoint3D.FLAG_USE_LIMIT)
	if limits_enabled:
		var limit_lower := get_param(HingeJoint3D.PARAM_LIMIT_LOWER)
		var limit_upper := get_param(HingeJoint3D.PARAM_LIMIT_UPPER)
		if limit_lower <= limit_upper:
			ref_shift = -(limit_lower + limit_upper) / 2.0
	var angular_shift := Vector3(0.0, 0.0, ref_shift)

	var origin_a := local_ref_a.origin
	if _is_valid_body(body_a):
		origin_a = origin_a * body_a.scale - _get_center_of_mass(body_a)

	var origin_b := local_ref_b.origin
	if _is_valid_body(body_b):
		origin_b = origin_b * body_b.scale - _get_center_of_mass(body_b)

	var shifted_basis_a := local_ref_a.basis * Basis.from_euler(angular_shift, EulerOrder.EULER_ORDER_ZYX)
	var shifted_origin_a := origin_a - local_ref_a.basis * Vector3.ZERO
	var shifted_ref_a := Transform3D(shifted_basis_a, shifted_origin_a)
	var shifted_ref_b := Transform3D(local_ref_b.basis, origin_b)

	var hinge_axis_1 := shifted_ref_a.basis[Vector3.Axis.AXIS_Z]
	var normal_axis_1 := shifted_ref_a.basis[Vector3.Axis.AXIS_X]
	var hinge_axis_2 := shifted_ref_b.basis[Vector3.Axis.AXIS_Z]
	var normal_axis_2 := shifted_ref_b.basis[Vector3.Axis.AXIS_X]

	_body_a = body_a
	_body_b = body_b
	_local_space_hinge_axis = hinge_axis_1
	_inv_initial_orientation = Quaternion.IDENTITY

	if normal_axis_1.is_equal_approx(normal_axis_2) && hinge_axis_1.is_equal_approx(hinge_axis_2):
		return
	var constraint1 := Basis(normal_axis_1, hinge_axis_1.cross(normal_axis_1), hinge_axis_1)
	var constraint2 := Basis(normal_axis_2, hinge_axis_2.cross(normal_axis_2), hinge_axis_2)
	var c1roquatinv := constraint1.get_rotation_quaternion().inverse()
	_inv_initial_orientation = constraint2.get_rotation_quaternion() * c1roquatinv

func _compute_current_angle() -> float:
	if Engine.is_editor_hint():
		return 0.0
	var rotation1 := _get_rotation(_body_a)
	var rotation2 := _get_rotation(_body_b)
	var diff := rotation2 * _inv_initial_orientation * rotation1.inverse()
	if is_equal_approx(diff.w, 0.0):
		return PI
	var axis := rotation1 * _local_space_hinge_axis
	return 2.0 * atan(Vector3(diff.x, diff.y, diff.z).dot(axis) / diff.w)

func _get_rotation(body: Node3D) -> Quaternion:
	if _is_valid_body(body):
		return body.global_basis.get_rotation_quaternion()
	return Quaternion.IDENTITY

func _get_center_of_mass(body: PhysicsBody3D) -> Vector3:
	if _is_valid_body(body):
		return PhysicsServer3D.body_get_direct_state(body.get_rid()).center_of_mass
	return Vector3.ZERO

func _is_valid_body(body: Object) -> bool:
	return body != null && body != _fixed_to_world
