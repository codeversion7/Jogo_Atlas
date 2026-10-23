shader_type canvas_item;
render_mode unshaded;
uniform float clip_floor = 1000.0;
varying float local_y;
void vertex() { local_y = VERTEX.y; }
void fragment() {
	vec4 pixel = texture(TEXTURE,UV);
	if (pixel.a < 0.85 || local_y > clip_floor) { discard; }
	COLOR = vec4(pixel.rgb,1.0);
}
