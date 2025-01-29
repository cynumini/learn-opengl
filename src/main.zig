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
    defer glfw.makeContextCurrent(null);

    if (!gl_procs.init(glfw.getProcAddress)) return error.GlInitFailed;

    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT);

        gl.Begin(gl.TRIANGLES);
        gl.Vertex2f(-0.5, -0.5);
        gl.Vertex2f(0.0, 0.5);
        gl.Vertex2f(0.5, -0.5);
        gl.End();

        printError();

        window.swapBuffers();

        glfw.pollEvents();
    }
}
