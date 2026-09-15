#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:skybox_utils.glsl>

layout(location = 0) in vec4 glpos;

layout(location = 0) out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    fragColor = ColorModulator;
}