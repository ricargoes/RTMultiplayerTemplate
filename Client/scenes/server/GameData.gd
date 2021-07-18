extends Node

var spawning_locations
var map
var player_data: Dictionary


remote func start_game(spawning_locs: Dictionary):
	spawning_locations = spawning_locs
	for player_id in spawning_locs.keys():
		player_data[player_id] = {"position": spawning_locs[player_id]}
	get_tree().change_scene("res://scenes/level/Map.tscn")


func send_player_state(player_state: Dictionary):
	rpc_unreliable_id(1, "recieve_player_state", player_state)


remote func recieve_world_state(world_state: Dictionary):
	if map:
		map.update_world_state(world_state)
