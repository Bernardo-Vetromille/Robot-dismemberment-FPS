shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D noise_texture;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float edge_size : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform float emission_strength = 3.0;

void fragment() {
    vec4 base_tex = texture(base_texture, UV);

    float noise = texture(noise_texture, UV).r;

    if (noise < dissolve) {
        discard;
    }

    float edge = smoothstep(dissolve, dissolve + edge_size, noise);

    ALBEDO = mix(edge_color.rgb * emission_strength, base_tex.rgb, edge);
    EMISSION = edge_color.rgb * (1.0 - edge) * emission_strength;
    ALPHA = base_tex.a;
}