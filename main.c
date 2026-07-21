#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include <glad/gl.h>

#include <GLFW/glfw3.h>

#define UNUSED(variable) ((void)variable)
#define UNREACHABLE() _unreachable(__FILE__, __LINE__);

static void _unreachable(const char *file, int line) {
    fprintf(stderr, "%s:%d: unreachable\n", file, line);
    abort();
}

static void framebuffer_size_callback(GLFWwindow *window, int width,
                                      int height) {
    UNUSED(window);
    glViewport(0, 0, width, height);
}

static void process_input(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

static GLuint create_shader(GLenum type, const char *shader_source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &shader_source, NULL);
    glCompileShader(shader);
    int success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        int size;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &size);
        char *info_log = malloc(size);
        glGetShaderInfoLog(shader, size, NULL, info_log);
        const char *type_name = NULL;
        if (type == GL_VERTEX_SHADER) {
            type_name = "VERTEX";
        } else if (type == GL_FRAGMENT_SHADER) {
            type_name = "FRAGMENT";
        } else {
            UNREACHABLE();
        }
        printf("ERROR::SHADER::%s::COMPILATION_FAILED\n%s\n", type_name,
               info_log);
        UNREACHABLE();
    }
    return shader;
}

static GLuint create_program(const char *vs_code, const char *fs_code) {
    GLuint vs = create_shader(GL_VERTEX_SHADER, vs_code);
    GLuint fs = create_shader(GL_FRAGMENT_SHADER, fs_code);
    int success;
    GLuint program = glCreateProgram();
    glAttachShader(program, vs);
    glAttachShader(program, fs);
    glLinkProgram(program);
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        int size = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &size);
        char *info_log = malloc(size);
        glGetProgramInfoLog(program, size, NULL, info_log);
        if (size == 0)
            info_log = NULL;
        printf("ERROR::SHADER::PROGRAM::COMPILATION_FAILED\n%s\n", info_log);
        UNREACHABLE();
    }
    glDeleteShader(vs);
    glDeleteShader(fs);
    return program;
}

static const int SCR_WIDTH = 800;
static const int SCR_HEIGHT = 600;

const char *vertex_shader_source =
    "#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}";

const char *fragment_shader_source =
    "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}";

int main(void) {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window =
        glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    assert(window != NULL);
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    assert(gladLoadGL((GLADloadfunc)glfwGetProcAddress) != 0);

    GLuint shader_program =
        create_program(vertex_shader_source, fragment_shader_source);

    float vertices[] = {
        0.5f,  0.5f,  0.0f, // top right
        0.5f,  -0.5f, 0.0f, // bottom right
        -0.5f, -0.5f, 0.0f, // bottom left
        -0.5f, 0.5f,  0.0f  // top left
    };
    unsigned int indices[] = {
        0, 1, 3, // first Triangle
        1, 2, 3  // second Triangle
    };
    GLuint vbo, vao, ebo;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);
    glGenBuffers(1, &ebo);

    {
        glBindVertexArray(vao);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices,
                     GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices,
                     GL_STATIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float),
                              (void *)0);
        glEnableVertexAttribArray(0);

        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    while (!glfwWindowShouldClose(window)) {
        process_input(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shader_program);
        glBindVertexArray(vao);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteVertexArrays(1, &vao);
    glDeleteBuffers(1, &vbo);
    glDeleteProgram(shader_program);

    glfwTerminate();
    return 0;
}
