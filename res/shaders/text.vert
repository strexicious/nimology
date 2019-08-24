#version 150 core

in vec3 position;
in uint symbol;

out uint g_symbol;

void main() {
    g_symbol = symbol;
    gl_Position = vec4(position, 1.0);
}
