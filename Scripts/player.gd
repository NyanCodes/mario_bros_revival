extends CharacterBody2D


const SPEED = 200
const JUMP_VELOCITY = -350
# const RUN_SPEED = 300
var DEAD = false
var DEATH_Y = 500
@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var _spawn_point: Vector2

func _ready() -> void:
	_spawn_point = global_position
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.4
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var accel := 1200.0 if is_on_floor() else 600.0
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, accel * delta)

	move_and_slide()
	_check_block_hits()
	_update_animation(direction)
	
func _update_animation(direction: float) -> void:
	if DEAD:
		return

	if direction != 0.0:
		_anim.flip_h = direction < 0.0

	var next := "idle"
	if not is_on_floor():
		next = "jump"
	elif direction != 0.0:
		next = "run"

	# fall back to idle if that animation doesn't exist yet
	if not _anim.sprite_frames.has_animation(next):
		next = "idle"

	_anim.play(next)
	
func _check_block_hits() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var collider := c.get_collider()
		if collider != null and collider.has_method("on_hit"):
			collider.on_hit(self, c.get_normal())

	# still cancel upward momentum when bonking a ceiling
	if is_on_ceiling():
		velocity.y = 60.0

# stub for later
func die() -> void:
	if DEAD: 
		return 
	DEAD = true
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die() # Replace with function body.
