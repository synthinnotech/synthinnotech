import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _pushKey = 'pushNotificationsEnabled';
  static const _projectAlertsKey = 'projectAlertsEnabled';

  static final pushNotificationsEnabled = StateProvider<bool>((ref) => true);
  static final projectAlertsEnabled = StateProvider<bool>((ref) => true);

  static Future<void> loadPreferences(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(pushNotificationsEnabled.notifier).state =
        prefs.getBool(_pushKey) ?? true;
    ref.read(projectAlertsEnabled.notifier).state =
        prefs.getBool(_projectAlertsKey) ?? true;
  }

  static Future<void> setPushNotifications(WidgetRef ref, bool value) async {
    ref.read(pushNotificationsEnabled.notifier).state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
  }

  static Future<void> setProjectAlerts(WidgetRef ref, bool value) async {
    ref.read(projectAlertsEnabled.notifier).state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_projectAlertsKey, value);
  }
}
