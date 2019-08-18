#version 150 core

layout(points) in;
layout(line_strip, max_vertices = 64) out;

in vec3 g_color[];
in float g_sides[];

out vec3 f_color;

#define PI 3.1415926

void main() {
    f_color = g_color[0];
    
    for (int i = 0; i <= g_sides[0]; i++) {
        // Angle between each side in radians
        float ang = PI * 2.0 / g_sides[0] * i;

        // Offset from center of point (0.3 to accomodate for aspect ratio)
        vec4 offset = vec4(cos(ang) * 0.3, -sin(ang) * 0.4, 0.0, 0.0);
        gl_Position = gl_in[0].gl_Position + offset;

        EmitVertex();
    }
    
    EndPrimitive();
}
