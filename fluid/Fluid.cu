//
// Created by lewis on 24/05/2023.
//

#include "Fluid.cuh"
#include <iostream>

// Consider looking into uchar4 type
// https://stackoverflow.com/questions/26993351/is-there-a-penalty-to-using-char-variables-in-cuda-kernels
// https://docs.nvidia.com/cuda/cuda-math-api/group__CUDA__MATH__INTRINSIC__SIMD.html#group__CUDA__MATH__INTRINSIC__SIMD
__global__ void setPixels(FieldCell *field, int fieldWidth, int fieldHeight, float *pixels, int screenWidth, int screenHeight) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x >= screenWidth || y >= screenHeight) return;

    int pixel_index = (x + y * screenWidth) * 3;
    int fieldIndex = ((int) floor(((float) fieldWidth / screenWidth) * x)) + ((int) floor(((float) fieldHeight / screenHeight) * y)) * fieldWidth;

    float density = field[fieldIndex].density;

    pixels[pixel_index] = density;
    pixels[pixel_index + 1] = 0.0f;
    pixels[pixel_index + 2] = density;
}

Fluid::Fluid(int screenWidth, int screenHeight, int fieldWidth, int fieldHeight) :
m_screenWidth(screenWidth), m_screenHeight(screenHeight), m_fieldWidth(fieldWidth), m_fieldHeight(fieldHeight) {
    cudaError_t cErr;

    glViewport(0, 0, screenWidth, screenHeight);

    cudaMalloc(&m_fluidField1, fieldWidth * fieldHeight * sizeof(FieldCell));
    cudaMemset(m_fluidField1, 0, fieldWidth * fieldHeight * sizeof(FieldCell));

    cudaMalloc(&m_fluidField2, fieldWidth * fieldHeight * sizeof(FieldCell));
    cudaMemset(m_fluidField2, 0, fieldWidth * fieldHeight * sizeof(FieldCell));

    glGenBuffers(1, &m_pbo);
    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_pbo);
    glBufferData(GL_PIXEL_UNPACK_BUFFER, screenWidth * screenHeight * sizeof(GLfloat) * 3, 0, GL_STREAM_DRAW);

    cErr = cudaGraphicsGLRegisterBuffer(&m_cudaPboResource, m_pbo, cudaGraphicsMapFlagsWriteDiscard);
    if(cErr != cudaSuccess) std::cout << "Error registering m_pbo with CUDA: " << cudaGetErrorString(cErr) << std::endl;
}

void Fluid::render() {
    cudaError_t cErr;

    FieldCell *old_fluid, *new_fluid;
    old_fluid = m_useBackBuffer == 0 ? m_fluidField1 : m_fluidField2;
    new_fluid = m_useBackBuffer == 0 ? m_fluidField2 : m_fluidField1;
    m_useBackBuffer ^= 1;

    dim3 blockSize1(1, 1);
    dim3 gridSize1(m_fieldWidth, m_fieldHeight);
    updateFluid<<<gridSize1, blockSize1>>>(old_fluid, new_fluid, m_fieldWidth, m_fieldHeight);
    cErr = cudaGetLastError();
    if(cErr != cudaSuccess) std::cout << "Error updating fluid:  " << cudaGetErrorString(cErr) << std::endl;

    cudaDeviceSynchronize();

    cErr = cudaGraphicsMapResources(1, &m_cudaPboResource, 0);
    if(cErr != cudaSuccess) std::cout << "Error mapping pbo: " << cudaGetErrorString(cErr) << std::endl;

    cErr = cudaGraphicsResourceGetMappedPointer((void**) &m_pixels, NULL, m_cudaPboResource);
    if(cErr != cudaSuccess) std::cout << "Error getting mapped pointer to pbo: " << cudaGetErrorString(cErr) << std::endl;

    dim3 blockSize(16, 16);
    dim3 gridSize((m_screenWidth + blockSize.x - 1) / blockSize.x, (m_screenHeight + blockSize.y - 1) / blockSize.y);
    setPixels<<<gridSize, blockSize>>>(new_fluid, m_fieldWidth, m_fieldHeight, m_pixels, m_screenWidth, m_screenHeight);
    cErr = cudaGetLastError();
    if(cErr != cudaSuccess) std::cout << "Error rendering:  " << cudaGetErrorString(cErr) << std::endl;

    cudaDeviceSynchronize();

    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_pbo);
    glRasterPos2i(-1, -1);
    glDrawPixels(m_screenWidth, m_screenHeight, GL_RGB, GL_FLOAT, 0);

    cudaGraphicsUnmapResources(1, &m_cudaPboResource, 0);
}