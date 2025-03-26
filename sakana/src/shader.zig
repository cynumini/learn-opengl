const std = @import("std");
const gl = @import("gl.zig");

program: gl.ShaderProgram,
const Self = @This();

pub fn init(allocator: std.mem.Allocator, writer: std.fs.File.Writer, vertex_path: []const u8, fragment_path: []const u8) !Self {
    const program = gl.ShaderProgram.init();

    // vertex source
    const vertex_file = try std.fs.cwd().openFile(vertex_path, .{ .mode = .read_only });
    defer vertex_file.close();
    var vertex_source = try vertex_file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(vertex_source);
    vertex_source = try allocator.realloc(vertex_source, vertex_source.len + 1);
    vertex_source[vertex_source.len - 1] = 0;

    // fragment source
    const fragment_file = try std.fs.cwd().openFile(fragment_path, .{ .mode = .read_only });
    defer fragment_file.close();
    var fragment_source = try fragment_file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(fragment_source);
    fragment_source = try allocator.realloc(fragment_source, fragment_source.len + 1);
    fragment_source[fragment_source.len - 1] = 0;

    // compile vertex shader
    const vertex_shader = gl.Shader.init(.vertex_shader);
    defer vertex_shader.deinit();
    vertex_shader.source(vertex_source);
    try vertex_shader.compile(writer);

    // Ccmpile fragment shader
    const fragment_shader = gl.Shader.init(.fragment_shader);
    defer fragment_shader.deinit();
    fragment_shader.source(fragment_source);
    try fragment_shader.compile(writer);

    // attach and link
    program.attachShader(vertex_shader);
    program.attachShader(fragment_shader);
    try program.link(writer);

    return .{ .program = program };
}

pub fn deinit(self: Self) void {
    self.program.deinit();
}

pub fn use(self: Self) void {
    self.program.use();
}

pub fn setUniform1(self: Self, T: type, name: []const u8, value: T) void {
    comptime switch (T) {
        .bool => self.program.getUniform(name).set1i(@intFromBool(value)),
        .i32 => self.program.getUniform(name).set1i(value),
        .f32 => self.program.getUniform(name).set1f(value),
    };
}
