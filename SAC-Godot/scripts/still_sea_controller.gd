extends Node3D
class_name StillSeaController

## Drives the recovered radial ripple shader on a water MeshInstance3D.
## Call trigger_water_reaction() when a character, projectile, or ability touches the sea.

@export var water_mesh: MeshInstance3D

var _water_material: ShaderMaterial
var _ripple_age: float = 10.0
var _ripple_strength: float = 0.0


func _ready() -> void:
    if water_mesh == null:
        push_error("StillSeaController: assign water_mesh in the Inspector.")
        set_process(false)
        return

    var source_material: Material = water_mesh.material_override
    if source_material == null:
        source_material = water_mesh.get_active_material(0)

    if not source_material is ShaderMaterial:
        push_error("StillSeaController: water mesh must use the recovered ShaderMaterial.")
        set_process(false)
        return

    _water_material = source_material.duplicate() as ShaderMaterial
    water_mesh.material_override = _water_material
    _water_material.set_shader_parameter("ripple_age", _ripple_age)
    _water_material.set_shader_parameter("ripple_strength", _ripple_strength)


func trigger_water_reaction(world_position: Vector3, strength: float = 1.0) -> void:
    if _water_material == null:
        return

    _ripple_age = 0.0
    _ripple_strength = clampf(strength, 0.0, 2.0)
    _water_material.set_shader_parameter(
        "ripple_origin",
        Vector2(world_position.x, world_position.z)
    )
    _water_material.set_shader_parameter("ripple_age", _ripple_age)
    _water_material.set_shader_parameter("ripple_strength", _ripple_strength)


func _process(delta: float) -> void:
    if _water_material == null or _ripple_strength <= 0.0:
        return

    _ripple_age += delta
    _water_material.set_shader_parameter("ripple_age", _ripple_age)

    if _ripple_age >= 8.0:
        _ripple_strength = 0.0
        _water_material.set_shader_parameter("ripple_strength", 0.0)
