#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;

out vec4 vertexColor;
out float isHorizon;

#define HORIZONDIST 128

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    isHorizon = 0.0;

    if ((ModelViewMat * vec4(Position, 1.0)).z > -HORIZONDIST - 10.0) {
        isHorizon = 1.0;
    }
    
    vertexColor = Color;

}
