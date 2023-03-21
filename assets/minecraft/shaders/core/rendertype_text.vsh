#version 150

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 glpos;

bool isAt(int offset, int vID, int pos) {
    return (((vID == 1 || vID == 2) && offset == pos) || ((vID == 0 || vID == 3) && offset == (pos+8)));
}

void main() {
    vec3 pos = Position;

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);

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
    if(Position.z == 0.0 // z location is always 0 
        && ((length(Color.rgb - vec3(0.501, 1.0, 0.125)) < 0.002 && (isAt(offset, vID, 26) || isAt(offset, vID, 27))) // the bright text starts 27 pixels from the bottom, sometimes at 26
        || (length(Color.rgb - vec3(0.0, 0.0, 0.0)) < 0.002 && (isAt(offset, vID, 25) || isAt(offset, vID, 26) || isAt(offset, vID, 27) || isAt(offset, vID, 28))))) { // the darker background consists out of 3 elements (26,27,28), sometimes (25,26,27)
        
        /** Reposition (Remove up to Reposition End if unnecessary)**/
        pos += vec3(0.0,1000.0,0.0); // apply an offset
        /* Reposition End */
    }
    
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    glpos = gl_Position;
}
