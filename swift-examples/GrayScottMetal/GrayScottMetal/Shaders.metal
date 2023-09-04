//
//  Shaders.metal
//  GrayScottMetal
//
//  Created by Gavin Wiggins on 9/4/23.
//

#include <metal_stdlib>
using namespace metal;

struct Parameters
{
    float F;      // dimensionless feed rate
    float k;      // dimensionless rate constant
    float Du;     // diffusion coefficient for U
    float Dv;     // diffusion coefficient for V
    uint width;   // 2x frame width of the SwiftUI view
    uint height;  // 2x frame height of the SwiftUI view
};

// Remap value that has expected range of low1 to high1 into target range of low2 to high2
// The result is clamped to be within range of 0.0 to 1.0
static float remap(float value, float low1, float high1, float low2, float high2) {
    float x = low2 + (value - low1) * (high2 - low2) / (high1 - low1);
    return saturate(x);
}

kernel void draw(constant float *Unew [[buffer(0)]],
                 constant float3 *colormap [[buffer(1)]],
                 texture2d<half, access::write> output [[texture(0)]],
                 uint2 grid [[thread_position_in_grid]]
){
    uint width = output.get_width();
    uint i = grid.x + grid.y * width;  // map 2D grid coordinates to 1D
        
    float u = remap(Unew[i], 0.2, 0.9, 0.0, 1.0);
    int colorIndex = u * 255;
    half4 color = half4(half3(colormap[colorIndex]), 1);
    
    output.write(color, grid);
}

kernel void grayscott(constant float *U [[buffer(0)]],
                      constant float *V [[buffer(1)]],
                      device float *Unew [[buffer(2)]],
                      device float *Vnew [[buffer(3)]],
                      constant Parameters *params [[buffer(4)]],
                      uint2 grid [[thread_position_in_grid]]
){
    float F = params -> F;
    float k = params -> k;
    float Du = params -> Du;
    float Dv = params -> Dv;
    
    uint width = params -> width;
    uint height = params -> height;
    
    uint i = grid.x + grid.y * width;  // map 2D grid coordinates to 1D
    
    uint north = grid.x + (grid.y - 1) * width;
    uint south = grid.x + (grid.y + 1) * width;
    uint east = (grid.x + 1) + grid.y * width;
    uint west = (grid.x - 1) + grid.y * width;
    
    uint firstrow = grid.x + 0 * width;
    uint lastrow = grid.x + (height - 1) * width;
    
    uint firstcol = 0 + grid.y * width;
    uint lastcol = (width - 1) + grid.y * width;
        
    uint up = (grid.y == 0) ? lastrow : north;              // top grid point for f(x, y + h)
    uint down = (grid.y == height - 1) ? firstrow : south;  // bottom grid point for f(x, y - h)
    uint left = (grid.x == 0) ? lastcol : west ;            // left grid point for f(x - h, y)
    uint right = (grid.x == width - 1) ? firstcol : east;   // right grid point for f(x + h, y)
    
    float lapU = U[left] + U[right] + U[up] + U[down] - 4 * U[i];
    float lapV = V[left] + V[right] + V[up] + V[down] - 4 * V[i];
    float UVV = U[i] * V[i] * V[i];

    Unew[i] = U[i] + Du * lapU - UVV + F * (1 - U[i]);
    Vnew[i] = V[i] + Dv * lapV + UVV - (F + k) * V[i];
}
