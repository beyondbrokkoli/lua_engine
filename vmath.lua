local ffi = require("ffi")
local math = require("math")
local vmath = {}

function vmath.perspective_inf_revz(fov_degrees, aspect, near, out)
    local f = 1.0 / math.tan(math.rad(fov_degrees) * 0.5)

    -- Row 0
    out[0]  = f / aspect
    out[1]  = 0.0
    out[2]  = 0.0
    out[3]  = 0.0
    
    -- Row 1 (-f to correct Vulkan's inverted Y)
    out[4]  = 0.0
    out[5]  = -f
    out[6]  = 0.0
    out[7]  = 0.0
    
    -- Row 2 (Z-Clip mapping to 'near')
    out[8]  = 0.0
    out[9]  = 0.0
    out[10] = 0.0
    out[11] = near
    
    -- Row 3 (W-Clip mapping to -Z)
    out[12] = 0.0
    out[13] = 0.0
    out[14] = -1.0
    out[15] = 0.0
end

function vmath.lookAt(eye_x, eye_y, eye_z, center_x, center_y, center_z, out)
    local fx = center_x - eye_x
    local fy = center_y - eye_y
    local fz = center_z - eye_z
    local f_inv = 1.0 / math.sqrt(fx*fx + fy*fy + fz*fz)
    fx = fx * f_inv; fy = fy * f_inv; fz = fz * f_inv

    -- Absolute Up Vector fallback to prevent NaN Gimbal Lock
    local up_x = 0.0; local up_y = 1.0; local up_z = 0.0
    if math.abs(fx) < 0.001 and math.abs(fz) < 0.001 then
        if fy > 0 then up_z = -1.0 else up_z = 1.0 end
        up_y = 0.0
    end

    -- Right Vector: cross(fwd, up)
    local rx = fy * up_z - fz * up_y
    local ry = fz * up_x - fx * up_z
    local rz = fx * up_y - fy * up_x
    local r_inv = 1.0 / math.sqrt(rx*rx + ry*ry + rz*rz)
    rx = rx * r_inv; ry = ry * r_inv; rz = rz * r_inv

    -- True Up Vector: cross(right, fwd)
    local ux = ry * fz - rz * fy
    local uy = rz * fx - rx * fz
    local uz = rx * fy - ry * fx

    -- Row 0: Right
    out[0]  = rx; out[1]  = ry; out[2]  = rz; out[3]  = -(rx*eye_x + ry*eye_y + rz*eye_z)
    -- Row 1: Up
    out[4]  = ux; out[5]  = uy; out[6]  = uz; out[7]  = -(ux*eye_x + uy*eye_y + uz*eye_z)
    -- Row 2: Forward (-Z mapping)
    out[8]  = -fx; out[9] = -fy; out[10]= -fz; out[11] = (fx*eye_x + fy*eye_y + fz*eye_z)
    -- Row 3: Identity padding
    out[12] = 0.0; out[13] = 0.0; out[14] = 0.0; out[15] = 1.0
end

function vmath.multiply_mat4(a, b, out)
    -- Intermediate buffer prevents memory aliasing if 'out' == 'a' or 'b'
    local temp = ffi.new("float[16]")
    for i = 0, 3 do
        for j = 0, 3 do
            temp[i*4 + j] = a[i*4 + 0] * b[0*4 + j] +
                            a[i*4 + 1] * b[1*4 + j] +
                            a[i*4 + 2] * b[2*4 + j] +
                            a[i*4 + 3] * b[3*4 + j]
        end
    end
    for k = 0, 15 do
        out[k] = temp[k]
    end
end

return vmath
