#version 420

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
out mat4 ProjInv;
out vec3 cscale;
out vec3 c1;
out vec3 c2;
out vec3 c3;
out vec2 texCoord0;
out float isSun;

#define SUNSIZE 60
#define SUNDIST 110
#define OVERLAYSCALE 2.0

vec2[] corners = vec2[](
    vec2(-2.0, 2.0),
    vec2(-2.0, -1.0),
    vec2(1.0, -1.0),
    vec2(1.0, 2.0)
);

void main() {
    vec4 candidate = ProjMat * ModelViewMat * vec4(Position, 1.0);
    ProjInv = mat4(0.0);
    cscale = vec3(0.0);
    c1 = vec3(0.0);
    c2 = vec3(0.0);
    c3 = vec3(0.0);
    isSun = 0.0;

    // test if sun or moon. Position.y limit excludes worldborder.
    if (Position.y < SUNDIST  && Position.y > -SUNDIST && (ModelViewMat * vec4(Position, 1.0)).z > -SUNDIST) {
        isSun = 1.0;

        // modify position of sun so that it covers the entire screen and store c1, c2, c3 so player space position of sun can be extracted in fsh.
        // this is the key to get everything working since it guarantees that we can access sun info in the control pixels in fsh.
        candidate = vec4(corners[gl_VertexID % 4] * OVERLAYSCALE, 0.0, 1.0);
        switch (gl_VertexID % 4)
        {
            case 0:
                c1 = Position;
                cscale.x = 1.0;
                break;
            case 1:
                c2 = Position;
                cscale.y = 1.0;
                break;
            case 2:
                c3 = Position;
                cscale.z = 1.0;
                break;
        }

        ProjInv = inverse(ProjMat * ModelViewMat);
    }

    gl_Position = candidate;
    texCoord0 = UV0;
}