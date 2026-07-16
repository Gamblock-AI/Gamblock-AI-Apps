#ifndef RUNNER_NATIVE_PROTECTION_CODEC_H_
#define RUNNER_NATIVE_PROTECTION_CODEC_H_

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <string>

namespace gamblock::native_bridge {

std::wstring ExecutableDirectory();
std::string EscapeJson(const std::string& value);
std::string JsonString(const std::string& json,
                       const std::string& key,
                       const std::string& fallback = "");
bool JsonBool(const std::string& json,
              const std::string& key,
              bool fallback = false);
int JsonInt(const std::string& json,
            const std::string& key,
            int fallback = 0);

flutter::EncodableMap SnapshotMap(const std::string& json);
flutter::EncodableMap SelfTestMap(const std::string& json);
flutter::EncodableList AggregateItems(const std::string& json);
std::string SerializeMap(const flutter::EncodableMap& map);
std::string SerializeList(const flutter::EncodableList& list);
const flutter::EncodableMap* Arguments(
    const flutter::MethodCall<flutter::EncodableValue>& call);
const flutter::EncodableValue* FindArgument(
    const flutter::EncodableMap* arguments,
    const std::string& key);

}  // namespace gamblock::native_bridge

#endif  // RUNNER_NATIVE_PROTECTION_CODEC_H_
