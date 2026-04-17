#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:skybox_utils.vsh>

uniform sampler2D Sampler0;

in vec2 texCoord0;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}