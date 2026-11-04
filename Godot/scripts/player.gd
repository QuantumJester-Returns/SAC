extends CharacterBody3D

@export var move_speed := 7.0
@export var gravity := 18.0

func _physics_process(delta: float) -> void:
    var input_vector := Vector2.ZERO
    input_vector.x = float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
    input_vector.y = float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
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
