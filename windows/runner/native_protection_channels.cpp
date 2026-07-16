#include "native_protection_bridge.h"

#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>

#include <utility>

#include "native_protection_codec.h"

namespace {

using gamblock::native_bridge::AggregateItems;
using gamblock::native_bridge::Arguments;
using gamblock::native_bridge::EscapeJson;
using gamblock::native_bridge::ExecutableDirectory;
using gamblock::native_bridge::FindArgument;
using gamblock::native_bridge::JsonBool;
using gamblock::native_bridge::JsonString;
using gamblock::native_bridge::SelfTestMap;
using gamblock::native_bridge::SerializeList;
using gamblock::native_bridge::SerializeMap;
using gamblock::native_bridge::SnapshotMap;

}  // namespace

void NativeProtectionBridge::ConfigureMethodChannel(
    flutter::FlutterEngine* engine) {
  method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), "com.gamblock/protection",
          &flutter::StandardMethodCodec::GetInstance());
  method_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        const auto* arguments = Arguments(call);
        if (call.method_name() == "getProtectionSnapshot") {
          result->Success(flutter::EncodableValue(SnapshotMap(CallService("snapshot"))));
        } else if (call.method_name() == "openPlatformSetup") {
          const std::wstring script =
              ExecutableDirectory() + L"\\scripts\\install-service.ps1";
          const std::wstring shell_arguments =
              L"-NoProfile -ExecutionPolicy Bypass -File \"" + script + L"\"";
          const auto launched = reinterpret_cast<INT_PTR>(ShellExecuteW(
              window_, L"runas", L"powershell.exe", shell_arguments.c_str(),
              ExecutableDirectory().c_str(), SW_SHOWNORMAL));
          result->Success(flutter::EncodableValue(launched > 32));
        } else if (call.method_name() == "runLocalSelfTest") {
          result->Success(flutter::EncodableValue(
              SelfTestMap(CallService("self_test"))));
        } else if (call.method_name() == "checkArtifactUpdates") {
          const auto* value = FindArgument(arguments, "base_url");
          const auto* base_url = value ? std::get_if<std::string>(value) : nullptr;
          const std::string fields = ",\"base_url\":\"" +
              EscapeJson(base_url == nullptr ? "" : *base_url) + "\"";
          const std::string response = CallService("check_artifacts", fields, 30000);
          result->Success(flutter::EncodableValue(flutter::EncodableMap{
              {flutter::EncodableValue("checked"),
               flutter::EncodableValue(JsonBool(response, "checked", false))},
          }));
        } else if (call.method_name() == "setDeviceId") {
          const auto* value = FindArgument(arguments, "device_id");
          const auto* device = value ? std::get_if<std::string>(value) : nullptr;
          const std::string fields = ",\"device_id\":\"" +
              EscapeJson(device == nullptr ? "" : *device) + "\"";
          result->Success(flutter::EncodableValue(
              JsonBool(CallService("set_device", fields), "ok")));
        } else if (call.method_name() == "drainDailyAggregates") {
          result->Success(flutter::EncodableValue(
              AggregateItems(CallService("drain_aggregates"))));
        } else if (call.method_name() == "getCurrentDailyAggregates") {
          result->Success(flutter::EncodableValue(
              AggregateItems(CallService("current_aggregates"))));
        } else if (call.method_name() == "ackDailyAggregates") {
          const auto* value = FindArgument(arguments, "keys");
          const auto* keys = value ? std::get_if<flutter::EncodableList>(value) : nullptr;
          const std::string fields = ",\"keys\":" +
              (keys == nullptr ? std::string("[]") : SerializeList(*keys));
          result->Success(flutter::EncodableValue(
              JsonBool(CallService("ack_aggregates", fields), "ok")));
        } else if (call.method_name() == "storeProtectionGrant") {
          const auto* value = FindArgument(arguments, "grant");
          const auto* grant = value ? std::get_if<flutter::EncodableMap>(value) : nullptr;
          const std::string fields = ",\"grant\":" +
              (grant == nullptr ? std::string("{}") : SerializeMap(*grant));
          result->Success(flutter::EncodableValue(
              JsonBool(CallService("store_grant", fields), "ok")));
        } else if (call.method_name() == "getPairingToken" ||
                   call.method_name() == "rotatePairingToken") {
          const std::string response = CallService(
              call.method_name() == "getPairingToken"
                  ? "get_pairing_token"
                  : "rotate_pairing_token");
          result->Success(flutter::EncodableValue(
              JsonString(response, "pairing_token")));
        } else if (call.method_name() == "setHealthNotifications") {
          result->Success(flutter::EncodableValue(true));
        } else {
          result->NotImplemented();
        }
      });
}

void NativeProtectionBridge::ConfigureEventChannel(
    flutter::FlutterEngine* engine) {
  event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          engine->messenger(), "com.gamblock/intervention",
          &flutter::StandardMethodCodec::GetInstance());
  event_channel_->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue*,
                 std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& sink) {
            event_sink_ = std::move(sink);
            std::queue<std::string> pending;
            {
              std::lock_guard lock(event_mutex_);
              std::swap(pending, pending_flutter_events_);
            }
            while (!pending.empty()) {
              DispatchEvent(pending.front());
              pending.pop();
            }
            return nullptr;
          },
          [this](const flutter::EncodableValue*) {
            event_sink_.reset();
            return nullptr;
          }));
}
