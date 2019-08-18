#version 150 core

in vec2 f_texcoord;

out vec4 color;

uniform sampler2D scene;

void main()
{
    color = texture(scene, f_texcoord);
}
