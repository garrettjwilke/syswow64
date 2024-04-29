extends Node3D

# ----------- VARIABLES -----------
var rng_seed = ["open source software", "system76", "linux"]
# preload meshes
var pill_mesh = preload("res://scenes/pill_mesh.tscn")
var tree_mesh = preload("res://scenes/tree_mesh.tscn")
var house_mesh = preload("res://scenes/house_mesh.tscn")
var grass_mesh = preload("res://scenes/grass.tscn")
# these change in game DO NOT EDIT
var camera_rotation_speed = 0.1 # DO NOT EDIT
var menu_state= 0 # DO NOT EDIT
var fps = 0.0 # DO NOT EDIT
var timer = 0.0 # DO NOT EDIT
var enable_debug_messages = false # DO NOT EDIT
var debug_number = 0 # DO NOT EDIT
var bypass_debug_messages = false # DO NOT EDIT
var enable_fullscreen = false # DO NOT EDIT
var window_size = Vector2i() # DO NOT EDIT
var show_stats = true # DO NOT EDIT
var total_day_cycles = 0 # DO NOT EDIT
# ----------- END VARIABLES -----------


# ----------- FUNCTIONS ----------- 
# function to spawn 3d mesh
# the meshes are defined above in the VARIABLES section
# it takes in the mesh scene and the position you want to place it
func spawn_mesh(mesh_scene, mesh_position, mesh_rotation, mesh_scale, mesh_name):
	var mesh = mesh_scene.instantiate()
	mesh.name = mesh_name
	if mesh_scene == grass_mesh:
		if mesh.name != "grass_mesh_1":
			mesh.find_child("water").hide()
	mesh.position = mesh_position
	mesh.rotation.y = mesh_rotation
	mesh.scale = mesh_scale
	add_child(mesh)
	print(mesh.name)

# handle all keyboard inputs
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed == true:
		match event.as_text_keycode():
			# if Escape is pressed, show/hide the menu
			"Escape":
				if menu_state== 0:
					$Menu.show()
					menu_state = 1
				else:
					$Menu.hide()
					menu_state = 0

# show debug messages if the enable_debug_messages var is set to true
func debug_message(message1, message2):
	if enable_debug_messages == true or bypass_debug_messages == true:
		debug_number = debug_number + 1
		print("---- Debug: ", debug_number, " ----")
		print(message1)
		print(message2)
		#print("----")

func rng(rng_seed_slot, low, high):
	var number = RandomNumberGenerator.new()
	number.randomize()
	number.set_seed(rng_seed_slot.hash())
	number = number.randf_range(low, high)
	#print(number)
	return number
# ----------- END FUNCTIONS -----------


# this runs only when everything is loaded and ready to go
func _ready():
	# connect signals from other nodes
	$skybox.connect("total_day_cycles", _total_day_cycles)
	# hide the menu on start
	$Menu.hide()
	# spawn_mesh(amount_of_spawns, meshvar, position(vector3), rotation(int), scale(vector3), name)
	spawn_mesh(house_mesh, Vector3(rng(rng_seed[0], -10, 10), -0.1, rng(rng_seed[1], -15, 15)), rng(rng_seed[2], 0, 360), Vector3(1, 1, 1), "house_mesh_1")
	spawn_mesh(house_mesh, Vector3(rng(rng_seed[1], -11, 11), -0.1, rng(rng_seed[2], -15, 15)), rng(rng_seed[0], 0, 360), Vector3(1, 1, 1), "house_mesh_2")
	spawn_mesh(pill_mesh, Vector3(rng(rng_seed[0], -15, 15), 1.5, rng(rng_seed[1], -15, 15)), 0, Vector3(1, 1, 1),"pill_mesh_1")
	spawn_mesh(pill_mesh, Vector3(rng(rng_seed[1], -10, 10), 1.5, rng(rng_seed[0], -20, 20)), 0, Vector3(2, 2, 2),"pill_mesh_2")
	spawn_mesh(tree_mesh, Vector3(rng(rng_seed[0], -10, 10), 0, rng(rng_seed[1], -10, 10)), 0, Vector3(0.03, 0.03, 0.03), "tree_mesh_1")
	spawn_mesh(tree_mesh, Vector3(rng(rng_seed[1], -10, 10), 0, rng(rng_seed[2], -10, 10)), 0, Vector3(0.03, 0.03, 0.03), "tree_mesh_2")
	spawn_mesh(tree_mesh, Vector3(rng(rng_seed[2], -10, 10), 0, rng(rng_seed[0], -10, 10)), 0, Vector3(0.03, 0.03, 0.03), "tree_mesh_3")
	spawn_mesh(grass_mesh, Vector3(0, 0, 0), 0, Vector3(1, 1, 1), "grass_mesh_1")
	spawn_mesh(grass_mesh, Vector3(-150, 0, 0), 120, Vector3(4, 1, 1), "grass_mesh_2")
	spawn_mesh(grass_mesh, Vector3(-200, 0, 0), 50, Vector3(4, 1, 1), "grass_mesh_3")
	spawn_mesh(grass_mesh, Vector3(0, 0, 150), 90, Vector3(4, 1, 1), "grass_mesh_4")
	spawn_mesh(grass_mesh, Vector3(100, 0, 100), -34, Vector3(3, 1, 1), "grass_mesh_5")
# this runs once per frame in realtime
func _process(delta):
	# calculate the frames per second
	if show_stats == true:
		fps = 1.0 / delta
		fps = "%.02f" % fps
		window_size = get_viewport().get_size()
		var window_size_x = "%.00f" % window_size.x
		var window_size_y = "%.00f" % window_size.y
		$stats/stats_label.text = str(
			#"RNG Seed: " + rng_seed + "\n" +
			"FPS: " + fps + "\n" +
			"Window Size: " + window_size_x + "x" + window_size_y + "\n" +
			"Day Cycles: " + "%.00f" % total_day_cycles
		)
		
	if enable_debug_messages == true:
		timer += delta
		if timer >= 1.0:
			debug_message("Frames Per Second:", fps)
			timer = 0.0
	# rotate camera around scene
	$skybox.rotation.y += camera_rotation_speed*delta

func _on_cam_speed_slider_value_changed(value):
	camera_rotation_speed = value
	debug_message("camera rotation speed: ", value)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_debug_toggle_button_toggled(_toggled_on):
	if enable_debug_messages == false:
		enable_debug_messages = true
		debug_message("Enable Debug Messages:", enable_debug_messages)
	else:
		enable_debug_messages = false
		bypass_debug_messages = true
		debug_message("Enable Debug Messages:", enable_debug_messages)
		bypass_debug_messages = false

func _on_enable_fullscreen_toggle_button_toggled(_toggled_on):
	#$Menu.hide()
	window_size = get_viewport().get_size()
	$Screen_Transition_Thingy.size = window_size
	$Screen_Transition_Thingy.show()
	await get_tree().create_timer(0.5).timeout
	get_window().mode = (Window.MODE_FULLSCREEN if not enable_fullscreen else Window.MODE_WINDOWED)
	enable_fullscreen = !enable_fullscreen
	window_size = get_viewport().get_size()
	debug_message("Window Size:", window_size)
	#$Menu.show()
	$Screen_Transition_Thingy.hide()

func _on_show_stats_button_toggled(_toggled_on):
	if show_stats == true:
		$stats.hide()
		show_stats = false
	else:
		$stats.show()
		show_stats = true

func _total_day_cycles(days):
	total_day_cycles = days - 1
