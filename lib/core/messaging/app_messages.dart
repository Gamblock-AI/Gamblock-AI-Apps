import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class AppMessages {
  AppMessages._();

  static String generic(BuildContext context) =>
      AppLocalizations.of(context)!.msgErrGeneric;

  static String forCode(BuildContext context, String? code) {
    final loc = AppLocalizations.of(context)!;
    if (code == null) return loc.msgErrGeneric;
    switch (code) {
      case 'email_required':
        return loc.msgErrEmailRequired;
      case 'validation_failed':
        return loc.msgErrEmailNameRequired;
      case 'invalid_credentials':
        return loc.msgErrInvalidCredentials;
      case 'registration_failed':
        return loc.msgErrRegisterFailed;
      case 'dev_login_failed':
        return loc.msgErrDevLogin;
      case 'google_token_required':
        return loc.msgErrGoogleTokenRequired;
      case 'google_verification_failed':
        return loc.msgErrGoogleVerification;
      case 'invalid_refresh_token':
        return loc.msgErrInvalidSession;
      case 'refresh_token_required':
        return loc.msgErrSessionExpired;
      case 'logout_failed':
        return loc.msgErrLogout;
      case 'device_create_failed':
        return loc.msgErrCreateDevice;
      case 'device_update_failed':
        return loc.msgErrUpdateDevice;
      case 'heartbeat_failed':
        return loc.msgErrHeartbeat;
      case 'partner_email_required':
        return loc.msgErrPartnerEmailRequired;
      case 'fetch_partners_failed':
        return loc.msgErrLoadPartner;
      case 'partner_invite_failed':
        return loc.msgErrSendInvite;
      case 'partner_accept_failed':
        return loc.msgErrAcceptInvite;
      case 'partner_revoke_failed':
        return loc.msgErrDisconnectPartner;
      case 'fetch_approval_requests_failed':
        return loc.msgErrLoadRequests;
      case 'action_required':
        return loc.msgErrActionRequired;
      case 'approval_request_failed':
        return loc.msgErrSubmitRequest;
      case 'approval_cancel_failed':
        return loc.msgErrCancelRequest;
      case 'approval_approve_failed':
        return loc.msgErrApproveRequest;
      case 'approval_deny_failed':
        return loc.msgErrRejectRequest;
      case 'name_required':
        return loc.msgErrGroupNameRequired;
      case 'create_org_failed':
        return loc.msgErrCreateGroup;
      case 'org_not_found':
        return loc.msgErrGroupNotFound;
      case 'group_code_required':
        return loc.msgErrGroupCodeRequired;
      case 'join_failed':
        return loc.msgErrInvalidGroupCodeSpecific;
      case 'no_org':
        return loc.msgErrNotInGroup;
      case 'list_members_failed':
        return loc.msgErrLoadMembers;
      case 'analytics_failed':
        return loc.msgErrLoadGroupAnalytics;
      case 'remove_member_failed':
        return loc.msgErrRemoveMember;
      case 'mission_fetch_failed':
        return loc.msgErrLoadMissions;
      case 'invalid_mission':
        return loc.msgErrInvalidMission;
      case 'mission_update_failed':
        return loc.msgErrUpdateMission;
      case 'fetch_reflections_failed':
        return loc.msgErrLoadJournal;
      case 'reflection_create_failed':
        return loc.msgErrSaveJournal;
      case 'fetch_modules_failed':
        return loc.msgErrLoadPsychoeducation;
      case 'module_not_found':
        return loc.msgErrModuleNotFound;
      case 'text_required':
        return loc.msgErrTextRequired;
      case 'token_required':
        return loc.msgErrTokenRequired;
      case 'invalid_token':
        return loc.msgErrInvalidToken;
      case 'invalid_input':
        return loc.msgErrInvalidInput;
      case 'resolve_failed':
        return loc.msgErrProcessRequest;
      case 'fetch_support_cases_failed':
        return loc.msgErrLoadTicket;
      case 'support_case_failed':
        return loc.msgErrSendTicket;
      case 'summary_required':
        return loc.msgErrSummaryRequired;
      case 'fetch_data_requests_failed':
        return loc.msgErrLoadDataRequest;
      case 'data_request_failed':
        return loc.msgErrSubmitDataRequest;
      case 'type_required':
        return loc.msgErrTypeRequired;
      case 'fetch_admin_modules_failed':
        return loc.msgErrLoadAdminModules;
      case 'fetch_admin_model_releases_failed':
        return loc.msgErrLoadAdminModelReleases;
      case 'fetch_admin_support_cases_failed':
        return loc.msgErrLoadAdminSupportCases;
      case 'create_model_release_failed':
        return loc.msgErrCreateModelRelease;
      case 'create_ruleset_release_failed':
        return loc.msgErrCreateRulesetRelease;
      case 'create_network_release_failed':
        return loc.msgErrCreateNetworkRelease;
      case 'release_not_found':
        return loc.msgErrReleaseNotFound;
      case 'generate_key_failed':
        return loc.msgErrCreateEmergencyKey;
      case 'emergency_key_required':
        return loc.msgErrEmergencyKeyRequired;
      case 'invalid_key':
        return loc.msgErrInvalidEmergencyKey;
      default:
        return loc.msgErrGeneric;
    }
  }

  static String friendlyMessage(BuildContext context, Object error) {
    final code = _extractCode(error);
    final backendMessage = _extractMessage(error);
    final status = _extractStatus(error);

    if (!AppConfig.isProduction) {
      if (code != null) {
        return '[$code] ${backendMessage ?? forCode(context, code)}';
      }
      if (status != null) return 'API error: $status';
      return error.toString();
    }

    if (backendMessage != null && backendMessage.trim().isNotEmpty) {
      return backendMessage;
    }
    if (code != null) return forCode(context, code);
    if (status != null) return _statusMessage(context, status);
    return generic(context);
  }

  static String? _extractCode(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          final code = err['code'];
          if (code is String) return code;
        }
      }
    }
    return null;
  }

  static String? _extractMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          final msg = err['message'];
          if (msg is String) return msg;
        }
      }
    }
    return null;
  }

  static int? _extractStatus(Object error) {
    if (error is DioException) return error.response?.statusCode;
    return null;
  }

  static String _statusMessage(BuildContext context, int status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case 400:
        return loc.msgErrInvalidRequest;
      case 401:
        return loc.msgErrSessionExpired;
      case 403:
        return loc.msgErrUnauthorized;
      case 404:
        return loc.msgErrDataNotFound;
      case 409:
        return loc.msgErrDataConflict;
      case 429:
        return loc.msgErrTooManyRequests;
      case 500:
      case 502:
      case 503:
        return loc.msgErrServerBusy;
      default:
        return loc.msgErrGeneric;
    }
  }
}
