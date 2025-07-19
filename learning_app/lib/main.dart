import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/screens/landing_page.dart';
import 'package:learning_app/screens/desktop_video_app.dart';
import 'package:learning_app/screens/mobile_video_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dance_shared/dance_shared.dart';

// Provider for managing the current locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('es'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  

  
  runApp(const ProviderScope(child: MyApp()));

}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/desktop-video',
      builder: (context, state) => const DesktopVideoApp(),
    ),
    GoRoute(
      path: '/mobile-video',
      builder: (context, state) => const MobileVideoApp(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      locale: locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}