import 'package:auto_flow/features/splash_screen/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_flow/core/theme/dark_theme.dart';
import 'package:auto_flow/core/theme/light_theme.dart';
import 'package:auto_flow/core/theme/theme_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeNotifier())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeNotifier>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      home: SplashScreen(),
    );
  }
}
