const std = @import("std");

const gl = @import("gl");

const renderer = @import("renderer.zig");

const Self = @This();

renderer_id: u32,
count: usize,

pub fn init(data: []const u32) Self {
    var renderer_id: u32 = undefined;
    renderer.glCall(gl.GenBuffers, .{ 1, @as([*]u32, @ptrCast(&renderer_id)) }, @src());
    renderer.glCall(gl.BindBuffer, .{ gl.ELEMENT_ARRAY_BUFFER, renderer_id }, @src());
    renderer.glCall(gl.BufferData, .{
        gl.ELEMENT_ARRAY_BUFFER,
        @as(isize, @intCast(data.len * @sizeOf(u32))),
        data.ptr,
        gl.STATIC_DRAW,
    }, @src());
    return .{ .renderer_id = renderer_id, .count = data.len };
}

pub fn deinit(self: *Self) void {
    renderer.glCall(gl.DeleteBuffers, .{ 1, @as([*]u32, @ptrCast(&self.renderer_id)) }, @src());
}

pub fn bind(self: Self) void {
    renderer.glCall(gl.BindBuffer, .{ gl.ELEMENT_ARRAY_BUFFER, self.renderer_id }, @src());
}

pub fn unbind(self: Self) void {
    _ = self;
    renderer.glCall(gl.BindBuffer, .{ gl.ELEMENT_ARRAY_BUFFER, 0 }, @src());
}
