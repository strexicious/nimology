#version 150 core

in vec2 position;
in vec3 color;
in float sides;

out vec3 g_color;
out float g_sides;

void main() {
    g_color = color;
    g_sides = sides;
    gl_Position = vec4(position, 0.0, 1.0);
}
