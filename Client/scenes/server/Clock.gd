extends Node

var time: int
var decimal_collector: float = 0

var latency_array = []
var latency: int = 0
var delta_latency = 0

func start_sync():
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	$LatencyKeeper.start()
	set_physics_process(true)


func _physics_process(delta):
	var delta_msecs = delta*1000
	time += int(delta_msecs) + delta_latency
	delta_latency = 0
	decimal_collector += delta_msecs - int(delta_msecs)
	if decimal_collector >= 1.00:
		time += 1
		decimal_collector -= 1.00


remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	time = server_time + latency


func _on_LatencyKeeper_timeout():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())


remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() - 1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		var avg_latency = total_latency / latency_array.size()
		delta_latency = avg_latency - latency
		latency = avg_latency
		latency_array.clear()
