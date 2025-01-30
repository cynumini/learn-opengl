const std = @import("std");

const gl = @import("gl");
const glfw = @import("mach-glfw");

var gl_procs: gl.ProcTable = undefined;

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

fn printError() void {
    const gl_error = gl.GetError();
    if (gl_error != 0) {
        std.debug.print("{}\n", .{gl_error});
    }
}

fn compileShader(@"type": u32, source: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const id = gl.CreateShader(@"type");
    gl.ShaderSource(id, 1, &.{source.ptr}, null);
    gl.CompileShader(id);
    var result: i32 = undefined;
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &result);
    if (result == gl.FALSE) {
        var length: i32 = undefined;
        gl.GetShaderiv(id, gl.INFO_LOG_LENGTH, &length);
        const message: []u8 = try allocator.alloc(u8, @intCast(length));
        gl.GetShaderInfoLog(id, length, &length, message.ptr);
        const type_str = if (@"type" == gl.VERTEX_SHADER) "vertex" else "fragment";
        std.debug.print("Failed to compile {s} shader!\n{s}\n", .{ type_str, message });
        gl.DeleteShader(id);
        return error.FailedToCompileShader;
    }
    return id;
}

fn createShader(vertex_shader: []const u8, fragment_shader: []const u8) !u32 {
    const program = gl.CreateProgram();

    const vs = try compileShader(gl.VERTEX_SHADER, vertex_shader);
    defer gl.DeleteShader(vs);

    const fs = try compileShader(gl.FRAGMENT_SHADER, fragment_shader);
    defer gl.DeleteShader(fs);

    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    gl.ValidateProgram(program);

    return program;
}

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{ .platform = .wayland })) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        return error.GlfwInitFailed;
    }
    defer glfw.terminate();

    // Create our window
    const window = glfw.Window.create(640, 480, "Hello, mach-glfw!", null, null, .{}) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        return error.GlfwWindowCreateFailed;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    if (!gl_procs.init(glfw.getProcAddress)) return error.GlInitFailed;

    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    std.debug.print("{s}\n", .{gl.GetString(gl.VERSION).?});

    const positions = [_]f32{
        -0.5, -0.5,
        0.0,  0.5,
        0.5,  -0.5,
    };

    var buffer: gl.uint = undefined;
    gl.GenBuffers(1, @ptrCast(&buffer));
    gl.BindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.BufferData(gl.ARRAY_BUFFER, positions.len * @sizeOf(f32), &positions, gl.STATIC_DRAW);
    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * @sizeOf(f32), 0);

    const vertex_shader = @embedFile("shader.vert");
    const fragment_shader = @embedFile("shader.frag");

    const shader = try createShader(vertex_shader, fragment_shader);
    defer gl.DeleteProgram(shader);

    gl.UseProgram(shader);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.DrawArrays(gl.TRIANGLES, 0, comptime positions.len / 2);

        window.swapBuffers();

        glfw.pollEvents();
    }
}
