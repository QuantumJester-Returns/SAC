extends Node3D

const PLAYER_HEIGHT := 1.88976
const WATER_SHADER := preload("res://shaders/interactive_still_sea.gdshader")

var player: CharacterBody3D
var water_material: ShaderMaterial
var last_ripple_position := Vector3.ZERO
var ripple_cooldown := 0.0

func _ready() -> void:
	_build_environment()
	_build_water()
	_build_player()
	_build_opponent_marker()
	_build_touch_controls()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.055, 0.30, 0.72)
	sky_material.sky_horizon_color = Color(0.58, 0.78, 0.96)
	sky_material.ground_bottom_color = Color(0.025, 0.055, 0.11)
	sky_material.ground_horizon_color = Color(0.30, 0.48, 0.67)
	sky_material.sun_angle_max = 12.0
	sky_material.sun_curve = 0.12
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.7
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.0
	environment.tonemap_white = 1.15
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "HighSun"
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_color = Color(1.0, 0.94, 0.82)
	sun.light_energy = 1.45
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

func _build_water() -> void:
	var sea := MeshInstance3D.new()
	sea.name = "OpenSea"
	var plane := PlaneMesh.new()
	plane.size = Vector2(600.0, 600.0)
	plane.subdivide_width = 180
	plane.subdivide_depth = 180
	sea.mesh = plane
	water_material = ShaderMaterial.new()
	water_material.shader = WATER_SHADER
	water_material.set_shader_parameter("sea_color", Color(0.018, 0.105, 0.19, 1.0))
	water_material.set_shader_parameter("reflection_strength", 0.82)
	water_material.set_shader_parameter("surface_roughness", 0.045)
	sea.material_override = water_material
	add_child(sea)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-3.5, PLAYER_HEIGHT * 0.5, 0.0)
	add_child(player)

	var body := MeshInstance3D.new()
	body.name = "TemporaryBaseBody"
	var capsule := CapsuleMesh.new()
	capsule.height = PLAYER_HEIGHT
	capsule.radius = 0.28
	body.mesh = capsule
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.10, 0.16, 0.23)
	body_material.roughness = 0.72
	body.material_override = body_material
	player.add_child(body)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.height = PLAYER_HEIGHT
	shape.radius = 0.28
	collision.shape = shape
	player.add_child(collision)

	var camera_pivot := Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0.0, 1.2, 0.0)
	player.add_child(camera_pivot)
	var camera := Camera3D.new()
	camera.position = Vector3(-1.2, 1.7, 8.5)
	camera.fov = 68.0
	camera.current = true
	camera_pivot.add_child(camera)
	camera.look_at(Vector3(0.0, 1.0, -12.0), Vector3.UP)

func _build_opponent_marker() -> void:
	var opponent := MeshInstance3D.new()
	opponent.name = "DistantDuelistPlaceholder"
	opponent.position = Vector3(3.5, PLAYER_HEIGHT * 0.5, -30.0)
	var capsule := CapsuleMesh.new()
	capsule.height = PLAYER_HEIGHT
	capsule.radius = 0.25
	opponent.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.82, 0.96)
	material.roughness = 0.55
	opponent.material_override = material
	add_child(opponent)

func _build_touch_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TouchControls"
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var labels := [
		["◀", "move_left", Vector2(34, -112)],
		["▶", "move_right", Vector2(174, -112)],
		["▲", "move_forward", Vector2(104, -182)],
		["▼", "move_back", Vector2(104, -42)]
	]
	for item in labels:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size = Vector2(62, 62)
		button.position = Vector2(item[2].x, 0.0)
		button.anchor_left = 0.0
		button.anchor_right = 0.0
		button.anchor_top = 1.0
		button.anchor_bottom = 1.0
		button.position.y = item[2].y
		button.modulate = Color(1.0, 1.0, 1.0, 0.78)
		button.focus_mode = Control.FOCUS_NONE
		root.add_child(button)
		button.button_down.connect(_press_action.bind(item[1]))
		button.button_up.connect(_release_action.bind(item[1]))

func _press_action(action: String) -> void:
	Input.action_press(action)

func _release_action(action: String) -> void:
	Input.action_release(action)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input.x, 0.0, input.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	player.velocity.x = direction.x * 5.0
	player.velocity.z = direction.z * 5.0
	player.velocity.y = 0.0
	if direction.length_squared() > 0.01:
		player.rotation.y = atan2(direction.x, direction.z)
	player.move_and_slide()
	ripple_cooldown = maxf(0.0, ripple_cooldown - delta)
	if player.position.distance_to(last_ripple_position) > 0.45 and ripple_cooldown <= 0.0:
		last_ripple_position = player.position
		ripple_cooldown = 0.22
		water_material.set_shader_parameter("ripple_origin", Vector2(player.position.x, player.position.z))
		water_material.set_shader_parameter("ripple_age", 0.0)
		water_material.set_shader_parameter("ripple_strength", 0.75)
	else:
		var age := float(water_material.get_shader_parameter("ripple_age")) + delta
		water_material.set_shader_parameter("ripple_age", age)
