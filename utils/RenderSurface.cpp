//
// Created by lewis on 01/05/2022.
//

#include "RenderSurface.h"

RenderSurface::RenderSurface() {
    setupQuad();
}

void RenderSurface::setupQuad() {
    GLuint VBO, EBO;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    glBindVertexArray(vao);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(quadIndices), quadIndices, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*) 0);
    glEnableVertexAttribArray(0);
    // texture coord attribute
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}

void RenderSurface::attachShader(Shader *shader) {
    this->shader = shader;
}

/*void RenderSurface::setupDefaultShader() {
    GLuint vertID, fragID;

    vertID = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertID, 1, &vertSource, nullptr);
    glCompileShader(vertID);
    checkShaderError(vertID);

    fragID = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragID, 1, &fragSource, nullptr);
    glCompileShader(fragID);
    checkShaderError(fragID);

    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertID);
    glAttachShader(shaderProgram, fragID);
    glLinkProgram(shaderProgram);

    glUseProgram(shaderProgram);
    glUniform1i(glGetUniformLocation(shaderProgram, "screenTexture"), 0);

    glDeleteShader(vertID);
    glDeleteShader(fragID);
}*/

void RenderSurface::render() {
    shader->bind();
    glBindVertexArray(vao);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

void RenderSurface::checkShaderError(GLuint shader) {
    GLint success = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if(success == GL_FALSE) {
        std::cout << "Error compiling shader" << std::endl;
        GLint maxLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength);

        std::cout << maxLength << std::endl;

        // The maxLength includes the NULL character
        std::vector<GLchar> errorLog(maxLength);
        glGetShaderInfoLog(shader, maxLength, &maxLength, &errorLog[0]);

        // Provide the infolog in whatever manor you deem best.
        std::cout << errorLog.data() << std::endl;

        // Exit with failure.
        glDeleteShader(shader); // Don't leak the shader.
        return;
    }}

RenderSurface::~RenderSurface() {

}