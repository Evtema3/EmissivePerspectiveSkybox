#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:skybox_utils.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

layout(location = 0) in vec2 texCoord0;
layout(location = 1) in vec3 cscale;
layout(location = 2) in vec3 c1;
layout(location = 3) in vec3 c2;
layout(location = 4) in vec3 c3;
layout(location = 5) in float isSun;
layout(location = 6) in mat4 ProjInv;

layout(location = 0) out vec4 fragColor;

#define PRECISIONSCALE 1000.0
#define MAGICSUNSIZE 3.0

void main() {
	gl_FragDepth = gl_FragCoord.z;
    vec4 color = vec4(0.0);

    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    // currently in a control/message pixel
    if(index != -1) {
		gl_FragDepth = 1.0;
        // store the sun position in eye space indices [0,2]
        if (isSun > 0.75 && index >= 0 && index <= 2) {
            vec4 sunDir = ModelViewMat * vec4(normalize(c1 / cscale.x + c3 / cscale.z), 0.0);
            // color = encodeFloat(sunDir[index]);
        }
        else if (isSun < 0.25) {
            color = texture(Sampler0, texCoord0);
        }
    }

    // calculate screen space UV of the sun since it was transformed to cover the entire screen in vsh so texCoord0 no longer works
    else if(isSun > 0.75) {
        vec3 p1 = c1 / cscale.x;
        vec3 p2 = c2 / cscale.y;
        vec3 p3 = c3 / cscale.z;
        vec3 center = (p1 + p3) / (2 * PRECISIONSCALE); // scale down vector to reduce fp issues

        vec4 tmp = (ProjInv * vec4(2.0 * (gl_FragCoord.xy / ScreenSize - 0.5), 1.0, 1.0));
        vec3 planepos = tmp.xyz / tmp.w;
        float lookingat = dot(planepos, center);
        planepos = planepos / lookingat;
        vec2 uv = vec2(dot(p2 - p1, planepos - center), dot(p3 - p2, planepos - center));
        uv = uv / PRECISIONSCALE * MAGICSUNSIZE + vec2(0.5);

        // only draw one sun lol
        if (lookingat > 0.0 && all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
            color = texture(Sampler0, uv);
        }
    } else {
        color = texture(Sampler0, texCoord0);
    }

    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}