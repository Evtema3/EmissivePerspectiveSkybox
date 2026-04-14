#version 420

#moj_import <shader_selector:marker_settings.vsh>
#moj_import <shader_selector:utils.vsh>

uniform sampler2D MainSampler;
uniform sampler2D MainDepthSampler;
uniform sampler2D DataSampler;
uniform sampler2D SkyBox1Sampler;
uniform sampler2D SkyBox2Sampler;
uniform sampler2D SkyBox3Sampler;
uniform sampler2D SkyBox4Sampler;
uniform sampler2D SkyBox5Sampler;
uniform sampler2D SkyBox6Sampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

in vec2 texCoord;
in vec2 oneTexel;
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

vec3 screenToPlayer(mat4 projInv, vec3 screen) {
    vec4 ndc = vec4(screen * 2.0 - 1.0, 1.0);
    vec4 temp = projInv * ndc;
    return temp.xyz / temp.w;
}

void main() {
	vec3 direction = normalize(screenToPlayer(projInv, vec3(texCoord, 1.0)) - screenToPlayer(projInv, vec3(texCoord, 0.0)));

	float realDepth = linearizeDepth(texture(MainDepthSampler, texCoord).r);
    fragColor = texture(MainSampler, texCoord);

	vec3 temp = fragColor.rgb - vec3(0.157, 0.024, 0.024);
	bool isNether = dot(temp, temp) < FUDGE;

	if (fogColor.rgb != vec3(0)) {
		
        float control_color = decodeColor(texelFetch(DataSampler, ivec2(4, SKYBOX_CHANNEL), 0));
        vec3 skyColor = sampleSkybox(SkyBox1Sampler, direction);

        switch(int(control_color * 255.)) {
            case 1:
                skyColor = sampleSkybox(SkyBox1Sampler, direction);
                break;
            case 2:
                skyColor = sampleSkybox(SkyBox2Sampler, direction);
                break;
            case 3:
                skyColor = sampleSkybox(SkyBox3Sampler, direction);
                break;
            case 4:
                skyColor = sampleSkybox(SkyBox4Sampler, direction);
                break;
			case 5:
                skyColor = sampleSkybox(SkyBox5Sampler, direction);
                break;
			case 6:
                skyColor = sampleSkybox(SkyBox6Sampler, direction);
                break;
        }

		float factor = smoothstep(-0.1, 0.1, timeOfDay);

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
