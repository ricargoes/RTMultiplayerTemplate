extends Node

var network = NetworkedMultiplayerENet.new()
var port = 15001
var MIN_NUMBER_PLAYERS = 0
var MAX_NUMBER_PLAYERS = 5
var game_started = false

var available_colors = [Color.red, Color.blue, Color.yellow, Color.green, Color.purple]
var player_info = {}

onready var Game = $GameData


func _ready():
	StartServer()

func StartServer():
	network.create_server(port, MAX_NUMBER_PLAYERS)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")


func _on_peer_connected(player_id: int):
	print("User " + str(player_id) + " connected." )


func _on_peer_disconnected(player_id: int):
	if player_info.has(player_id):
		var color = player_info[player_id]["color"]
		player_info.erase(player_id)
		available_colors.append(color)
		Game.player_state_collection.erase(player_id)
	print("User " + str(player_id) + " disconnected")


remote func claim_player_slot(alias: String):
	var player_id = get_tree().get_rpc_sender_id()
	if game_started:
		rpc_id(player_id, "connection_problem", "Game has already started.")
		return
		
	var color = available_colors.pop_front()
	player_info[player_id] = {"color": color, "alias": alias, "ready": false}
	rpc_id(player_id, "set_player_id", player_id)
	print("Player " + str(player_id) + " is called " + alias + " and has color " + str(color))
	rpc("update_players_info", player_info)


remote func player_ready():
	var player_id = get_tree().get_rpc_sender_id()
	player_info[player_id]["ready"] = true
	rpc("update_players_info", player_info)
	check_start_game()


func check_start_game():
	var does_game_start = true
	for info in player_info.values():
		if not info["ready"]:
			does_game_start = false
	if player_info.size() < MIN_NUMBER_PLAYERS:
		does_game_start = false
	
	if does_game_start:
		game_started = true
		Game.start_game()
	else:
		return

