import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _onboardingKey = 'onboarding_completed_v1';

/// Public storage key for the onboarding-completed flag. Exposed so
/// development tooling (e.g. `--dart-define=RESET_ONBOARDING=true`) can clear
/// it without duplicating the string.
const onboardingCompletedKey = _onboardingKey;

class OnboardingState {
  const OnboardingState({this.isLoading = true, this.isCompleted = false});

  final bool isLoading;
  final bool isCompleted;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._storage) : super(const OnboardingState()) {
    _load();
  }

  final FlutterSecureStorage _storage;

  Future<void> _load() async {
    final value = await _storage.read(key: _onboardingKey);
    state = OnboardingState(isLoading: false, isCompleted: value == 'true');
  }

  Future<void> complete() async {
    await _storage.write(key: _onboardingKey, value: 'true');
    state = const OnboardingState(isLoading: false, isCompleted: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier(const FlutterSecureStorage());
    });
