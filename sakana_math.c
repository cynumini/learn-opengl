#include "sakana_math.h"

mat4 skn_mat4_identity(void) {
    return (mat4){{
        {1, 0, 0, 0}, //
        {0, 1, 0, 0}, //
        {0, 0, 1, 0}, //
        {0, 0, 0, 1}, //
    }};
}

mat4 skn_mat4_translation(vec3 position) {
    return (mat4){{
        {1, 0, 0, 0},                            //
        {0, 1, 0, 0},                            //
        {0, 0, 1, 0},                            //
        {position.x, position.y, position.z, 1}, //
    }};
}

mat4 skn_mat4_multiplication(mat4 a, mat4 b) {
    mat4 result = {0};
    for (int col = 0; col < 4; col++) {
        for (int row = 0; row < 4; row++) {
            for (int i = 0; i < 4; i++) {
                result.m[col][row] += a.m[i][row] * b.m[col][i];
            }
        }
    }
    return result;
}
