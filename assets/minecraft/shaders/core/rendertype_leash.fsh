#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:skybox_utils.vsh>

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
flat in vec4 vertexColor;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    fragColor = apply_fog(vertexColor, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}