include_guard(GLOBAL)

find_program(GO_EXECUTABLE go REQUIRED)

# ---- User options (set via presets or -D) ----
set(GO_OS   ""  CACHE STRING "Target GOOS (empty = host)")
set(GO_ARCH ""  CACHE STRING "Target GOARCH (empty = host)")
set(GO_BUILD_TAGS "" CACHE STRING "Go build tags, comma separated")
option(GO_ENABLE_CGO "Enable cgo (needs a C compiler)" OFF)
set(GO_CC  "" CACHE STRING "C compiler used by cgo (e.g. gcc, clang)")
set(GO_CXX "" CACHE STRING "C++ compiler used by cgo (e.g. g++, clang++)")

# ---- Version info ----
execute_process(
  COMMAND git rev-parse --short HEAD
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  OUTPUT_VARIABLE GO_GIT_COMMIT
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET)
if (NOT GO_GIT_COMMIT)
  set(GO_GIT_COMMIT "unknown")
endif()

# ---- Environment passed to every go command ----
function(_go_env out_var)
  set(env_list "")
  if (GO_OS)
    list(APPEND env_list "GOOS=${GO_OS}")
  endif()
  if (GO_ARCH)
    list(APPEND env_list "GOARCH=${GO_ARCH}")
  endif()
  if (GO_ENABLE_CGO)
    list(APPEND env_list "CGO_ENABLED=1")
    if (GO_CC)
      list(APPEND env_list "CC=${GO_CC}")
    endif()
    if (GO_CXX)
      list(APPEND env_list "CXX=${GO_CXX}")
    endif()
  else()
    list(APPEND env_list "CGO_ENABLED=0")
  endif()
  set(${out_var} ${env_list} PARENT_SCOPE)
endfunction()

# ---- add_go_executable(<target> SOURCE_DIR <dir> [PACKAGE <pkg>] [OUTPUT_NAME <name>]) ----
function(add_go_executable target)
  cmake_parse_arguments(ARG "" "SOURCE_DIR;PACKAGE;OUTPUT_NAME" "" ${ARGN})

  if (NOT ARG_SOURCE_DIR)
    set(ARG_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()
  if (NOT ARG_PACKAGE)
    set(ARG_PACKAGE ".")
  endif()
  if (NOT ARG_OUTPUT_NAME)
    set(ARG_OUTPUT_NAME "${target}")
  endif()

  # Executable suffix depends on the *target* OS
  if (GO_OS STREQUAL "windows" OR (NOT GO_OS AND CMAKE_HOST_WIN32))
    set(exe_suffix ".exe")
  else()
    set(exe_suffix "")
  endif()

  set(output "${CMAKE_BINARY_DIR}/bin/${ARG_OUTPUT_NAME}${exe_suffix}")
  _go_env(go_env)

  # Build flags
  set(build_args build)
  if (GO_BUILD_TAGS)
    list(APPEND build_args "-tags=${GO_BUILD_TAGS}")
  endif()

  set(ldflags "-X main.version=${PROJECT_VERSION} -X main.commit=${GO_GIT_COMMIT}")
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND build_args "-gcflags=all=-N -l")
  else()
    list(APPEND build_args -trimpath)
    set(ldflags "-s -w ${ldflags}")
  endif()
  list(APPEND build_args "-ldflags=${ldflags}" -o "${output}" "${ARG_PACKAGE}")

  add_custom_target(${target} ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/bin"
    COMMAND "${CMAKE_COMMAND}" -E env ${go_env} "${GO_EXECUTABLE}" ${build_args}
    WORKING_DIRECTORY "${ARG_SOURCE_DIR}"
    COMMENT "go build ${target} (GOOS=${GO_OS} GOARCH=${GO_ARCH} CGO=${GO_ENABLE_CGO})"
    USES_TERMINAL
    VERBATIM)

  add_custom_target(${target}_run
    COMMAND "${CMAKE_COMMAND}" -E env ${go_env} "${output}"
    DEPENDS ${target}
    WORKING_DIRECTORY "${ARG_SOURCE_DIR}"
    USES_TERMINAL
    VERBATIM)

  add_custom_target(${target}_fmt
    COMMAND "${GO_EXECUTABLE}" fmt ./...
    WORKING_DIRECTORY "${ARG_SOURCE_DIR}"
    USES_TERMINAL
    VERBATIM)

  add_custom_target(${target}_vet
    COMMAND "${CMAKE_COMMAND}" -E env ${go_env} "${GO_EXECUTABLE}" vet ./...
    WORKING_DIRECTORY "${ARG_SOURCE_DIR}"
    USES_TERMINAL
    VERBATIM)

  add_custom_target(${target}_test
    COMMAND "${CMAKE_COMMAND}" -E env ${go_env} "${GO_EXECUTABLE}" test ./...
    WORKING_DIRECTORY "${ARG_SOURCE_DIR}"
    USES_TERMINAL
    VERBATIM)

  # ctest integration (not for cross-compiled binaries)
  if (NOT GO_OS AND NOT GO_ARCH)
    add_test(NAME ${target}_gotest
      COMMAND "${CMAKE_COMMAND}" -E env ${go_env} "${GO_EXECUTABLE}" test ./...
      WORKING_DIRECTORY "${ARG_SOURCE_DIR}")
  endif()

  install(PROGRAMS "${output}" DESTINATION bin)
endfunction()