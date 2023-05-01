shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;


uniform vec4 color : source_color;
uniform float pulse_speed = 1.0;
uniform float pulse_variance = 0.05;


void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a + pulse_variance * sin(pulse_speed * TIME);
}
