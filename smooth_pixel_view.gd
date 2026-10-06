class_name SmoothPixelView
extends SubViewportContainer
## Shows a pixel-art SubViewport at a whole-number scale that fits the window, with a
## one-game-pixel margin on every side. A `SmoothPixelCamera2D` inside sets `subpixel_offset`
## to shift the upscaled image by the camera's leftover sub-pixel, so motion stays smooth
## while game pixels stay on the grid. Make the SubViewport its only child.

## Smallest area, in game pixels, that is always visible. Sets the scale.
@export var min_game_size := Vector2i(640, 360)

## Camera's rounded minus true position, in game pixels. Set by `SmoothPixelCamera2D`.
var subpixel_offset := Vector2.ZERO:
	set(value):
		subpixel_offset = value
		_place()

var _base_position := Vector2.ZERO


func _ready() -> void:
	stretch = true
	get_viewport().size_changed.connect(_fit)
	_fit()


func _fit() -> void:
	var area := Vector2i(get_viewport().get_visible_rect().size)
	@warning_ignore_start("integer_division")
	var shrink := maxi(1, mini(area.x / min_game_size.x, area.y / min_game_size.y))
	# Cover the area plus a game pixel each side, rounded up to even so the camera
	# centre lands on a whole pixel.
	var game := (area + Vector2i.ONE * (shrink - 1)) / shrink + Vector2i(2, 2)
	@warning_ignore_restore("integer_division")
	game += game % 2
	stretch_shrink = shrink
	size = game * shrink
	_base_position = ((Vector2(area) - size) / 2).floor()
	_place()


func _place() -> void:
	position = _base_position + subpixel_offset * stretch_shrink
