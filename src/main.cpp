#include <signal.h>
#include <stdio.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

void assert(bool ok) {
    if (!ok) raise(SIGTRAP);
}

int main() {
    if (!glfwInit()) return -1;

    auto window = glfwCreateWindow(640, 480, "learn-opengl", NULL, NULL);
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

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
