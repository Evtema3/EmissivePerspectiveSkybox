#ifndef GOOD_PHANTOM_SKYBOX_UTILS_GLSL
#define GOOD_PHANTOM_SKYBOX_UTILS_GLSL

#include <minecraft:float_utils.glsl>

#define FAKEFOG 1
#define NUMCONTROLS 23
#define THRESH 0.5
#define FPRECISION 4000000.0
#define PROJNEAR 0.05

/*
Control Map:
[0] sunDir.x
[1] sunDir.y
[2] sunDir.z
[3] arctan(ProjMat[0][0])
[4] arctan(ProjMat[1][1])
[5] IProjViewMat[0][0]
[6] IProjViewMat[0][1]
[7] IProjViewMat[0][2]
[8] IProjViewMat[0][3]
[9] IProjViewMat[1][0]
[10] IProjViewMat[1][1]
[11] IProjViewMat[1][2]
[12] IProjViewMat[1][3]
[13] IProjViewMat[2][0]
[14] IProjViewMat[2][1]
[15] IProjViewMat[2][2]
[16] IProjViewMat[2][3]
[17] IProjViewMat[3][0]
[18] IProjViewMat[3][1]
[19] IProjViewMat[3][2]
[20] IProjViewMat[3][3]
[21] FogColor
[22] BaseColor
*/

// returns control pixel index or -1 if not control
int inControl(vec2 screenCoord, float screenWidth) {
    if (screenCoord.y < 1.0) {
        float index = floor(screenWidth / 2.0) + THRESH / 2.0;
        index = (screenCoord.x - index) / 2.0;
        if (fract(index) < THRESH && index < NUMCONTROLS && index >= 0) {
            return int(index);
        }
    }
    return -1;
}

// discards the current pixel if it is control
void discardControl(vec2 screenCoord, float screenWidth) {
    if (screenCoord.y < 1.0) {
        float index = floor(screenWidth / 2.0) + THRESH / 2.0;
        index = (screenCoord.x - index) / 2.0;
        if (fract(index) < THRESH && index < NUMCONTROLS && index >= 0) {
            discard;
        }
    }
}

// discard but for when ScreenSize is not given
void discardControlGLPos(vec2 screenCoord, vec4 glpos) {
    if (screenCoord.y < 1.0) {
        float screenWidth = round(screenCoord.x * 2.0 / (glpos.x / glpos.w + 1.0));
        float index = floor(screenWidth / 2.0) + THRESH / 2.0;
        index = (screenCoord.x - index) / 2.0;
        if (fract(index) < THRESH && index < NUMCONTROLS && index >= 0) {
            discard;
        }
    }
}

#endif