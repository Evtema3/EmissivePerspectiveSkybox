#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:skybox_utils.glsl>
#include <minecraft:globals.glsl>

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    mat4 TextureMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
};

uniform sampler2D Sampler0;

layout(location = 0) in vec2 texCoord0;
layout(location = 1) in vec4 vertexColor;

layout(location = 0) out vec4 fragColor;

void main() {
    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    if (index != -1) {
        fragColor = vec4(0);
    } else {
        vec4 color = texture(Sampler0, texCoord0) * vertexColor;
        if (color.a < 0.1) {
            discard;
        }
        fragColor = color * ColorModulator;
    }
}