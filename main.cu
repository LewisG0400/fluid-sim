#include <iostream>

// Need to add this so the entry point is here instead of in SDL
#define SDL_MAIN_HANDLED
#include <GL/glew.h>
#include "SDL.h"
#include <cuda.h>
#include <cuda_gl_interop.h>
#include "fluid/Fluid.cuh"

void createTexturedQuad();

int main(int agrc, char *argv[]) {
    int screenWidth = 1200, screenHeight = 960;
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

    glClearColor(1.0, 0.0, 0.0, 1.0);

    Fluid *fluid = new Fluid(screenWidth, screenHeight, 50, 50);

    SDL_Event event;
    while(running) {
        SDL_PollEvent(&event);
        if(event.type == SDL_QUIT) {
            running = false;
        }
        glClear(GL_COLOR_BUFFER_BIT);
        glDisable(GL_DEPTH_TEST);

        fluid->render();

        std::cout << "Frame done" << std::endl;

        SDL_GL_SwapWindow(window);
    }

    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}