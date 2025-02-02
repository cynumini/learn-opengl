const std = @import("std");

const gl = @import("gl");

pub fn assert(ok: bool) void {
    if (!ok) @breakpoint();
}

pub fn glCall(func: anytype, args: anytype, src: std.builtin.SourceLocation) @TypeOf(@call(.auto, func, args)) {
    glClearError();
    const value = @call(.auto, func, args);
    assert(glLogCall(src));
    return value;
}

fn glClearError() void {
    while (gl.GetError() != gl.NO_ERROR) {}
}

fn glLogCall(src: std.builtin.SourceLocation) bool {
    const @"error" = gl.GetError();

    while (@"error" != gl.NO_ERROR) {
        std.debug.print("do I really work?\n", .{});
        std.debug.print("[OpenGL Error] ({}): {s} {s}:{}\n", .{ @"error", src.fn_name, src.file, src.line });
        return false;
    }
    return true;
}
