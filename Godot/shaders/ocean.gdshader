shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.006, 0.045, 0.14, 1.0);
uniform vec4 horizon_color : source_color = vec4(0.035, 0.22, 0.42, 1.0);
uniform float time_seconds = 0.0;
// Each entry is world X, world Z, event start time, and impact strength.
uniform vec4 impact_events[8];

void fragment() {
    vec2 world_xz = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
    float micro_ripple_a = sin(world_xz.x * 0.018 + time_seconds * 0.22) * 0.002;
    float micro_ripple_b = cos(world_xz.y * 0.014 - time_seconds * 0.17) * 0.002;
    float combined_ripple = 0.0;

    // Accumulate independent impacts. Old events naturally fade away.
    for (int i = 0; i < 8; i++) {
        vec4 event_data = impact_events[i];
        float age = time_seconds - event_data.z;
        float radius = length(world_xz - event_data.xy);
        float envelope = exp(-max(age, 0.0) * 0.75)
            * step(0.0, age)
            * (1.0 - smoothstep(8.0, 24.0, radius))
            * step(0.001, event_data.w);
        float ring = sin(radius * 2.4 - age * 8.0) * envelope * event_data.w;
        combined_ripple += ring;
    }

    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
    ALBEDO = mix(deep_color.rgb, horizon_color.rgb, fresnel * 0.42);
    ROUGHNESS = 0.16 + abs(micro_ripple_a + micro_ripple_b) * 5.0;
    METALLIC = 0.12;
    SPECULAR = 0.85;
    NORMAL = normalize(NORMAL + vec3(combined_ripple * 0.08, 0.0, combined_ripple * 0.08));
}
