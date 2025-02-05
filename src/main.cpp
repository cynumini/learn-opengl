#include <signal.h>
#include <stdio.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include "types.hpp"

/*static void debug_assert(bool ok) {*/
/*    if (!ok) raise(SIGTRAP);*/
/*}*/

int main() {
    if (!glfwInit()) return -1;

    const auto window = glfwCreateWindow(640, 480, "learn-opengl", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    if (glewInit() != GLEW_OK) {
        printf("Can't load glew");
        return -1;
    }

    printf("%s\n", glGetString(GL_VERSION));

    const f32 positions[] = {
        -0.5f, -0.5f,  //
        0.5f,  -0.5f,  //
        0.5f,  0.5f,   //
        -0.5f, 0.5f,   //
    };

    const u32 indices[] = {
        0, 1, 2,  //
        2, 3, 0,  //
    };

    u32 vao0;
    glGenVertexArrays(1, &vao0);
    glBindVertexArray(vao0);

    u32 buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(f32), &positions, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(f32), nullptr);

    u32 ibo;
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(u32), &indices,
                 GL_STATIC_DRAW);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);
        glBindVertexArray(vao0);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
