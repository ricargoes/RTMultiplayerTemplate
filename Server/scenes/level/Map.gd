extends Node2D

var character_scene = preload("res://scenes/entities/CharacterServer.tscn")


func _ready():
	Server.Game.map = self
	spawn_players()
	set_physics_process(true)


func _physics_process(delta):
	render_world_state()


func render_world_state():
	var world_state = Server.Game.player_state_collection.duplicate(true)
	for player_id in world_state:
		var player_node = $Characters.get_node(str(player_id))
		player_node.position = world_state[player_id]["P"]


func spawn_players():
	var spawning_locations = $SpawningPositions.get_children()
	var spawning_locations_by_player = {}
	for id in Server.player_info.keys():
		spawning_locations_by_player[id] = spawning_locations.pop_front().position
		var spawning_entity = character_scene.instance()
		spawning_entity.position = spawning_locations_by_player[id]
		spawning_entity.name = str(id)
		$Characters.add_child(spawning_entity, true)
		
	Server.Game.start_client_games(spawning_locations_by_player)


