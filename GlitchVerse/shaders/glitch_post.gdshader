shader_type canvas_item;

// Full-screen post effect: chromatic aberration, scanlines, vignette and
// "glitch" tearing that is driven by GameState.glitch_amount.

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform float glitch : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.12;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float aberration = 0.0012;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float band = floor(uv.y * 24.0);
	float n = rand(vec2(band, floor(TIME * 14.0)));
	float shift = (n - 0.5) * 0.09 * glitch * step(0.55, n);
	uv.x += shift;
	float ab = aberration + glitch * 0.012;
	float r = texture(screen_tex, uv + vec2(ab, 0.0)).r;
	float g = texture(screen_tex, uv).g;
	float b = texture(screen_tex, uv - vec2(ab, 0.0)).b;
	vec3 col = vec3(r, g, b);
	col *= 1.0 - scanline_strength * (0.5 + 0.5 * sin(SCREEN_UV.y * 900.0));
	vec2 d = SCREEN_UV - vec2(0.5);
	col *= 1.0 - dot(d, d) * vignette_strength * 2.0;
	col += glitch * 0.06;
	COLOR = vec4(col, 1.0);
}
