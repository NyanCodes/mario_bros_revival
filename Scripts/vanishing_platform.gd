class_name VanishingPlatform
extends StaticBody2D

## Cat Mario ground: solid and ordinary until you commit to it, then gone.
##
## The cruelty is in the timing. `grace` is how long the player gets after
## first touching it - long enough to feel safe, short enough that a hesitant
## jump falls through. Set `stay_solid` for the opposite trick: the platform
## turns invisible but still blocks, so the player cannot see what they are
## standing on.

signal vanished

const RESET_GROUP := "resettable"

@export var grace := 0.3           ## seconds between the step and the drop
@export var respawn_after := 2.5   ## seconds until it returns; 0 = never
@export var stay_solid := false    ## invisible but still collidable

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _detector: Area2D = $Detector

var _home: Vector2
var _triggered := false
var _token := 0                    ## bumped by reset() to strand stale awaits


func _ready() -> void:
	add_to_group(RESET_GROUP)
	_home = position
	_detector.body_entered.connect(_on_detected)


func _on_detected(body: Node2D) -> void:
	if _triggered or not body.has_method("die"):
		return
	_triggered = true
	var token := _token
	_shudder()

	await get_tree().create_timer(grace).timeout
	if token != _token:
		return
	_vanish()

	if respawn_after <= 0.0:
		return
	await get_tree().create_timer(respawn_after).timeout
	if token == _token:
		reset()


func reset() -> void:
	_token += 1
	_triggered = false
	position = _home
	_sprite.visible = true
	_sprite.modulate.a = 1.0
	_shape.set_deferred("disabled", false)


func _vanish() -> void:
	_sprite.visible = false
	Audio.sfx(&"crumble", -3.0)
	if not stay_solid:
		_shape.set_deferred("disabled", true)
	vanished.emit()


## A tell, but a short one - the player sees it wobble and has to decide.
func _shudder() -> void:
	var t := create_tween()
	t.tween_property(self, "position:x", _home.x - 1.0, 0.05)
	t.tween_property(self, "position:x", _home.x + 1.0, 0.05)
	t.tween_property(self, "position:x", _home.x, 0.05)
