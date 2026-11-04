extends CharacterBody3D

@export var move_speed := 5.5
@export var gravity := 18.0

var touch_input := Vector2.ZERO
var camera_pitch := deg_to_rad(-17.0)
var look_touch_index := -1
var character_animation: AnimationPlayer
var active_animation := ""

func set_touch_direction(direction: Vector2, pressed: bool) -> void:
    if pressed:
        touch_input += direction
    else:
        touch_input -= direction
    touch_input.x = clampf(touch_input.x, -1.0, 1.0)
    touch_input.y = clampf(touch_input.y, -1.0, 1.0)

func _ready() -> void:
    character_animation = _find_animation_player(self)
    _set_character_animation("Idle")

func _physics_process(delta: float) -> void:
    var input_vector := touch_input
    input_vector.x += float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
    input_vector.y += float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()
    _set_character_animation("Walk" if input_vector.length() > 0.08 else "Idle")
    var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
    var world_direction := global_transform.basis * local_direction
    world_direction.y = 0.0
    world_direction = world_direction.normalized()
    velocity.x = world_direction.x * move_speed
    velocity.z = world_direction.z * move_speed
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    move_and_slide()

func _input(event: InputEvent) -> void:
    var screen_width := get_viewport().get_visible_rect().size.x
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x > screen_width * 0.42:
            look_touch_index = event.index
        elif not event.pressed and event.index == look_touch_index:
            look_touch_index = -1
    elif event is InputEventScreenDrag and event.index == look_touch_index:
        _apply_look(event.relative)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        _apply_look(event.relative)

func _apply_look(relative: Vector2) -> void:
    rotate_y(-relative.x * 0.004)
    camera_pitch = clampf(camera_pitch - relative.y * 0.003, deg_to_rad(-60.0), deg_to_rad(25.0))
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

func _set_character_animation(animation_name: String) -> void:
    if not character_animation:
        return
    if not character_animation.has_animation(animation_name):
        return
    if active_animation == animation_name:
        return
    character_animation.play(animation_name)
    active_animation = animation_name
