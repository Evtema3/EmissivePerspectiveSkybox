#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 maxLightColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    float alpha = color.a * 255.0;
    color = make_emissive(color, lightMapColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
    if(color.a < 0.15) discard;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}