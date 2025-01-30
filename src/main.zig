const std = @import("std");

const gl = @import("gl");
const glfw = @import("mach-glfw");

var gl_procs: gl.ProcTable = undefined;

inline fn assert(ok: bool) void {
    if (!ok) @breakpoint();
}

inline fn glCall(func: anytype, args: anytype, src: std.builtin.SourceLocation) @TypeOf(@call(.auto, func, args)) {
    glClearError();
    const value = @call(.auto, func, args);
    assert(glLogCall(src));
    return value;
}

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

inline fn glClearError() void {
    while (gl.GetError() != gl.NO_ERROR) {}
}

inline fn glLogCall(src: std.builtin.SourceLocation) bool {
    const @"error" = gl.GetError();

    while (@"error" != gl.NO_ERROR) {
        std.debug.print("do I really work?\n", .{});
        std.debug.print("[OpenGL Error] ({}): {s} {s}:{}\n", .{ @"error", src.fn_name, src.file, src.line });
        return false;
        // @"error" = gl.GetError();
    }
    return true;
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

    const id = glCall(gl.CreateShader, .{@"type"}, @src());
    glCall(gl.ShaderSource, .{ id, 1, @as([*]const [*]const u8, &.{source.ptr}), null }, @src());
    glCall(gl.CompileShader, .{id}, @src());
    var result: i32 = undefined;
    glCall(gl.GetShaderiv, .{ id, gl.COMPILE_STATUS, &result }, @src());
    if (result == gl.FALSE) {
        var length: i32 = undefined;
        glCall(gl.GetShaderiv, .{ id, gl.INFO_LOG_LENGTH, &length }, @src());
        const message: []u8 = try allocator.alloc(u8, @intCast(length));
        glCall(gl.GetShaderInfoLog, .{ id, length, &length, message.ptr }, @src());
        const type_str = if (@"type" == gl.VERTEX_SHADER) "vertex" else "fragment";
        std.debug.print("Failed to compile {s} shader!\n{s}\n", .{ type_str, message });
        glCall(gl.DeleteShader, .{id}, @src());
        return error.FailedToCompileShader;
    }
    return id;
}

inline fn createShader(vertex_shader: []const u8, fragment_shader: []const u8) !u32 {
    const program = glCall(gl.CreateProgram, .{}, @src());

    const vs = try compileShader(gl.VERTEX_SHADER, vertex_shader);
    defer glCall(gl.DeleteShader, .{vs}, @src());

    const fs = try compileShader(gl.FRAGMENT_SHADER, fragment_shader);
    defer glCall(gl.DeleteShader, .{fs}, @src());

    glCall(gl.AttachShader, .{ program, vs }, @src());
    glCall(gl.AttachShader, .{ program, fs }, @src());
    glCall(gl.LinkProgram, .{program}, @src());
    glCall(gl.ValidateProgram, .{program}, @src());

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

    if (!gl_procs.init(glfw.getProcAddress)) return error.GlInitFailed;

    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    std.debug.print("{s}\n", .{glCall(gl.GetString, .{gl.VERSION}, @src()).?});

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

    var buffer: u32 = undefined;
    glCall(gl.GenBuffers, .{ 1, @as([*]u32, @ptrCast(&buffer)) }, @src());
    glCall(gl.BindBuffer, .{ gl.ARRAY_BUFFER, buffer }, @src());
    glCall(gl.BufferData, .{ gl.ARRAY_BUFFER, positions.len * @sizeOf(f32), &positions, gl.STATIC_DRAW }, @src());

    glCall(gl.EnableVertexAttribArray, .{0}, @src());
    glCall(gl.VertexAttribPointer, .{ 0, 2, gl.FLOAT, gl.FALSE, 2 * @sizeOf(f32), 0 }, @src());

    var ibo: u32 = undefined;
    glCall(gl.GenBuffers, .{ 1, @as([*]u32, @ptrCast(&ibo)) }, @src());
    glCall(gl.BindBuffer, .{ gl.ELEMENT_ARRAY_BUFFER, ibo }, @src());
    glCall(gl.BufferData, .{ gl.ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(u32), &indices, gl.STATIC_DRAW }, @src());

    var source = try ShaderProgramSource.init(allocator, "res/shaders/basic.shader");
    defer source.deinit();

    const shader = try createShader(source.vertex, source.fragment);
    defer glCall(gl.DeleteProgram, .{shader}, @src());

    glCall(gl.UseProgram, .{shader}, @src());

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        glCall(gl.Clear, .{gl.COLOR_BUFFER_BIT}, @src());
        glCall(gl.DrawElements, .{ gl.TRIANGLES, indices.len, gl.UNSIGNED_INT, 0 }, @src());

        window.swapBuffers();

        glfw.pollEvents();
    }
}
