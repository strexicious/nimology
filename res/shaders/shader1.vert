#version 150 core

in float ivalue;

out float g_value;

void main() {
    g_value = sqrt(ivalue);
}
