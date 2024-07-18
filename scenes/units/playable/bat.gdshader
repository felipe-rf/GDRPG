shader_type canvas_item;
uniform bool look_right = true;
uniform vec4 color1 :source_color;
uniform float precision = 0.05;

vec4 replace_color(vec4 color, vec4 curr_color, float threshold){
	if((color.r + threshold >= curr_color.r && color.r - threshold <= curr_color.r) &&
    (color.g + threshold >= curr_color.g && color.g - threshold <= curr_color.g) &&
    (color.b + threshold >= curr_color.b && color.b - threshold <= curr_color.b)){
		return vec4(0.0,0.0,0.0,0.0);
	}else{
		return curr_color;
	}    
}

void fragment() {
	vec4 tex = texture(TEXTURE,UV);
    tex = replace_color(color1,tex, precision);
	COLOR=tex;
	COLOR = vec4(vec3(.0), .5 * COLOR.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
