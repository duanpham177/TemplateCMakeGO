# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.25)

project(CMakeGO VERSION 1.0.0 LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(GoHelpers)

enable_testing()

# Include sub-projects.
add_subdirectory ("CMakeGO")

