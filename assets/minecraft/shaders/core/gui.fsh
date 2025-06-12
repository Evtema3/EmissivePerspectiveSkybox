#version 150

#moj_import <minecraft:skybox_utils.vsh>

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
    float LineWidth;
};

in vec4 vertexColor;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}