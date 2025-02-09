cmake_minimum_required(VERSION 3.20)
project(ManageDependencies LANGUAGES NONE)

# define options for the dependency manager
option(ENABLE_TESTS "Enable tests for the dependency manager" OFF)

# add the CMake module directory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# include the dependency manager module
include(ManageDependencies)

# if tests are enabled, add them
if(ENABLE_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# installation setup
install(FILES cmake/ManageDependencies.cmake DESTINATION share/cmake/CMakeDependencyManager)

# export the package
include(CMakePackageConfigHelpers)
configure_package_config_file(
    cmake/CMakeDependencyManagerConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/ManageDependenciesConfig.cmake
    INSTALL_DESTINATION share/cmake/CMakeDependencyManager
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/ManageDependenciesConfig.cmake
    DESTINATION share/cmake/CMakeDependencyManager
)
