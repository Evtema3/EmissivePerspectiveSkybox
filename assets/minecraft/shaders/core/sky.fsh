#version 420

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in mat4 ProjInv;
in float isSky;
in float sphericalVertexDistance;
in float cylindricalVertexDistance;

out vec4 fragColor;

// at this point, the entire sky is drawable: isSky for sky, stars and void plane for everything else.
// similar logic can be added in vsh to separate void plane from stars.
void main() {
	gl_FragDepth = gl_FragCoord.z;
    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    if (index != -1) {
		gl_FragDepth = 1.0;
        if (isSky > 0.5) {
            if (index >= 5 && index <= 20) {
                int c = (index - 5) / 4;
                int r = (index - 5) % 4;
                fragColor = vec4(encodeFloat(ProjMat[c][r]), 1.0);
            } else if (index >= 21 && index <= 29) {
                int c = (index - 21) / 3;
                int r = (index - 21) - c * 3;
                fragColor = vec4(encodeFloat(ModelViewMat[c][r]), 1.0);
            } else if (index >= 3 && index <= 4) {
                fragColor = vec4(encodeFloat(atan(ProjMat[index - 3][index - 3])), 1.0);
            } else if (index == 30) {
                fragColor = FogColor;
            } else if (index == 31) {
                fragColor = vec4(0);
            } else {
                fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            }
        } else {
            discard;
        }
    } else if (isSky > 0.5) {
        vec4 screenPos = gl_FragCoord;
        screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
        screenPos.z = 0.0; // far plane in reverse-Z
        screenPos.w = 1.0;
        vec3 view = normalize((ProjInv * screenPos).xyz);
        float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
        ndusq = ndusq * ndusq;

        fragColor = apply_fog(ColorModulator, pow(1.0 - ndusq, 8.0), pow(1.0 - ndusq, 8.0), 0, 1, 0, 1, FogColor);
        fragColor.a = 0;
    }
    else {
		if (cylindricalVertexDistance < 800)
			discard;
		fragColor = ColorModulator;//apply_fog(ColorModulator, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
	}

}
