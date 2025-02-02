const std = @import("std");

const gl = @import("gl");
const glfw = @import("mach-glfw");

const renderer = @import("renderer.zig");
const VertexBuffer = @import("vertex_buffer.zig");
const IndexBuffer = @import("index_buffer.zig");

var gl_procs: gl.ProcTable = undefined;

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

const ShaderProgramSource = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    vertex: []const u8,
    fragment: []const u8,

    fn init(allocator: std.mem.Allocator, file_path: []const u8) !ShaderProgramSource {
        const ShaderType = enum(i8) {
            none = -1,
            vertex = 0,
            fragment = 1,
        };

        var file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        var shader_type = ShaderType.none;
        var shaders = [_]std.ArrayList(u8){
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
        };

        while (true) {
            var line = std.ArrayList(u8).init(allocator);
            defer line.deinit();

            file.reader().streamUntilDelimiter(line.writer(), '\n', null) catch |@"error"| switch (@"error") {
                error.EndOfStream => break,
                else => |e| return e,
            };

            if (std.mem.eql(u8, line.items, "#shader vertex")) {
                shader_type = .vertex;
            } else if (std.mem.eql(u8, line.items, "#shader fragment")) {
                shader_type = .fragment;
            } else {
                try shaders[@intCast(@intFromEnum(shader_type))].appendSlice(line.items);
                try shaders[@intCast(@intFromEnum(shader_type))].append('\n');
            }
        }

        inline for (0..2) |i| try shaders[i].append(0);

        return .{
            .allocator = allocator,
            .vertex = try shaders[0].toOwnedSlice(),
            .fragment = try shaders[1].toOwnedSlice(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.vertex);
        self.allocator.free(self.fragment);
    }
};

inline fn compileShader(@"type": u32, source: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const id = renderer.glCall(gl.CreateShader, .{@"type"}, @src());
    renderer.glCall(gl.ShaderSource, .{ id, 1, @as([*]const [*]const u8, &.{source.ptr}), null }, @src());
    renderer.glCall(gl.CompileShader, .{id}, @src());
    var result: i32 = undefined;
    renderer.glCall(gl.GetShaderiv, .{ id, gl.COMPILE_STATUS, &result }, @src());
    if (result == gl.FALSE) {
        var length: i32 = undefined;
        renderer.glCall(gl.GetShaderiv, .{ id, gl.INFO_LOG_LENGTH, &length }, @src());
        const message: []u8 = try allocator.alloc(u8, @intCast(length));
        renderer.glCall(gl.GetShaderInfoLog, .{ id, length, &length, message.ptr }, @src());
        const type_str = if (@"type" == gl.VERTEX_SHADER) "vertex" else "fragment";
        std.debug.print("Failed to compile {s} shader!\n{s}\n", .{ type_str, message });
        renderer.glCall(gl.DeleteShader, .{id}, @src());
        return error.FailedToCompileShader;
    }
    return id;
}

inline fn createShader(vertex_shader: []const u8, fragment_shader: []const u8) !u32 {
    const program = renderer.glCall(gl.CreateProgram, .{}, @src());

    const vs = try compileShader(gl.VERTEX_SHADER, vertex_shader);
    defer renderer.glCall(gl.DeleteShader, .{vs}, @src());

    const fs = try compileShader(gl.FRAGMENT_SHADER, fragment_shader);
    defer renderer.glCall(gl.DeleteShader, .{fs}, @src());

    renderer.glCall(gl.AttachShader, .{ program, vs }, @src());
    renderer.glCall(gl.AttachShader, .{ program, fs }, @src());
    renderer.glCall(gl.LinkProgram, .{program}, @src());
    renderer.glCall(gl.ValidateProgram, .{program}, @src());

    return program;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

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
    glfw.swapInterval(1);

    if (!gl_procs.init(glfw.getProcAddress)) return error.GlInitFailed;

    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    std.debug.print("{s}\n", .{renderer.glCall(gl.GetString, .{gl.VERSION}, @src()).?});

    const positions = [_]f32{
        -0.5, -0.5,
        0.5,  -0.5,
        0.5,  0.5,
        -0.5, 0.5,
    };

    const indices = [_]u32{
        0, 1, 2,
        2, 3, 0,
    };

    var vao: u32 = undefined;
    renderer.glCall(gl.GenVertexArrays, .{ 1, @as([*]u32, @ptrCast(&vao)) }, @src());
    renderer.glCall(gl.BindVertexArray, .{vao}, @src());

    var vb = VertexBuffer.init(&positions, positions.len * @sizeOf(f32));
    defer vb.deinit();

    renderer.glCall(gl.EnableVertexAttribArray, .{0}, @src());
    renderer.glCall(gl.VertexAttribPointer, .{ 0, 2, gl.FLOAT, gl.FALSE, 2 * @sizeOf(f32), 0 }, @src());

    var ib = IndexBuffer.init(&indices);
    defer ib.deinit();

    var source = try ShaderProgramSource.init(allocator, "res/shaders/basic.shader");
    defer source.deinit();

    const shader = try createShader(source.vertex, source.fragment);
    defer renderer.glCall(gl.DeleteProgram, .{shader}, @src());

    renderer.glCall(gl.UseProgram, .{shader}, @src());

    const location = renderer.glCall(gl.GetUniformLocation, .{ shader, "u_Color" }, @src());
    renderer.assert(location != -1);

    renderer.glCall(gl.BindVertexArray, .{0}, @src());
    renderer.glCall(gl.UseProgram, .{0}, @src());
    renderer.glCall(gl.BindBuffer, .{ gl.ARRAY_BUFFER, 0 }, @src());
    renderer.glCall(gl.BindBuffer, .{ gl.ELEMENT_ARRAY_BUFFER, 0 }, @src());

    var r: f32 = 0;
    var increment: f32 = 0.02;

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        renderer.glCall(gl.Clear, .{gl.COLOR_BUFFER_BIT}, @src());

        renderer.glCall(gl.UseProgram, .{shader}, @src());
        renderer.glCall(gl.Uniform4f, .{ location, r, 0.3, 0.8, 1.0 }, @src());

        renderer.glCall(gl.BindVertexArray, .{vao}, @src());
        ib.bind();
        renderer.glCall(gl.DrawElements, .{ gl.TRIANGLES, indices.len, gl.UNSIGNED_INT, 0 }, @src());

        if (r > 1.0 or r < 0) increment *= -1;
        r += increment;

        window.swapBuffers();

        glfw.pollEvents();
    }
}
