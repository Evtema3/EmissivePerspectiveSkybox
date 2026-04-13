#version 420

// get screen coordinates of a particular control index
vec2 getControl(int index, vec2 screenSize) {
    return vec2(floor(screenSize.x / 2.0) + float(index) * 2.0 + 0.5, 0.5) / screenSize;
}

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec3 encodeUint(uint i) {
    return vec3(uvec3(i, i >> 8u, i >> 16u) & 255u) / 255.0;
}

uint decodeUint(vec3 ivec) {
    uvec3 raw = uvec3(ivec * 255.0);
    return raw.r | (raw.g << 8u) | (raw.b << 16u);
}

vec3 encodeFloat(float f) {
    uint sign = f < 0.0 ? 1u : 0u;
    float av = abs(f);

    int exp;
    float norm = frexp(av, exp);

    if (exp < -63) {
        exp = -63;
    } else if (exp > 64) {
        exp = 64;
    }

    norm *= 2.0;
    exp -= 1;

    uint mantissa = uint((norm - 1.0) * 65536.0);
    uint bits = (sign << 23) | (uint(exp + 63) << 16) | (mantissa & 0xFFFFu);
    return encodeUint(f == 0.0 ? 0u : bits);
}

float decodeFloat(vec3 packedFloat) {
    uint bits = decodeUint(packedFloat);

    if (bits == 0u) return 0.0;

    uint sign = (bits >> 23) & 0x1u;
    uint exponent = (bits >> 16) & 0x7Fu;
    uint mantissa = bits & 0xFFFFu;

    float mant = 1.0 + float(mantissa) / 65536.0;
    int exp = int(exponent) - 63;

    float value = ldexp(mant, exp);

    return sign != 0u ? -value : value;
}