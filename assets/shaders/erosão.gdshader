shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float edge_size : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform float emission_strength = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;

    if (noise < dissolve) {
        discard;
    }

    float edge = smoothstep(dissolve, dissolve + edge_size, noise);

    COLOR.rgb = mix(edge_color.rgb * emission_strength, tex.rgb, edge);
    COLOR.a = tex.a;
}