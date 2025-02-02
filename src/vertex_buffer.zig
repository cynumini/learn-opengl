const gl = @import("gl");

const renderer = @import("renderer.zig");

const Self = @This();

renderer_id: u32,

pub fn init(data: anytype, size: u32) Self {
    var renderer_id: u32 = undefined;
    renderer.glCall(gl.GenBuffers, .{ 1, @as([*]u32, @ptrCast(&renderer_id)) }, @src());
    renderer.glCall(gl.BindBuffer, .{ gl.ARRAY_BUFFER, renderer_id }, @src());
    renderer.glCall(gl.BufferData, .{ gl.ARRAY_BUFFER, size, data, gl.STATIC_DRAW }, @src());
    return .{ .renderer_id = renderer_id };
}

pub fn deinit(self: *Self) void {
    renderer.glCall(gl.DeleteBuffers, .{ 1, @as([*]u32, @ptrCast(&self.renderer_id)) }, @src());
}

pub fn bind(self: Self) void {
    renderer.glCall(gl.BindBuffer, .{ gl.ARRAY_BUFFER, self.renderer_id }, @src());
}

pub fn unbind(self: Self) void {
    _ = self;
    renderer.glCall(gl.BindBuffer, .{ gl.ARRAY_BUFFER, 0 }, @src());
}
