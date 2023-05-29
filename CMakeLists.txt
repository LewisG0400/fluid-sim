cmake_minimum_required(VERSION 3.21)
project(AcceleratedPathTracer CUDA)
enable_language(CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(CUDA)
set(CMAKE_CUDA_STANDARD 17)

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 75)
endif()

find_package(OpenGL REQUIRED)

find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIR})

message(STATUS "${SDL2_INCLUDE_DIR}")

find_package(GLEW REQUIRED)
include_directories(${GLEW_INCLUDE_DIRS})

message(STATUS ${GLEW_LIBRARIES})

add_executable(AcceleratedPathTracer main.cu fluid/Fluid.cu fluid/Fluid.cuh fluid/updateFluid.cu fluid/Particle.h)
set_target_properties(AcceleratedPathTracer PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

target_link_libraries(AcceleratedPathTracer ${SDL2_LIBRARIES} ${GLEW_LIBRARIES} ${OPENGL_LIBRARIES})
