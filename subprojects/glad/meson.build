project(
    'glad',
    'c',
    version : '2.0.8',
    meson_version : '>= 1.3.0',
    default_options : ['warning_level=3'],
)

include = include_directories('include')

lib = library(
    'glad',
    'src/gl.c',
    include_directories: include,
)

glad_dep = declare_dependency(
    include_directories : include,
    link_with : lib,
)
