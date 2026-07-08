package learn_opengl

import "core:c"
import "core:math"

import gl "vendor:OpenGL"
import "vendor:glfw"
import stbi "vendor:stb/image"

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
		// positions (3) colors (3) texture coords (2)
		0.5,
		0.5,
		0.0,
		1.0,
		0.0,
		0.0,
		1.0,
		1.0, // top right
		0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0,
		1.0,
		0.0, // bottom right
		-0.5,
		-0.5,
		0.0,
		0.0,
		0.0,
		1.0,
		0.0,
		0.0, // bottom left
		-0.5,
		0.5,
		0.0,
		1.0,
		1.0,
		0.0,
		0.0,
		1.0, // top left
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

		gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 8 * size_of(u32), 0)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 8 * size_of(f32), uintptr(3 * size_of(f32)))
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(2, 2, gl.FLOAT, false, 8 * size_of(f32), uintptr(6 * size_of(f32)))
		gl.EnableVertexAttribArray(2)

		gl.BindVertexArray(0) //first unselected
	}

	textures: [2]u32
	gl.GenTextures(2, raw_data(&textures))

	for i in textures {
		gl.BindTexture(gl.TEXTURE_2D, i)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
		gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	}

	{
		widths: [2]i32
		heights: [2]i32
		channels_in_files: [2]i32

		stbi.set_flip_vertically_on_load(1)
		data: [2][^]byte

		data[0] = stbi.load("fish.png", &widths[0], &heights[0], &channels_in_files[0], 4)
		defer stbi.image_free(data[0])

		data[1] = stbi.load("work.png", &widths[1], &heights[1], &channels_in_files[1], 4)
		defer stbi.image_free(data[1])

		for i in 0..<2 {
			gl.BindTexture(gl.TEXTURE_2D, textures[i])
			gl.TexImage2D(
				gl.TEXTURE_2D,
				0,
				gl.RGBA,
				widths[i],
				heights[i],
				0,
				gl.RGBA,
				gl.UNSIGNED_BYTE,
				data[i],
			)
			gl.GenerateMipmap(gl.TEXTURE_2D)
		}
	}

	gl.UseProgram(shader_program)
	location := gl.GetUniformLocation(shader_program, "texture1")
	gl.Uniform1i(location, 0)
	location = gl.GetUniformLocation(shader_program, "texture2")
	gl.Uniform1i(location, 1)

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

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, textures[0])
		gl.ActiveTexture(gl.TEXTURE1)
		gl.BindTexture(gl.TEXTURE_2D, textures[1])

		gl.BindVertexArray(vao)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, rawptr(uintptr(0)))

		// check and call events and swap the buffers
		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

}
