#version 460

layout(location = 0) out vec4 fragColor;

void main() {
    uint id = gl_VertexIndex;

    // Isolate the first 100 particles. Throw the remaining 999,900 out of bounds.
    if (id >= 100) {
        gl_Position = vec4(2.0, 2.0, 2.0, 1.0); 
        return;
    }

    // Force a 10x10 grid stretching across the screen (-0.8 to +0.8)
    float x = (float(id % 10) / 4.5) - 1.0;
    float y = (float(id / 10) / 4.5) - 1.0;

    // Z = 0.5 guarantees it passes the Reverse-Z depth test (0.5 > 0.0)
    gl_Position = vec4(x * 0.8, y * 0.8, 0.5, 1.0);
    
    // Massive unmissable block
    gl_PointSize = 40.0; 

    fragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
