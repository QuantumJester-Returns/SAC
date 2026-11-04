extends Node3D

const WATER_SHADER = preload("res://shaders/ocean.gdshader")
const CHARACTER_PATH := "res://assets/characters/KnightCaptain.glb"
const MAX_WATER_IMPACTS := 8

var player: CharacterBody3D
var water_material: ShaderMaterial
var impact_clock := 0.0
var step_clock := 0.0
var next_impact_slot := 0
var impact_buffer := PackedVector4Array()

func _ready() -> void:
    for i in range(MAX_WATER_IMPACTS):
        impact_buffer.append(Vector4(0.0, 0.0, -1000.0, 0.0))
    _build_sky()
    _build_ocean()
    _build_player()
    _build_mobile_controls()
    _build_lighting()

func _process(delta: float) -> void:
    impact_clock += delta
    if water_material:
        water_material.set_shader_parameter("time_seconds", impact_clock)
    # Footfalls, not screen taps, disturb the otherwise still water.
    if player:
        var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
        if horizontal_speed > 0.7:
            step_clock += delta
            if step_clock >= 0.30:
                var strength := clampf(horizontal_speed / 9.5, 0.35, 1.25)
                register_water_impact(player.global_position, strength)
                step_clock = 0.0
        else:
            step_clock = 0.0

func register_water_impact(world_position: Vector3, strength: float = 1.0) -> void:
    # Public impact entry point: any character, prop, projectile or physics
    # object can call this. Eight independent events can coexist on the surface.
    if not water_material:
        return
    impact_buffer[next_impact_slot] = Vector4(
        world_position.x,
        world_position.z,
        impact_clock,
        clampf(strength, 0.0, 2.0)
    )
    next_impact_slot = (next_impact_slot + 1) % MAX_WATER_IMPACTS
    water_material.set_shader_parameter("impact_events", impact_buffer)

func _on_water_body_entered(body: Node3D) -> void:
    if body != player:
        register_water_impact(body.global_position, 1.4)

func _build_sky() -> void:
    # A clean procedural sky replaces the HDRI panorama, whose baked landscape
    # was creating unwanted silhouettes and clutter along the sea horizon.
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var clear_sky := ProceduralSkyMaterial.new()
    clear_sky.sky_top_color = Color(0.025, 0.20, 0.62)
    clear_sky.sky_horizon_color = Color(0.30, 0.66, 0.96)
    clear_sky.sky_curve = 0.18
    clear_sky.sky_energy_multiplier = 1.0
    clear_sky.ground_bottom_color = Color(0.006, 0.045, 0.14)
    clear_sky.ground_horizon_color = Color(0.30, 0.66, 0.96)
    clear_sky.ground_curve = 0.12
    clear_sky.sun_angle_max = 3.0
    clear_sky.sun_curve = 0.12
    sky.sky_material = clear_sky
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
    water_material.set_shader_parameter("impact_events", impact_buffer)
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

    var interaction_area := Area3D.new()
    interaction_area.name = "WaterInteractionArea"
    interaction_area.collision_layer = 0
    interaction_area.collision_mask = 1
    var area_shape := CollisionShape3D.new()
    var area_box := BoxShape3D.new()
    area_box.size = Vector3(4000.0, 0.24, 4000.0)
    area_shape.shape = area_box
    area_shape.position.y = 0.08
    interaction_area.add_child(area_shape)
    interaction_area.body_entered.connect(_on_water_body_entered)
    add_child(interaction_area)

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
        character.scale = Vector3.ONE * 6.2
        player.add_child(character)
        var animation_player := _find_animation_player(character)
        if animation_player:
            var animations := animation_player.get_animation_list()
            if animations.has("Idle"):
                animation_player.play("Idle")
            elif animations.size() > 0:
                animation_player.play(animations[0])
    else:
        push_error("SAC 3D character GLB missing: " + CHARACTER_PATH)

    var camera := Camera3D.new()
    camera.name = "Camera3D"
    camera.position = Vector3(0.0, 7.0, 11.5)
    camera.rotation_degrees = Vector3(-25.0, 0.0, 0.0)
    camera.current = true
    camera.fov = 65.0
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
