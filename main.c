#include "sakana_gfx.h"

int main(void) {
    gfx_init(800, 800, "LearnOpenGL");

    Texture texture = load_texture("fish.png");

    set_clear_color(BLUE);

    float x = -1;

    while (!window_shold_close()) {
        // update
        x += 0.001;
        // draw
        draw_begin();
        clear();
        draw_plane((vec2){.x = x, .y = 0.25}, (vec2){.x = 0.5, .y = 0.5},
                   texture);
        draw_end();
    }

    gfx_deinit();
    return 0;
}
