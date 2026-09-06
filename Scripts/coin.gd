class_name Coin
extends Area2D

## A fruit pickup. Joins the "resettable" group, so dying restores every fruit
## along with the blocks (see player.gd::respawn).

signal collected(coin: Coin)

const RESET_GROUP := "resettable"
const COIN_GROUP := "coins"

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D

var _taken := false


func _ready() -> void:
	add_to_group(RESET_GROUP)
	add_to_group(COIN_GROUP)
	body_entered.connect(_on_body_entered)
	_anim.animation_finished.connect(_on_anim_finished)
	reset()


func _on_body_entered(body: Node2D) -> void:
	# Duck-typed like on_hit: anything that can die is the player.
	if _taken or not body.has_method("die"):
		return
	_taken = true
	_shape.set_deferred("disabled", true)
	_anim.play("collected")
	Audio.sfx(&"coin", -4.0, 0.12)
	collected.emit(self)


func _on_anim_finished() -> void:
	if _taken:
		visible = false


func reset() -> void:
	_taken = false
	_shape.set_deferred("disabled", false)
	visible = true
	_anim.play("idle")
