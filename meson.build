project(
    'learn-opengl',
    'c',
    meson_version : '>= 1.3.0',
    version : '1.2',
    default_options : ['warning_level=3'],
)

glad_proj = subproject('glad')
stb_proj = subproject('stb')

dependencies = [
    dependency('glfw3'),
    glad_proj.get_variable('glad_dep'),
    stb_proj.get_variable('stb_dep'),
]

sources = [
    'main.c',
    'sakana.c',
    'sakana_gfx.c',
    'sakana_math.c',
]

exe = executable(
    'learn-opengl',
    sources,
    dependencies : dependencies,
    install : true,
)
