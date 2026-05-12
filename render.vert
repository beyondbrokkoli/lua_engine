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

    // Expand the 10x10 grid into World Space (200x200 spread)
    float x = (float(id % 10) / 4.5) - 1.0;
    float y = (float(id / 10) / 4.5) - 1.0;
    vec4 worldPos = vec4(x * 200.0, y * 200.0, 0.0, 1.0);

    // Apply the Lua Matrix
    gl_Position = worldPos * pc.viewProj;
    
    gl_PointSize = 40.0; 
    fragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
