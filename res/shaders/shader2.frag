#version 150 core

out vec4 color;

const vec3 waterColor = vec3(0.19607843137, 0.51372549019, 0.65882352941);

void main() {
    color = vec4(waterColor, 1.0);
}
