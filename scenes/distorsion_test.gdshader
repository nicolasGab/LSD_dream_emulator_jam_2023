
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_1;
uniform sampler2D noise_2;
uniform sampler2D noise_3;
uniform float strenght = 0.85;
uniform float speed = 5.0;
uniform float chaos : hint_range(0., 32.) = 1.;

uniform float radius : hint_range(0., 1.) = 0.5;

uniform float attenuation : hint_range(1., 5.) = 2.;

varying vec2 amount_r;
varying vec2 amount_g;
varying vec2 amount_b;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) - .5;
}

void vertex() {
	vec2 shifted_uv = (UV * 2.) - 1.;
	amount_r = normalize(
		vec2(rand(TIME * 1.3 * shifted_uv),
		rand(TIME * 1.64 * shifted_uv)));
	amount_g = normalize(
		vec2(rand(TIME * 1.5 * shifted_uv),
		rand(TIME * 1.7 * shifted_uv)));
	amount_b = normalize(
		vec2(rand(TIME * 1.17 * shifted_uv),
		rand(TIME * 1.23 * shifted_uv)));
}


void fragment() {
	float noiseValue = 0.0;
	
	float time = (TIME - floor(TIME)) * speed;
	time = time - float(int(time));
	
	if (time < 0.33){
	noiseValue = texture(noise_1, UV).r;
	}
	else if (time > 0.33 && time < 0.66){
	noiseValue = texture(noise_2, UV).r;
	}
	else{
	noiseValue = texture(noise_3, UV).r;
	}
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 fragCoord = FRAGCOORD;
	vec2 p = fragCoord.xy / iResolution.x;
	float prop = iResolution.x / iResolution.y;
	vec2 m = vec2(0.5, 0.5 / prop);
	vec2 d = p - m;
	float r = sqrt(dot(d, d)); 
	
	
	
	vec2 uv;
	uv = p + noiseValue / (100.0 / strenght);
	uv.y *= prop;
	
	vec3 col = texture(SCREEN_TEXTURE, uv).rgb;
	vec2 chaos_v = vec2(chaos, -chaos) * SCREEN_PIXEL_SIZE;
	
	float dist = length((UV - vec2(0.5)) * 1.);
	float att = clamp(dist / radius, 0., 1.);
	
	chaos_v *= 1. - pow(att, attenuation);
	col = vec3(
		texture(SCREEN_TEXTURE, uv + chaos_v * amount_r).r,
		texture(SCREEN_TEXTURE, uv + chaos_v * amount_g).g,
		texture(SCREEN_TEXTURE, uv+ chaos_v * amount_b).b);
	COLOR = vec4(col, 1.0);
}