//
// Created by lewis on 29/05/2023.
//

__device__ unsigned int getFieldIndex(unsigned int x, unsigned int y, unsigned int field_width) {
    return x + y * field_width;
}