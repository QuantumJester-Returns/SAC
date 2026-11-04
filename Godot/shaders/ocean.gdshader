shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.006, 0.045, 0.14, 1.0);
uniform vec4 horizon_color : source_color = vec4(0.035, 0.22, 0.42, 1.0);
uniform float time_seconds = 0.0;
uniform vec2 impact_position = vec2(0.0);
uniform float impact_time = -1000.0;
uniform float impact_strength = 0.0;

void fragment() {
    vec2 world_xz = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
    float wave_a = sin(world_xz.x * 0.018 + time_seconds * 0.22) * 0.002;
    float wave_b = cos(world_xz.y * 0.014 - time_seconds * 0.17) * 0.002;
    float age = time_seconds - impact_time;
    float radius = length(world_xz - impact_position);
    float envelope = exp(-max(age, 0.0) * 0.75) * step(0.0, age) * (1.0 - smoothstep(8.0, 24.0, radius));
    float ring = sin(radius * 2.4 - age * 8.0) * envelope * impact_strength;
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
    ALBEDO = mix(deep_color.rgb, horizon_color.rgb, fresnel * 0.42);
    ROUGHNESS = 0.16 + abs(wave_a + wave_b) * 5.0;
    METALLIC = 0.12;
    SPECULAR = 0.85;
    NORMAL = normalize(NORMAL + vec3(ring * 0.08, 0.0, ring * 0.08));
}
