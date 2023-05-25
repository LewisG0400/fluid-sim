//
// Created by lewis on 23/05/2023.
//

#ifndef FLUID_SIM_FLUID_H
#define FLUID_SIM_FLUID_H

#include "../utils/RenderSurface.h"
#include <cuda.h>
#include <cuda_gl_interop.h>

class Fluid {
public:
    Fluid();

    void render();
private:
RenderSurface *renderSurface;
GLuint positionBuffer, velocityBuffer;
cudaGraphicsResource *positionResource, *velocityResource;

const int N_PARTICLES = 100;
};


#endif //FLUID_SIM_FLUID_H
