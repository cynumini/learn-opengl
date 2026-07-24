#include "sakana_gfx.h"

int main(void) {
    gfx_init(800, 800, "LearnOpenGL");

    Texture texture = load_texture("fish.png");

    set_clear_color(BLUE);


    vec3 vertices[6] = {
        {.x = -0.5, .y = 0.5, .z = 0},  //
        {.x = 0.5, .y = 0.5, .z = 0},   //
        {.x = -0.5, .y = -0.5, .z = 0}, //
        {.x = 0.5, .y = 0.5, .z = 0},   //
        {.x = -0.5, .y = -0.5, .z = 0}, //
        {.x = 0.5, .y = -0.5, .z = 0},  //
    };
    vec3 position = {.x = 0, .y = 0, .z = 0};
    // vec2 size = {.x = 0.5, .y = 0.5};

    while (!window_shold_close()) {
        // update
        position.x += 0.001;
        // draw
        draw_begin();
        clear();
        draw_vertices(vertices, 6, position);
        draw_end();
    }

    gfx_deinit();
    return 0;
}
