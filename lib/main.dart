import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/intro_screen.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force status bar color and icon brightness for consistent UI across iOS/Android
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppTheme.primaryColor,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Health',
      // Force Material platform styling so iOS and Android look identical
      theme: AppTheme.lightTheme.copyWith(
        platform: TargetPlatform.android,
      ),
      // Use a uniform scroll behaviour (no iOS bounce) across platforms
      scrollBehavior: const _UniformScrollBehavior(),
      home: const IntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Use ClampingScrollPhysics (Android-style) everywhere so scrolling
// behaves the same on iOS and Android.
class _UniformScrollBehavior extends MaterialScrollBehavior {
  const _UniformScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
