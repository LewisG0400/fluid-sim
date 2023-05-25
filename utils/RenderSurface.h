//
// Created by lewis on 01/05/2022.
//

#ifndef FLUIDSIM_TEXTUREDQUAD_H
#define FLUIDSIM_TEXTUREDQUAD_H

#include <iostream>
#include <vector>
#include <GL/glew.h>
#include "Shader.h"

class RenderSurface {
public:
    RenderSurface();

    void attachShader(Shader *shader);
    void setupDefaultShader();

    void render();

    ~RenderSurface();

private:
    GLuint vao;
    Shader *shader;

    const float quadVertices[20] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
    };

    const unsigned int quadIndices[6] = {
            0, 1, 2,
            2, 3, 0
    };

    const float quadUVs[8] = {
            -1.0f, -1.0f,
            1.0f, -1.0f, 0.0f,
            0,0,0
    };

    const char* vertSource = "#version 330 core\n"
                             "layout (location=0) in vec3 pos;\n"
                             "layout (location=1) in vec2 in_uv;\n"
                             "\n"
                             "out vec2 uv;"
                             "\n"
                             "void main() {\n"
                             "  gl_Position = vec4(pos, 1.0);\n"
                             "  uv = in_uv;\n"
                             "}\n";
    const char* fragSource = "#version 330 core\n"
                             "\n"
                             "in vec2 uv;\n"
                             "out vec4 fragColour; \n"
                             "\n"
                             "uniform sampler2D screenTexture;\n"
                             "\n"
                             "void main()\n"
                             "{\n"
                             "    fragColour = texture(screenTexture, uv);\n"
                             "}";

    void setupQuad();
    void checkShaderError(GLuint shader);
};


#endif //FLUIDSIM_TEXTUREDQUAD_H
