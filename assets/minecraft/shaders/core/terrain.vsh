#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float dimension;
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec4 lightColor;
out vec4 maxLightColor;
out vec2 texCoord0;
out vec3 faceLightingNormal;
out vec4 glpos;

void main() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

	dimension = get_dimension(minecraft_sample_lightmap(Sampler2, ivec2(0.0, 0.0)));
    vertexColor = Color;
	lightColor = minecraft_sample_lightmap(Sampler2, UV2);
	maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    texCoord0 = UV0;
	faceLightingNormal = Normal;
    glpos = gl_Position;
}
