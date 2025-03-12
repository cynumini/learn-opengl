const std = @import("std");

const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

export fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: c_int, height: c_int) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: *c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
}

pub fn main() !void {
    _ = c.glfwInit();
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(800, 600, "LearnOpenGL", null, null) orelse {
        std.debug.print("Failed to create GLFW window\n", .{});
        c.glfwTerminate();
        return error.CantCreateGLFWWindow;
    };

    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.CantInitGLAD;
    }

    c.glViewport(0, 0, 800, 600);

    // render loop
    while (c.glfwWindowShouldClose(window) != 1) {
        // input
        processInput(window);

        // rendering commands here
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        // check and call events and swap the buffers
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}
