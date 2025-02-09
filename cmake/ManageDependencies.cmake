include(FetchContent)

set(DECLARED_DEPENDENCIES "" CACHE INTERNAL "List of declared dependencies")

function(declare_dependency NAME)
    cmake_parse_arguments(
        PARSED_ARGS
        "" # No flags
        "GIT_URL;GIT_TAG;LOCAL_PATH" # Single value arguments
        "" # No multi-value arguments
        ${ARGN}
    )

    if(NOT DEFINED PARSED_ARGS_GIT_TAG)
        set(PARSED_ARGS_GIT_TAG "main")
    endif()

    list(APPEND DECLARED_DEPENDENCIES "${NAME};${PARSED_ARGS_GIT_URL};${PARSED_ARGS_GIT_TAG};${PARSED_ARGS_LOCAL_PATH}")
    set(DECLARED_DEPENDENCIES "${DECLARED_DEPENDENCIES}" CACHE INTERNAL "List of declared dependencies")
endfunction()

# Function to check for conflicts in the local repo
function(check_git_conflicts repo_path target_version out_var)
    find_package(Git QUIET)
    if(GIT_FOUND)
        # Check if the target version exists
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --verify ${target_version}
            WORKING_DIRECTORY ${repo_path}
            RESULT_VARIABLE version_exists
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )

        if(NOT version_exists EQUAL 0)
            set(${out_var} "MISSING_VERSION" PARENT_SCOPE)
            return()
        endif()

        # Check if there are uncommitted changes
        execute_process(
            COMMAND ${GIT_EXECUTABLE} status --porcelain
            WORKING_DIRECTORY ${repo_path}
            OUTPUT_VARIABLE git_status
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(NOT "${git_status}" STREQUAL "")
            set(${out_var} "UNCOMMITTED_CHANGES" PARENT_SCOPE)
            return()
        endif()

        # Check if there are extra commits beyond the requested version
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-list --count ${target_version}..HEAD
            WORKING_DIRECTORY ${repo_path}
            OUTPUT_VARIABLE extra_commits
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(NOT "${extra_commits}" STREQUAL "0")
            set(${out_var} "EXTRA_COMMITS" PARENT_SCOPE)
            return()
        endif()

        set(${out_var} "CLEAN" PARENT_SCOPE)
    else()
        set(${out_var} "GIT_NOT_FOUND" PARENT_SCOPE)
    endif()
endfunction()

# Function to fetch or use local dependencies
function(fetch_dependencies)
    foreach(DEP ${DECLARED_DEPENDENCIES})
        list(GET DEP 0 NAME)
        list(GET DEP 1 GIT_URL)
        list(GET DEP 2 GIT_TAG)
        list(GET DEP 3 LOCAL_PATH)

        set(WORKTREE_DEPENDENCY_PATH "${CMAKE_BINARY_DIR}/external/${NAME}")

        option(FETCH_${NAME} "Force fetching ${NAME} instead of using local copy" OFF)

        if(NOT FETCH_${NAME} AND EXISTS "${LOCAL_PATH}/.git")
            check_git_conflicts(${LOCAL_PATH} ${GIT_TAG} CONFLICT_STATUS)

            if(CONFLICT_STATUS STREQUAL "MISSING_VERSION")
                message(WARNING "Local ${NAME} does not have the required version (${GIT_TAG}). Fetching from GitHub instead.")
            elseif(CONFLICT_STATUS STREQUAL "UNCOMMITTED_CHANGES")
                message(WARNING "Local ${NAME} has uncommitted changes. Consider committing or stashing them before using it.")
            elseif(CONFLICT_STATUS STREQUAL "EXTRA_COMMITS")
                message(WARNING "Local ${NAME} has additional commits beyond ${GIT_TAG}. Consider checking out a clean version.")
            elseif(CONFLICT_STATUS STREQUAL "CLEAN")
                message(STATUS "Using local ${NAME} from ${LOCAL_PATH} (version ${GIT_TAG})")
                add_subdirectory(${LOCAL_PATH} external/${NAME})
                continue()
            endif()
        endif()

        message(STATUS "Fetching ${NAME} (${GIT_TAG}) from GitHub...")
        FetchContent_Declare(
            ${NAME}
            GIT_REPOSITORY ${GIT_URL}
            GIT_TAG ${GIT_TAG}
        )
        FetchContent_MakeAvailable(${NAME})
    endforeach()
endfunction()
