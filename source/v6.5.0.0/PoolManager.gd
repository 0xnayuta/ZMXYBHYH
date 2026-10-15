
extends Node

var pools = {}


func create_pool(scene_path: String, _initial_size: int):

	if not pools.has(scene_path):
		pools[scene_path] = []
	var scene = load(scene_path)
	for i in pools[scene_path].size():
		var instance = scene.instantiate()
		instance.name = "PooledInstance"
		instance.queue_free()
		pools[scene_path].append(instance)


func get_instance(scene_path: String) -> Node:
	if pools.has(scene_path) and pools[scene_path].size() > 0:
		return pools[scene_path].pop_front()
	else:
		var scene = load(scene_path)
		return scene.instantiate()


func recycle_instance(scene_path: String, instance: Node):
	if not pools.has(scene_path):
		pools[scene_path] = []
	instance.queue_free()
	pools[scene_path].append(instance)
