#version 330
#extension GL_ARB_separate_shader_objects : require
 
#include <minecraft:projection.glsl>
#include <minecraft:float_utils.glsl>

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(location = 0) out vec2 texCoord;
layout(location = 1) out vec2 oneTexel;
layout(location = 2) out float timeOfDay;
layout(location = 3) out float near;
layout(location = 4) out float far;
layout(location = 5) out vec4 fogColor;
layout(location = 6) out vec4 baseColor;
layout(location = 7) out vec3 up;
layout(location = 8) out vec3 sunDir;
layout(location = 9) out mat4 projInv;

#define FPRECISION 4000000.0
#define PROJNEAR 0.05

void main(){
    vec2 uv = vec2((gl_VertexIndex << 1) & 2, gl_VertexIndex & 2);
    vec4 pos = vec4(uv * vec2(2, 2) + vec2(-1, -1), 0, 1);

    gl_Position = pos;
    texCoord = uv;

    oneTexel = 1.0 / InSize;
	
	vec2 start = getControl(0, OutSize);
    vec2 inc = vec2(2.0 / OutSize.x, 0.0);

    mat4 ModelViewMat = mat4(decodeFloat(texture(MainSampler, start + 21.0 * inc)), decodeFloat(texture(MainSampler, start + 22.0 * inc)), decodeFloat(texture(MainSampler, start + 23.0 * inc)), 0.0,
                            decodeFloat(texture(MainSampler, start + 24.0 * inc)), decodeFloat(texture(MainSampler, start + 25.0 * inc)), decodeFloat(texture(MainSampler, start + 26.0 * inc)), 0.0,
                            decodeFloat(texture(MainSampler, start + 27.0 * inc)), decodeFloat(texture(MainSampler, start + 28.0 * inc)), decodeFloat(texture(MainSampler, start + 29.0 * inc)), 0.0,
                            0.0, 0.0, 0.0, 1.0);
    
    mat4 ProjMat = mat4(decodeFloat(texture(MainSampler, start + 5.0 * inc)), decodeFloat(texture(MainSampler, start + 6.0 * inc)), decodeFloat(texture(MainSampler, start + 7.0 * inc)), decodeFloat(texture(MainSampler, start + 8.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 9.0 * inc)), decodeFloat(texture(MainSampler, start + 10.0 * inc)), decodeFloat(texture(MainSampler, start + 11.0 * inc)), decodeFloat(texture(MainSampler, start + 12.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 13.0 * inc)), decodeFloat(texture(MainSampler, start + 14.0 * inc)), decodeFloat(texture(MainSampler, start + 15.0 * inc)),  decodeFloat(texture(MainSampler, start + 16.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 17.0 * inc)), decodeFloat(texture(MainSampler, start + 18.0 * inc)), decodeFloat(texture(MainSampler, start + 19.0 * inc)), decodeFloat(texture(MainSampler, start + 20.0 * inc)));

    for (int c = 0; c < 4; c++) {
        for (int r = 0; r < 4; r++) {
            if (abs(ProjMat[c][r]) < 0.0001) {
                ProjMat[c][r] = 0.0;
            } else if (abs(ProjMat[c][r]) > 100000.0) {
                ProjMat[c][r] = 0.0;
            }
        }
    }
    
    sunDir = normalize((inverse(ModelViewMat) * vec4(decodeFloat(texture(MainSampler, start)), 
                                                    decodeFloat(texture(MainSampler, start + inc)), 
                                                    decodeFloat(texture(MainSampler, start + 2.0 * inc)),
                                                    1.0)).xyz);

    up = vec3(0, 1, 0); 

    fogColor = texture(MainSampler, start + inc * 30);

    baseColor = texture(MainSampler, start + inc * 31);

    timeOfDay = dot(sunDir, vec3(0, 1, 0));
    timeOfDay = 1.0;

    near = PROJNEAR;
    far = ProjMat[3][2] * near / (ProjMat[3][2] + 2.0 * near);
    float fov = atan(1 / ProjMat[1][1]);

    projInv = inverse(ProjMat * ModelViewMat);

	vec2 squareUV = (texCoord - 0.5) / (OutSize.yy / OutSize.xy);
}
