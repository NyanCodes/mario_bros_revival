class_name EnemyShooter
extends Node2D

## A fixed emplacement that fires on a timer. Aim it with `travel`; the shot
## is spawned as a sibling so it keeps flying while this node stays put.

const RESET_GROUP := "resettable"

@export var projectile: PackedScene
@export var interval := 2.2
@export var travel := Vector2(-90.0, 0.0)
@export var muzzle := Vector2(-12.0, -8.0)
@export var start_delay := 0.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var _clock := 0.0


func _ready() -> void:
	add_to_group(RESET_GROUP)
	_anim.flip_h = travel.x > 0.0
	reset()


func _process(delta: float) -> void:
	_clock -= delta
	if _clock > 0.0:
		return
	_clock = interval
	_fire()


func _fire() -> void:
	if projectile == null:
		return
	var shot := projectile.instantiate()
	shot.travel = travel
	shot.position = position + muzzle
	get_parent().add_child(shot)
	_anim.play("fire")


func reset() -> void:
	_clock = interval + start_delay
	_anim.play("idle")
