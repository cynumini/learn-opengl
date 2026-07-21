#ifndef PROGRAM_H
#define PROGRAM_H

#include <stdbool.h>

#include <glad/gl.h>

#include <GLFW/glfw3.h>

#define UNREACHABLE() _unreachable(__FILE__, __LINE__);

void _unreachable(const char *file, int line);

typedef struct State {
    GLFWwindow *window;
} State;

State init(int width, int height);
void deinit(State state);
GLuint create_program(const char *vs_path, const char *fs_path);
GLuint load_texture(const char *filename);
bool window_should_close(State state);
void draw_end(State state);



#endif // PROGRAM_H
