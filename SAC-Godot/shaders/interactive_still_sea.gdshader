shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 sea_color : source_color = vec4(0.018, 0.105, 0.19, 1.0);
uniform float reflection_strength : hint_range(0.0, 1.0) = 1.0;
uniform float surface_roughness : hint_range(0.0, 0.2) = 0.025;

// These values change only when gameplay calls trigger_water_reaction().
uniform vec2 ripple_origin = vec2(0.0);
uniform float ripple_age = 10.0;
uniform float ripple_strength = 0.0;
uniform float ripple_speed = 5.0;
uniform float ripple_frequency = 5.0;
uniform float ripple_width = 1.4;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 from_event = world_position.xz - ripple_origin;
    float distance_from_event = length(from_event);
    float ring_distance = distance_from_event - ripple_age * ripple_speed;
    float ring_envelope = exp(-pow(ring_distance / ripple_width, 2.0));
    float fade = exp(-ripple_age * 1.35) * ripple_strength;
    float wave = sin(ring_distance * ripple_frequency) * ring_envelope * fade;

    vec2 radial = distance_from_event > 0.001 ? normalize(from_event) : vec2(0.0);
    vec2 ripple_slope = radial * wave * 0.32;
    NORMAL_MAP = vec3(0.5 + ripple_slope.x, 0.5 + ripple_slope.y, 1.0);

    ALBEDO = sea_color.rgb;
    METALLIC = reflection_strength;
    ROUGHNESS = surface_roughness;
    SPECULAR = 1.0;
}
