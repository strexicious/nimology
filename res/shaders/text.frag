#version 150 core

in vec2 f_texcoord;

out vec4 color;

uniform sampler2DRect font;
uniform vec3 fontColor;

void main() {
    vec4 texelColor = texture(font, f_texcoord);
    if (texelColor == vec4(1.0, 1.0, 1.0, 1.0)) discard;

    // we need 1 - channel for each, we avg it because it's suppose to be grey scale
    color = vec4((3 - texelColor.x + texelColor.y + texelColor.z) / 3 * fontColor, texelColor.w);
}
