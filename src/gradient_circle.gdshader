shader_type canvas_item;

uniform sampler2D texture_overlay;
uniform float radius = 0.5;

void fragment()
{
	vec4 sample = texture(texture_overlay, UV);
	float alpha = length(UV - 0.5) < radius ? 1.0 : 0.0;
	COLOR = vec4(COLOR.rgb * (1.0 - UV.x), alpha) * sample;
}