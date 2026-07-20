project(
    'learn-opengl',
    'c',
    meson_version : '>= 1.3.0',
    version : '1.2',
    default_options : ['warning_level=3'],
)

glad_proj = subproject('glad')

dependencies = [
    dependency('glfw3'),
    glad_proj.get_variable('glad_dep')
]

sources = [
    'main.c',
]

exe = executable(
    'learn-opengl',
    sources,
    dependencies : dependencies,
    install : true,
)
