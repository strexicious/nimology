#version 150 core

in vec2 position;
in vec2 texcoord;

out vec2 f_texcoord;

uniform float xoffset;

void main() {
    f_texcoord = texcoord;
    gl_Position = vec4(vec2(xoffset, 0.0) + position, 0.0, 1.0);
}
