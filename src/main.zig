const std = @import("std");

const glfw = @import("sakana").glfw;
const gl = @import("sakana").gl;
const Shader = @import("sakana").Shader;

fn framebufferSizeCallback(window: glfw.Window, width: i32, height: i32) void {
    _ = window;
    gl.viewport(0, 0, width, height);
}

fn processInput(window: glfw.Window) void {
    if (window.getKey(.escape) == .press) {
        window.setShouldClose(true);
    }
}

const screen_width = 800;
const screen_height = 600;

const vertex_shader_source = @embedFile("basic.vert");
const fragment_shader_source = @embedFile("basic.frag");

pub fn main() !void {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer {
        _ = debug_allocator.deinit();
    }
    const allocator = debug_allocator.allocator();

    const std_err = std.io.getStdErr().writer();

    try glfw.init();
    defer glfw.deinit();

    glfw.setupOpenGL(3, 3, .core_profile);

    const window = try glfw.Window.init(screen_width, screen_height, "LearnOpenGL");

    window.makeContextCurrent();
    _ = window.setFramebufferSizeCallback(framebufferSizeCallback);

    try gl.init();

    const shader = try Shader.init(allocator, std_err, "basic.vert", "basic.frag");
    defer shader.deinit();

    const vertices = [_]f32{
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, // top right
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, // bottom left
        -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, // top left
    };

    const indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };

    const VAO = gl.VertexArray.init();
    defer VAO.deinit();

    const VBO = gl.Buffer.init(.array);
    defer VBO.deinit();
    const EBO = gl.Buffer.init(.element_array);
    defer EBO.deinit();

    // Setup or VAO
    {
        VAO.bind(); // first select

        VBO.bind();
        defer VBO.unbind();

        VBO.data(f32, &vertices);

        EBO.bind();
        defer EBO.unbind();

        EBO.data(u32, &indices);

        VBO.vertexAttribPointer(0, 3, .float, false, 6 * @sizeOf(f32), @ptrFromInt(0));
        VBO.enableVertexAttribArray(0);

        VBO.vertexAttribPointer(1, 3, .float, false, 6 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));
        VBO.enableVertexAttribArray(1);

        VAO.unbind();
    }

    // Wireframe mode
    // gl.polygonMode(.line);

    // render loop
    while (!window.shouldClose()) {
        // input
        processInput(window);

        // rendering commands here
        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.color_buffer_bit);

        shader.use();

        VAO.bind();
        gl.drawElements(.triangles, 6, .unsigned_int);

        // check and call events and swap the buffers
        window.swapBuffers();
        glfw.pollEvents();
    }
}
