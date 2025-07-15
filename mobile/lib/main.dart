import 'package:dance_sf/controllers/log_controller.dart';
import 'package:dance_shared/dance_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dance_sf/utils/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'router.dart';
import 'package:dance_sf/utils/app_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();

  print('Initializing Supabase');
  await SupabaseConfig.initialize();

  // LogController.setZone(AppStorage.zone);

  LogController.logNavigation('App initialization started');

  // Error handling for the app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const ProviderScope(child: DanceApp()));
}

class DanceApp extends ConsumerStatefulWidget {
  const DanceApp({super.key});

  @override
  ConsumerState<DanceApp> createState() => _DanceAppState();
}

class _DanceAppState extends ConsumerState<DanceApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initUniLinks();
  }

  @override
  void dispose() {
    UniLinksHandler.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    await UniLinksHandler.initialize(
      onLinkReceived: (String link, bool initial) {
        final cleanPath = UniLinksHandler.parseLink(link);
        if (cleanPath != null) {
          // Get router from provider
          final router = ref.read(routerProvider);
          router.push(cleanPath);
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App came back to foreground');
    } else if (state == AppLifecycleState.paused) {
      print('App went to background');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Dance in SF',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
    );
  }
}
