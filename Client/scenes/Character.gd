extends KinematicBody2D

class_name Character

var char_max_speed = 5
var move_dir = Vector2.ZERO


func _ready():
	set_physics_process(true)


func _physics_process(_delta):
	update_move_direction()
	movement()


func movement():
	var _collision = move_and_collide(move_dir*char_max_speed)
	
	if move_dir == Vector2.ZERO:
		$AnimatedSprite.play("down")
	if move_dir.x > 0:
		$AnimatedSprite.play("right")
	elif move_dir.x < 0:
		$AnimatedSprite.play("left")
	elif move_dir.y > 0:
		$AnimatedSprite.play("down")
	elif move_dir.y < 0:
		$AnimatedSprite.play("up")


func update_move_direction():
	return Vector2.ZERO


func reclaim_by_player(player_id: int):
	name = str(player_id)
	modulate = Server.players[player_id]["color"]


func move_to(new_position: Vector2):
	set_position(new_position)
