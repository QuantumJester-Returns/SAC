extends CharacterBody3D

@export var walk_speed := 3.0
@export var jog_speed := 5.5
@export var sprint_speed := 9.5
@export var jump_velocity := 5.8
@export var gravity := 18.0

var move_input := Vector2.ZERO
var sprint_held := false
var jog_enabled := true
var camera_pitch := deg_to_rad(-18.0)
var look_touch_index := -1
var character_animation: AnimationPlayer
var active_animation := ""

func set_move_vector(direction: Vector2) -> void:
    move_input = direction.limit_length(1.0)

func set_sprint(pressed: bool) -> void:
    sprint_held = pressed

func toggle_jog() -> void:
    jog_enabled = not jog_enabled

func jump() -> void:
    if is_on_floor():
        velocity.y = jump_velocity
        _play_if_available("Jump")

func _ready() -> void:
    character_animation = _find_animation_player(self)
    _set_character_animation("Idle")

func _physics_process(delta: float) -> void:
    var input_vector := move_input
    input_vector.x += float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
    input_vector.y += float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()

    var moving := input_vector.length() > 0.08
    var speed := walk_speed
    if jog_enabled:
        speed = jog_speed
    if sprint_held or Input.is_key_pressed(KEY_SHIFT):
        speed = sprint_speed

    var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
    var world_direction := global_transform.basis * local_direction
    world_direction.y = 0.0
    world_direction = world_direction.normalized()
    velocity.x = world_direction.x * speed
    velocity.z = world_direction.z * speed

    if not is_on_floor():
        velocity.y -= gravity * delta
    elif velocity.y < 0.0:
        velocity.y = 0.0

    if moving and is_on_floor():
        _set_character_animation("Run" if sprint_held or Input.is_key_pressed(KEY_SHIFT) else "Walk")
    elif is_on_floor():
        _set_character_animation("Idle")

    move_and_slide()

func _input(event: InputEvent) -> void:
    var screen_size := get_viewport().get_visible_rect().size
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        var over_action_buttons := touch.position.x > screen_size.x - 270.0 and touch.position.y > screen_size.y - 250.0
        if touch.pressed and touch.position.x > screen_size.x * 0.42 and not over_action_buttons:
            look_touch_index = touch.index
        elif not touch.pressed and touch.index == look_touch_index:
            look_touch_index = -1
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == look_touch_index:
            _apply_look(drag.relative)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        _apply_look(event.relative)
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            jump()

func _apply_look(relative: Vector2) -> void:
    rotate_y(-relative.x * 0.004)
    camera_pitch = clampf(camera_pitch - relative.y * 0.003, deg_to_rad(-55.0), deg_to_rad(20.0))
    var camera := get_node("Camera3D") as Camera3D
    camera.rotation.x = camera_pitch

func _find_animation_player(node: Node) -> AnimationPlayer:
    for child in node.get_children():
        if child is AnimationPlayer:
            return child as AnimationPlayer
        var found := _find_animation_player(child)
        if found:
            return found
    return null

func _play_if_available(animation_name: String) -> void:
    if character_animation and character_animation.has_animation(animation_name):
        character_animation.play(animation_name)
        active_animation = animation_name

func _set_character_animation(animation_name: String) -> void:
    if not character_animation or not character_animation.has_animation(animation_name):
        return
    if active_animation == animation_name:
        return
    character_animation.play(animation_name)
    active_animation = animation_name
