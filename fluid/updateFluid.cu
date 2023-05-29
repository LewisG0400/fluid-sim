//
// Created by lewis on 25/05/2023.
//

#include "Particle.h"

__global__ void updateFluid(FieldCell *original_fluid, FieldCell *result_fluid, int fieldWidth, int fieldHeight) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x >= fieldWidth || y >= fieldHeight) return;

    int index = (x + y * fieldWidth);

    for(int x_offset = -1; x_offset < 1; x_offset ++) {
        for(int y_offset = -1; y_offset < 1; y_offset ++) {
            if(x == 0 && y == 0) continue;
            int temp;
            temp = (x + x_offset) % fieldWidth;
            int cell_x = temp == -1 ? fieldWidth - 1 : temp;
            temp = (y + y_offset) % fieldHeight;
            int cell_y = temp == -1 ? fieldHeight - 1 : temp;

            int cell_index = (cell_x + cell_y * fieldWidth);

            result_fluid[index].vx += original_fluid[index].density - original_fluid[cell_index].density;
            result_fluid[index].vy += original_fluid[cell_index].vy;
        }
    }
}