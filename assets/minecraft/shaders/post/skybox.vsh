#version 420
 
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:float_utils.vsh>

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

out vec2 texCoord;
out vec2 oneTexel;
out float timeOfDay;
out float near;
out float far;
out mat4 projInv;
out vec4 fogColor;
out vec3 up;
out vec3 sunDir;

#define FPRECISION 4000000.0
#define PROJNEAR 0.05

void main(){
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    vec4 pos = vec4(uv * vec2(2, 2) + vec2(-1, -1), 0, 1);

    gl_Position = pos;
    texCoord = uv;

    oneTexel = 1.0 / InSize;
	
	vec2 start = getControl(0, OutSize);
    vec2 inc = vec2(2.0 / OutSize.x, 0.0);

    mat4 ModelViewMat = mat4(decodeFloat(texture(MainSampler, start + 21.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 22.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 23.0 * inc).xyz), 0.0,
                            decodeFloat(texture(MainSampler, start + 24.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 25.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 26.0 * inc).xyz), 0.0,
                            decodeFloat(texture(MainSampler, start + 27.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 28.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 29.0 * inc).xyz), 0.0,
                            0.0, 0.0, 0.0, 1.0);
    
    mat4 ProjMat = mat4(decodeFloat(texture(MainSampler, start + 5.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 6.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 7.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 8.0 * inc).xyz),
                        decodeFloat(texture(MainSampler, start + 9.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 10.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 11.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 12.0 * inc).xyz),
                        decodeFloat(texture(MainSampler, start + 13.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 14.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 15.0 * inc).xyz),  decodeFloat(texture(MainSampler, start + 16.0 * inc).xyz),
                        decodeFloat(texture(MainSampler, start + 17.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 18.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 19.0 * inc).xyz), decodeFloat(texture(MainSampler, start + 20.0 * inc).xyz));

    sunDir = normalize((inverse(ModelViewMat) * vec4(decodeFloat(texture(MainSampler, start).xyz), 
                                                    decodeFloat(texture(MainSampler, start + inc).xyz), 
                                                    decodeFloat(texture(MainSampler, start + 2.0 * inc).xyz),
                                                    1.0)).xyz);

    up = vec3(0, 1, 0); 

    fogColor = texture(MainSampler, start + inc * 30);

    timeOfDay = dot(sunDir, vec3(0, 1, 0));
    timeOfDay = 1.0;

    near = PROJNEAR;
    far = ProjMat[3][2] * near / (ProjMat[3][2] + 2.0 * near);
    float fov = atan(1 / ProjMat[1][1]);

    projInv = inverse(ProjMat * ModelViewMat);

	vec2 squareUV = (texCoord - 0.5) / (OutSize.yy / OutSize.xy);
}
