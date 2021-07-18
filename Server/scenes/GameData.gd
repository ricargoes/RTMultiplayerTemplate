extends Node

var map
var spawn_locations = [Vector2(165, 150), Vector2(375, 450), Vector2(500, 150), Vector2(620, 150), Vector2(860, 150)]
var player_state_collection = {}
var world_state


func start_game():
	get_tree().change_scene("res://scenes/level/Map.tscn")


func start_client_games(spawning_locations_by_player):
	rpc("start_game", spawning_locations_by_player)
	set_physics_process(true)


remote func recieve_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	
	if player_state_collection.get(player_id, {"T": -1})["T"] < player_state["T"]:
		player_state_collection[player_id] = player_state


func _physics_process(delta):
	if player_state_collection.empty():
		return
	
	world_state = player_state_collection.duplicate(true)
	for player_id in world_state.keys():
		world_state[player_id].erase("T")
	world_state["T"] = OS.get_system_time_msecs()
	
	send_world_state(world_state)


func send_world_state(world_state):
	rpc_unreliable("recieve_world_state", world_state)
