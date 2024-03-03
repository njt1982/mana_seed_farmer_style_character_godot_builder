shader_type canvas_item;

uniform sampler2D base_ramp;
uniform int base_ramp_steps;

uniform sampler2D seed_ramp;
uniform int seed_ramp_steps;

uniform sampler2D seed2_ramp;
uniform int seed2_ramp_steps;

uniform int style;

void fragment() {
	// Only apply if the colour is not transparent
	if (COLOR.a > 0.0) {
		// Convert the colour from float to 0-255 int. This makes comparison much more reliable.
		ivec3 colori = ivec3(round(COLOR.rgb * 255.0));
		
		// Calculate the "v" part of UV for the offset of the seed ramp. It's essentially a fraction of the height (eg, 3 of 6 would be 0.5)
		float v = float(style*2) / float(textureSize(seed_ramp, 0).y);
				
		bool found = false;

		// Loop over the primary ramp stemps
		for (int i = 0; i < seed_ramp_steps; i++) {
			// Calculate the U part pf the UV (essentially a fraction of the width) for the base
			// We add 0.5 so we dont pick from a pixel boundary.
			float u = ((float(i) + 0.5) / float(base_ramp_steps));
			
			// Get the int colour (0-255) for that U-offset of the base ramp.
			ivec3 basei = ivec3(round(texture(base_ramp, vec2(u, 0.5)).rgb * 255.0));
			
			// If the current pixel matches the base ramp...
			if (colori == basei) {
				// ... then swap it for the pixel at the UV offset in the seed_ramp.
				float seed_u = (float(i) + 0.5) / float(seed_ramp_steps);
				COLOR.rgba = texture(seed_ramp, vec2(seed_u, v));
				found = true;
				break;
			}
		}
		
		if (!found && seed2_ramp_steps > 0) {
			// Loop over the secondary ramp stemps
			for (int i = 0; i < seed2_ramp_steps; i++) {
				// Calculate the U part pf the UV (essentially a fraction of the width) for the base
				// We add 0.5 so we dont pick from a pixel boundary.
				float u = ((float(i + seed_ramp_steps) + 0.5) / float(base_ramp_steps));
				
				// Get the int colour (0-255) for that U-offset of the base ramp.
				ivec3 basei = ivec3(round(texture(base_ramp, vec2(u, 0.5)).rgb * 255.0));
				
				// If the current pixel matches the base ramp...
				if (colori == basei) {
					// ... then swap it for the pixel at the UV offset in the seed_ramp.
					float seed_u = (float(i) + 0.5) / float(seed2_ramp_steps);
					COLOR.rgba = texture(seed2_ramp, vec2(seed_u, v));
					found = true;
					break;
				}
			}
		}
	}
}

