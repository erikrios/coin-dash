@tool
extends Node

@export var coin_scene: PackedScene
@export var powerup_scene: PackedScene
@export var playtime := 30

var level := 1
var score := 0
var time_left := 0
var screensize := Vector2.ZERO
var playing := false

func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()
	
func _process(_delta: float) -> void:
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()
		$PowerupTimer.wait_time = randi_range(0, 5)
		$PowerupTimer.start()

func _get_configuration_warnings() -> PackedStringArray:
	var warning: PackedStringArray = []
	
	if not coin_scene:
		warning.append("Coin Scene is not initialized. Please set a valid PackedScene.")
		
	if not powerup_scene:
		warning.append("Powerup Scene is not initialized. Please set a valid PackedScene.")
	
	return warning
	
func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	
func spawn_coins():
	for i in level + 4:
		var c := coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2(randf_range(0, screensize.x), randf_range(0, screensize.y))
	$LevelSound.play()

func game_over() -> void:
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free()")
	$HUD.show_game_over()
	$Player.die()
	$EndSound.play()

func _on_game_timer_timeout() -> void:
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()


func _on_player_hurt() -> void:
	game_over()

func _on_player_pickup(type: String) -> void:
	match type:
		"coin":
			score += 1
			$HUD.update_score(score)
			$CoinSound.play()
		"powerup":
			time_left += 5
			$HUD.update_timer(time_left)
			$PowerupSound.play()

func _on_hud_start_game() -> void:
	new_game()

func _on_powerup_timer_timeout() -> void:
	var p := powerup_scene.instantiate()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(randf_range(0, screensize.x), randf_range(0, screensize.y))
