extends Spatial

var _stream: StreamPeerTCP = StreamPeerTCP.new()
var _status: int = 0
var _mame_pid: int = 0
onready var _screen_material: SpatialMaterial = $Screen.get_surface_material(0)
var _screen_image: Image = Image.new()
var _screen_texture: ImageTexture = ImageTexture.new()

func _ready():
	var dir = Directory.new()
	dir.remove("snap/screen.png")
	
	var config = ConfigFile.new()
	var err = config.load("punchmania-vr.cfg")
	
	if err != OK:
		return
	
	var mame_path: String
	var rom_name: String
	for section in config.get_sections():
		if section == "mame":
			mame_path = config.get_value("mame", "mame_path")
			rom_name = config.get_value("mame", "rom_name")
	
	_mame_pid = OS.execute(mame_path + "/mame.exe", 
	["-inipath", mame_path, 
	"-cfg_directory", mame_path+"/cfg", 
	"-nvram_directory", mame_path+"/nvram", 
	"-autoboot_script", "punchmania-vr.lua", 
	"-snapname", "screen", 
	"-window", "-skip_gameinfo", rom_name], 
	false)
	
	if _stream.connect_to_host("127.0.0.1", 5555) != OK:
		print("Error connecting to host.")
	
	pass

func _process(_delta):
	var err = _screen_image.load("snap/screen.png")
	if err == OK:
		_screen_texture.create_from_image(_screen_image)
		_screen_material.albedo_texture = _screen_texture
	
	var status = _stream.get_status()
	if status != _status:
		_status = status
		match _status:
			_stream.STATUS_NONE:
				print("Disconnected from host.")
			_stream.STATUS_CONNECTING:
				print("Connecting to host.")
			_stream.STATUS_CONNECTED:
				print("Connected to host.")
			_stream.STATUS_ERROR:
				print("Error with socket stream.")
	
	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			_handle_data(_stream.get_string(available_bytes))
	
	pass

func _handle_data(data: String):
	var values: PoolStringArray = data.split(",")
	$LeftTop.position = int(values[0])
	$LeftMiddle.position = int(values[1])
	$LeftBottom.position = int(values[2])
	$RightTop.position = int(values[3])
	$RightMiddle.position = int(values[4])
	$RightBottom.position = int(values[5])
	$LeftTop.lamp = true if int(values[6]) == 1 else false
	$LeftMiddle.lamp = true if int(values[7]) == 1 else false
	$LeftBottom.lamp = true if int(values[8]) == 1 else false
	$RightTop.lamp = true if int(values[9]) == 1 else false
	$RightMiddle.lamp = true if int(values[10]) == 1 else false
	$RightBottom.lamp = true if int(values[11]) == 1 else false
	pass

func _on_Punchmaniavr_tree_exiting():
	var _err = OS.kill(_mame_pid)
	
	pass

func _handle_input(controller: String, button: int, pressed: bool):
	if _status == _stream.STATUS_CONNECTED:
		if controller == "left" && button == 15:
			_stream.put_string("button_select_left_pressed" if pressed else "button_select_left_release")
		elif controller == "right" && button == 15:
			_stream.put_string("button_select_right_pressed" if pressed else "button_select_right_release")
		elif button == 1:
			_stream.put_string("button_coin_pressed" if pressed else "button_coin_release")
		elif button == 7:
			_stream.put_string("button_start_pressed" if pressed else "button_start_release")
	pass

func _on_FPController_left_controller_button_pressed(button):
	_handle_input("left", button, true)
	pass


func _on_FPController_left_controller_button_release(button):
	_handle_input("left", button, false)
	pass


func _on_FPController_right_controller_button_pressed(button):
	_handle_input("right", button, true)
	pass


func _on_FPController_right_controller_button_release(button):
	_handle_input("right", button, false)
	pass

func _on_LeftTop_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_top_pressed")
	pass

func _on_LeftTop_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_top_release")
	pass

func _on_LeftMiddle_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_middle_pressed")
	pass

func _on_LeftMiddle_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_middle_release")
	pass

func _on_LeftBottom_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_bottom_pressed")
	pass

func _on_LeftBottom_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_left_bottom_release")
	pass

func _on_RightTop_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_top_pressed")
	pass

func _on_RightTop_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_top_release")
	pass

func _on_RightMiddle_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_middle_pressed")
	pass

func _on_RightMiddle_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_middle_release")
	pass

func _on_RightBottom_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_bottom_pressed")
	pass

func _on_RightBottom_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_string("button_right_bottom_release")
	pass
