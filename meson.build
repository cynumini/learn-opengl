project(
    'learn-opengl',
    'c',
    meson_version : '>= 1.3.0',
    version : '1.2',
    default_options : ['warning_level=3'],
)

glad_proj = subproject('glad')
stb_proj = subproject('stb')
cglm_proj = subproject('cglm-0.9.6')

dependencies = [
    dependency('glfw3'),
    glad_proj.get_variable('glad_dep'),
    stb_proj.get_variable('stb_dep'),
    cglm_proj.get_variable('cglm_dep')
]

sources = [
    'main.c',
    'program.c',
]

exe = executable(
    'learn-opengl',
    sources,
    dependencies : dependencies,
    install : true,
)
