# CMake Dependency Manager

## Overview
CMake Dependency Manager is a lightweight and flexible CMake module for managing project dependencies. It allows you to:

- Use local repositories when available
- Fetch dependencies from remote Git repositories when needed
- Detect version conflicts and uncommitted changes
- Keep CMakeLists.txt clean and readable

## Features
- **Local-first approach**: Prioritizes local copies of dependencies
- **Version locking**: Ensures correct dependency versions are used
- **Conflict detection**: Warns about uncommitted changes or extra commits
- **Modular design**: Easy to integrate into any CMake project
- **Optional fetching**: Avoids unnecessary downloads

## Installation
Clone this repository or add it as a submodule in your project:

```sh
git submodule add https://github.com/Delta-dev-99/CMake-Dependency-Manager.git cmake-dependency-manager
```

Then, in your `CMakeLists.txt`, add the following:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-dependency-manager/cmake")
include(ManageDependencies)
```

## Usage

### 1. Declaring Dependencies
Use `declare_dependency` to specify project dependencies:

```cmake
declare_dependency(
    NAME MyLibrary
    GIT_URL https://github.com/someuser/MyLibrary.git
    GIT_TAG v1.2.3
    LOCAL_PATH ${CMAKE_SOURCE_DIR}/external/MyLibrary
)
```

### 2. Fetching Dependencies
After declaring dependencies, call:

```cmake
fetch_dependencies()
```

This will:
- Use the local copy if available and clean
- Warn if the local copy has conflicts
- Fetch the dependency from the remote Git repository if needed

### 3. Enabling Tests
To enable tests, configure CMake with:

```sh
cmake -DENABLE_TESTS=ON ..
make
ctest
```

## Project Structure
```
cmp-dependency-manager/
│── cmake/
│   ├── ManageDependencies.cmake  # Main dependency manager
│── tests/
│   ├── CMakeLists.txt            # Test suite
│   ├── test_fetching.cmake       # Fetching tests
│── examples/
│── CMakeLists.txt
│── README.md
│── LICENSE
│── .gitignore
```

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project is licensed under the MIT License.

