#version 150 core

in vec2 position;
in vec3 color;
in vec2 texcoord;

out vec3 f_color;
out vec2 f_texcoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
    f_color = color;
    f_texcoord = texcoord;
    gl_Position = proj * view * model * vec4(position, 0.0, 1.0);
}
