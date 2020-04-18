shader_type canvas_item;
uniform float rps = 1.0;

void vertex() {
	UV.x -= mod(TIME*rps, 1.0)/32.0;
}