class_name Projectile
extends Area2D

## Fired by enemy_shooter.gd. Lethal, short-lived, and cleaned up on a reset
## so a respawn is never met by a bullet still in flight.

const RESET_GROUP := "resettable"

@export var travel := Vector2.ZERO
@export var life := 5.0


func _ready() -> void:
	add_to_group(RESET_GROUP)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += travel * delta
	life -= delta
	if life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		queue_free()


func reset() -> void:
	queue_free()
