extends Control

@onready var img: TextureRect = $img

var tcpChild: StreamPeerTCP

var getTime: float = 0
var KEY: Dictionary = {
	"87": "Exit1",
	"65": "move_left1",
	"83": "down1",
	"68": "move_right1",
	"74": "normalhit1",
	"75": "jump1",
	"32": "无双1",
	"72": "MagicWeapon1",
	"89": "slz1",
	"85": "lys1",
	"73": "lyfb1",
	"79": "hmz1",
	"76": "hytj1"
}


func _ready() -> void:
	pass
	tcpChild = StreamPeerTCP.new()
	tcpChild.big_endian = true
	if tcpChild.connect_to_host("127.0.0.1", 8889) != OK:
		get_tree().quit()


func _physics_process(delta) -> void:
	if tcpChild == null:
		return
	getTime += delta
	if getTime >= 0.01:
		getTime = 0
		tcpChild.poll()
		if tcpChild.get_status() != StreamPeerTCP.STATUS_NONE && tcpChild.get_available_bytes() >= 16:
			var dataList: PackedByteArray = tcpChild.get_data(8)[1]
			var dataLen: int = dataList.decode_u32(0)
			var sendLen: int = dataList.decode_u32(4)
			if dataLen != 0:
				var data: PackedByteArray = tcpChild.get_data(sendLen)[1]
				if data != null && data.size() == sendLen:
					call_deferred("setTextuer", data.decompress(dataLen, 3))
			else:
				get_tree().quit()


func setTextuer(data: PackedByteArray) -> void:
	var img_: Image = Image.new()
	img_.load_jpg_from_buffer(data)

	var image_texture: ImageTexture = ImageTexture.create_from_image(img_)
	img.texture = image_texture


func _on_tree_exited():
	tcpChild.disconnect_from_host()


func _input(event: InputEvent):
	if event is InputEventKey:
		var key: String = str(event.keycode)
		if KEY.has(key):
			var data: PackedByteArray = []
			data.resize(5)
			if event.pressed:
				data[0] = 1
			else:
				data[0] = 2
			data.append_array((KEY[key] as String).to_utf8_buffer())
			data.encode_u32(1, data.size() - 5)
			tcpChild.put_data(data)
