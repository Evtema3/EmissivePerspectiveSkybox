#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:skybox_utils.vsh>

in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    fragColor = ColorModulator;
}