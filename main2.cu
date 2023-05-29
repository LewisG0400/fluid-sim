#include <iostream>

// Need to add this so the entry point is here instead of in SDL
#define SDL_MAIN_HANDLED
#include <GL/glew.h>
#include "SDL.h"
#include <cuda.h>
#include <cuda_gl_interop.h>
#include "utils/TexturedQuad.h"

void createTexturedQuad();

// Consider looking into uchar4 type
// https://stackoverflow.com/questions/26993351/is-there-a-penalty-to-using-char-variables-in-cuda-kernels
// https://docs.nvidia.com/cuda/cuda-math-api/group__CUDA__MATH__INTRINSIC__SIMD.html#group__CUDA__MATH__INTRINSIC__SIMD
__global__ void render(unsigned int *pixels, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if(x >= width || y >= height) return;
    int index = (x + y * width) * 3;
    pixels[0] = 1.0f;
    pixels[index+1] = 0.0f;
    pixels[index+2] = 1.0f;
}

int main(int agrc, char *argv[]) {
    int screenWidth = 800, screenHeight = 600;
    size_t imageSize = screenWidth * screenHeight * sizeof(float) * 3;
    bool running = true;

    cudaError_t cErr;

    std::cout << "Done init" << std::endl;

    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window *window = SDL_CreateWindow(
            "SDL2Test",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            screenWidth,
            screenHeight,
            SDL_WINDOW_OPENGL
    );

    SDL_GLContext context = SDL_GL_CreateContext(window);

    cErr = cudaSetDevice(0);
    if(cErr != cudaSuccess) std::cout << "Error Setting up device: " << cudaGetErrorString(cErr) << std::endl;

    glewInit();
    glViewport(0, 0, screenWidth, screenHeight);
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);

    TexturedQuad q1 = TexturedQuad();

    // Generate a texture
    GLuint screenTexture;
    glGenTextures(1, &screenTexture);
    glBindTexture(GL_TEXTURE_2D, screenTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, screenWidth, screenHeight, 0, GL_RGB, GL_FLOAT, NULL);
    q1.attachTexture(screenTexture);

    struct cudaGraphicsResource* screenResourceHandle;

    cErr = cudaGraphicsGLRegisterImage(&screenResourceHandle, screenTexture, GL_TEXTURE_2D, cudaGraphicsRegisterFlagsNone);
    if(cErr != cudaSuccess) std::cout << "Error registering the GL image with CUDA: " << cudaGetErrorString(cErr) << std::endl;

    float *pixels;
    cudaMalloc(&pixels, imageSize);
    cudaMemset(pixels, 0, imageSize);

    float *hostPixels;
    hostPixels = (float*) malloc(imageSize);
    for(int i = 0; i < screenWidth * screenHeight * 3; i++) hostPixels[i] = 1.0f;
    cudaMemcpy(pixels, hostPixels, screenWidth * screenHeight * 3, cudaMemcpyHostToDevice);
    cudaMemcpy(hostPixels, pixels, 100, cudaMemcpyDeviceToHost);

    for(int i = 0; i < 100; i++) std::cout << (float) hostPixels[i] << std::endl;

    SDL_Event event;
    while(running) {
        SDL_PollEvent(&event);
        if(event.type == SDL_QUIT) {
            running = false;
        }

        dim3 blockSize(16, 16);
        dim3 gridSize((screenWidth + blockSize.x - 1) / blockSize.x, (screenHeight + blockSize.y - 1) / blockSize.y);

        //render<<<gridSize, blockSize>>>(pixels, screenWidth, screenHeight);

        cudaDeviceSynchronize();

        cudaArray *cudaArrayPointer;

        cErr = cudaGraphicsMapResources(1, &screenResourceHandle, 0);
        if(cErr != cudaSuccess) std::cout << "Error mapping the cuda resource: " << cudaGetErrorString(cErr) << std::endl;

        cErr = cudaGraphicsSubResourceGetMappedArray(&cudaArrayPointer, screenResourceHandle, 0, 0);
        if(cErr != cudaSuccess) std::cout << "Error getting a mapped pointer for the resource: " << cudaGetErrorString(cErr) << std::endl;

        cudaMemcpyToArray(cudaArrayPointer, 0, 0, pixels, imageSize, cudaMemcpyDeviceToDevice);

        cudaGraphicsUnmapResources(1, &screenResourceHandle, 0);

        glClear(GL_COLOR_BUFFER_BIT);

        q1.render();

        SDL_GL_SwapWindow(window);
    }

    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}