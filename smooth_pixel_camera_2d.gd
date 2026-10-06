class_name SmoothPixelCamera2D
extends Camera2D
## Follows `target` smoothly but sits on whole game pixels. Inside a `SmoothPixelView`, the
## leftover sub-pixel shifts the upscaled image so motion looks smooth. Without one it is a
## pixel-snapped smooth follow camera.

@export var target: Node2D
## How quickly the camera catches up with the target. Higher is snappier.
@export var follow_speed := 5.0
## How far the camera leans from the target toward the mouse.
@export_range(0.0, 1.0) var mouse_look := 0.0

var _true_position := Vector2.ZERO ## smooth, unrounded camera position


func _init() -> void:
	# Placed by hand every frame. Set before entering the tree, where Camera2D picks its mode.
	physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_OFF
	process_callback = CAMERA2D_PROCESS_IDLE
	position_smoothing_enabled = false


func _ready() -> void:
	_true_position = target.global_position if target else global_position
	global_position = _true_position.round()


func _process(delta: float) -> void:
	if not target:
		return
	var goal := target.global_position
	if mouse_look > 0.0:
		var from_centre := get_viewport().get_mouse_position() - get_viewport_rect().size / 2
		goal = goal.lerp(goal + from_centre, mouse_look)
	_true_position = _true_position.lerp(goal, 1.0 - exp(-follow_speed * delta))
	global_position = _true_position.round()
	var view := get_viewport().get_parent() as SmoothPixelView
	if view:
		view.subpixel_offset = global_position - _true_position
