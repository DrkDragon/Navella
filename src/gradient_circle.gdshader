shader_type canvas_item;

void fragment()
{
	COLOR = vec4(COLOR.rgb * (1.0 - UV.x), (length(UV - 0.5) < 0.5) ? 1.0 : 0.0);
}