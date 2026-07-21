#include "program.h"

#include <GLFW/glfw3.h>
#include <assert.h>
#include <stb_image.h>
#include <stdio.h>
#include <stdlib.h>

void _unreachable(const char *file, int line) {
    fprintf(stderr, "%s:%d: unreachable\n", file, line);
    abort();
}

#define UNUSED(variable) ((void)variable)

static void framebuffer_size_callback(GLFWwindow *window, int width,
                                      int height) {
    UNUSED(window);
    glViewport(0, 0, width, height);
}

State init(int width, int height) {
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window =
        glfwCreateWindow(width, height, "LearnOpenGL", NULL, NULL);
    assert(window != NULL);
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    assert(gladLoadGL((GLADloadfunc)glfwGetProcAddress) != 0);
    return (State){.window = window};
}

void deinit(State state) {
    glfwDestroyWindow(state.window);
    glfwTerminate();
}

bool window_should_close(State state) {
    return glfwWindowShouldClose(state.window);
}

void draw_end(State state) {
    glfwSwapBuffers(state.window);
    glfwPollEvents();
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

static char *read_file_alloc(const char *filename) {
    FILE *file = fopen(filename, "r");
    assert(file != NULL);
    assert(fseek(file, 0, SEEK_END) == 0);
    size_t size = ftell(file);
    rewind(file);
    char *buffer = malloc(size + 1);
    assert(fread(buffer, 1, size, file) == size);
    fclose(file);
    buffer[size] = 0;
    return buffer;
}

GLuint create_program(const char *vs_filename, const char *fs_filename) {

    char *vs_code = read_file_alloc(vs_filename);
    GLuint vs = create_shader(GL_VERTEX_SHADER, vs_code);
    free(vs_code);

    char *fs_code = read_file_alloc(fs_filename);
    GLuint fs = create_shader(GL_FRAGMENT_SHADER, fs_code);
    free(fs_code);

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

GLuint load_texture(const char *filename) {
    GLuint id;
    glGenTextures(1, &id);
    glBindTexture(GL_TEXTURE_2D, id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    int width, height, channels;
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data = stbi_load(filename, &width, &height, &channels, 0);
    assert(data);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);
    stbi_image_free(data);
    return id;
}
