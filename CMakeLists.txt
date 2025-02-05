cmake_minimum_required(VERSION 3.31)

project("learn-opengl" VERSION 0.1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_FLAGS "-Werror -Weverything -Wno-c++98-compat -Wno-c++-compat")

find_package(glfw3 REQUIRED)
find_package(GLEW REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} glfw GL GLEW::glew)
