//
// Created by lewis on 24/05/2023.
//

#ifndef ACCELERATEDPATHTRACER_FLUID_CUH
#define ACCELERATEDPATHTRACER_FLUID_CUH

#include "GL/glew.h"
#include "cuda_gl_interop.h"
#include "Particle.h"

__global__ void updateFluid(FieldCell *original_fluid, FieldCell *result_fluid, unsigned int fieldWidth, unsigned int fieldHeight);

class Fluid {
public:
    Fluid(unsigned int screenWidth, unsigned int screenHeight, unsigned int fieldWidth, unsigned int fieldHeight);
    void render();
private:
    float *m_pixels;

    FieldCell *m_fluidField1, *m_fluidField2;
    bool m_useBackBuffer = 0;

    unsigned int m_screenWidth, m_screenHeight;
    unsigned int m_fieldWidth, m_fieldHeight;

    GLuint m_pbo;
    cudaGraphicsResource *m_cudaPboResource;
};


#endif //ACCELERATEDPATHTRACER_FLUID_CUH
