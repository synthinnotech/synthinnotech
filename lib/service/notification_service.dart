import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/config/app_colors.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'general_channel',
          channelName: 'General Notifications',
          channelDescription: 'General app notifications',
          importance: NotificationImportance.High,
          defaultColor: primaryColor,
          ledColor: primaryColor,
          enableVibration: true,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'project_channel',
          channelName: 'Project Notifications',
          channelDescription: 'Notifications about project updates',
          importance: NotificationImportance.High,
          defaultColor: purpleColor,
          ledColor: purpleColor,
        ),
        NotificationChannel(
          channelKey: 'finance_channel',
          channelName: 'Finance Notifications',
          channelDescription: 'Notifications about financial updates',
          importance: NotificationImportance.High,
          defaultColor: successColor,
          ledColor: successColor,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Notifications',
          channelDescription: 'Notifications for new chat messages',
          importance: NotificationImportance.High,
          defaultColor: primaryColor,
          ledColor: primaryColor,
          enableVibration: true,
          playSound: true,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onDismissActionReceivedMethod: onDismissAction,
    );
  }

  static Future<bool> requestPermission() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String channelKey = 'general_channel',
    Map<String, String>? payload,
    bool withActions = true,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: payload,
        wakeUpScreen: true,
      ),
      actionButtons: withActions
          ? [
              NotificationActionButton(
                key: 'VIEW',
                label: 'View',
                actionType: ActionType.Default,
              ),
              NotificationActionButton(
                key: 'DISMISS',
                label: 'Dismiss',
                actionType: ActionType.DismissAction,
                isDangerousOption: false,
              ),
            ]
          : null,
    );
  }

  static Future<void> showFromFCM(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await showNotification(
      title: notification.title ?? 'SynthinnoTech',
      body: notification.body ?? '',
      payload: message.data.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceived(ReceivedAction action) async {
    if (action.buttonKeyPressed == 'VIEW') {
      Get.toNamed('/notifications');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreated(
      ReceivedNotification notification) async {
    debugPrint('Notification created: ${notification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayed(
      ReceivedNotification notification) async {
    debugPrint('Notification displayed: ${notification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissAction(ReceivedAction action) async {
    debugPrint('Notification dismissed: ${action.id}');
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showFromFCM(message);
}
