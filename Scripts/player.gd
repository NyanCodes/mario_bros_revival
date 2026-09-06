class_name Player
extends CharacterBody2D

## Stage 1 player controller: walking, jumping, gravity and platform collision.
##
## The numbers below are tuned together — a jump reaches about 63 px (3.5 tiles)
## and carries the player roughly 110 px (6 tiles) across a gap at full speed.
## Change SPEED or JUMP_VELOCITY and the level's gaps need re-checking.

const SPEED := 200.0              # top horizontal speed, px/s
const ACCEL_GROUND := 1600.0      # px/s^2 while standing on something
const ACCEL_AIR := 900.0          # weaker steering mid-air
const FRICTION_GROUND := 1800.0
const FRICTION_AIR := 400.0

const JUMP_VELOCITY := -420.0
const FALL_GRAVITY_SCALE := 1.35  # heavier on the way down so jumps feel snappy
const JUMP_CUT := 0.4             # upward speed kept when jump is released early
const MAX_FALL_SPEED := 600.0

const COYOTE_TIME := 0.10         # jump still works just after leaving a ledge
const JUMP_BUFFER := 0.12         # jump pressed just before landing still counts

# Long enough to read the death counter, short enough that fifty deaths do
# not cost a minute and a half of staring. The death sting outlives it by
# design - it carries over into the respawn.
const RESPAWN_DELAY := 1.2

## Three hits and the run is over, like the lives counter in the original.
const MAX_HEALTH := 3

signal died
signal respawned
signal health_changed(current: int, maximum: int)
signal game_over

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var _spawn_point: Vector2
var _coyote := 0.0
var _buffer := 0.0
var _dead := false
var _was_grounded := true
var _health := MAX_HEALTH


func _ready() -> void:
	_spawn_point = global_position
	health_changed.emit(_health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	_apply_gravity(delta)
	_apply_jump(delta)
	_apply_walk(direction, delta)

	move_and_slide()
	_report_landing()
	_report_hits()
	_update_animation(direction)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var gravity := get_gravity()
	if velocity.y > 0.0:
		gravity *= FALL_GRAVITY_SCALE
	velocity += gravity * delta
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)


func _apply_jump(delta: float) -> void:
	_coyote = COYOTE_TIME if is_on_floor() else maxf(_coyote - delta, 0.0)
	_buffer = JUMP_BUFFER if Input.is_action_just_pressed("jump") else maxf(_buffer - delta, 0.0)

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_buffer = 0.0
		_coyote = 0.0
		Audio.sfx(&"jump")

	# Letting go early cuts the jump short, so a tap gives a small hop.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT


func _apply_walk(direction: float, delta: float) -> void:
	var grounded := is_on_floor()
	if direction != 0.0:
		var accel := ACCEL_GROUND if grounded else ACCEL_AIR
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
	else:
		var friction := FRICTION_GROUND if grounded else FRICTION_AIR
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


## One thud on the frame the player touches down, not every frame after.
func _report_landing() -> void:
	var grounded := is_on_floor()
	if grounded and not _was_grounded and not _dead:
		Audio.sfx(&"land", -7.0)
	_was_grounded = grounded


## Lets blocks react to being bumped (see hidden_block.gd).
func _report_hits() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider != null and collider.has_method("on_hit"):
			collider.on_hit(self, collision.get_normal())

	# Bonking a ceiling kills upward momentum instead of scraping along it.
	if is_on_ceiling():
		velocity.y = 60.0


func _update_animation(direction: float) -> void:
	if _dead:
		return

	if direction != 0.0:
		_anim.flip_h = direction < 0.0

	var next := "idle"
	if not is_on_floor():
		next = "jump" if velocity.y < 0.0 else "fall"
	elif direction != 0.0:
		next = "run"

	# Not every player scene defines every state — walk down to one that exists.
	for candidate in [next, "jump", "idle"]:
		if _anim.sprite_frames.has_animation(candidate):
			next = candidate
			break

	_anim.play(next)


func die() -> void:
	if _dead:
		return
	_dead = true
	_health -= 1
	health_changed.emit(_health, MAX_HEALTH)
	Audio.sfx(&"death", 0.0, 0.03)
	Audio.stop_music()
	died.emit()
	velocity = Vector2.ZERO
	set_physics_process(false)
	if _anim.sprite_frames.has_animation("hit"):
		_anim.play("hit")

	# Out of hearts: stay down and let the stage handle the restart, so this
	# node is not mid-await when the scene is reloaded out from under it.
	if _health <= 0:
		game_over.emit()
		return

	await get_tree().create_timer(RESPAWN_DELAY).timeout
	respawn()


## Death does not reload the scene, so anything the player changed on the way
## through has to be put back by hand. Blocks and other one-shot props join the
## "resettable" group and define reset() (see hidden_block.gd).
func respawn() -> void:
	global_position = _spawn_point
	velocity = Vector2.ZERO
	_coyote = 0.0
	_buffer = 0.0
	_dead = false
	get_tree().call_group(HiddenBlock.RESET_GROUP, "reset")
	set_physics_process(true)
	Audio.play_music(&"stage1")
	respawned.emit()


## Checkpoints call this to move where death sends the player back to.
func set_spawn(point: Vector2) -> void:
	_spawn_point = point


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
