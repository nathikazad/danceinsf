import 'package:flutter/material.dart';
import 'package:learning_app/screens/landing_page.dart';
import 'screens/desktop_video_app.dart';
import 'screens/mobile_video_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // final mediaQueryData = MediaQueryData.fromView(WidgetsBinding.instance.window);
  // final screenWidth = mediaQueryData.size.width;

  // Get the screen width
  final screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / 
                     WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  // Decide based on width threshold (600px)
  // if (screenWidth > 600) {
  //   // Desktop version
  //   runApp(const DesktopVideoApp());
  // } else {
  //   // Mobile version
  //   runApp(const MobileVideoApp());
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}