class_name HiddenSpike
extends Area2D

## A surprise spike that reveals near a living player and hides on respawn.
## Only SpikeHidden instances use this behavior; regular hazards stay visible.

@export_range(16.0, 256.0, 1.0) var reveal_distance := 64.0

@onready var _sprite: Sprite2D = $Sprite2D
var _proximity: Area2D


func _ready() -> void:
	add_to_group(HiddenBlock.RESET_GROUP)
	body_entered.connect(_on_body_entered)
	_proximity = Area2D.new()
	_proximity.collision_layer = 0
	_proximity.collision_mask = collision_mask
	_proximity.monitorable = false
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = reveal_distance
	shape.shape = circle
	_proximity.add_child(shape)
	add_child(_proximity)
	reset()


func _physics_process(_delta: float) -> void:
	for body in _proximity.get_overlapping_bodies():
		if body is Player and not body._dead:
			# Overlaps can still describe the previous frame after a respawn teleport.
			if global_position.distance_squared_to(body.global_position) > reveal_distance * reveal_distance:
				continue
			_sprite.visible = true
			set_physics_process(false)
			return


func reset() -> void:
	_sprite.visible = false
	set_physics_process(true)


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("die"):
		return
	_sprite.visible = true
	body.die()
