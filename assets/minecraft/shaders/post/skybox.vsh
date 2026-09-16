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
layout(location = 3) out vec4 fogColor;
layout(location = 4) out vec4 baseColor;
layout(location = 5) out vec3 up;
layout(location = 6) out vec3 sunDir;
layout(location = 7) out mat4 projInv;

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
    
    projInv = mat4(decodeFloat(texture(MainSampler, start + 5.0 * inc)), decodeFloat(texture(MainSampler, start + 6.0 * inc)), decodeFloat(texture(MainSampler, start + 7.0 * inc)), decodeFloat(texture(MainSampler, start + 8.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 9.0 * inc)), decodeFloat(texture(MainSampler, start + 10.0 * inc)), decodeFloat(texture(MainSampler, start + 11.0 * inc)), decodeFloat(texture(MainSampler, start + 12.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 13.0 * inc)), decodeFloat(texture(MainSampler, start + 14.0 * inc)), decodeFloat(texture(MainSampler, start + 15.0 * inc)),  decodeFloat(texture(MainSampler, start + 16.0 * inc)),
                        decodeFloat(texture(MainSampler, start + 17.0 * inc)), decodeFloat(texture(MainSampler, start + 18.0 * inc)), decodeFloat(texture(MainSampler, start + 19.0 * inc)), decodeFloat(texture(MainSampler, start + 20.0 * inc)));
    
    // sunDir = normalize((inverse(ModelViewMat) * vec4(decodeFloat(texture(MainSampler, start)), 
    //                                                 decodeFloat(texture(MainSampler, start + inc)), 
    //                                                 decodeFloat(texture(MainSampler, start + 2.0 * inc)),
    //                                                 1.0)).xyz);
    sunDir = vec3(0);

    up = vec3(0, 1, 0); 

    fogColor = texture(MainSampler, start + inc * 21);

    baseColor = texture(MainSampler, start + inc * 22);

    // timeOfDay = dot(sunDir, vec3(0, 1, 0));
    timeOfDay = 1.0;

	vec2 squareUV = (texCoord - 0.5) / (OutSize.yy / OutSize.xy);
}
