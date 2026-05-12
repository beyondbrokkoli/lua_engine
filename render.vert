#version 460

layout(push_constant) uniform PushConstants {
    uint pos_x_idx;
    uint pos_y_idx;
    uint pos_z_idx;
    uint particle_count;
    float dt;
    uint _pad[3]; 
    mat4 viewProj; 
} pc;

layout(location = 0) out vec4 fragColor;

void main() {
    uint id = gl_VertexIndex;

    if (id >= 100) {
        gl_Position = vec4(2.0, 2.0, 2.0, 1.0); 
        return;
    }

    // Shrink back to NDC boundaries (-0.8 to 0.8)
    float x = (float(id % 10) / 4.5) - 1.0;
    float y = (float(id / 10) / 4.5) - 1.0;
    
    // Z = 0.5 to pass Reverse-Z
    vec4 localPos = vec4(x * 0.8, y * 0.8, 0.5, 1.0);

    // Multiply by the Lua-injected Identity Matrix
    gl_Position = localPos * pc.viewProj;
    
    gl_PointSize = 40.0; 
    fragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
