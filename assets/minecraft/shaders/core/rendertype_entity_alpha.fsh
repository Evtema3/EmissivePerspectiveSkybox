#version 150

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec2 texCoord2;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControl(gl_FragCoord.xy, ScreenSize.x);
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < vertexColor.a) {
        discard;
    }
    fragColor = color;
}