#ifndef SAKANA_GFX
#define SAKANA_GFX

#include "sakana.h"
#include <stdbool.h>

typedef struct Texture {
    uint id;
    int width;
    int height;
} Texture;

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

typedef vec4 Color;

#define SKN_RED (vec4){.r = 1, .b = 0, .g = 0, .a = 0}
#define RED SKN_RED
#define SKN_BLUE (vec4){.r = 0, .b = 1, .g = 0, .a = 0}
#define BLUE SKN_BLUE
#define SKN_GREEN (vec4){.r = 0, .b = 0, .g = 1, .a = 0}
#define GREEN SKN_GREEN

// init & deint
void skn_gfx_init(int width, int height, const char *title);
#define gfx_init skn_gfx_init
void skn_gfx_deinit(void);
#define gfx_deinit skn_gfx_deinit

// draw
bool skn_window_should_close(void);
#define window_shold_close skn_window_should_close
void skn_set_clear_color(Color color);
#define set_clear_color skn_set_clear_color
void skn_clear(void);
#define clear skn_clear
void skn_draw_begin(void);
#define draw_begin skn_draw_begin
void skn_draw_end(void);
#define draw_end skn_draw_end

// 3d
void skn_draw_plane(vec2 position, vec2 size, Texture texture);
#define draw_plane skn_draw_plane

// resource
Texture skn_load_texture(const char *filename);
#define load_texture skn_load_texture

#endif // SAKANA_GFX
