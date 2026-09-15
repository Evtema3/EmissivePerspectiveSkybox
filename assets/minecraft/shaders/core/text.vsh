#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#include <minecraft:fog.glsl>
#include <minecraft:sample_lightmap.glsl>
#endif

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
layout(location = 3) in ivec2 UV2;
#endif

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
uniform sampler2D Sampler2;
layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
#endif

layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;

layout(location = 4) out vec4 glpos;

bool isAt(int offset, int vID, int pos) {
    return (((vID == 1 || vID == 2) && offset == pos) || ((vID == 0 || vID == 3) && offset == (pos+8)));
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = Color * sample_lightmap(Sampler2, UV2);
#else
    vertexColor = Color;
    #ifdef IS_GUI
        // get the size of a text pixel
        vec2 pixel = vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
        // get the gui scale
        int guiScale = int(round(pixel.x / (1 / ScreenSize.x)));
        // get the size of the gui space
        vec2 guiSize = ScreenSize / guiScale;
        // get the vertex index for each specific character
        int vID = gl_VertexIndex % 4;
        // get the offset from the bottom 
        int offset = int(round(guiSize.y - Position.y));
        
        // remove xp text
        if(((length(Color.rgb - vec3(0.501, 1.0, 0.125)) < 0.002 && (isAt(offset, vID, 26) || isAt(offset, vID, 27))) // the bright text starts 27 pixels from the bottom, sometimes at 26
            || (length(Color.rgb - vec3(0.0, 0.0, 0.0)) < 0.002 && (isAt(offset, vID, 25) || isAt(offset, vID, 26) || isAt(offset, vID, 27) || isAt(offset, vID, 28))))) { // the darker background consists out of 3 elements (26,27,28), sometimes (25,26,27)
            vertexColor = vec4(0);
        }
    #endif
#endif
    texCoord0 = UV0;
	glpos = gl_Position;
}