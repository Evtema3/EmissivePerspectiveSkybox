#version 150

#moj_import <fog.glsl>
#moj_import <skybox_utils.vsh>
#moj_import <emissive_utils.vsh>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;

in float zPos;
in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 lightColor;
in vec4 maxLightColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = texture(Sampler0, texCoord0);
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    color = apply_emissive_perspective_for_item(color, lightColor, maxLightColor, vertexDistance, zPos, FogStart, FogEnd, alpha);
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}