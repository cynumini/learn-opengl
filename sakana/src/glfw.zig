pub const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub fn init() !void {
    if (c.glfwInit() != c.GLFW_TRUE) return error.GLFWInitError;
}

pub fn terminate() void {
    c.glfwTerminate();
}

const OpenGLProfile = enum(i32) {
    core_profile = c.GLFW_OPENGL_CORE_PROFILE,
    compat_profile = c.GLFW_OPENGL_COMPAT_PROFILE,
    any_profile = c.GLFW_OPENGL_ANY_PROFILE,
};

pub fn setupOpenGL(context_version_major: i32, context_version_minor: i32, opengl_profile: OpenGLProfile) void {
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, context_version_major);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, context_version_minor);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, @intFromEnum(opengl_profile));
}

pub const Window = struct {
    window: *c.GLFWwindow,

    const Self = @This();

    pub fn init(width: i32, height: i32, title: []const u8) !Self {
        const window = c.glfwCreateWindow(width, height, title.ptr, null, null) orelse {
            return error.GLFWCreateWindowError;
        };
        return .{ .window = window };
    }
};
