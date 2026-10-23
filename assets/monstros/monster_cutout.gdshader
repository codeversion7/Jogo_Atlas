shader_type canvas_item;
render_mode unshaded;
uniform float damage_flash : hint_range(0.0, 1.0) = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 1.0;
void fragment() {
	vec4 sample_color = texture(TEXTURE, UV);
	// Remove halo translúcido das fontes ampliadas, sem alterar os PNGs.
	if (sample_color.a < 0.85) { discard; }
	COLOR = vec4(mix(sample_color.rgb, vec3(1.0,0.72,0.65), damage_flash * 0.75), fade);
}
