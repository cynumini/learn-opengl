const std = @import("std");

const gl = @import("gl");

const renderer = @import("renderer.zig");

const Self = @This();

const VertexBufferElement = struct {
    count: i32,
    type: u32,
    normalized: u8,
    size_of_type: u32,
};

elements: std.ArrayList(VertexBufferElement),
stride: i32 = 0,

pub fn init(allocator: std.mem.Allocator) !Self {
    return .{
        .elements = std.ArrayList(VertexBufferElement).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.elements.deinit();
}

pub fn push(self: *Self, T: type, count: i32) !void {
    const element_type = switch (T) {
        f32 => gl.FLOAT,
        u32 => gl.UNSIGNED_INT,
        u8 => gl.UNSIGNED_BYTE,
        else => unreachable,
    };
    const normalized = if (element_type == gl.UNSIGNED_BYTE) gl.TRUE else gl.FALSE;
    try self.elements.append(.{
        .count = count,
        .normalized = normalized,
        .type = element_type,
        .size_of_type = @sizeOf(T),
    });
    self.stride = @sizeOf(T);
}

pub fn getElements(self: *const Self) *const std.ArrayList(VertexBufferElement) {
    return &self.elements;
}

pub fn getStride(self: Self) u32 {
    return self.stride;
}
