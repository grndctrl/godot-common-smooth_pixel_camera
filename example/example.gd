extends Node2D
## Example world: arrow keys move the player slowly, so the smooth sub-pixel camera
## motion is easy to see. Draws a checkerboard to show the pixels stay on the grid.


@export var speed := 80.0 ## game pixels per second

@onready var _player: Node2D = $Player


func _physics_process(delta: float) -> void:
	_player.position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed * delta


func _draw() -> void:
	for y in range(-32, 32):
		for x in range(-32, 32):
			var light := posmod(x + y, 2) == 0
			draw_rect(Rect2(x * 16, y * 16, 16, 16), Color("5a6988") if light else Color("3a4466"))
