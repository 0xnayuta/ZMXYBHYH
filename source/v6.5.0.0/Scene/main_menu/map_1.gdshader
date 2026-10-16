shader_type canvas_item;
uniform float scan_progress : hint_range(0, 1.5);
uniform int mode : hint_range(0, 5) = 0;
uniform vec4 color : source_color;
uniform float blur_radius : hint_range(0.0, .2, 0.01);

float mode_switch(int _mode, vec2 _uv){
	float alpha;
	switch (_mode){
		case 0:
			alpha = smoothstep(scan_progress - blur_radius, scan_progress + blur_radius, _uv.y);
			break;
		case 1:
			alpha = smoothstep(scan_progress - blur_radius, scan_progress + blur_radius, _uv.x);
			break;
		case 2:
			alpha = smoothstep(scan_progress * 2. - blur_radius, scan_progress * 2. + blur_radius, _uv.x + _uv.y);
			break;
		case 3:
			alpha = smoothstep(1. - scan_progress - blur_radius, 1. - scan_progress + blur_radius, _uv.y);
			break;
		case 4:
			alpha = smoothstep(scan_progress + blur_radius, scan_progress - blur_radius, _uv.x);
			break;
		case 5:
			alpha = smoothstep(1. - (scan_progress * 2.) - blur_radius, 1. - (scan_progress * 2.) + blur_radius, _uv.x + _uv.y);
			break;
		case 6:
			break;
	};
	return alpha;
}

void fragment() {
    COLOR = color;
    vec2 uv = SCREEN_UV;
	COLOR.a = mode_switch(mode, uv);
}
