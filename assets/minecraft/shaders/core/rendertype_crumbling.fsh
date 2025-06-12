#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:skybox_utils.vsh>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord2;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = texture(Sampler0, texCoord0) * vertexColor;
    if (color.a < 0.1) {
        discard;
    }
    color = color * ColorModulator;
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}