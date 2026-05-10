import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/service/firebase_service.dart';
import 'package:synthinnotech/service/notification_service.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/splash_screen.dart';

const Color baseColor1 = Color.fromARGB(255, 0, 146, 183);
const Color baseColor2 = Color.fromARGB(255, 71, 208, 242);
const Color baseColor3 = Color.fromARGB(255, 1, 79, 101);

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await FirebaseService.initialize();
  await NotificationService.showFromFCM(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await FirebaseService.initialize();

  if (FirebaseService.isAvailable) {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    await FirebaseService.requestPermission();
    await FirebaseService.setupFCMForegroudListener(
      (msg) => NotificationService.showFromFCM(msg),
    );
  }

  await NotificationService.initialize();
  await NotificationService.requestPermission();

  final isDark = await ThemeService.loadPreference();

  runApp(
    ProviderScope(
      overrides: [
        ThemeService.isDarkTheme.overrideWith((ref) => isDark),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeService.isDarkTheme);
    return GetMaterialApp(
      title: 'SynthInnoTech',
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
