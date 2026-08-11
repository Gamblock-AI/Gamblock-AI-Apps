add_executable(gamblock_ai_service
  "crypto_support.cpp"
  "device_key.cpp"
  "grant_verifier.cpp"
  "main.cpp"
  "json_support.cpp"
  "local_state.cpp"
  "pipe_security.cpp"
  "protection_service_agent.cpp"
  "protection_service_artifacts.cpp"
  "protection_service_evidence.cpp"
  "protection_service_pipe.cpp"
  "protection_service_runtime.cpp"
  "protection_service_state.cpp"
  "protection_service_websocket.cpp"
  "websocket_transport.cpp"
)

set(PROTECTION_GRANT_TRUST_STORE_BASE64
  "$ENV{PROTECTION_GRANT_TRUST_STORE_BASE64}"
  CACHE STRING
  "Base64 JSON map of protection-grant kid to base64 DER P-256 SPKI")
if(DEFINED ENV{PROTECTION_GRANT_TRUST_STORE_BASE64})
  set(PROTECTION_GRANT_TRUST_STORE_BASE64
    "$ENV{PROTECTION_GRANT_TRUST_STORE_BASE64}"
    CACHE STRING
    "Base64 JSON map of protection-grant kid to base64 DER P-256 SPKI"
    FORCE)
endif()
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/grant_trust_store.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/grant_trust_store.h"
  @ONLY)

apply_standard_settings(gamblock_ai_service)
target_compile_definitions(gamblock_ai_service PRIVATE "NOMINMAX")
target_include_directories(gamblock_ai_service PRIVATE
  "${CMAKE_SOURCE_DIR}"
  "${CMAKE_SOURCE_DIR}/protection"
  "${CMAKE_CURRENT_BINARY_DIR}"
)
target_link_libraries(gamblock_ai_service PRIVATE
  gamblock_hybrid
  "advapi32.lib"
  "bcrypt.lib"
  "crypt32.lib"
  "ncrypt.lib"
  "shell32.lib"
  "userenv.lib"
  "wtsapi32.lib"
  "ws2_32.lib"
)

if(GAMBLOCK_BUILD_NATIVE_TESTS)
  add_executable(gamblock_grant_verifier_test
    "crypto_support.cpp"
    "grant_verifier.cpp"
    "grant_verifier_test.cpp"
  )
  apply_standard_settings(gamblock_grant_verifier_test)
  target_compile_definitions(gamblock_grant_verifier_test PRIVATE "NOMINMAX")
  target_link_libraries(gamblock_grant_verifier_test PRIVATE
    "bcrypt.lib"
    "crypt32.lib"
  )
  add_test(NAME gamblock_protection_grants
           COMMAND gamblock_grant_verifier_test)
endif()
