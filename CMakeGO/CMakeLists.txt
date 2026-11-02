# CMakeList.txt : CMake project for CMakeGO, include source and define
# project specific logic here.
#

# Go integration: targets go-app, go-app_run, go-app_test, go-app_vet, go-app_fmt
add_go_executable(go-app SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
