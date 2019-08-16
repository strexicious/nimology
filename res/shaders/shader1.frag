#version 150 core

in vec3 f_color;
in vec2 f_texcoord;

out vec4 color;

uniform float time;
uniform sampler2D texKitten;

void main() {
    if (f_texcoord.y < 0.5)
        color = texture(texKitten, f_texcoord);
    else {
        float new_y = 1.0 - f_texcoord.y;
        float new_x = cos(time + new_y * 64) * 0.03 + f_texcoord.x;
        color = texture(texKitten, vec2(new_x, new_y));
    }
}
