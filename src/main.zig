const std = @import("std");

// const c = @cImport({
//     @cInclude("glad/glad.h");
//     @cInclude("GLFW/glfw3.h");
// });

const c = @import("sakana").c;
const glfw = @import("sakana").glfw;

export fn framebufferSizeCallback(window: ?*glfw.c.GLFWwindow, width: c_int, height: c_int) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: *glfw.c.GLFWwindow) void {
    if (glfw.c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        glfw.c.glfwSetWindowShouldClose(window, 1);
    }
}

const screenWidth = 800;
const screenHeight = 600;

const vertexShaderSource = @embedFile("basic.vert");
const fragmentShaderSource = @embedFile("basic.frag");

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    glfw.setupOpenGL(3, 3, .core_profile);

    const window = try glfw.Window.init(screenWidth, screenHeight, "LearnOpenGL");

    glfw.c.glfwMakeContextCurrent(window.window);
    _ = glfw.c.glfwSetFramebufferSizeCallback(window.window, framebufferSizeCallback);

    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.CantInitGLAD;
    }

    // Compile vertex shader
    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vertexShader, 1, @ptrCast(&vertexShaderSource), null);
    c.glCompileShader(vertexShader);

    var success: i32 = undefined;
    var infoLog: [512]u8 = undefined;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.debug.print("{s}", .{infoLog});
        return error.ShaderVertexCompilationFailed;
    }

    // Compile fragment shader
    const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fragmentShader, 1, @ptrCast(&fragmentShaderSource), null);
    c.glCompileShader(fragmentShader);

    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(fragmentShader, 512, null, &infoLog);
        std.debug.print("{s}", .{infoLog});
        return error.ShaderFragmentCompilationFailed;
    }

    const shaderProgram = c.glCreateProgram();
    defer c.glDeleteProgram(shaderProgram);

    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        c.glGetProgramInfoLog(shaderProgram, 512, null, &infoLog);
        std.debug.print("{s}", .{infoLog});
        return error.shaderProgramLinkError;
    }

    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);

    const vertices = [_]f32{
        0.5, 0.5, 0.0, // top right
        0.5, -0.5, 0.0, // bottom right
        -0.5, -0.5, 0.0, // bottom left
        -0.5, 0.5, 0.0, // top left
    };

    const indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };

    var VBO: u32, var VAO: u32, var EBO: u32 = .{ undefined, undefined, undefined };

    c.glGenVertexArrays(1, @ptrCast(&VAO));
    defer c.glDeleteVertexArrays(1, @ptrCast(&VAO));

    c.glGenBuffers(1, @ptrCast(&VBO));
    defer c.glDeleteBuffers(1, @ptrCast(&VBO));

    c.glGenBuffers(1, @ptrCast(&EBO));
    defer c.glDeleteBuffers(1, @ptrCast(&EBO));

    // Setup or VAO
    {
        c.glBindVertexArray(VAO); // first selected

        c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
        defer c.glBindBuffer(c.GL_ARRAY_BUFFER, 0); // unselect VBO

        c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, c.GL_STATIC_DRAW);

        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, EBO);
        defer c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, 0); // unselect EBO

        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(u32) * indices.len, &indices, c.GL_STATIC_DRAW);

        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
        c.glEnableVertexAttribArray(0);

        c.glBindVertexArray(0); // first unselected
    }

    // Wireframe mode
    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

    // render loop
    while (glfw.c.glfwWindowShouldClose(window.window) != 1) {
        // input
        processInput(window.window);

        // rendering commands here
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);
        c.glBindVertexArray(VAO);
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));

        // check and call events and swap the buffers
        glfw.c.glfwSwapBuffers(window.window);
        glfw.c.glfwPollEvents();
    }
}
