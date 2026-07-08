package learn_opengl

import "core:c"

import "vendor:glfw"
import gl "vendor:OpenGL"

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int) {
    gl.Viewport(0, 0, width, height);
}

main :: proc() {
    result := glfw.Init();
    assert(result == true)
    defer glfw.Terminate();

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_COMPAT_PROFILE)

    window := glfw.CreateWindow(800, 600, "LearnOpenGL", nil, nil)
    assert(window != nil)
    defer glfw.DestroyWindow(window)

    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback);

    glfw.MakeContextCurrent(window)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address);

    gl.Viewport(0, 0, 800, 600);

    // render loop
    for !glfw.WindowShouldClose(window) {
        // input
        if (glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS) {
            glfw.SetWindowShouldClose(window, true);
        }

        // rendering commands here
        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        // check and call events and swap the buffers
        glfw.SwapBuffers(window);
        glfw.PollEvents();
    }

}
