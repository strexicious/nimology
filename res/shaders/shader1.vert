#version 150 core

in vec2 position;
in vec3 color;
in vec2 texcoord;

out vec3 f_color;
out vec2 f_texcoord;

void main() {
    f_color = color;
    f_texcoord = texcoord;
    gl_Position = vec4(position, 0.0, 1.0);
}
