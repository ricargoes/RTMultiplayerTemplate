extends Node

var network = NetworkedMultiplayerENet.new()
var player_network_id
var players = {}

signal player_joined
signal connection_problem

onready var Game = $GameData
onready var Clock = $Clock


func _ready():
	network.connect("connection_failed", self, "_on_connection_failed")


func connect_to_server(ip: String, port: int, alias: String):
	network.connect("connection_succeeded", self, "_on_connection_succeded", [alias])
	network.create_client(ip, port)
	get_tree().set_network_peer(network)


func _on_connection_failed():
	connection_problem("Could not establish connection")


func _on_connection_succeded(alias: String):
	print("Succesfully connected. Claiming slot for alias " + alias)
	rpc_id(1, "claim_player_slot", alias)


remote func set_player_id(network_id: int):
	player_network_id = network_id
	$Clock.start_sync()
	emit_signal("player_joined")


remote func connection_problem(message: String):
	disconnect_server()
	emit_signal("connection_problem", message)


func disconnect_server():
	network.disconnect("connection_succeeded", self, "_on_connection_succeded")
	network.close_connection()


remote func update_players_info(info: Dictionary):
	players = info


func player_ready():
	rpc_id(1, "player_ready")

