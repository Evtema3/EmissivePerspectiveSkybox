#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:skybox_utils.vsh>
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
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    color = make_emissive(color, lightMapColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
#endif
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}