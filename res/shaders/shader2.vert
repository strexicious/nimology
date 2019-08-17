#version 150 core

in vec2 position;

out float y;

uniform float time;
uniform mat4 view;
uniform mat4 proj;

#define PI 3.141592

void main() {
    y = sin((time + position.x * 0.9 + position.y) * 0.5 * PI) * 0.2;
    gl_Position = proj * view * vec4(position.x, y, position.y, 1.0);
}
