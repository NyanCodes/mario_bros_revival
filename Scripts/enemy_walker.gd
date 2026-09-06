class_name EnemyWalker
extends CharacterBody2D

## A ground enemy that paces a platform. Stomp it from above and it dies;
## touch it any other way and you do.
##
## It turns at ledges and walls by raycast rather than by patrol markers, so
## you can drop one anywhere in the level and it stays on its platform.

const RESET_GROUP := "resettable"

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


func _ready() -> void:
	add_to_group(RESET_GROUP)
	_home = position
	_anim.animation_finished.connect(_on_anim_finished)
	reset()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	velocity += get_gravity() * delta
	if is_on_floor():
		# No ground ahead, or a wall in the way - about face.
		if not _floor_ahead.is_colliding() or _wall_ahead.is_colliding():
			_dir = -_dir
			_aim_rays()
		velocity.x = _dir * speed
	move_and_slide()

	_anim.flip_h = (_dir > 0) != sprite_faces_right
	_anim.play("run" if is_on_floor() else "idle")
	_check_player()


## Overlap is polled rather than signalled: body_entered fires once on entry,
## which misses a player who lands on an enemy already touching them.
func _check_player() -> void:
	for body in _hitbox.get_overlapping_bodies():
		if not body.has_method("die"):
			continue
		var above := body.global_position.y < global_position.y - 4.0
		if above and body.velocity.y > 0.0:
			_stomped(body)
		else:
			body.die()
		return


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


## Both rays live ahead of the enemy, so they swap sides when it turns.
func _aim_rays() -> void:
	_floor_ahead.position.x = 10.0 * _dir
	_wall_ahead.target_position.x = 12.0 * _dir
