#ifndef SAKANA_MATH
#define SAKANA_MATH

typedef union skn_vec2 {
    struct {
        float x;
        float y;
    };
    float v[2];
} skn_vec2;
#define vec2 skn_vec2

typedef union skn_vec3 {
    struct {
        float x;
        float y;
        float z;
    };
    float v[3];
} skn_vec3;
#define vec3 skn_vec3

typedef union skn_vec4 {
    struct {
        float x;
        float y;
        float z;
        float w;
    };
    struct {
        float r;
        float g;
        float b;
        float a;
    };
    float v[4];
} skn_vec4;
#define vec4 skn_vec4

typedef struct skn_mat4 {
    float m[4][4];
} skn_mat4;
#define mat4 skn_mat4

mat4 skn_mat4_identity(void);
#define mat4_identity skn_mat4_identity

mat4 skn_mat4_translation(vec3 position);
#define mat4_translation skn_mat4_translation

mat4 skn_mat4_multiplication(mat4 a, mat4 b);
#define mat4_multiplication skn_mat4_multiplication

#endif // SAKANA_MATH
