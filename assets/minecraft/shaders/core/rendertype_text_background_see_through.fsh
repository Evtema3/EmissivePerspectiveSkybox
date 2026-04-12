#version 420

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:dynamictransforms.glsl>

in vec4 vertexColor;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = vertexColor;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = color * ColorModulator;
}