cmake_minimum_required(VERSION 3.10)
project(TensorFlowExamples VERSION 0.0.0 LANGUAGES CXX)

#==
# Dependencies
#==

find_package(TensorFlow CONFIG REQUIRED)

#==
# Build target
#==

add_executable(tf_hello_world src/main.cpp)
target_link_libraries(tf_hello_world PUBLIC TensorFlow::TensorFlow)
target_compile_features(tf_hello_world PRIVATE cxx_std_14)

#==
# Package installation
#==

install(
  TARGETS tf_hello_world
  RUNTIME DESTINATION bin
)

# EOF
