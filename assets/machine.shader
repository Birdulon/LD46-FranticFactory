shader_type canvas_item;
uniform float rps = 1.0;
uniform vec3 bg_color = vec3(0.251);

void vertex() {
	UV.y -= floor(mod(TIME*rps, 1.0)*4.0)/16.0;
}

void fragment(){
//	if (COLOR.rgb == bg_color){
//		COLOR.r = 1.0;
//	}
//	else COLOR = COLOR;
}