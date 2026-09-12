class_name HealthBar
extends Control

## The three-heart life meter in the HUD.
##
## The hearts are drawn rather than textured: the UI folder has no heart art,
## and a drawn one stays crisp at any HUD scale instead of blurring the way a
## 16 px sprite would.

const HEART_SIZE := 26.0
const HEART_GAP := 6.0

const FULL := Color(0.94, 0.24, 0.33)
const FULL_SHINE := Color(1.0, 0.55, 0.60)
const EMPTY := Color(0.20, 0.16, 0.20, 0.75)
const OUTLINE := Color(0.043, 0.054, 0.078)

var _maximum := 3
var _current := 3


func _ready() -> void:
	_resize()


## Called by the stage whenever the player's health changes.
func set_health(current: int, maximum: int) -> void:
	_current = current
	_maximum = maximum
	_resize()
	queue_redraw()


func _resize() -> void:
	custom_minimum_size = Vector2(
		_maximum * HEART_SIZE + maxf(_maximum - 1, 0) * HEART_GAP,
		HEART_SIZE
	)


func _draw() -> void:
	for i in _maximum:
		var origin := Vector2(i * (HEART_SIZE + HEART_GAP), 0.0)
		var filled := i < _current
		# The outline is the same heart drawn slightly larger underneath, which
		# keeps the hearts readable against both sky and stone.
		_draw_heart(origin + Vector2(-1.5, -1.5), HEART_SIZE + 3.0, OUTLINE)
		_draw_heart(origin, HEART_SIZE, FULL if filled else EMPTY)
		if filled:
			draw_circle(origin + Vector2(HEART_SIZE * 0.32, HEART_SIZE * 0.26), HEART_SIZE * 0.09, FULL_SHINE)


## Two lobes and a wedge - enough of a heart at HUD size.
func _draw_heart(origin: Vector2, size: float, color: Color) -> void:
	var lobe := size * 0.27
	draw_circle(origin + Vector2(size * 0.29, size * 0.31), lobe, color)
	draw_circle(origin + Vector2(size * 0.71, size * 0.31), lobe, color)
	draw_colored_polygon(PackedVector2Array([
		origin + Vector2(size * 0.02, size * 0.36),
		origin + Vector2(size * 0.98, size * 0.36),
		origin + Vector2(size * 0.50, size * 0.97),
	]), color)
