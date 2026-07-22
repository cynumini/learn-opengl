#include "sakana_gfx.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include <glad/gl.h>

#include <GLFW/glfw3.h>

static GLFWwindow *skn_window;
static uint skn_program;

static void framebuffer_size_callback(GLFWwindow *window, int width,
                                      int height) {
    UNUSED(window);
    glViewport(0, 0, width, height);
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

void skn_gfx_init(int width, int height, const char *title) {
    assert(glfwInit() == GLFW_TRUE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    skn_window = glfwCreateWindow(width, height, title, NULL, NULL);
    assert(skn_window != NULL);
    glfwMakeContextCurrent(skn_window);
    glfwSetFramebufferSizeCallback(skn_window, framebuffer_size_callback);
    assert(gladLoadGL((GLADloadfunc)glfwGetProcAddress) != 0);

    skn_program = create_program("basic.vert", "basic.frag");

    uint vbo, vao;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);

    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float),
                          (void *)0);
    glEnableVertexAttribArray(0);
}

void skn_gfx_deinit(void) {
    glfwDestroyWindow(skn_window);
    glfwTerminate();
}

bool skn_window_should_close(void) { return glfwWindowShouldClose(skn_window); }

void skn_set_clear_color(Color color) {
    glClearColor(color.r, color.g, color.b, color.a);
}

void skn_clear(void) { glClear(GL_COLOR_BUFFER_BIT); }

void skn_draw_end(void) {
    glfwSwapBuffers(skn_window);
    glfwPollEvents();
}

void skn_draw_begin(void) {}

void skn_draw_plane(vec2 position, vec2 size, Texture texture) {
    UNUSED(position);
    UNUSED(size);
    UNUSED(texture);
    vec3 vertices[6] = {
        (vec3){.x = position.x, .y = position.y, .z = 0.0f},          // left
        (vec3){.x = position.x + size.x, .y = position.y, .z = 0.0f}, // right
        (vec3){.x = position.x, .y = position.y - size.y, .z = 0.0f},  // top

        (vec3){.x = position.x + size.x, .y = position.y, .z = 0.0f}, // right
        (vec3){.x = position.x, .y = position.y - size.y, .z = 0.0f},  // top
        (vec3){.x = position.x + size.x, .y = position.y - size.y, .z = 0.0f}    // top
    };
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glUseProgram(skn_program);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

Texture skn_load_texture(const char *filename) {
    UNUSED(filename);
    /* GLuint id; */
    /* glGenTextures(1, &id); */
    /* glBindTexture(GL_TEXTURE_2D, id); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); */
    /* int width, height, channels; */
    /* stbi_set_flip_vertically_on_load(true); */
    /* unsigned char *data = stbi_load(filename, &width, &height, &channels, 0);
     */
    /* assert(data); */
    /* glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, */
    /*              GL_UNSIGNED_BYTE, data); */
    /* glGenerateMipmap(GL_TEXTURE_2D); */
    /* stbi_image_free(data); */
    /* return id; */
    return (Texture){0};
}
