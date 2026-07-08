package learn_opengl

import "core:c"

import gl "vendor:OpenGL"
import "vendor:glfw"

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int) {
	gl.Viewport(0, 0, width, height)
}

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

main :: proc() {
	result := glfw.Init()
	assert(result == true)
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_COMPAT_PROFILE)

	window := glfw.CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "LearnOpenGL", nil, nil)
	assert(window != nil)
	defer glfw.DestroyWindow(window)

	glfw.MakeContextCurrent(window)

	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	shader_program, ok := gl.load_shaders("basic.vert", "basic.frag")
	assert(ok)
	defer gl.DeleteProgram(shader_program)

	vertices := [?]f32 {
		0.5,
		0.5,
		0.0, // top right
		0.5,
		-0.5,
		0.0, // bottom right
		-0.5,
		-0.5,
		0.0, // bottom left
		-0.5,
		0.5,
		0.0, // top left
	}

	indices := [?]u32 {
		0,
		1,
		3, // first triangle
		1,
		2,
		3, // second triangle
	}

	vbo, vao, ebo: u32

	gl.GenVertexArrays(1, &vao)
	defer gl.DeleteVertexArrays(1, &vao)

	gl.GenVertexArrays(1, &vbo)
	defer gl.DeleteVertexArrays(1, &vbo)

	gl.GenBuffers(1, &ebo)
	defer gl.DeleteBuffers(1, &ebo)

	// Setup or VAO
	{
		gl.BindVertexArray(vao) // first selected

		gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
		defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

		gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
		defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0) // unselect EBO

		gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

		gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(u32), 0)
		gl.EnableVertexAttribArray(0)

		gl.BindVertexArray(0) //first unselected
	}

	// Wireframe mode
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	// render loop
	for !glfw.WindowShouldClose(window) {
		// input
		if (glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS) {
			glfw.SetWindowShouldClose(window, true)
		}

		// rendering commands here
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(shader_program)
		gl.BindVertexArray(vao)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, rawptr(uintptr(0)))

		// check and call events and swap the buffers
		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

}
