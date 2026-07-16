add_library(gamblock_hybrid STATIC
  "hybrid_classifier.cpp"
)
apply_standard_settings(gamblock_hybrid)
target_include_directories(gamblock_hybrid PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

option(GAMBLOCK_BUILD_NATIVE_TESTS "Build portable Hybrid-v1 fixture tests" OFF)
if(GAMBLOCK_BUILD_NATIVE_TESTS)
  enable_testing()
  add_executable(gamblock_hybrid_test "hybrid_classifier_test.cpp")
  target_compile_features(gamblock_hybrid_test PRIVATE cxx_std_17)
  target_link_libraries(gamblock_hybrid_test PRIVATE gamblock_hybrid)
  add_test(
    NAME gamblock_hybrid_fixtures
    COMMAND gamblock_hybrid_test
      "${CMAKE_SOURCE_DIR}/../assets/protection/dummy-lr-v1.json"
      "${CMAKE_SOURCE_DIR}/../assets/protection/dummy-rules-v1.json"
  )
endif()
