run: compile
	./build/learn-opengl

clean:
	rm -rf ./build

compile: ./build
	meson compile -C build

./build:
	meson setup build

.PHONY: clean run compile
