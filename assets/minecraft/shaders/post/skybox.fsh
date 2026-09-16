#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D MainSampler;
uniform sampler2D MainDepthSampler;
uniform sampler2D SkyBoxSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(location = 0) in vec2 texCoord;
layout(location = 1) in vec2 oneTexel;
layout(location = 2) in float timeOfDay; // 1 - Noon, -1 - Midnight
layout(location = 3) in float near;
layout(location = 4) in float far;
layout(location = 5) in vec4 fogColor;
layout(location = 6) in vec4 baseColor;
layout(location = 7) in vec3 up;
layout(location = 8) in vec3 sunDir;
layout(location = 9) in mat4 projInv;

layout(location = 0) out vec4 fragColor;

const float FUDGE = 0.01;

float linearizeDepth(float depth) {
    return (2.0 * near * far) / (far + near - depth * (far - near));    
}

vec3 sampleSkybox(sampler2D skyboxSampler, vec3 direction) {
	float l = max(max(abs(direction.x), abs(direction.y)), abs(direction.z));
	vec3 dir = direction / l;
	vec3 absDir = abs(dir);
	
	vec2 skyboxUV;
	vec4 backgroundColor;
	if (absDir.x >= absDir.y && absDir.x > absDir.z) {
		if (dir.x > 0) {
			skyboxUV = vec2(0, 0.5) + (dir.zy * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(2.0 / 3, 0.5) + (-dir.zy + 1) / 2 / vec2(3, 2);
		}
	} else if (absDir.y >= absDir.z) {
		if (dir.y > 0) {
			skyboxUV = vec2(1.0 / 3, 0) + (dir.xz * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(0, 0) + (-dir.xz + 1) / 2 / vec2(3, 2);
		}
	} else {
		if (dir.z > 0) {
			skyboxUV = vec2(1.0 / 3, 0.5) + (-dir.xy + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(2.0 / 3, 0) + (dir.xy * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		}
	}
	return texture(skyboxSampler, skyboxUV).rgb;
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

vec3 screenToPlayer(mat4 projInv, vec3 screen) {
    vec4 ndc = vec4(screen * 2.0 - 1.0, 1.0);
    vec4 temp = projInv * ndc;
    return temp.xyz / temp.w;
}

void main() {
	vec3 direction = normalize(screenToPlayer(projInv, vec3(texCoord, 1.0)) - screenToPlayer(projInv, vec3(texCoord, 0.0)));
    float depth = texture(MainDepthSampler, texCoord).r;
    vec4 main = texture(MainSampler, texCoord);
	fragColor = main;

	vec3 temp = main.rgb - vec3(0.157, 0.024, 0.024);
	bool isNether = dot(temp, temp) < FUDGE;

	if (depth < 1 && fogColor.rgb != baseColor.rgb) {
        vec3 skyColor = sampleSkybox(SkyBoxSampler, direction);
		float factor = smoothstep(-0.1, 0.1, timeOfDay);

		vec4 screenPos = gl_FragCoord;
        screenPos.xy = (screenPos.xy / OutSize - vec2(0.5)) * 2.0;
        screenPos.z = 0.0; // far plane in reverse-Z
        screenPos.w = 1.0;
        vec3 view = normalize((projInv * screenPos).xyz);
        float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
        ndusq = ndusq * ndusq;

		vec3 sky = vec3(0,0,0);
		vec4 terrain = main;
		terrain.rgb = (main.rgb - sky * (1-main.a)) / max(main.a, 0.01);

		vec4 finalColor = linear_fog(vec4(skyColor, 1), pow(1.0 - ndusq, 8.0), 0.0, 1.0, fogColor / fogColor.a);
		
		fragColor = vec4(mix(
			finalColor.rgb,
			terrain.rgb,
			main.a
		), 1);
	}
	
}
