#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:globals.glsl>

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
flat in vec4 vertexColor;
in vec4 glpos;

out vec4 fragColor;

void main() {
    discardControl(gl_FragCoord.xy, ScreenSize.x);
    fragColor = apply_fog(vertexColor, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}