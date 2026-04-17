#version 330

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:globals.glsl>

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
};

uniform sampler2D Sampler0;

in vec2 texCoord0;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    if (index != -1) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec4 color = texture(Sampler0, texCoord0) * vertexColor;
        if (color.a < 0.1) {
            discard;
        }
        fragColor = color * ColorModulator;
    }
}