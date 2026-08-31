class_name HiddenBlock
extends StaticBody2D

signal bumped(by: Node2D)
@onready var _shape: CollisionShape2D = $CollisionShape2D

@export var reveal_on_hit: bool = true
@export var kills_player: bool = false
@export var one_shot: bool = true

@onready var _sprite: Sprite2D = $Sprite2D

var _home_y: float
var _used: bool = false

func _ready() -> void:
	_sprite.visible = false
	_home_y = position.y

func on_hit(body: Node2D, normal: Vector2) -> void:
	if normal.y <= 0.5:
		return
	if _used and one_shot:
		return
	_used = true

	if reveal_on_hit:
		_sprite.visible = true
		_shape.set_deferred("one_way_collision", false)

	# nudge away from the player
	var start_y := position.y
	var t := create_tween()
	t.tween_property(self, "position:y", start_y + 4.0 ,0.07)
	t.tween_property(self, "position:y", start_y, 0.07)

	bumped.emit(body)
