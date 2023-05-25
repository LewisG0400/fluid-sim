#include "Shader.h"



Shader::Shader(std::string path) {
	std::string vertSource = readFile(path + ".vert");
	const GLchar* vertSourceA = vertSource.c_str();

	std::string fragSource = readFile(path + ".frag");
	const GLchar* fragSourceA = fragSource.c_str();

	GLuint vertID = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertID, 1, &vertSourceA, NULL);
	glCompileShader(vertID);
	GLint success;
	GLchar infoLog[512];
	glGetShaderiv(vertID, GL_COMPILE_STATUS, &success);
	if (!success) {
		glGetShaderInfoLog(vertID, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
	}

	GLuint fragID = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragID, 1, &fragSourceA, NULL);
	glCompileShader(fragID);
	glGetShaderiv(fragID, GL_COMPILE_STATUS, &success);
	if (!success) {
		glGetShaderInfoLog(fragID, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
	}

	programID = glCreateProgram();
	glAttachShader(programID, vertID);
	glAttachShader(programID, fragID);
	glLinkProgram(programID);
	glGetProgramiv(programID, GL_LINK_STATUS, &success);
	if (!success) {
		glGetProgramInfoLog(programID, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
	}

	glDeleteShader(vertID);
	glDeleteShader(fragID);
}

void Shader::addUniform(std::string name) {
	uniforms[name] = glGetUniformLocation(programID, name.c_str());
}

void Shader::setUniform1i(std::string uniformName, int val) {
	glUniform1i(uniforms[uniformName], val);
}

void Shader::bind() {
	glUseProgram(programID);
}

void Shader::unbind() {
	glUseProgram(0);
}

Shader::~Shader() {}
