import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/constants.dart';
import 'package:learning_app/screens/landing_page.dart';
import 'package:learning_app/screens/desktop_video_app.dart';
import 'package:learning_app/screens/mobile_video_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dance_shared/dance_shared.dart';
import 'package:learning_app/utils/user_payments.dart';

// Provider for managing the current locale
final localeProvider = StateProvider<Locale>((ref) {
  final uri = Uri.base;
  return uri.host.contains('mx') ? const Locale('es') : const Locale('en');
});
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  // get browser url
  final uri = Uri.base;
  print('browser url: $uri');
  if (uri.host.contains('mx')) {
    site = 'mx';
  } else {
    site = 'us';
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    // Listen to auth changes and update payment service
    ref.listen(authProvider, (previous, next) => UserPaymentService.instance.fetch());
    
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
      redirect: (context, state) async {
        print('current location: ${state.matchedLocation}');
        if (state.matchedLocation == '/desktop-video' || state.matchedLocation == '/mobile-video') {
          
          if (ref.read(authProvider).user == null) {
            print('result: / (no user)');
            return '/';
          } else {
            print('result: null (user)');
            return null;
          }
        }
        // Only check for redirect on the landing page
        if (state.matchedLocation == '/') {
          String? result = await _checkAuthAndRedirect(context, ref);
          print('result: $result, old location: ${state.matchedLocation}');
          return result;
        } else {
          if (ref.read(authProvider).user == null) {
            print('result: / (no user)');
            return '/';
          }
          if (state.matchedLocation == '/desktop-video' || state.matchedLocation == '/mobile-video') {
            if (UserPaymentService.instance.currentValue == true) {
              return null;
            }
            print('result: / (no payment)');
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

  Future<String?> _checkAuthAndRedirect(BuildContext context, WidgetRef ref) async {
    // Watch auth state
    final authNotifier = ref.watch(authProvider);
    final user = authNotifier.user;
    
    print('router: user: ${user?.id}');
    
    // If user is not logged in, stay on landing page
    if (user == null) {
      print('router: result: null (no user)');
      return null;
    }


    final hasPayment = await UserPaymentService.instance.fetch();
    
    // If user has payment, redirect to appropriate video app
    if (hasPayment) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isDesktop = screenWidth > mobileWidth; // Using mobileWidthpx threshold as in landing page
      
      final redirectPath = isDesktop ? '/desktop-video' : '/mobile-video';
      print('result: $redirectPath (has payment)');
      return redirectPath;
    }
    
    // If user is logged in but doesn't have payment, stay on landing page
    print('router: result: null (no payment)');
    return null;
  }
}