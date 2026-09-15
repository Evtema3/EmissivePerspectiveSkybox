#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;

layout(location = 0) out vec4 vertexColor;
layout(location = 1) out float isHorizon;

#define HORIZONDIST 128

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    isHorizon = 0.0;

    if ((ModelViewMat * vec4(Position, 1.0)).z > -HORIZONDIST - 10.0) {
        isHorizon = 1.0;
    }
    
    vertexColor = Color;
}