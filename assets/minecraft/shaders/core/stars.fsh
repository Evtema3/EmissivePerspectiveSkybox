#version 150

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControl(gl_FragCoord.xy, ScreenSize.x);
    fragColor = ColorModulator;
}