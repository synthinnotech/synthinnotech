import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around the "has this device seen onboarding / accepted the
/// policy" flag. Kept in SharedPreferences because it is a per-device UX
/// concern, not account state.
class OnboardingPrefs {
  static const _policyKey = 'policy_accepted_v1';

  static Future<bool> policyAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    // Honour the legacy key too so existing installs don't re-onboard.
    return prefs.getBool(_policyKey) ?? prefs.getBool('policy') ?? false;
  }

  static Future<void> setPolicyAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_policyKey, true);
    await prefs.setBool('policy', true);
  }
}
