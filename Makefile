debug = ./out/debug
debug_bin = $(debug)/learn-opengl

run: compile
	$(debug_bin)

compile: | $(debug)
	cmake --build $(debug)

$(debug):
	cmake -DCMAKE_BUILD_TYPE=Debug -B $(debug)

.PHONY: run compile
