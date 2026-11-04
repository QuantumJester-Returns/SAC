extends Node3D

const WATER_SHADER = preload("res://shaders/ocean.gdshader")

var player: CharacterBody3D
var water_material: ShaderMaterial
var impact_clock := 0.0

func _ready() -> void:
    _build_sky()
    _build_ocean()
    _build_clouds()
    _build_player()
    _build_mobile_controls()
    _build_lighting()

func _process(delta: float) -> void:
    impact_clock += delta
    if water_material:
        water_material.set_shader_parameter("time_seconds", impact_clock)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _make_ripple(Vector2(event.position.x / get_viewport().size.x, event.position.y / get_viewport().size.y))
    elif event is InputEventMouseButton and event.pressed:
        _make_ripple(Vector2(event.position.x / get_viewport().size.x, event.position.y / get_viewport().size.y))

func _make_ripple(screen_uv: Vector2) -> void:
    if not player or not water_material:
        return
    var camera := player.get_node("Camera3D") as Camera3D
    var pixel := screen_uv * Vector2(get_viewport().size)
    var origin := camera.project_ray_origin(pixel)
    var direction := camera.project_ray_normal(pixel)
    if absf(direction.y) < 0.0001:
        return
    var distance := -origin.y / direction.y
    if distance > 0.0:
        var hit := origin + direction * distance
        water_material.set_shader_parameter("impact_position", Vector2(hit.x, hit.z))
        water_material.set_shader_parameter("impact_time", impact_clock)
        water_material.set_shader_parameter("impact_strength", 1.0)

func _build_sky() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.015, 0.12, 0.42)
    sky_material.sky_horizon_color = Color(0.22, 0.55, 0.88)
    sky_material.ground_bottom_color = Color(0.025, 0.08, 0.18)
    sky_material.ground_horizon_color = Color(0.20, 0.48, 0.72)
    sky_material.sun_angle_max = 18.0
    sky.sky_material = sky_material
    environment.sky = sky
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = environment
    add_child(world)

func _build_lighting() -> void:
    var sun := DirectionalLight3D.new()
    sun.name = "SAC_Sun"
    sun.rotation_degrees = Vector3(-32.0, -28.0, 0.0)
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    add_child(sun)

func _build_ocean() -> void:
    var ocean := MeshInstance3D.new()
    ocean.name = "StillSapphireOcean"
    var plane := PlaneMesh.new()
    plane.size = Vector2(4000.0, 4000.0)
    plane.subdivide_width = 128
    plane.subdivide_depth = 128
    ocean.mesh = plane
    water_material = ShaderMaterial.new()
    water_material.shader = WATER_SHADER
    ocean.material_override = water_material
    ocean.position.y = 0.0
    add_child(ocean)

    # Invisible water-level collision keeps the explorer above the ocean.
    var water_floor := StaticBody3D.new()
    water_floor.name = "WaterLevelCollision"
    var floor_shape := CollisionShape3D.new()
    var floor_box := BoxShape3D.new()
    floor_box.size = Vector3(4000.0, 1.0, 4000.0)
    floor_shape.shape = floor_box
    floor_shape.position.y = -0.5
    water_floor.add_child(floor_shape)
    add_child(water_floor)

func _build_clouds() -> void:
    var cloud_material := StandardMaterial3D.new()
    cloud_material.albedo_color = Color(0.82, 0.91, 1.0)
    cloud_material.roughness = 1.0
    var cloud_mesh := SphereMesh.new()
    cloud_mesh.radial_segments = 12
    cloud_mesh.rings = 8
    cloud_mesh.material = cloud_material
    var rng := RandomNumberGenerator.new()
    rng.seed = 7319
    for i in range(42):
        var bank := Node3D.new()
        bank.name = "CloudBank_%02d" % i
        var x := rng.randf_range(-900.0, 900.0)
        var z := rng.randf_range(-1150.0, 500.0)
        var base_y := rng.randf_range(95.0, 245.0)
        var puffs := rng.randi_range(4, 9)
        for j in range(puffs):
            var puff := MeshInstance3D.new()
            puff.mesh = cloud_mesh
            puff.position = Vector3(rng.randf_range(-55.0, 55.0), rng.randf_range(-12.0, 24.0), rng.randf_range(-30.0, 30.0))
            puff.scale = Vector3(rng.randf_range(24.0, 55.0), rng.randf_range(10.0, 23.0), rng.randf_range(20.0, 42.0))
            bank.add_child(puff)
        bank.position = Vector3(x, base_y, z)
        add_child(bank)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Explorer"
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    collider.shape = capsule
    collider.position.y = 0.9
    player.add_child(collider)
    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.42
    body_mesh.height = 1.8
    var body_mat := StandardMaterial3D.new()
    body_mat.albedo_color = Color(0.12, 0.32, 0.62)
    body_mesh.material = body_mat
    body.mesh = body_mesh
    body.position.y = 0.9
    player.add_child(body)
    var camera := Camera3D.new()
    camera.name = "Camera3D"
    camera.position = Vector3(0.0, 3.4, 7.0)
    camera.rotation_degrees = Vector3(-18.0, 0.0, 0.0)
    camera.current = true
    player.add_child(camera)
    player.position = Vector3(0.0, 1.0, -8.0)
    add_child(player)
    player.set_script(load("res://scripts/player.gd"))

func _build_mobile_controls() -> void:
    var layer := CanvasLayer.new()
    layer.name = "MobileControls"
    add_child(layer)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    layer.add_child(root)

    var directions := [
        {"label": "▲", "direction": Vector2(0, -1), "position": Vector2(112, 500)},
        {"label": "▼", "direction": Vector2(0, 1), "position": Vector2(112, 624)},
        {"label": "◀", "direction": Vector2(-1, 0), "position": Vector2(48, 562)},
        {"label": "▶", "direction": Vector2(1, 0), "position": Vector2(176, 562)}
    ]
    for item in directions:
        var button := Button.new()
        button.text = item.label
        button.position = item.position
        button.size = Vector2(58, 58)
        button.focus_mode = Control.FOCUS_NONE
        button.add_theme_font_size_override("font_size", 26)
        button.modulate = Color(1.0, 1.0, 1.0, 0.78)
        var direction: Vector2 = item.direction
        button.button_down.connect(func(): player.set_touch_direction(direction, true))
        button.button_up.connect(func(): player.set_touch_direction(direction, false))
        root.add_child(button)

    var hint := Label.new()
    hint.text = "DRAG RIGHT SIDE TO LOOK"
    hint.position = Vector2(900, 660)
    hint.add_theme_font_size_override("font_size", 16)
    hint.modulate = Color(1.0, 1.0, 1.0, 0.65)
    root.add_child(hint)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()
