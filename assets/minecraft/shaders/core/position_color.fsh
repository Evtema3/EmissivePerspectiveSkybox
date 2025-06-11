#version 150

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

in vec4 vertexColor;
in float isHorizon;

out vec4 fragColor;

void main() {
    if (isHorizon > 0.5) {
        discardControl(gl_FragCoord.xy, ScreenSize.x);
    }
    
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
	if (isHorizon > 0.5) {
		fragColor.a = 0;
	}
}
