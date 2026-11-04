extends Node3D

const WATER_SHADER = preload("res://shaders/ocean.gdshader")
const CHARACTER_PATH := "res://assets/characters/KnightCaptain.glb"
const MAX_WATER_IMPACTS := 8
const TARGET_CHARACTER_HEIGHT := 1.88 # 6 ft 2 in, in metres

var player: CharacterBody3D
var water_material: ShaderMaterial
var impact_clock := 0.0
var step_clock := 0.0
var next_impact_slot := 0
var impact_buffer := PackedVector4Array()
var jog_button: Button
var joystick_knob: Panel
var joystick_touch_index := -1

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
    # A clean procedural sky avoids baked land silhouettes on the horizon.
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

    var character_scene := load(CHARACTER_PATH) as PackedScene
    var model_height := TARGET_CHARACTER_HEIGHT
    if character_scene:
        var character := character_scene.instantiate()
        character.name = "CharacterModel"
        player.add_child(character)
        var bounds: Array[AABB] = []
        _collect_model_bounds(character, Transform3D.IDENTITY, bounds)
        if not bounds.is_empty() and bounds[0].size.y > 0.01:
            var model_scale := TARGET_CHARACTER_HEIGHT / bounds[0].size.y
            character.scale = Vector3.ONE * model_scale
            character.position.y = -bounds[0].position.y * model_scale
        else:
            push_warning("Could not measure character mesh; using its authored scale.")
        var animation_player := _find_animation_player(character)
        if animation_player:
            var animations := animation_player.get_animation_list()
            if animations.has("Idle"):
                animation_player.play("Idle")
            elif animations.size() > 0:
                animation_player.play(animations[0])
    else:
        push_error("SAC 3D character GLB missing: " + CHARACTER_PATH)

    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.30
    capsule.height = model_height
    collider.shape = capsule
    collider.position.y = model_height * 0.5
    player.add_child(collider)

    var camera := Camera3D.new()
    camera.name = "Camera3D"
    camera.position = Vector3(0.0, 2.65, 5.4)
    camera.rotation_degrees = Vector3(-18.0, 0.0, 0.0)
    camera.current = true
    camera.fov = 70.0
    player.add_child(camera)
    player.position = Vector3(0.0, 0.05, -8.0)
    player.set_script(load("res://scripts/player.gd"))
    add_child(player)

func _collect_model_bounds(node: Node, parent_transform: Transform3D, bounds: Array[AABB]) -> void:
    var node_transform := parent_transform
    if node is Node3D:
        node_transform = parent_transform * (node as Node3D).transform
    if node is VisualInstance3D:
        var mesh_bounds := (node as VisualInstance3D).get_aabb() * node_transform
        if bounds.is_empty():
            bounds.append(mesh_bounds)
        else:
            bounds[0] = bounds[0].merge(mesh_bounds)
    for child in node.get_children():
        _collect_model_bounds(child, node_transform, bounds)

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
    var screen_h := view_size.y
    var screen_w := view_size.x

    # Free-Fire-style movement zone: a floating-feel joystick on the left.
    var joystick := Panel.new()
    joystick.name = "MovementJoystick"
    joystick.position = Vector2(34.0, screen_h - 214.0)
    joystick.size = Vector2(180.0, 180.0)
    joystick.mouse_filter = Control.MOUSE_FILTER_STOP
    var base_style := StyleBoxFlat.new()
    base_style.bg_color = Color(0.08, 0.16, 0.25, 0.42)
    base_style.border_color = Color(0.72, 0.86, 1.0, 0.48)
    base_style.set_border_width_all(2)
    base_style.set_corner_radius_all(90)
    joystick.add_theme_stylebox_override("panel", base_style)
    root.add_child(joystick)

    joystick_knob = Panel.new()
    joystick_knob.name = "JoystickKnob"
    joystick_knob.size = Vector2(66.0, 66.0)
    joystick_knob.position = Vector2(57.0, 57.0)
    joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var knob_style := StyleBoxFlat.new()
    knob_style.bg_color = Color(0.72, 0.86, 1.0, 0.78)
    knob_style.border_color = Color(1.0, 1.0, 1.0, 0.85)
    knob_style.set_border_width_all(2)
    knob_style.set_corner_radius_all(40)
    joystick_knob.add_theme_stylebox_override("panel", knob_style)
    joystick.add_child(joystick_knob)

    joystick.gui_input.connect(func(event: InputEvent):
        if event is InputEventScreenTouch:
            var touch := event as InputEventScreenTouch
            if touch.pressed:
                joystick_touch_index = touch.index
                _update_joystick(touch.position)
            elif touch.index == joystick_touch_index:
                joystick_touch_index = -1
                player.set_move_vector(Vector2.ZERO)
                joystick_knob.position = Vector2(57.0, 57.0)
        elif event is InputEventScreenDrag and (event as InputEventScreenDrag).index == joystick_touch_index:
            _update_joystick((event as InputEventScreenDrag).position)
        elif event is InputEventMouseButton:
            var mouse := event as InputEventMouseButton
            if mouse.button_index == MOUSE_BUTTON_LEFT:
                if mouse.pressed:
                    _update_joystick(mouse.position)
                else:
                    player.set_move_vector(Vector2.ZERO)
                    joystick_knob.position = Vector2(57.0, 57.0)
    )

    var jump_button := _make_action_button(root, "JUMP", Vector2(screen_w - 112.0, screen_h - 190.0), Vector2(82.0, 82.0))
    jump_button.pressed.connect(func(): player.jump())

    var sprint_button := _make_action_button(root, "SPRINT", Vector2(screen_w - 222.0, screen_h - 94.0), Vector2(94.0, 62.0))
    sprint_button.button_down.connect(func(): player.set_sprint(true))
    sprint_button.button_up.connect(func(): player.set_sprint(false))

    jog_button = _make_action_button(root, "JOG", Vector2(screen_w - 112.0, screen_h - 92.0), Vector2(82.0, 62.0))
    jog_button.pressed.connect(_toggle_jog_mode)

    var camera_hint := Label.new()
    camera_hint.text = "SWIPE TO LOOK"
    camera_hint.position = Vector2(screen_w * 0.57, screen_h - 34.0)
    camera_hint.add_theme_font_size_override("font_size", 13)
    camera_hint.modulate = Color(1.0, 1.0, 1.0, 0.62)
    root.add_child(camera_hint)

func _update_joystick(local_position: Vector2) -> void:
    var center := Vector2(90.0, 90.0)
    var offset := (local_position - center).limit_length(58.0)
    joystick_knob.position = center + offset - joystick_knob.size * 0.5
    player.set_move_vector(Vector2(offset.x / 58.0, offset.y / 58.0))

func _make_action_button(parent: Control, caption: String, button_position: Vector2, button_size: Vector2) -> Button:
    var button := Button.new()
    button.text = caption
    button.position = button_position
    button.size = button_size
    button.focus_mode = Control.FOCUS_NONE
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.06, 0.14, 0.24, 0.72)
    style.border_color = Color(0.65, 0.82, 1.0, 0.78)
    style.set_border_width_all(2)
    style.set_corner_radius_all(18)
    button.add_theme_stylebox_override("normal", style)
    var hover := style.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.12, 0.25, 0.38, 0.88)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    parent.add_child(button)
    return button

func _toggle_jog_mode() -> void:
    player.toggle_jog()
    jog_button.text = "JOG" if player.jog_enabled else "WALK"

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()
