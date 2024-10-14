#version 330

#moj_import <shader_selector:marker_settings.glsl>
#moj_import <shader_selector:utils.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D MainDepthSampler;
uniform sampler2D DataSampler;
uniform sampler2D SkyBoxDay1Sampler;
uniform sampler2D SkyBoxNight1Sampler;
uniform sampler2D SkyBoxDay2Sampler;
uniform sampler2D SkyBoxNight2Sampler;
uniform sampler2D SkyBoxDay3Sampler;
uniform sampler2D SkyBoxNight3Sampler;
uniform sampler2D SkyBoxDay4Sampler;
uniform sampler2D SkyBoxNight4Sampler;
uniform vec2 OutSize;

in vec2 texCoord;
in vec2 oneTexel;
in vec3 direction;
in float timeOfDay; // 1 - Noon, -1 - Midnight
in float near;
in float far;
in mat4 projInv;
in vec4 fogColor;
in vec3 up;
in vec3 sunDir;

out vec4 fragColor;

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

void main() {
	float realDepth = linearizeDepth(texture(MainDepthSampler, texCoord).r);
    fragColor = texture(DiffuseSampler, texCoord);

	vec3 temp = fragColor.rgb - vec3(0.157, 0.024, 0.024);
	bool isNether = dot(temp, temp) < FUDGE;

	if (far > 50 && realDepth > far / 2 - 5) {
		
        float control_color = decodeColor(texelFetch(DataSampler, ivec2(4, SKYBOX_CHANNEL), 0));
        vec3 daySkybox = sampleSkybox(SkyBoxDay1Sampler, direction);
		vec3 nightSkybox = sampleSkybox(SkyBoxNight1Sampler, direction);

        switch(int(control_color * 255.)) {
            case 1:
                daySkybox = sampleSkybox(SkyBoxDay1Sampler, direction);
                nightSkybox = sampleSkybox(SkyBoxNight1Sampler, direction);
                break;
            case 2:
                daySkybox = sampleSkybox(SkyBoxDay2Sampler, direction);
                nightSkybox = sampleSkybox(SkyBoxNight2Sampler, direction);
                break;
            case 3:
                daySkybox = sampleSkybox(SkyBoxDay3Sampler, direction);
                nightSkybox = sampleSkybox(SkyBoxNight3Sampler, direction);
                break;
            case 4:
                daySkybox = sampleSkybox(SkyBoxDay4Sampler, direction);
                nightSkybox = sampleSkybox(SkyBoxNight4Sampler, direction);
                break;
        }

		float factor = smoothstep(-0.1, 0.1, timeOfDay);

		vec3 skyColor = mix(nightSkybox, daySkybox, factor);

		vec4 screenPos = gl_FragCoord;
        screenPos.xy = (screenPos.xy / OutSize - vec2(0.5)) * 2.0;
        screenPos.zw = vec2(1.0);
        vec3 view = normalize((projInv * screenPos).xyz);
        float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
        ndusq = ndusq * ndusq;

		vec4 finalColor = linear_fog(vec4(skyColor, 1), pow(1.0 - ndusq, 8.0), 0.0, 1.0, fogColor / fogColor.a);
		
		fragColor = vec4(mix(
			finalColor.rgb,
			fragColor.rgb,
			fragColor.a
		), 1);
		

	}
	
}
