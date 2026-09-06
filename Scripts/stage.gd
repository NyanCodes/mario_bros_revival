extends Node2D

## Stage bookkeeping: counts fruit and announces the finish.
##
## Dying resets the whole stage (blocks, fruit, vanishing platforms), so the
## fruit counter resets with it - this node is in the "resettable" group too.

const RESET_GROUP := "resettable"

@onready var _count: Label = $HUD/FruitPanel/Row/Count
@onready var _banner: Control = $HUD/Banner
@onready var _banner_text: Label = $HUD/Banner/Text
@onready var _death_box: Control = $HUD/DeathBox
@onready var _death_tally: Label = $HUD/DeathBox/Row/Count

var _collected := 0
var _total := 0
var _deaths := 0


func _ready() -> void:
	add_to_group(RESET_GROUP)
	var coins := get_tree().get_nodes_in_group(Coin.COIN_GROUP)
	_total = coins.size()
	for coin in coins:
		coin.collected.connect(_on_coin_collected)

	var goal := get_node_or_null("Goal")
	if goal != null:
		goal.reached.connect(_on_goal_reached)

	var player := get_node_or_null("Player")
	if player != null:
		player.died.connect(_on_player_died)
		player.respawned.connect(_on_player_respawned)

	_banner.visible = false
	_death_box.visible = false
	_refresh()
	Audio.play_music(&"stage1")


func _on_coin_collected(_coin: Coin) -> void:
	_collected += 1
	_refresh()


## Shown during the respawn pause. The tally deliberately survives a death -
## it is a running count for the whole attempt, not per life.
func _on_player_died() -> void:
	_deaths += 1
	_death_tally.text = "x %d" % _deaths
	_death_box.visible = true


func _on_player_respawned() -> void:
	_death_box.visible = false


func _on_goal_reached() -> void:
	Audio.sfx(&"stage_clear", 0.0, 0.0)
	_banner_text.text = "STAGE CLEAR\n%d / %d fruit    %d deaths" % [_collected, _total, _deaths]
	_banner.visible = true


func reset() -> void:
	_collected = 0
	_refresh()


func _refresh() -> void:
	_count.text = "%d / %d" % [_collected, _total]
