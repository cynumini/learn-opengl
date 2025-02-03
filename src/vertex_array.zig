const gl = @import("gl");

const renderer = @import("renderer.zig");
const VertexBuffer = @import("vertex_buffer.zig");
const VertexBufferLayout = @import("vertex_buffer_layout.zig");

const Self = @This();

renderer_id: u32,

pub fn init() Self {
    var renderer_id: u32 = undefined;
    renderer.glCall(gl.GenVertexArrays, .{ 1, @as([*]u32, @ptrCast(&renderer_id)) }, @src());
    renderer.glCall(gl.BindVertexArray, .{renderer_id}, @src());
    return .{ .renderer_id = renderer_id };
}

pub fn deinit(self: *Self) void {
    renderer.glCall(gl.DeleteVertexArrays, .{ 1, @as([*]u32, @ptrCast(&self.renderer_id)) }, @src());
}

pub fn bind(self: Self) void {
    renderer.glCall(gl.BindVertexArray, .{self.renderer_id}, @src());
}

pub fn unbind(self: Self) void {
    _ = self;
    renderer.glCall(gl.BindVertexArray, .{0}, @src());
}

pub fn addBuffer(self: Self, vb: *const VertexBuffer, layout: *const VertexBufferLayout) void {
    self.bind();
    vb.bind();
    const elements = layout.getElements();
    var offset: u32 = 0;
    for (elements.items, 0..) |*element, i| {
        renderer.glCall(gl.EnableVertexAttribArray, .{@as(u32, @intCast(i))}, @src());
        renderer.glCall(gl.VertexAttribPointer, .{
            @as(u32, @intCast(i)),
            element.count,
            element.type,
            element.normalized,
            layout.stride,
            offset,
        }, @src());
        offset += element.size_of_type * @as(u32, @intCast(element.count));
    }
}
