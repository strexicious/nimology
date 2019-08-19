#version 150 core

layout(points) in;
layout(triangle_strip, max_vertices = 3) out;

in float[] g_value;
out float ovalue;

void main()
{
    for (int i = 0; i < 3; i++) {
        ovalue = g_value[0] + i;
        EmitVertex();
    }

    EndPrimitive();
}
