project(
    'stb',
    'c',
    version : '2.30',
    meson_version : '>= 1.3.0',
    default_options : ['warning_level=3'],
)

include = include_directories('.')

c = meson.get_compiler('c')

stb_dep = declare_dependency(
    include_directories : include,
    dependencies: c.find_library('m')
)
