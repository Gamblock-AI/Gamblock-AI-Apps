import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class AppMessages {
  AppMessages._();

  static String generic(BuildContext context) =>
      AppLocalizations.of(context)!.msgErrGeneric;

  static String forCode(BuildContext context, String? code) {
    final loc = AppLocalizations.of(context)!;
    if (code == null) return loc.msgErrGeneric;
    switch (code) {
      case 'auth_required':
        return loc.msgErrAuthRequired;
      case 'forbidden':
        return loc.msgErrForbidden;
      case 'invalid_body':
        return loc.msgErrInvalidBody;
      case 'privacy_payload_rejected':
        return loc.msgErrPrivacyPayloadRejected;
      case 'err_validation':
        return loc.msgErrValidation;
      case 'err_internal':
        return loc.msgErrInternal;
      case 'create_admin_module_failed':
        return loc.msgErrCreateAdminModule;
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
      case 'password_reset_invalid':
        return loc.msgErrPasswordResetInvalid;
      case 'password_reset_failed':
        return loc.msgErrPasswordResetFailed;
      case 'initial_password_change_invalid':
      case 'phone_required':
      case 'admin_accounts_fetch_failed':
      case 'admin_account_create_failed':
      case 'admin_account_update_failed':
      case 'operator_invitation_retired':
        return loc.msgErrInvalidRequest;
      case 'invalid_refresh_token':
        return loc.msgErrInvalidSession;
      case 'refresh_token_required':
        return loc.msgErrSessionExpired;
      case 'logout_failed':
        return loc.msgErrLogout;
      case 'email_verification_failed':
      case 'email_verification_delivery_failed':
      case 'phone_verification_failed':
      case 'phone_verification_required':
      case 'recent_auth_required':
        return loc.msgErrInvalidRequest;
      case 'device_create_failed':
        return loc.msgErrCreateDevice;
      case 'device_id_required':
      case 'client_instance_required':
        return loc.msgErrCreateDevice;
      case 'device_update_failed':
        return loc.msgErrUpdateDevice;
      case 'heartbeat_failed':
        return loc.msgErrHeartbeat;
      case 'dashboard_summary_failed':
      case 'protection_status_failed':
      case 'progress_snapshot_failed':
      case 'aggregate_event_rejected':
      case 'profile_not_found':
      case 'profile_update_failed':
      case 'password_update_failed':
      case 'analytics_period_invalid':
      case 'protection_analytics_failed':
        return loc.msgErrGeneric;
      case 'reminder_preference_load_failed':
      case 'reminder_preference_update_failed':
      case 'push_subscription_update_failed':
        return loc.msgErrGeneric;
      case 'reminder_preference_invalid':
      case 'push_subscription_invalid':
        return loc.msgErrInvalidRequest;
      case 'password_validation_failed':
        return loc.msgErrPasswordValidation;
      case 'current_password_invalid':
        return loc.msgErrCurrentPasswordInvalid;
      case 'password_reuse_not_allowed':
        return loc.msgErrPasswordReuse;
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
      case 'approval_apply_failed':
        return loc.msgErrSubmitRequest;
      case 'accountability_workspace_failed':
        return loc.msgErrLoadPartner;
      case 'accountability_group_create_failed':
        return loc.msgErrCreateGroup;
      case 'accountability_code_invalid':
      case 'accountability_join_failed':
        return loc.msgErrInvalidGroupCodeSpecific;
      case 'accountability_code_rotate_failed':
      case 'accountability_group_archive_failed':
      case 'accountability_sharing_update_failed':
      case 'accountability_leave_failed':
      case 'accountability_leave_cancel_failed':
      case 'accountability_leave_resolve_failed':
      case 'accountability_member_remove_failed':
      case 'partner_contact_create_failed':
      case 'partner_contact_transition_failed':
        return loc.msgErrInvalidRequest;
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
      case 'custom_mission_limit':
      case 'custom_mission_invalid':
      case 'custom_mission_not_editable':
        return loc.msgErrUpdateMission;
      case 'learning_hub_fetch_failed':
      case 'learning_hub_progress_failed':
      case 'learning_hub_state_invalid':
      case 'learning_hub_checkpoint_invalid':
      case 'learning_hub_item_not_found':
      case 'learning_hub_mutation_failed':
      case 'learning_hub_admin_failed':
      case 'learning_hub_admin_not_found':
      case 'learning_hub_admin_validation_failed':
      case 'learning_hub_admin_conflict':
      case 'learning_hub_taxonomy_conflict':
        return loc.msgErrGeneric;
      case 'fetch_reflections_failed':
        return loc.msgErrLoadJournal;
      case 'reflection_create_failed':
      case 'reflection_update_failed':
        return loc.msgErrSaveJournal;
      case 'fetch_modules_failed':
        return loc.msgErrLoadPsychoeducation;
      case 'module_not_found':
        return loc.msgErrModuleNotFound;
      case 'education_conflict':
        return loc.msgErrDataConflict;
      case 'education_validation_failed':
      case 'education_media_invalid':
        return loc.msgErrInvalidRequest;
      case 'education_media_not_found':
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
      case 'support_case_not_found':
      case 'support_reply_failed':
      case 'support_transition_failed':
      case 'support_claim_failed':
      case 'support_release_failed':
        return loc.msgErrLoadTicket;
      case 'recovery_records_failed':
      case 'recovery_record_save_failed':
      case 'recovery_practice_fetch_failed':
      case 'recovery_space_fetch_failed':
      case 'weekly_review_fetch_failed':
      case 'weekly_review_save_failed':
        return loc.msgErrSaveJournal;
      case 'fetch_data_requests_failed':
        return loc.msgErrLoadDataRequest;
      case 'data_request_failed':
      case 'data_request_retry_failed':
      case 'data_request_reject_failed':
      case 'data_export_unavailable':
      case 'account_deletion_failed':
        return loc.msgErrSubmitDataRequest;
      case 'type_required':
        return loc.msgErrTypeRequired;
      case 'fetch_admin_modules_failed':
        return loc.msgErrLoadAdminModules;
      case 'fetch_admin_model_releases_failed':
        return loc.msgErrLoadAdminModelReleases;
      case 'fetch_admin_support_cases_failed':
        return loc.msgErrLoadAdminSupportCases;
      case 'fetch_admin_releases_failed':
      case 'admin_overview_failed':
      case 'site_social_links_failed':
      case 'audit_events_failed':
      case 'operators_fetch_failed':
      case 'operator_invite_failed':
      case 'operator_update_failed':
      case 'operator_invitation_revoke_failed':
      case 'operator_invitation_invalid':
      case 'operator_invitation_accept_failed':
      case 'release_rollout_create_failed':
      case 'release_rollout_transition_failed':
        return loc.msgErrGeneric;
      case 'create_model_release_failed':
        return loc.msgErrCreateModelRelease;
      case 'create_ruleset_release_failed':
        return loc.msgErrCreateRulesetRelease;
      case 'create_network_release_failed':
        return loc.msgErrCreateNetworkRelease;
      case 'release_not_found':
        return loc.msgErrReleaseNotFound;
      case 'release_validation_failed':
      case 'artifact_unavailable':
      case 'portal_overview_failed':
        return loc.msgErrGeneric;
      case 'generate_key_failed':
        return loc.msgErrCreateEmergencyKey;
      case 'emergency_request_failed':
      case 'emergency_request_not_found':
      case 'emergency_review_failed':
        return loc.msgErrCreateEmergencyKey;
      case 'emergency_key_required':
        return loc.msgErrEmergencyKeyRequired;
      case 'invalid_key':
        return loc.msgErrInvalidEmergencyKey;

      // translation (DeepSeek)
      case 'translation_failed':
        return loc.msgErrTranslationFailed;
      case 'translation_invalid_input':
        return loc.msgErrTranslationInvalidInput;
      case 'translation_unavailable':
        return loc.msgErrTranslationUnavailable;
      case 'translation_rate_limited':
        return loc.msgErrTranslationRateLimited;

      // SPK decision support
      case 'spk_recommendation_failed':
        return loc.msgErrSpkRecommendationFailed;
      case 'spk_intervention_not_found':
        return loc.msgErrSpkInterventionNotFound;
      case 'spk_intervention_complete_failed':
        return loc.msgErrSpkInterventionCompleteFailed;
      case 'blocked_events_rejected':
        return loc.msgErrBlockedEventsRejected;
      case 'spk_preference_invalid':
        return loc.msgErrSpkPreferenceInvalid;

      default:
        return loc.msgErrGeneric;
    }
  }

  static String friendlyMessage(BuildContext context, Object error) {
    final code = codeOf(error);
    final status = _extractStatus(error);

    if (code != null) return forCode(context, code);
    if (status != null) return _statusMessage(context, status);
    return generic(context);
  }

  static String? codeOf(Object error) {
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
