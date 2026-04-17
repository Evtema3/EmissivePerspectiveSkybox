#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.vsh>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:chunksection.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

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
    vec3 pos = Position + (ChunkPosition - CameraBlockPos) + CameraOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

	dimension = get_dimension(sample_lightmap(Sampler2, ivec2(0.0, 0.0)));
    vertexColor = Color;
	lightColor = sample_lightmap(Sampler2, UV2);
	maxLightColor = sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    texCoord0 = UV0;
    glpos = gl_Position;
}