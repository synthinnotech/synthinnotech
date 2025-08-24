import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/initial_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(ProviderScope(child: const MyApp()));
}

const Color baseColor1 = Color.fromARGB(255, 0, 146, 183);
const Color baseColor2 = Color.fromARGB(255, 71, 208, 242);
const Color baseColor3 = Color.fromARGB(255, 1, 79, 101);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(ThemeService.isDarkTheme);
    return GetMaterialApp(
      title: 'SynthinnoTech',
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: InitialPage(),
    );
  }
}
