extends NorthContinentLevel

var exit_requests: = 0

func _leave_level_from_exit() -> void :
	exit_requests += 1

func check_can_exit() -> bool:
	return true
