extends Control


func _ready():
	enter_join_server_form()
	Server.connect("connection_problem", self, "_on_connection_problem")
	Server.connect("player_joined", self, "enter_lobby")


func _on_Join_pressed():
	var ip = find_node("IP").text
	var port = int(find_node("Port").text)
	var alias = find_node("Alias").text
	find_node("JoinButton").disabled = true
	Server.connect_to_server(ip, port, alias)


func _on_connection_problem(message: String):
	find_node("JoinButton").disabled = false
	print("Failed to connect: " + message)


func enter_join_server_form():
	find_node("JoinPanel").show()
	find_node("LobbyPanel").hide()
	find_node("JoinButton").disabled = false


func enter_lobby():
	find_node("JoinPanel").hide()
	find_node("LobbyPanel").show()
	find_node("LobbyRefresh").start()
	find_node("ReadyButton").disabled = false


func _on_LobbyRefresh_timeout():
	var item_list = find_node("Participants")
	item_list.clear()
	var player_ids = Server.players.keys()
	player_ids.sort()
	for id in player_ids:
		var player_info = Server.players[id]
		var extra_info = "  +  " if player_info["ready"] else ""
		item_list.add_item(player_info["alias"] + extra_info, null, false)


func _on_Ready_pressed():
	Server.player_ready()
	find_node("ReadyButton").disabled = true
