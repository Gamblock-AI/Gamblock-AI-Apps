add_executable(gamblock_ai_service
  "main.cpp"
  "json_support.cpp"
  "local_state.cpp"
  "network_client.cpp"
  "pipe_security.cpp"
  "protection_service_agent.cpp"
  "protection_service_artifacts.cpp"
  "protection_service_pipe.cpp"
  "protection_service_runtime.cpp"
  "protection_service_state.cpp"
  "protection_service_websocket.cpp"
  "websocket_transport.cpp"
)
apply_standard_settings(gamblock_ai_service)
target_compile_definitions(gamblock_ai_service PRIVATE "NOMINMAX")
target_include_directories(gamblock_ai_service PRIVATE
  "${CMAKE_SOURCE_DIR}"
  "${CMAKE_SOURCE_DIR}/protection"
)
target_link_libraries(gamblock_ai_service PRIVATE
  gamblock_hybrid
  "advapi32.lib"
  "bcrypt.lib"
  "crypt32.lib"
  "shell32.lib"
  "userenv.lib"
  "winhttp.lib"
  "wtsapi32.lib"
  "ws2_32.lib"
)
