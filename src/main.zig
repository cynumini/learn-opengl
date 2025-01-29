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

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.DrawArrays(gl.TRIANGLES, 0, comptime positions.len / 2);

        window.swapBuffers();

        glfw.pollEvents();
    }
}
