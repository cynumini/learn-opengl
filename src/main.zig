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

fn compileShader(@"type": u32, source: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    const id = gl.CreateShader(@"type");
    gl.ShaderSource(id, 1, &.{source.ptr}, null);
    gl.CompileShader(id);
    var result: i32 = undefined;
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &result);
    if (result == gl.FALSE) {
        var length: i32 = undefined;
        gl.GetShaderiv(id, gl.INFO_LOG_LENGTH, &length);
        const message: []u8 = try allocator.alloc(u8, @intCast(length));
        gl.GetShaderInfoLog(id, length, &length, message.ptr);
        const type_str = if (@"type" == gl.VERTEX_SHADER) "vertex" else "fragment";
        std.debug.print("Failed to compile {s} shader!\n{s}\n", .{ type_str, message });
        gl.DeleteShader(id);
        return error.FailedToCompileShader;
    }
    return id;
}

fn createShader(vertex_shader: []const u8, fragment_shader: []const u8) !u32 {
    const program = gl.CreateProgram();

    const vs = try compileShader(gl.VERTEX_SHADER, vertex_shader);
    defer gl.DeleteShader(vs);

    const fs = try compileShader(gl.FRAGMENT_SHADER, fragment_shader);
    defer gl.DeleteShader(fs);

    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    gl.ValidateProgram(program);

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

    std.debug.print("{s}\n", .{gl.GetString(gl.VERSION).?});

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
    gl.GenBuffers(1, @ptrCast(&buffer));
    gl.BindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.BufferData(gl.ARRAY_BUFFER, positions.len * @sizeOf(f32), &positions, gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * @sizeOf(f32), 0);

    var ibo: u32 = undefined;
    gl.GenBuffers(1, @ptrCast(&ibo));
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(u32), &indices, gl.STATIC_DRAW);

    var source = try ShaderProgramSource.init(allocator, "res/shaders/basic.shader");
    defer source.deinit();

    const shader = try createShader(source.vertex, source.fragment);
    defer gl.DeleteProgram(shader);

    gl.UseProgram(shader);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.DrawArrays(gl.TRIANGLES, 0, comptime positions.len / 2);
        gl.DrawElements(gl.TRIANGLES, indices.len, gl.UNSIGNED_INT, 0);

        window.swapBuffers();

        glfw.pollEvents();
    }
}
