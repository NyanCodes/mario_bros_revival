extends Node2D

## Stage bookkeeping: counts fruit and announces the finish.
##
## Dying resets the whole stage (blocks, fruit, vanishing platforms), so the
## fruit counter resets with it - this node is in the "resettable" group too.

const RESET_GROUP := "resettable"

const MAIN_MENU := "res://Scenes/MainMenu.tscn"

@onready var _count: Label = $HUD/FruitPanel/Row/Count
@onready var _hearts: HealthBar = $HUD/HealthPanel/Row/Hearts
@onready var _banner: Control = $HUD/Banner
@onready var _banner_text: Label = $HUD/Banner/Box/Text
@onready var _banner_stats: Label = $HUD/Banner/Box/Stats
@onready var _again_button: Button = $HUD/Banner/Box/Buttons/Again
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
		player.health_changed.connect(_on_health_changed)
		player.game_over.connect(_on_game_over)
		_hearts.set_health(player.MAX_HEALTH, player.MAX_HEALTH)

	_again_button.pressed.connect(_on_play_again)
	$HUD/Banner/Box/Buttons/Menu.pressed.connect(_on_main_menu)

	# A run that ended on the pause menu leaves the tree paused behind it.
	get_tree().paused = false
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


func _on_health_changed(current: int, maximum: int) -> void:
	_hearts.set_health(current, maximum)


## The last heart is gone. The run ends here and the player chooses what next -
## nothing restarts on its own, so the score stays on screen as long as they want.
func _on_game_over() -> void:
	_death_box.visible = false
	_show_banner("GAME OVER")


func _on_goal_reached() -> void:
	Audio.sfx(&"stage_clear", 0.0, 0.0)
	_show_banner("STAGE CLEAR")


## Pausing freezes enemies, cannons and the player behind the panel. The banner
## itself is set to PROCESS_MODE_ALWAYS in the scene, so its buttons still work.
func _show_banner(heading: String) -> void:
	_banner_text.text = heading
	_banner_stats.text = "%d / %d fruit    %d deaths" % [_collected, _total, _deaths]
	_banner.visible = true
	get_tree().paused = true
	_again_button.grab_focus()


func _on_play_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)


func reset() -> void:
	_collected = 0
	_refresh()


func _refresh() -> void:
	_count.text = "%d / %d" % [_collected, _total]
