class_name PoolMgr_Component extends Node


var pools: Dictionary = {}


func create_pool(scene: PackedScene, initial_size: int) -> void :
	var scene_path: = scene.resource_path
	if not pools.has(scene_path):
		pools[scene_path] = {
			"scene": scene, 
			"available": [], 
			"capacity": 0
		}


	var pool = pools[scene_path]
	while pool.available.size() < initial_size:
		var instance: = scene.instantiate()
		instance.set_meta("is_pooled", true)
		pool.available.append(instance)
		pool.capacity += 1


func GetObject(scene: PackedScene, parent: Node = null) -> Node:
	var scene_path: = scene.resource_path
	if not pools.has(scene_path):
		create_pool(scene, 5)

	var pool = pools[scene_path]
	if pool.available.is_empty():

		var instance: = scene.instantiate()
		pool.capacity += 1
		if parent != null:
			parent.add_child(instance)
			_reset_instance(instance)
		return instance

	var instance = pool.available.pop_back()
	instance.set_meta("is_pooled", true)

	if parent != null:
		parent.add_child(instance)
		_reset_instance(instance)

	return instance


func release_object(instance: Node) -> void :

	if not instance.get_meta("is_pooled", false):
		instance.queue_free()
		return


	var scene_path: String
	for path in pools:
		if instance in pools[path].available:
			scene_path = path
			break

	if scene_path.is_empty():
		instance.queue_free()
		return




	if instance.is_inside_tree():
		instance.get_parent().remove_child(instance)

	pools[scene_path].available.append(instance)


func _reset_instance(instance: Node) -> void :

	if instance is Node2D:
		instance.position = Vector2.ZERO
		instance.visible = true


	if instance.has_method("Reset"):
		instance.Reset()


func print_pool_status() -> void :
	print("==== Pool Status ====")
	for path in pools:
		var pool = pools[path]
		print("%s: %d/%d (available/capacity)" % [
			path.get_file(), 
			pool.available.size(), 
			pool.capacity
		])

func reset_pool(scene: PackedScene) -> void :
	var scene_path: = scene.resource_path
	if not pools.has(scene_path):
		return

	var pool = pools[scene_path]


	for instance in pool.available:
		if is_instance_valid(instance):
			instance.queue_free()


	pool.available = []
	pool.capacity = 0
	print("已重置池: ", scene_path.get_file())


func reset_all_pools() -> void :
	print("==== 开始强制重置所有池 ====")


	var all_instances_to_destroy = []


	for scene_path in pools:
		var pool = pools[scene_path]


		if pool.has("active_instances"):
			for instance in pool.active_instances:
				if is_instance_valid(instance):
					all_instances_to_destroy.append(instance)


		for instance in pool.available:
			if is_instance_valid(instance):
				all_instances_to_destroy.append(instance)


	for child in get_children():
		if child.get_meta("is_pooled", false):
			if is_instance_valid(child) and not child in all_instances_to_destroy:
				all_instances_to_destroy.append(child)


	var destroyed_count = 0
	for instance in all_instances_to_destroy:
		if is_instance_valid(instance):

			if instance.is_inside_tree():
				var parent = instance.get_parent()
				if is_instance_valid(parent):
					parent.remove_child(instance)


			instance.free()
			destroyed_count += 1


	for scene_path in pools:
		var pool = pools[scene_path]
		pool.available.clear()
		if pool.has("active_instances"):
			pool.active_instances.clear()
		pool.capacity = 0

	pools.clear()

	print("==== 重置完成 ====")
	print("共销毁实例数: ", destroyed_count)
	print("当前子节点剩余: ", get_child_count())
