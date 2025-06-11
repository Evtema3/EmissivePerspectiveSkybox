#version 150

#moj_import <minecraft:skybox_utils.vsh>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

in vec4 glpos;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;

out vec4 fragColor;

void main() {
    discardControlGLPos(gl_FragCoord.xy, glpos);
    
    fragColor = apply_fog(ColorModulator, sphericalVertexDistance, cylindricalVertexDistance, 0.0, FogSkyEnd, FogSkyEnd, FogSkyEnd, FogColor);
}