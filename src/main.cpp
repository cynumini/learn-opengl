#include <signal.h>
#include <stdio.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include "types.hpp"

/*static void debug_assert(bool ok) {*/
/*    if (!ok) raise(SIGTRAP);*/
/*}*/

struct ShaderProgramSource {
    const char* vertex;
};

static i32 GetLine(FILE* file, char* buffer) {
    usize i = 0;
    char c = 0;
    while ((c = (char)fgetc(file)) != '\n') {
        if (c == EOF) {
            buffer[i] = 0;
            return EOF;
        }
        buffer[i] = c;
        i++;
    }
    buffer[i] = 0;
    return 0;
}

static ShaderProgramSource InitShaderSourceProgram(const char* file_path) {
    FILE* file = fopen(file_path, "r");
    char buffer[256];
    while (GetLine(file, buffer) != EOF) {
        printf("line: %s\n", buffer);
    }
    fclose(file);
    return ShaderProgramSource{"I'm working"};
}

int main() {
    if (!glfwInit()) return -1;

    GLFWwindow* window = glfwCreateWindow(640, 480, "learn-opengl", NULL, NULL);
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

    const f32 positions[8] = {
        -0.5f, -0.5f,  //
        0.5f,  -0.5f,  //
        0.5f,  0.5f,   //
        -0.5f, 0.5f,   //
    };

    const u32 indices[] = {
        0, 1, 2,  //
        2, 3, 0,  //
    };

    u32 vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    u32 vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(f32), &positions, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(f32), nullptr);

    u32 ibo;
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(u32), &indices,
                 GL_STATIC_DRAW);

    const ShaderProgramSource source =
        InitShaderSourceProgram("res/shaders/basic.shader");
    printf("%s\n", source.vertex);

    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);
        glBindVertexArray(vao);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
