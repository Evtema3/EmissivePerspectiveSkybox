#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>
#moj_import <minecraft:skybox_utils.vsh>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 maxLightColor;
in vec4 glpos;

out vec4 fragColor;

// ShaderSelector
flat in int isMarker;
flat in ivec4 iColor;

void main() {
    // ShaderSelector
    if (isMarker == 1) {
        fragColor = vec4(iColor.rgb, 255) / 255.0;
        return;
    }
    discardControlGLPos(gl_FragCoord.xy, glpos);
    // Vanilla code + emissive stuff
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
