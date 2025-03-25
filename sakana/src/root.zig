const std = @import("std");

pub const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub const gl = @import("gl.zig");
pub const glfw = @import("glfw.zig");
