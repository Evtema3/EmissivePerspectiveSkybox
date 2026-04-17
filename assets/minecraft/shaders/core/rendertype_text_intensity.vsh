#version 330

#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 glpos;

bool isAt(int offset, int vID, float pos0, float pos1) {
    return (((vID == 1 || vID == 2) && offset >= pos0 && offset <= pos1) || ((vID == 0 || vID == 3) && offset >= (pos0+8) && offset <= (pos1+8)));
}

void main() {
    vec3 pos = Position;

    sphericalVertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    cylindricalVertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * sample_lightmap(Sampler2, UV2);

    texCoord0 = UV0;
    
    // get the size of a text pixel
    vec2 pixel = vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
    // get the gui scale
    int guiScale = int(round(pixel.x / (1 / ScreenSize.x)));
    // get the size of the gui space
    vec2 guiSize = ScreenSize / guiScale;
    // get the vertex id for each specific character
    int vID = gl_VertexID % 4;
    // get the offset from the bottom 
    int offset = int(round(guiSize.y - Position.y));
    
    // offset xp text
    if((length(Color.rgb - vec3(0.501, 1.0, 0.125)) < 0.002 && (isAt(offset, vID, 25,28))) // the bright text starts 27 pixels from the bottom, sometimes at 26
        || (length(Color.rgb - vec3(0.0, 0.0, 0.0)) < 0.002 && (isAt(offset, vID, 24,29)))) { // the darker background consists out of 3 elements (26,27,28), sometimes (25,26,27)
        vertexColor = vec4(0);
    }
    
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    glpos = gl_Position;
}
