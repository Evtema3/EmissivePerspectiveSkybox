#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 maxLightColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    float alpha = color.a * 255.0;
    color = make_emissive(color, lightMapColor, maxLightColor, max(sphericalVertexDistance, cylindricalVertexDistance), alpha);
	color.a = remap_alpha(alpha) / 255.0;
    if(color.a < 0.15) discard;
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}