#include <assert.h>
#include <stdbool.h>

#include <glad/gl.h>
#include <GLFW/glfw3.h>

#define UNUSED(variable) ((void)variable)

// glfw: whenever the window size changed (by OS or user resize) this
// callback function executes
// ------------------------------------------------------------------
static void framebuffer_size_callback(GLFWwindow *window, int width,
                                      int height) {
    UNUSED(window);
    // make sure the viewport matches the new window dimensions; note
    // that width and height will be significantly larger than
    // specified on retina displays.
    glViewport(0, 0, width, height);
}


// process all input: query GLFW whether relevant keys are
// pressed/released this frame and react accordingly
// -------------------------------------------------------
static void process_input(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

// settings
const int SCR_WIDTH = 800;
const int SCR_HEIGHT = 600;

int main(void) {
    // glfw: initialize and configure
    // ------------------------------
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // glfw window creation
    // --------------------
    GLFWwindow *window =
        glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    assert(window != NULL);
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // glad: load all OpenGL function pointers
    // ---------------------------------------
    assert(gladLoadGL((GLADloadfunc)glfwGetProcAddress) != 0);

    // render loop
    // -----------
    while (!glfwWindowShouldClose(window))
    {
        // input
        // -----
        process_input(window);

        // glfw: swap buffers and poll IO events (keys
        // pressed/released, mouse moved etc.)
        // -------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // glfw: terminate, clearing all previously allocated GLFW
    // resources.
    // -------------------------------------------------------
    glfwTerminate();
    return 0;
}
