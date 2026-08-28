#include "native_protection_bridge.h"

#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>

#include <utility>

#include "native_protection_codec.h"

namespace {

using gamblock::native_bridge::AggregateItems;
using gamblock::native_bridge::Arguments;
using gamblock::native_bridge::EscapeJson;
using gamblock::native_bridge::FindArgument;
using gamblock::native_bridge::JsonBool;
using gamblock::native_bridge::JsonString;
using gamblock::native_bridge::SelfTestMap;
using gamblock::native_bridge::SerializeList;
using gamblock::native_bridge::SnapshotMap;

} // namespace

void NativeProtectionBridge::ConfigureMethodChannel(
    flutter::FlutterEngine *engine) {
  method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), "com.gamblock/protection",
          &flutter::StandardMethodCodec::GetInstance());
  method_channel_->SetMethodCallHandler([this](const auto &call, auto result) {
    const auto *arguments = Arguments(call);
    if (call.method_name() == "getProtectionSnapshot") {
      result->Success(
          flutter::EncodableValue(SnapshotMap(CallService("snapshot"))));
    } else if (call.method_name() == "openPlatformSetup") {
      // Production setup is owned by the per-machine MSI. Never elevate a
      // script or register a service binary from a user-writable bundle.
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("snapshot"), "service_running", false)));
    } else if (call.method_name() == "runLocalSelfTest") {
      result->Success(
          flutter::EncodableValue(SelfTestMap(CallService("self_test"))));
    } else if (call.method_name() == "setDeviceId") {
      const auto *value = FindArgument(arguments, "device_id");
      const auto *device = value ? std::get_if<std::string>(value) : nullptr;
      const std::string fields = ",\"device_id\":\"" +
                                 EscapeJson(device == nullptr ? "" : *device) +
                                 "\"";
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("set_device", fields), "ok")));
    } else if (call.method_name() == "getGrantKeyEnrollment") {
      const auto *device_value = FindArgument(arguments, "device_id");
      const auto *device =
          device_value ? std::get_if<std::string>(device_value) : nullptr;
      const auto *challenge_value = FindArgument(arguments, "challenge_token");
      const auto *challenge =
          challenge_value ? std::get_if<std::string>(challenge_value) : nullptr;
      const std::string fields =
          ",\"device_id\":\"" + EscapeJson(device == nullptr ? "" : *device) +
          "\",\"challenge_token\":\"" +
          EscapeJson(challenge == nullptr ? "" : *challenge) + "\"";
      const std::string response =
          CallService("get_grant_key_enrollment", fields);
      result->Success(flutter::EncodableValue(flutter::EncodableMap{
          {flutter::EncodableValue("public_jwk"),
           flutter::EncodableValue(JsonString(response, "public_jwk"))},
          {flutter::EncodableValue("jwk_thumbprint"),
           flutter::EncodableValue(JsonString(response, "jwk_thumbprint"))},
          {flutter::EncodableValue("proof"),
           flutter::EncodableValue(JsonString(response, "proof"))},
      }));
    } else if (call.method_name() == "drainDailyAggregates") {
      result->Success(flutter::EncodableValue(
          AggregateItems(CallService("drain_aggregates"))));
    } else if (call.method_name() == "getCurrentDailyAggregates") {
      result->Success(flutter::EncodableValue(
          AggregateItems(CallService("current_aggregates"))));
    } else if (call.method_name() == "ackDailyAggregates") {
      const auto *value = FindArgument(arguments, "keys");
      const auto *keys =
          value ? std::get_if<flutter::EncodableList>(value) : nullptr;
      const std::string fields =
          ",\"keys\":" +
          (keys == nullptr ? std::string("[]") : SerializeList(*keys));
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("ack_aggregates", fields), "ok")));
    } else if (call.method_name() == "storeProtectionGrant") {
      const auto *value = FindArgument(arguments, "grant_token");
      const auto *token = value ? std::get_if<std::string>(value) : nullptr;
      const std::string fields = ",\"grant_token\":\"" +
                                 EscapeJson(token == nullptr ? "" : *token) +
                                 "\"";
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("store_grant", fields), "ok")));
    } else if (call.method_name() == "getPairingToken" ||
               call.method_name() == "rotatePairingToken") {
      const std::string response = CallService(
          call.method_name() == "getPairingToken" ? "get_pairing_token"
                                                  : "rotate_pairing_token");
      result->Success(
          flutter::EncodableValue(JsonString(response, "pairing_token")));
    } else if (call.method_name() == "setHealthNotifications") {
      result->Success(flutter::EncodableValue(true));
    } else if (call.method_name() == "recordInterventionCommitted") {
      const auto *value = FindArgument(arguments, "evidence_id");
      const auto *evidence_id =
          value ? std::get_if<std::string>(value) : nullptr;
      const std::string fields =
          ",\"evidence_id\":\"" +
          EscapeJson(evidence_id == nullptr ? "" : *evidence_id) + "\"";
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("intervention_committed", fields), "ok")));
    } else if (call.method_name() == "ackInterventionVisible") {
      FlushPendingBlockAction(750);
      const auto *value = FindArgument(arguments, "intervention_id");
      const auto *intervention_id =
          value ? std::get_if<std::string>(value) : nullptr;
      const std::string fields =
          ",\"intervention_id\":\"" +
          EscapeJson(intervention_id == nullptr ? "" : *intervention_id) + "\"";
      const bool acknowledged =
          JsonBool(CallService("ack_intervention_visible", fields, 1000), "ok");
      if (acknowledged)
        HideNativeInterventionShell();
      result->Success(flutter::EncodableValue(acknowledged));
    } else if (call.method_name() == "completeIntervention") {
      FlushPendingBlockAction(750);
      const auto *value = FindArgument(arguments, "intervention_id");
      const auto *intervention_id =
          value ? std::get_if<std::string>(value) : nullptr;
      const std::string id = intervention_id == nullptr ? "" : *intervention_id;
      const std::string fields =
          ",\"intervention_id\":\"" + EscapeJson(id) + "\"";
      const bool completed =
          JsonBool(CallService("complete_intervention", fields, 1000), "ok");
      if (completed && id == active_intervention_id_) {
        KillTimer(window_, kInterventionExpiryTimer);
        KillTimer(window_, kInterventionCloseGateTimer);
        active_intervention_id_.clear();
        HideNativeInterventionShell();
        pending_block_action_result_.reset();
        if (intervention_lock_changed_)
          intervention_lock_changed_(false);
      }
      result->Success(flutter::EncodableValue(completed));
    } else if (call.method_name() == "beginApprovedRemoval") {
      result->Success(flutter::EncodableValue(
          JsonBool(CallService("begin_approved_removal", "", 10000), "ok")));
    } else {
      result->NotImplemented();
    }
  });
}

void NativeProtectionBridge::ConfigureEventChannel(
    flutter::FlutterEngine *engine) {
  event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          engine->messenger(), "com.gamblock/intervention",
          &flutter::StandardMethodCodec::GetInstance());
  event_channel_->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue *,
                 std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
                     &&sink) {
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
          [this](const flutter::EncodableValue *) {
            event_sink_.reset();
            return nullptr;
          }));
}
