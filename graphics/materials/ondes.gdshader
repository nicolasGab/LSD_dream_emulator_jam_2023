shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
const float p_o5859_gradient_0_pos = 0.000000000;
const vec4 p_o5859_gradient_0_col = vec4(0.508208990, 0.696682990, 0.710937977, 1.000000000);
const float p_o5859_gradient_1_pos = 0.170292000;
const vec4 p_o5859_gradient_1_col = vec4(0.566864014, 0.559067011, 0.808593988, 1.000000000);
const float p_o5859_gradient_2_pos = 0.370206000;
const vec4 p_o5859_gradient_2_col = vec4(0.613892019, 0.768283010, 0.835937977, 1.000000000);
const float p_o5859_gradient_3_pos = 0.435080000;
const vec4 p_o5859_gradient_3_col = vec4(0.851562023, 0.668609977, 0.844416022, 1.000000000);
const float p_o5859_gradient_4_pos = 0.557836000;
const vec4 p_o5859_gradient_4_col = vec4(0.560608029, 0.754339993, 0.859375000, 1.000000000);
const float p_o5859_gradient_5_pos = 0.654286000;
const vec4 p_o5859_gradient_5_col = vec4(0.914062023, 0.527857006, 0.217804000, 1.000000000);
const float p_o5859_gradient_6_pos = 1.000000000;
const vec4 p_o5859_gradient_6_col = vec4(0.396605998, 0.617088020, 0.667968988, 1.000000000);
vec4 o5859_gradient_gradient_fct(float x) {
  if (x < 0.5*(p_o5859_gradient_0_pos+p_o5859_gradient_1_pos)) {
    return p_o5859_gradient_0_col;
  } else if (x < 0.5*(p_o5859_gradient_1_pos+p_o5859_gradient_2_pos)) {
    return p_o5859_gradient_1_col;
  } else if (x < 0.5*(p_o5859_gradient_2_pos+p_o5859_gradient_3_pos)) {
    return p_o5859_gradient_2_col;
  } else if (x < 0.5*(p_o5859_gradient_3_pos+p_o5859_gradient_4_pos)) {
    return p_o5859_gradient_3_col;
  } else if (x < 0.5*(p_o5859_gradient_4_pos+p_o5859_gradient_5_pos)) {
    return p_o5859_gradient_4_col;
  } else if (x < 0.5*(p_o5859_gradient_5_pos+p_o5859_gradient_6_pos)) {
    return p_o5859_gradient_5_col;
  }
  return p_o5859_gradient_6_col;
}
const float seed_o5903 = 0.111630335;
const float p_o5904_amount = 1.000000000;
const float p_o5904_eps = 0.980000000;
const float p_o5908_repeat = 4.000000000;
const float p_o5908_gradient_0_pos = 0.000000000;
const vec4 p_o5908_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o5908_gradient_1_pos = 1.000000000;
const vec4 p_o5908_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o5908_gradient_gradient_fct(float x) {
  if (x < p_o5908_gradient_0_pos) {
    return p_o5908_gradient_0_col;
  } else if (x < p_o5908_gradient_1_pos) {
    return mix(p_o5908_gradient_0_col, p_o5908_gradient_1_col, ((x-p_o5908_gradient_0_pos)/(p_o5908_gradient_1_pos-p_o5908_gradient_0_pos)));
  }
  return p_o5908_gradient_1_col;
}
float o5904_input_d(vec2 uv, float _seed_variation_) {
vec4 o5908_0_1_rgba = o5908_gradient_gradient_fct(fract(p_o5908_repeat*1.41421356237*length(fract((uv))-vec2(0.5, 0.5))));
return (dot((o5908_0_1_rgba).rgb, vec3(1.0))/3.0);
}
vec2 o5904_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o5904_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o5904_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o5904_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o5904_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o5857_amount1 = 0.500000000;
const float p_o5857_amount2 = 0.500000000;
const float p_o5857_amount3 = 0.500000000;
const float p_o5857_amount4 = 0.500000000;
const float p_o5857_amount5 = 0.500000000;
const float p_o5857_amount6 = 0.500000000;
const float p_o5857_amount7 = 0.500000000;
const float p_o5857_amount8 = 0.500000000;
const float p_o5857_amount9 = 0.500000000;
const float p_o5854_sides = 2.000000000;
const float p_o5854_radius = 1.000000000;
const float p_o5854_edge = 0.000000000;
const float seed_o5855 = 0.934016347;
const float p_o5893_sides = 2.000000000;
const float p_o5893_radius = 0.900000000;
const float p_o5893_edge = 0.000000000;
const float p_o5891_sides = 2.000000000;
const float p_o5891_radius = 0.800000000;
const float p_o5891_edge = 0.000000000;
const float p_o5889_sides = 2.000000000;
const float p_o5889_radius = 0.700000000;
const float p_o5889_edge = 0.000000000;
const float p_o5887_sides = 2.000000000;
const float p_o5887_radius = 0.600000000;
const float p_o5887_edge = 0.000000000;
const float p_o5858_sides = 2.000000000;
const float p_o5858_radius = 0.500000000;
const float p_o5858_edge = 0.000000000;
const float p_o5877_sides = 2.000000000;
const float p_o5877_radius = 0.400000000;
const float p_o5877_edge = 0.000000000;
const float p_o5881_sides = 2.000000000;
const float p_o5881_radius = 0.300000000;
const float p_o5881_edge = 0.000000000;
const float p_o5883_sides = 2.000000000;
const float p_o5883_radius = 0.200000000;
const float p_o5883_edge = 0.000000000;
const float p_o5885_sides = 2.000000000;
const float p_o5885_radius = 0.100000000;
const float p_o5885_edge = 0.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o5904_0_slope = o5904_slope((uv), p_o5904_eps, _seed_variation_);
vec2 o5904_0_warp = o5904_0_slope;float o5855_0_1_f = (fract(elapsed_time+param_rnd(0,1, (seed_o5855+fract(_seed_variation_))+0.420167)));
float o5854_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5854_sides, p_o5854_radius*o5855_0_1_f, p_o5854_edge*1.0);
float o5893_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5893_sides, p_o5893_radius*o5855_0_1_f, p_o5893_edge*1.0);
vec4 o5892_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5893_0_1_f), 1.0).rgb, vec4(vec3(o5893_0_1_f), 1.0).a);
float o5891_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5891_sides, p_o5891_radius*o5855_0_1_f, p_o5891_edge*1.0);
vec4 o5890_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5891_0_1_f), 1.0).rgb, vec4(vec3(o5891_0_1_f), 1.0).a);
float o5889_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5889_sides, p_o5889_radius*o5855_0_1_f, p_o5889_edge*1.0);
vec4 o5888_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5889_0_1_f), 1.0).rgb, vec4(vec3(o5889_0_1_f), 1.0).a);
float o5887_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5887_sides, p_o5887_radius*o5855_0_1_f, p_o5887_edge*1.0);
vec4 o5886_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5887_0_1_f), 1.0).rgb, vec4(vec3(o5887_0_1_f), 1.0).a);
float o5858_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5858_sides, p_o5858_radius*o5855_0_1_f, p_o5858_edge*1.0);
vec4 o5856_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5858_0_1_f), 1.0).rgb, vec4(vec3(o5858_0_1_f), 1.0).a);
float o5877_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5877_sides, p_o5877_radius*o5855_0_1_f, p_o5877_edge*1.0);
vec4 o5878_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5877_0_1_f), 1.0).rgb, vec4(vec3(o5877_0_1_f), 1.0).a);
float o5881_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5881_sides, p_o5881_radius*o5855_0_1_f, p_o5881_edge*1.0);
vec4 o5880_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5881_0_1_f), 1.0).rgb, vec4(vec3(o5881_0_1_f), 1.0).a);
float o5883_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5883_sides, p_o5883_radius*o5855_0_1_f, p_o5883_edge*1.0);
vec4 o5882_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5883_0_1_f), 1.0).rgb, vec4(vec3(o5883_0_1_f), 1.0).a);
float o5885_0_1_f = shape_circle(((uv)+p_o5904_amount*o5904_0_warp), p_o5885_sides, p_o5885_radius*o5855_0_1_f, p_o5885_edge*1.0);
vec4 o5884_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o5885_0_1_f), 1.0).rgb, vec4(vec3(o5885_0_1_f), 1.0).a);
vec4 o5857_0_b = vec4(vec3(o5854_0_1_f), 1.0);
vec4 o5857_0_l;
float o5857_0_a;

