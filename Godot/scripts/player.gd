extends CharacterBody3D

@export var move_speed := 7.0
@export var gravity := 18.0

var touch_input := Vector2.ZERO
var camera_pitch := deg_to_rad(-18.0)

func set_touch_direction(direction: Vector2, pressed: bool) -> void:
    if pressed:
        touch_input += direction
    else:
        touch_input -= direction
    touch_input.x = clampf(touch_input.x, -1.0, 1.0)
    touch_input.y = clampf(touch_input.y, -1.0, 1.0)

func _physics_process(delta: float) -> void:
    var input_vector := touch_input
    input_vector.x += float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
    input_vector.y += float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()
    var direction := Vector3(input_vector.x, 0.0, input_vector.y)
    velocity.x = direction.x * move_speed
    velocity.z = direction.z * move_speed
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenDrag and event.position.x > get_viewport().size.x * 0.42:
        rotate_y(-event.relative.x * 0.003)
        camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, deg_to_rad(-65.0), deg_to_rad(20.0))
        var camera := get_node("Camera3D") as Camera3D
        camera.rotation.x = camera_pitch
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        rotate_y(-event.relative.x * 0.003)
        camera_pitch = clampf(camera_pitch - event.relative.y * 0.003, deg_to_rad(-65.0), deg_to_rad(20.0))
        var camera := get_node("Camera3D") as Camera3D
        camera.rotation.x = camera_pitch
