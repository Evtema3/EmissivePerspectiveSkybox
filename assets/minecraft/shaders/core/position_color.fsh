#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>
#include <minecraft:skybox_utils.glsl>
#include <minecraft:globals.glsl>

layout(location = 0) in vec4 vertexColor;
layout(location = 1) in float isHorizon;

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    #endif
    return color;
}

void main() {
    if (isHorizon > 0.5) {
        discardControl(gl_FragCoord.xy, ScreenSize.x);
    }
    
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }

    color *= ColorModulator;
    if (isHorizon > 0.5) {
        color.a = 0;
    }

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}