o5857_0_l = o5892_0_1_rgba;
o5857_0_a = p_o5857_amount1*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5890_0_1_rgba;
o5857_0_a = p_o5857_amount2*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5888_0_1_rgba;
o5857_0_a = p_o5857_amount3*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5886_0_1_rgba;
o5857_0_a = p_o5857_amount4*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5856_0_1_rgba;
o5857_0_a = p_o5857_amount5*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5878_0_1_rgba;
o5857_0_a = p_o5857_amount6*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5880_0_1_rgba;
o5857_0_a = p_o5857_amount7*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5882_0_1_rgba;
o5857_0_a = p_o5857_amount8*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

o5857_0_l = o5884_0_1_rgba;
o5857_0_a = p_o5857_amount9*1.0;
o5857_0_b = vec4(blend_normal(((uv)+p_o5904_amount*o5904_0_warp), o5857_0_l.rgb, o5857_0_b.rgb, o5857_0_a*o5857_0_l.a), min(1.0, o5857_0_b.a+o5857_0_a*o5857_0_l.a));

vec4 o5857_0_2_rgba = o5857_0_b;
vec4 o5904_0_1_rgba = o5857_0_2_rgba;
vec3 o5903_0_rand = ((o5904_0_1_rgba).rgb);vec3 o5903_0_1_rgb = rand3( vec2( float((seed_o5903+fract(_seed_variation_))) + o5903_0_rand.x, rand( o5903_0_rand.yz ) ) );
vec4 o5859_0_1_rgba = o5859_gradient_gradient_fct((dot(o5903_0_1_rgb, vec3(1.0))/3.0));

	vec4 color_tex = o5859_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



