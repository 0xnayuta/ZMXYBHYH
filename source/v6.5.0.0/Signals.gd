extends Node
signal choose_pressed


func ConnectChooseBoxSignal(Obj: Object, funcName: String):
	for i in choose_pressed.get_connections():
		var RemoveCallable = i["callable"]
		disconnect("choose_pressed", RemoveCallable)
	connect("choose_pressed", Callable(Obj, funcName))
