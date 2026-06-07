cmake_minimum_required(VERSION 3.11)
project(3C)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(RAYLIB_VERSION 6.0)

# Enable assembly support
enable_language(ASM)

# Optional: Set assembly flags
if(CMAKE_ASM_COMPILER)
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -g")
endif()

find_package(raylib ${RAYLIB_VERSION} QUIET)
if(NOT raylib_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        raylib
        DOWNLOAD_EXTRACT_TIMESTAMP OFF
        URL https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz
    )
    FetchContent_GetProperties(raylib)
    if(NOT raylib_POPULATED)
        set(FETCHCONTENT_QUIET NO)
        FetchContent_MakeAvailable(raylib)
    endif()
endif()

add_executable(${PROJECT_NAME} main.s)
target_link_libraries(${PROJECT_NAME} raylib)

if(PLATFORM STREQUAL "Web")
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_GLFW=3 -s ASSERTIONS=1 -s WASM=1 -s ASYNCIFY -s GL_ENABLE_GET_PROC_ADDRESS=1")
endif()

if(APPLE)
    target_link_libraries(${PROJECT_NAME} 
        "-framework IOKit"
        "-framework Cocoa" 
        "-framework OpenGL"
    )
endif()