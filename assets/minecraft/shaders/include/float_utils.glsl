#ifndef GOOD_PHANTOM_FLOAT_UTILS_GLSL
#define GOOD_PHANTOM_FLOAT_UTILS_GLSL

#define FPRECISION 4000000.0

// get screen coordinates of a particular control index
vec2 getControl(int index, vec2 screenSize) {
    return vec2(floor(screenSize.x / 2.0) + float(index) * 2.0 + 0.5, 0.5) / screenSize;
}

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec3 encodeInt(int i) {
    int s = int(i < 0) * 128;
    i = abs(i);
    int r = intmod(i, 256);
    i = i / 256;
    int g = intmod(i, 256);
    i = i / 256;
    int b = intmod(i, 128);
    return vec3(float(r) / 255.0, float(g) / 255.0, float(b + s) / 255.0);
}

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int s = ivec.b >= 128.0 ? -1 : 1;
    return s * (int(ivec.r) + int(ivec.g) * 256 + (int(ivec.b) - 64 + s * 64) * 256 * 256);
}

vec4 encodeFloat(float value) {
    uint iValue = floatBitsToUint(value);
    return vec4(
        iValue >> 24u,
        iValue >> 16u & 0xffu,
        iValue >>  8u & 0xffu,
        iValue        & 0xffu
    ) / 255.;
}

float decodeFloat(vec4 color) {
    uvec4 iColor = uvec4(round(color * 255.));
    uint iValue = iColor.r << 24 | iColor.g << 16 | iColor.b << 8 | iColor.a;
    return uintBitsToFloat(iValue);
}

#endif