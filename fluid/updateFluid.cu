//
// Created by lewis on 25/05/2023.
//

#include "Particle.h"

#define SQRT_2_2 0.70710678118f

__device__ unsigned int getFieldIndex(unsigned int x, unsigned int y, unsigned int field_width);

__global__ void updateFluid(FieldCell *original_fluid, FieldCell *result_fluid, unsigned int fieldWidth, unsigned int fieldHeight) {
    unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x >= fieldWidth || y >= fieldHeight) return;

    unsigned int index = (x + y * fieldWidth);

    // Let result velocity be the divergence of density
    // Define indices for each neighbour
    unsigned int left_x = (x - 1) % 0xffff;
    unsigned int right_x = (x + 1) % fieldWidth;
    unsigned int down_y  = (y + 1) % fieldHeight;
    unsigned int up_y = (y - 1) % 0xffff;

    // Row by row for cache efficiency
    // Start with top row
    result_fluid[index].vx =
            // Top left
            -SQRT_2_2 * (original_fluid[getFieldIndex(left_x, up_y, fieldWidth)].density - original_fluid[index].density)
            // Top right
            + SQRT_2_2 * (original_fluid[getFieldIndex(right_x, up_y, fieldWidth)].density - original_fluid[index].density);
    result_fluid[index].vy =
            // Top left
            SQRT_2_2 * (original_fluid[getFieldIndex(left_x, up_y, fieldWidth)].density - original_fluid[index].density)
            // Top middle
            + (original_fluid[getFieldIndex(x, up_y, fieldWidth)].density - original_fluid[index].density)
            // Top right
            + SQRT_2_2 * (original_fluid[getFieldIndex(right_x, up_y, fieldWidth)].density - original_fluid[index].density);

    // Middle row
    result_fluid[index].vx +=
            // Middle left
            -(original_fluid[getFieldIndex(left_x, y, fieldWidth)].density - original_fluid[index].density)
            // Middle right
            + (original_fluid[getFieldIndex(right_x, y, fieldWidth)].density - original_fluid[index].density);

    // Bottom row
    result_fluid[index].vx +=
            // Bottom left
            -SQRT_2_2 * (original_fluid[getFieldIndex(left_x, down_y, fieldWidth)].density - original_fluid[index].density)
            // Bottom right
            + SQRT_2_2 * (original_fluid[getFieldIndex(right_x, down_y, fieldWidth)].density - original_fluid[index].density);
    result_fluid[index].vy -=
            // Top left
            SQRT_2_2 * (original_fluid[getFieldIndex(left_x, down_y, fieldWidth)].density - original_fluid[index].density)
            // Top middle
            + (original_fluid[getFieldIndex(x, down_y, fieldWidth)].density - original_fluid[index].density)
            // Top right
            + SQRT_2_2 * (original_fluid[getFieldIndex(right_x, down_y, fieldWidth)].density - original_fluid[index].density);

    // Gravity
    //result_fluid[index].vy -= 0.1f;

    // 0.125f to average over 8 neighbours
    result_fluid[index].density += result_fluid[index].vx * 0.125f;
    result_fluid[index].density += result_fluid[index].vy * 0.125f;

    if(pow(x - fieldWidth * 0.5, 2) + pow(y - fieldHeight * 0.5, 2) >= 3) result_fluid[index].density = 0.1f;

    if(result_fluid[index].density < 0.0f) result_fluid[index].density = 0.0f;
}