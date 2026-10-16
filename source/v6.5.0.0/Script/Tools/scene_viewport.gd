extends Node

const maxNum: int = 1
var viewport: Viewport
var tcpServer: TCPServer
var tcpNum: int = 0
var TCPlist: Array[StreamPeerTCP] = []
var sendTime: float
var curImg: Image
var globalImg: Image


func _ready() -> void:
	viewport = get_viewport()
	tcpServer = TCPServer.new()
	if tcpServer.listen(8889, "127.0.0.1") != OK:
		if Global.has_method("AddMessageShow"):
			Global.AddMessageShow(self, "服务器创建失败！", 1.5, Vector2(470, 300))
	else:
		if Global.has_method("AddMessageShow"):
			Global.AddMessageShow(self, "服务器创建成功！", 1.5, Vector2(470, 300))


func loopServer() -> void:
	if tcpNum > 0:
		var img_: Image = viewport.get_texture().get_image()
		sendTexture(img_)
	if tcpNum < maxNum && tcpServer.is_listening():
		var tcp: StreamPeerTCP = tcpServer.take_connection()
		if tcp != null:
			tcpNum += 1
			TCPlist.append(tcp)


func getClientCom(i: StreamPeerTCP) -> void:
	if i.get_available_bytes() > 5:
		var com: int = i.get_data(1)[1][0]
		var dataLen := i.get_data(4)[1] as PackedByteArray
		var data := i.get_data(dataLen.decode_u32(0))[1] as PackedByteArray
		var ClientCom := data.get_string_from_utf8()
		if com == 1:
			Input.action_press(ClientCom)
		else:
			Input.action_release(ClientCom)


func sendTexture(sendImg: Image) -> void:
	var sendData: PackedByteArray = getImageData(sendImg)
	var removeList: Array[StreamPeerTCP] = []
	for i: StreamPeerTCP in TCPlist:
		i.poll()
		if i.get_status() == StreamPeerTCP.STATUS_NONE:
			removeList.append(i)
		else:
			getClientCom(i)
			i.put_data(sendData)
	removeClient(removeList)


func getImageData(sendImg: Image) -> PackedByteArray:
	var img: PackedByteArray = sendImg.save_jpg_to_buffer(0.5)
	var imgLen: int = img.size()
	var b: PackedByteArray = []
	b.resize(8)
	b.encode_u32(0, imgLen)
	var data: PackedByteArray = img.compress(3)
	b.encode_u32(4, data.size())
	return b + data


func removeClient(removeList: Array[StreamPeerTCP]) -> void:
	for i: StreamPeerTCP in removeList:
		tcpNum -= 1
		TCPlist.erase(i)


func _physics_process(delta):
	if tcpServer != null:
		sendTime += delta
		if sendTime >= 0.02:
			sendTime = 0
			loopServer()


func _on_tree_exited():
	for i: StreamPeerTCP in TCPlist:
		tcpNum -= 1
		if i.get_status() != StreamPeerTCP.STATUS_NONE:
			i.put_u64(0)
			i.put_u64(0)
	tcpServer.stop()
