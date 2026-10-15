extends SceneTree

const ARCHIVE_PROBE_PATH: = "user://_memory_archive_read_probe.json"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var memory_class: = root.get_node_or_null("MemoryClass")
	if memory_class == null:
		return _fail("MemoryClass autoload")

	_remove_probe_file()
	if not bool(memory_class.call("读取游戏", ARCHIVE_PROBE_PATH)):
		return _fail("missing archive must remain an empty slot")

	var empty_file: = FileAccess.open(ARCHIVE_PROBE_PATH, FileAccess.WRITE)
	if empty_file == null:
		return _fail("create empty archive")
	empty_file.close()
	if not bool(memory_class.call("读取游戏", ARCHIVE_PROBE_PATH)):
		return _fail("empty archive must remain an empty slot")

	var damaged_file: = FileAccess.open(ARCHIVE_PROBE_PATH, FileAccess.WRITE)
	if damaged_file == null:
		return _fail("create damaged archive")
	damaged_file.store_string("not an encrypted archive")
	damaged_file.close()
	if bool(memory_class.call("读取游戏", ARCHIVE_PROBE_PATH)):
		return _fail("damaged archive must reject entry")

	_remove_probe_file()
	print("MEMORY_ARCHIVE_READ_OK missing empty damaged null_guard")
	quit(0)


func _remove_probe_file() -> void :
	if FileAccess.file_exists(ARCHIVE_PROBE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ARCHIVE_PROBE_PATH))


func _fail(reason: String) -> bool:
	_remove_probe_file()
	push_error("MEMORY_ARCHIVE_READ_FAIL %s" % reason)
	quit(1)
	return false
