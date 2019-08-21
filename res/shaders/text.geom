#version 150 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

in uint g_symbol[];

out vec2 f_texcoord;

uniform float charSize;

#define CHAR_TEXELS 10u
#define TOTAL_ROWS 4u
#define TOTAL_COLS 10u

void main() {
    uint row = TOTAL_ROWS - g_symbol[0] / TOTAL_COLS - 1u;
    uint col = g_symbol[0] % TOTAL_COLS;

    gl_Position = gl_in[0].gl_Position + vec4(0.0, 0.0, 0.0, 0.0);
    f_texcoord = vec2(CHAR_TEXELS * col, CHAR_TEXELS * (row + 1u));
    EmitVertex();
    gl_Position = gl_in[0].gl_Position + vec4(0.0, -charSize, 0.0, 0.0);
    f_texcoord = vec2(CHAR_TEXELS * col, CHAR_TEXELS * row);
    EmitVertex();
    gl_Position = gl_in[0].gl_Position + vec4(charSize, 0.0, 0.0, 0.0);
    f_texcoord = vec2(CHAR_TEXELS * (col + 1u), CHAR_TEXELS * (row + 1u));
    EmitVertex();
    gl_Position = gl_in[0].gl_Position + vec4(charSize, -charSize, 0.0, 0.0);
    f_texcoord = vec2(CHAR_TEXELS * (col + 1u), CHAR_TEXELS * row);
    EmitVertex();

    EndPrimitive();
}
