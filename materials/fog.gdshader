shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_disabled;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float fade_start : hint_range(0.0, 100.0) = 10.0;
uniform float fade_end : hint_range(0.0, 500.0) = 50.0;

void vertex() {
	// Forces the quad to perfectly fill the screen clip space
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// 1. Get the raw background color
	vec3 original_color = texture(screen_texture, SCREEN_UV).rgb;
	
	// 2. Sample the raw depth buffer
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	// 3. If the depth is exactly 1.0, it's the skybox. Do not apply the fade.
	if (depth >= 1.0) {
		ALBEDO = original_color;
	} else {
		// 4. Convert depth to linear distance (meters) for geometry
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
		vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view.xyz /= view.w;
		float linear_depth = -view.z; // Distance from camera in units/meters

		// 5. Calculate the fade factor based on start and end distances
		float fade = clamp((linear_depth - fade_start) / (fade_end - fade_start), 0.0, 1.0);
		
		// 6. Mix the world color with your fade color
		ALBEDO = mix(original_color, fade_color.rgb, fade * fade_color.a);
	}
}
