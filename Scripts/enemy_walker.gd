class_name EnemyWalker
extends CharacterBody2D

## A ground enemy that paces a platform. Stomp it from above and it dies;
## touch it any other way and you do.
##
## It turns at ledges and walls by raycast rather than by patrol markers, so
## you can drop one anywhere in the level and it stays on its platform.

const RESET_GROUP := "resettable"

## How far past its own body the enemy looks for a wall, and how far below its
## feet it looks for ground. Both are measured out from the collision shape at
## runtime - see _aim_rays().
const WALL_REACH := 6.0
const LEDGE_DROP := 14.0

@export var speed := 40.0
@export var facing := -1                 ## -1 starts left, 1 starts right
@export var sprite_faces_right := false  ## Crusty Crew art is drawn facing left
@export var stomp_bounce := -260.0       ## upward kick the player gets

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _hitbox: Area2D = $HitBox
@onready var _floor_ahead: RayCast2D = $FloorAhead
@onready var _wall_ahead: RayCast2D = $WallAhead

var _home: Vector2
var _dir := -1
var _dead := false
var _half_width := 10.0


func _ready() -> void:
	add_to_group(RESET_GROUP)
	_home = position
	_half_width = _measure_half_width()
	_anim.animation_finished.connect(_on_anim_finished)
	reset()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	velocity += get_gravity() * delta
	if is_on_floor():
		# No ground ahead, or a wall in the way - about face.
		if not _floor_ahead.is_colliding() or _wall_ahead.is_colliding():
			_turn()
		velocity.x = _dir * speed
	move_and_slide()

	# Backstop for anything the lookahead ray cannot see: another enemy, the
	# player, an odd tile corner. Without it a blocked enemy keeps pushing into
	# whatever stopped it and never moves again.
	if is_on_floor() and is_on_wall():
		_turn()

	_anim.flip_h = (_dir > 0) != sprite_faces_right
	_anim.play("run" if is_on_floor() else "idle")
	_check_player()


## Overlap is polled rather than signalled: body_entered fires once on entry,
## which misses a player who lands on an enemy already touching them.
func _check_player() -> void:
	for body in _hitbox.get_overlapping_bodies():
		if not body.has_method("die"):
			continue
		if _is_stomp(body):
			_stomped(body)
		else:
			body.die()
		return


## A stomp is the player coming down onto the head: their feet have to clear
## the middle of the body, and they must not be moving upward.
##
## The check is deliberately not `velocity.y > 0`. The enemy is a solid body,
## so the landing frame that ends a stomp is also the frame move_and_slide
## zeroes the player's fall speed - requiring a positive value let a clean
## stomp read as a side hit and kill the player instead.
func _is_stomp(body: Node2D) -> bool:
	var head := global_position.y + _shape.position.y
	return body.global_position.y <= head and body.velocity.y >= 0.0


func _stomped(body: Node2D) -> void:
	_dead = true
	velocity = Vector2.ZERO
	_shape.set_deferred("disabled", true)
	_hitbox.set_deferred("monitoring", false)
	_anim.play("dead")
	Audio.sfx(&"stomp")
	body.velocity.y = stomp_bounce


func _on_anim_finished() -> void:
	if _dead:
		visible = false


func reset() -> void:
	_dead = false
	visible = true
	position = _home
	velocity = Vector2.ZERO
	_dir = facing
	_shape.set_deferred("disabled", false)
	_hitbox.set_deferred("monitoring", true)
	_aim_rays()
	_anim.play("idle")


func _turn() -> void:
	_dir = -_dir
	_aim_rays()


## Both probes sit just beyond the leading edge of the body, and the edge is
## measured from the collision shape rather than hardcoded per enemy scene.
##
## That measurement is the whole point. Every enemy scene shipped the same
## 12 px wall ray, but Crabby is 36 px wide and Pink Star 25 - their rays could
## not reach past their own bodies, so they never saw a wall, walked into one
## and pushed against it for the rest of the level. Only the 19 px Fierce Tooth
## happened to be narrow enough for the old numbers to work.
func _aim_rays() -> void:
	_wall_ahead.position.y = _shape.position.y
	_wall_ahead.target_position = Vector2((_half_width + WALL_REACH) * _dir, 0.0)

	# Just inside the leading edge, so the turn happens as the body reaches the
	# end of the platform instead of once it is already hanging off.
	_floor_ahead.position = Vector2((_half_width - 2.0) * _dir, -4.0)
	_floor_ahead.target_position = Vector2(0.0, LEDGE_DROP)

	# Rays only refresh at the next physics step, so without this the frame
	# after a turn still reports what the old side saw and the enemy can flip
	# straight back.
	if is_inside_tree():
		_wall_ahead.force_raycast_update()
		_floor_ahead.force_raycast_update()


func _measure_half_width() -> float:
	var shape := _shape.shape
	if shape is RectangleShape2D:
		return shape.size.x * 0.5
	if shape is CircleShape2D:
		return shape.radius
	if shape is CapsuleShape2D:
		return shape.radius
	return _half_width
