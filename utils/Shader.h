#pragma once

#include <map>
#include <string>
#include <fstream>
#include <iostream>
#include <GL/glew.h>

class Shader {
public:
	Shader(std::string path);

	static std::string readFile(std::string path) {
		std::ifstream f;
		std::string line;
		std::string content;
		f.open(path, std::ios::in);
		if (f.is_open()) {
			while (std::getline(f, line)) {
				content.append(line + '\n');
			}
			f.close();
		}
		return content;
	}

	void addUniform(std::string name);

	void setUniform1i(std::string uniformName, int val);

	void bind();
	void unbind();

	~Shader();

private:
	GLuint programID;
	std::map<std::string, GLuint> uniforms;
};

