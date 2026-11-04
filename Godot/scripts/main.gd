extends Node3D

const WATER_SHADER = preload("res://shaders/ocean.gdshader")
const CHARACTER_PATH := "res://assets/characters/KnightCaptain.glb"
const SKY_PATH := "res://assets/sky/kloppenheim_05_puresky_2k.jpg"
const CLOUD_PATHS := [
    "res://assets/clouds/Cloud001.glb",
    "res://assets/clouds/Cloud002.glb",
    "res://assets/clouds/Cloud003.glb"
]

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
    var panorama := PanoramaSkyMaterial.new()
    var sky_texture := load(SKY_PATH) as Texture2D
    if sky_texture:
        panorama.panorama = sky_texture
        sky.sky_material = panorama
    else:
        var fallback := ProceduralSkyMaterial.new()
        fallback.sky_top_color = Color(0.015, 0.12, 0.42)
        fallback.sky_horizon_color = Color(0.22, 0.55, 0.88)
        fallback.ground_bottom_color = Color(0.025, 0.08, 0.18)
        fallback.ground_horizon_color = Color(0.20, 0.48, 0.72)
        fallback.sun_angle_max = 12.0
        sky.sky_material = fallback
    environment.sky = sky
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    world.environment = environment
    add_child(world)

func _build_lighting() -> void:
    var sun := DirectionalLight3D.new()
    sun.name = "SAC_Sun"
    sun.rotation_degrees = Vector3(-38.0, -28.0, 0.0)
    sun.light_energy = 1.8
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
    add_child(ocean)
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
    var rng := RandomNumberGenerator.new()
    rng.seed = 7319
    for i in range(24):
        var cloud_scene := load(CLOUD_PATHS[rng.randi_range(0, CLOUD_PATHS.size() - 1)]) as PackedScene
        if not cloud_scene:
            continue
        var cloud := cloud_scene.instantiate() as Node3D
        cloud.name = "VolumetricCloud_%02d" % i
        cloud.position = Vector3(rng.randf_range(-900.0, 900.0), rng.randf_range(95.0, 245.0), rng.randf_range(-1250.0, -250.0))
        var size := rng.randf_range(0.7, 2.1)
        cloud.scale = Vector3.ONE * size
        add_child(cloud)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Explorer"
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.34
    capsule.height = 1.72
    collider.shape = capsule
    collider.position.y = 0.86
    player.add_child(collider)
    var character_scene := load(CHARACTER_PATH) as PackedScene
    if character_scene:
        var character := character_scene.instantiate()
        character.name = "CharacterModel"
        player.add_child(character)
        var animation_player := _find_animation_player(character)
        if animation_player and animation_player.has_animation("Armature|mixamo.com|Layer0"):
            animation_player.play("Armature|mixamo.com|Layer0")
    var camera := Camera3D.new()
    camera.name = "Camera3D"
    camera.position = Vector3(0.0, 3.0, 7.2)
    camera.rotation_degrees = Vector3(-17.0, 0.0, 0.0)
    camera.current = true
    camera.fov = 72.0
    player.add_child(camera)
    player.position = Vector3(0.0, 0.05, -8.0)
    player.set_script(load("res://scripts/player.gd"))
    add_child(player)

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _build_mobile_controls() -> void:
    var layer := CanvasLayer.new()
    layer.name = "MobileControls"
    add_child(layer)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    layer.add_child(root)
    var view_size := get_viewport().get_visible_rect().size
    var h := view_size.y
    var directions := [
        {"label": "▲", "direction": Vector2(0, -1), "position": Vector2(92, h - 194)},
        {"label": "▼", "direction": Vector2(0, 1), "position": Vector2(92, h - 66)},
        {"label": "◀", "direction": Vector2(-1, 0), "position": Vector2(28, h - 130)},
        {"label": "▶", "direction": Vector2(1, 0), "position": Vector2(156, h - 130)}
    ]
    for item in directions:
        var button := Button.new()
        button.text = item.label
        button.position = item.position
        button.size = Vector2(58, 58)
        button.focus_mode = Control.FOCUS_NONE
        button.add_theme_font_size_override("font_size", 25)
        button.modulate = Color(0.82, 0.91, 1.0, 0.82)
        var direction: Vector2 = item.direction
        button.button_down.connect(func(): player.set_touch_direction(direction, true))
        button.button_up.connect(func(): player.set_touch_direction(direction, false))
        root.add_child(button)
    var hint := Label.new()
    hint.text = "DRAG RIGHT SIDE TO LOOK"
    hint.position = Vector2(view_size.x - 300, h - 42)
    hint.add_theme_font_size_override("font_size", 15)
    hint.modulate = Color(1.0, 1.0, 1.0, 0.72)
    root.add_child(hint)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()
