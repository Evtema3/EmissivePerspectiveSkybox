#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform vec3 ModelOffset;

out float vertexDistance;
out float dimension;
out vec4 vertexColor;
out vec4 lightColor;
out vec4 maxLightColor;
out vec2 texCoord0;
out vec3 faceLightingNormal;
out vec4 glpos;

void main() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position + ModelOffset, 1.0)).xyz);
	dimension = get_dimension(minecraft_sample_lightmap(Sampler2, ivec2(0.0, 0.0)));
    vertexColor = Color;
	lightColor = minecraft_sample_lightmap(Sampler2, UV2);
	maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    texCoord0 = UV0;
	faceLightingNormal = Normal;
    glpos = gl_Position;
}
