#include "service_support.h"

#include <winhttp.h>

namespace gamblock {

std::optional<std::vector<unsigned char>> HttpGet(const std::string& base_url,
                                                  const std::string& path) {
  const std::string combined =
      path.rfind("http://", 0) == 0 || path.rfind("https://", 0) == 0
          ? path
          : base_url.substr(0, base_url.find_last_not_of('/') + 1) + "/" +
                path.substr(path.find_first_not_of('/'));
  const std::wstring url = Widen(combined);
  URL_COMPONENTSW components{};
  components.dwStructSize = sizeof(components);
  components.dwSchemeLength = static_cast<DWORD>(-1);
  components.dwHostNameLength = static_cast<DWORD>(-1);
  components.dwUrlPathLength = static_cast<DWORD>(-1);
  components.dwExtraInfoLength = static_cast<DWORD>(-1);
  if (!WinHttpCrackUrl(url.c_str(), static_cast<DWORD>(url.size()), 0,
                       &components)) return std::nullopt;

  const std::wstring host(components.lpszHostName,
                          components.dwHostNameLength);
  std::wstring target(components.lpszUrlPath, components.dwUrlPathLength);
  if (components.dwExtraInfoLength > 0) {
    target.append(components.lpszExtraInfo, components.dwExtraInfoLength);
  }
  HINTERNET session = WinHttpOpen(
      L"GamblockAI/1.0", WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY,
      WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
  if (session == nullptr) return std::nullopt;
  WinHttpSetTimeouts(session, 10000, 10000, 15000, 15000);
  HINTERNET connection = WinHttpConnect(session, host.c_str(),
                                        components.nPort, 0);
  if (connection == nullptr) {
    WinHttpCloseHandle(session);
    return std::nullopt;
  }
  const DWORD flags = components.nScheme == INTERNET_SCHEME_HTTPS
                          ? WINHTTP_FLAG_SECURE
                          : 0;
  HINTERNET request = WinHttpOpenRequest(
      connection, L"GET", target.c_str(), nullptr, WINHTTP_NO_REFERER,
      WINHTTP_DEFAULT_ACCEPT_TYPES, flags);
  if (request == nullptr ||
      !WinHttpSendRequest(request, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                          WINHTTP_NO_REQUEST_DATA, 0, 0, 0) ||
      !WinHttpReceiveResponse(request, nullptr)) {
    if (request) WinHttpCloseHandle(request);
    WinHttpCloseHandle(connection);
    WinHttpCloseHandle(session);
    return std::nullopt;
  }

  DWORD status = 0;
  DWORD status_size = sizeof(status);
  WinHttpQueryHeaders(request,
                      WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                      WINHTTP_HEADER_NAME_BY_INDEX, &status, &status_size,
                      WINHTTP_NO_HEADER_INDEX);
  std::vector<unsigned char> body;
  while (status >= 200 && status < 300) {
    DWORD available = 0;
    if (!WinHttpQueryDataAvailable(request, &available) || available == 0) {
      break;
    }
    const size_t offset = body.size();
    body.resize(offset + available);
    DWORD read = 0;
    if (!WinHttpReadData(request, body.data() + offset, available, &read)) {
      body.clear();
      break;
    }
    body.resize(offset + read);
  }
  WinHttpCloseHandle(request);
  WinHttpCloseHandle(connection);
  WinHttpCloseHandle(session);
  return status >= 200 && status < 300
             ? std::optional<std::vector<unsigned char>>(std::move(body))
             : std::nullopt;
}

}  // namespace gamblock
