#include "service_support.h"

#include <aclapi.h>
#include <wtsapi32.h>

namespace gamblock {

bool BuildPipeSecurity(DWORD session_id,
                       SECURITY_ATTRIBUTES* attributes,
                       PSECURITY_DESCRIPTOR* descriptor,
                       PACL* acl) {
  HANDLE user_token = nullptr;
  if (session_id == 0xffffffff ||
      !WTSQueryUserToken(session_id, &user_token)) {
    return false;
  }
  DWORD token_bytes = 0;
  GetTokenInformation(user_token, TokenLogonSid, nullptr, 0, &token_bytes);
  std::vector<BYTE> token_buffer(token_bytes);
  if (!GetTokenInformation(user_token, TokenLogonSid, token_buffer.data(),
                           token_bytes, &token_bytes)) {
    CloseHandle(user_token);
    return false;
  }
  CloseHandle(user_token);
  const auto* groups = reinterpret_cast<const TOKEN_GROUPS*>(token_buffer.data());
  PSID logon_sid = groups->Groups[0].Sid;
  SID_IDENTIFIER_AUTHORITY nt_authority = SECURITY_NT_AUTHORITY;
  PSID system_sid = nullptr;
  if (!AllocateAndInitializeSid(&nt_authority, 1, SECURITY_LOCAL_SYSTEM_RID, 0,
                                0, 0, 0, 0, 0, 0, &system_sid)) return false;
  EXPLICIT_ACCESSW entries[2]{};
  for (auto& entry : entries) {
    entry.grfAccessPermissions = GENERIC_READ | GENERIC_WRITE;
    entry.grfAccessMode = SET_ACCESS;
    entry.grfInheritance = NO_INHERITANCE;
    entry.Trustee.TrusteeForm = TRUSTEE_IS_SID;
    entry.Trustee.TrusteeType = TRUSTEE_IS_USER;
  }
  entries[0].Trustee.ptstrName = static_cast<LPWSTR>(logon_sid);
  entries[1].Trustee.ptstrName = static_cast<LPWSTR>(system_sid);
  const DWORD acl_result = SetEntriesInAclW(2, entries, nullptr, acl);
  FreeSid(system_sid);
  if (acl_result != ERROR_SUCCESS) return false;
  *descriptor = static_cast<PSECURITY_DESCRIPTOR>(
      LocalAlloc(LPTR, SECURITY_DESCRIPTOR_MIN_LENGTH));
  if (*descriptor == nullptr ||
      !InitializeSecurityDescriptor(*descriptor, SECURITY_DESCRIPTOR_REVISION) ||
      !SetSecurityDescriptorDacl(*descriptor, TRUE, *acl, FALSE)) {
    if (*descriptor) LocalFree(*descriptor);
    if (*acl) LocalFree(*acl);
    return false;
  }
  attributes->nLength = sizeof(SECURITY_ATTRIBUTES);
  attributes->lpSecurityDescriptor = *descriptor;
  attributes->bInheritHandle = FALSE;
  return true;
}

}  // namespace gamblock
