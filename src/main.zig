const std = @import("std");

const glfw = @import("sakana").glfw;
const gl = @import("sakana").gl;
const stb = @import("sakana").stb;
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
const screen_height = 800;

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
        // positions (3) colors (3) texture coords (2)
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom left
        -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top left
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

        VBO.vertexAttribPointer(0, 3, .float, false, 8 * @sizeOf(f32), @ptrFromInt(0));
        VBO.enableVertexAttribArray(0);

        VBO.vertexAttribPointer(1, 3, .float, false, 8 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));
        VBO.enableVertexAttribArray(1);

        VBO.vertexAttribPointer(2, 2, .float, false, 8 * @sizeOf(f32), @ptrFromInt(6 * @sizeOf(f32)));
        VBO.enableVertexAttribArray(2);

        VAO.unbind();
    }

    // texture
    var textures: [2]u32 = undefined;
    gl.c.glGenTextures(2, &textures);
    // set the texture wrapping/filtering options (on the currently bound texture object)
    for (0..2) |i| {
        gl.c.glBindTexture(gl.c.GL_TEXTURE_2D, textures[i]);
        gl.c.glTexParameteri(gl.c.GL_TEXTURE_2D, gl.c.GL_TEXTURE_WRAP_S, gl.c.GL_REPEAT);
        gl.c.glTexParameteri(gl.c.GL_TEXTURE_2D, gl.c.GL_TEXTURE_WRAP_T, gl.c.GL_REPEAT);
        gl.c.glTexParameteri(gl.c.GL_TEXTURE_2D, gl.c.GL_TEXTURE_MIN_FILTER, gl.c.GL_NEAREST);
        gl.c.glTexParameteri(gl.c.GL_TEXTURE_2D, gl.c.GL_TEXTURE_MAG_FILTER, gl.c.GL_NEAREST);
    }

    {
        var widths: [2]i32 = undefined;
        var heights: [2]i32 = undefined;
        var channels_in_files: [2]i32 = undefined;

        stb.c.stbi_set_flip_vertically_on_load(1);
        var data: [2][*c]u8 = undefined;
        data[0] = stb.c.stbi_load("fish.png", @ptrCast(&widths[0]), @ptrCast(&heights[0]), @ptrCast(&channels_in_files[0]), 4);
        data[1] = stb.c.stbi_load("b.jpg", @ptrCast(&widths[1]), @ptrCast(&heights[1]), @ptrCast(&channels_in_files[1]), 4);

        defer {
            for (0..2) |i| {
                stb.c.stbi_image_free(data[i]);
            }
        }

        for (0..2) |i| {
            gl.c.glBindTexture(gl.c.GL_TEXTURE_2D, textures[i]);
            gl.c.glTexImage2D(gl.c.GL_TEXTURE_2D, 0, gl.c.GL_RGBA, widths[i], heights[i], 0, gl.c.GL_RGBA, gl.c.GL_UNSIGNED_BYTE, data[i]);
            gl.c.glGenerateMipmap(gl.c.GL_TEXTURE_2D);
        }
    }

    shader.use();
    shader.setUniform1(i32, "texture1", 0);
    shader.setUniform1(i32, "texture2", 1);

    // Wireframe mode
    // gl.polygonMode(.line);

    // render loop
    while (!window.shouldClose()) {
        // input
        processInput(window);

        // rendering commands here
        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.color_buffer_bit);

        gl.c.glActiveTexture(gl.c.GL_TEXTURE0);
        gl.c.glBindTexture(gl.c.GL_TEXTURE_2D, textures[0]);
        gl.c.glActiveTexture(gl.c.GL_TEXTURE1);
        gl.c.glBindTexture(gl.c.GL_TEXTURE_2D, textures[1]);

        shader.use();
        VAO.bind();
        gl.drawElements(.triangles, 6, .unsigned_int);

        // check and call events and swap the buffers
        window.swapBuffers();
        glfw.pollEvents();
    }
}
