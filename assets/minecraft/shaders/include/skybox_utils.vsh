#version 330

#moj_import <minecraft:float_utils.vsh>

#define NUMCONTROLS 40
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
[5] ProjMat[0][0]
[6] ProjMat[0][1]
[7] ProjMat[0][2]
[8] ProjMat[0][3]
[9] ProjMat[1][0]
[10] ProjMat[1][1]
[11] ProjMat[1][2]
[12] ProjMat[1][3]
[13] ProjMat[2][0]
[14] ProjMat[2][1]
[15] ProjMat[2][2]
[16] ProjMat[2][3]
[17] ProjMat[3][0]
[18] ProjMat[3][1]
[19] ProjMat[3][2]
[20] ProjMat[3][3]
[21] ModelViewMat[0][0]
[22] ModelViewMat[0][1]
[23] ModelViewMat[0][2]
[24] ModelViewMat[1][0]
[25] ModelViewMat[1][1]
[26] ModelViewMat[1][2]
[27] ModelViewMat[2][0]
[28] ModelViewMat[2][1]
[29] ModelViewMat[2][2]
[30] FogColor
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