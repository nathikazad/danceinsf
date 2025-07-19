import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/screens/landing_page.dart';
import 'package:learning_app/screens/desktop_video_app.dart';
import 'package:learning_app/screens/mobile_video_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dance_shared/dance_shared.dart';
import 'package:learning_app/utils/stripe_util.dart';

// Provider for managing the current locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('es'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _createRouter(ref),
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
  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        print('state: ${state.matchedLocation}');
        // Only check for redirect on the landing page
        if (state.matchedLocation == '/') {
          String? result = _checkAuthAndRedirect(context, ref);
          print('result: $result');
          return result;
        } else {
          if (ref.read(authProvider).user == null) {
            return '/';
          }
          if (state.matchedLocation == '/desktop-video' || state.matchedLocation == '/mobile-video') {
            if (ref.read(userHasPaymentProvider).hasValue && ref.read(userHasPaymentProvider).value == true) {
              return null;
            }
            return '/';
          }
        }
        return null;
      },
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
  }

  String? _checkAuthAndRedirect(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authNotifier = ref.watch(authProvider);
    final user = authNotifier.user;
    
    print('user: ${user?.id}');
    
    // If user is not logged in, stay on landing page
    if (user == null) {
      print('result: null (no user)');
      return null;
    }
    
    // Only watch payment status if user is logged in
    final hasPaymentAsync = ref.watch(userHasPaymentProvider);
    
    // If still loading payment status, stay on landing page
    if (hasPaymentAsync.isLoading) {
      print('result: null (loading payment)');
      return null;
    }
    
    // If user has payment, redirect to appropriate video app
    if (hasPaymentAsync.hasValue && hasPaymentAsync.value == true) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isDesktop = screenWidth > 600; // Using 600px threshold as in landing page
      
      final redirectPath = isDesktop ? '/desktop-video' : '/mobile-video';
      print('result: $redirectPath (has payment)');
      return redirectPath;
    }
    
    // If user is logged in but doesn't have payment, stay on landing page
    print('result: null (no payment)');
    return null;
  }
}