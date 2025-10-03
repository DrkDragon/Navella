shader_type canvas_item;

uniform sampler2D noise_texture_x;
uniform sampler2D noise_texture_y;

uniform float speed = 0.001;
uniform float distortion = 0.004;

void fragment()
{
	vec2 noiseValue = vec2(
		(texture(
			noise_texture_x,
			fract(UV + (TIME * speed))
		).r * 2.0) - 1.0,
		(texture(
			noise_texture_y,
			fract(UV + (TIME * speed))
		).r * 2.0) - 1.0
	);
	
	vec2 noiseDistortion = (noiseValue * distortion);
	
	vec4 color = texture(TEXTURE, UV + noiseDistortion);
	
	COLOR = vec4(color.rgb, 1.0);
}