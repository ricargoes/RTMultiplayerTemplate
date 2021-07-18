extends Character

var player_state: Dictionary


func _physics_process(_delta):
	update_move_direction()
	movement()
	define_player_state()


func update_move_direction():
	var move_vector = Vector2(0,0)
	if Input.is_action_pressed("move_left"):
		move_vector.x += -1
	if Input.is_action_pressed("move_right"):
		move_vector.x += 1
	
	if Input.is_action_pressed("move_up"):
		move_vector.y += -1
	if Input.is_action_pressed("move_down"):
		move_vector.y += 1
	move_dir = move_vector.normalized()


func define_player_state():
	player_state = {"T": Server.Clock.time, "P": position, "D": move_dir}
	Server.Game.send_player_state(player_state)
