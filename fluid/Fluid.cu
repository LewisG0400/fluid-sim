//
// Created by lewis on 23/05/2023.
//

#include "Fluid.h"

Fluid::Fluid() {
    Shader *metaballShader = new Shader("../resources/shaders/metaballShader");
    renderSurface = new RenderSurface();
    renderSurface->attachShader(metaballShader);

    cudaError_t cErr;

    std::vector<float> startPositions;
    float startVelocities[100 * 2];
    for(int i = 0; i < N_PARTICLES; i+=2) {
        //startPositions.push_back((float) (i / 100.0f));
        //startPositions.push_back((float) (rand() % 100 - 50));
        startPositions.push_back(200.5f);
        startPositions.push_back(0.0f);
        startVelocities[i] = (rand() % 100 - 50) / 10.0f;
        startVelocities[i + 1] = (rand() % 100 - 50) / 10.0f;
    }

    // Setup the OpenGL position buffer
    glGenBuffers(1, &positionBuffer);
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, positionBuffer);
    glBufferData(GL_SHADER_STORAGE_BUFFER, sizeof(startPositions), &startPositions[0], GL_STATIC_DRAW);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, positionBuffer);

    // Attach the position buffer to a CUDA resource
    cudaGraphicsGLRegisterBuffer(&positionResource, positionBuffer, cudaGraphicsRegisterFlagsNone);

    glGenBuffers(1, &velocityBuffer);
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, velocityBuffer);
    glBufferData(GL_SHADER_STORAGE_BUFFER, N_PARTICLES * sizeof(float) * 2, startVelocities, GL_STATIC_DRAW);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, velocityBuffer);
}

void Fluid::render() {
    renderSurface->render();
}