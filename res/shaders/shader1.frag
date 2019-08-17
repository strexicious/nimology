#version 150 core

in vec3 f_color;
in vec2 f_texcoord;

out vec4 color;

uniform sampler2D texKitten;
uniform sampler2D texPuppy;

void main() {
    vec4 colKitten = texture(texKitten, f_texcoord);
    vec4 colPuppy = texture(texPuppy, f_texcoord);
    color = mix(colKitten, colPuppy, 0.5) * vec4(f_color, 1.0);
}
