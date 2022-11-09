extends Node

export (PackedScene) var Coin
export (int) var play_time

var level
var score
var time_left
var screen_size
var playing = false

func _ready():
	randomize()
	screen_size = get_viewport().get_visible_rect().size
	$Player.screen_size = screen_size
	$Player.hide()
	new_game()
	
func new_game():
	playing = true
	level = 1
	score = 0
	time_left = play_time
	$Player.start($PlayerStart.position)
	$Player.show()
	$GameTimer.start()
	spawn_coins()

func spawn_coins():
	for i in range(4 + level):
		var c = Coin.instance()
		$CoinContainer.add_child(c)
		c.screen_size = screen_size
		c.position = Vector2(rand_range(0, screen_size.x), rand_range(0, screen_size.y))
		
func _process(delta):
	if playing && $CoinContainer.get_child_count() == 0:
		level += 1
		time_left += 5
		spawn_coins()
