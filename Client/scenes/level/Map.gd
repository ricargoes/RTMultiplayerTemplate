extends Node2D

var character_scene = preload("res://scenes/Character.tscn")
var player_scene = preload("res://scenes/Player.tscn")

var last_world_state_time_msecs = 0
var world_state_buffer = []
const interpolation_offset_msecs = 100


func _ready():
	Server.Game.map = self
	spawn_players()
	set_physics_process(true)


func _physics_process(delta):
	interpolation()


func interpolation():
	if world_state_buffer.size() < 2:
		return
	
	# Rendering present time because we are rendering world states in the past
	var render_time = Server.Clock.time - interpolation_offset_msecs
	# Make sure world_state_buffer has following structure:
	# [2MostRecentPast_world_state, MostRecentPast_world_state, NearestFuture_world_state, nFuture_world_states, ..]
	while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
		world_state_buffer.pop_front()
	
	if world_state_buffer.size() > 2: # We have a future state
		var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
		for player_id in world_state_buffer[2].keys():
			if str(player_id) == "T":
				continue
			if player_id == Server.player_network_id:
				continue
			if not world_state_buffer[1].has(player_id):
				continue
			
			var new_position = lerp(world_state_buffer[1][player_id]["P"], world_state_buffer[2][player_id]["P"], interpolation_factor)
			$Characters.get_node(str(player_id)).move_to(new_position)
			$Characters.get_node(str(player_id)).move_dir = world_state_buffer[1][player_id]["D"]
	elif render_time > world_state_buffer[1]["T"]: # We have no future world_states
		var extrapolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for player_id in world_state_buffer[1].keys():
			if str(player_id) == "T":
				continue
			if player_id == Server.player_network_id:
				continue
			if not world_state_buffer[0].has(player_id):
				continue
			
			var extrapolation_guess = (world_state_buffer[1][player_id]["P"] - world_state_buffer[0][player_id]["P"])*extrapolation_factor
			var new_position = world_state_buffer[1][player_id]["P"] + extrapolation_guess
			$Characters.get_node(str(player_id)).move_to(new_position)
			$Characters.get_node(str(player_id)).move_dir = world_state_buffer[1][player_id]["D"]



func spawn_players():
	for id in Server.Game.spawning_locations.keys():
		var spawning_entity: Character
		if id == Server.player_network_id:
			spawning_entity = player_scene.instance()
		else:
			spawning_entity = character_scene.instance()
		spawning_entity.position = Server.Game.spawning_locations[id]
		spawning_entity.reclaim_by_player(id)
		$Characters.add_child(spawning_entity, true)


func update_world_state(world_state: Dictionary):
	if world_state["T"] < last_world_state_time_msecs:
		return
	
	last_world_state_time_msecs = world_state["T"]
	world_state_buffer.append(world_state)
