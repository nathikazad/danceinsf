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
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
  late StreamSubscription _intentSub;
  // final _sharedFiles = <SharedMediaFile>[];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initUniLinks();

        // Listen to media sharing coming from outside the app while the app is in the memory.
    // _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
    //   setState(() {
    //     _sharedFiles.clear();
    //     _sharedFiles.addAll(value);

    //     print(_sharedFiles.map((f) => f.toMap()));
    //   });
    // }, onError: (err) {
    //   print("getIntentDataStream error: $err");
    // });

    // // Get the media sharing coming from outside the app while the app is closed.
    // ReceiveSharingIntent.instance.getInitialMedia().then((value) {
    //   setState(() {
    //     _sharedFiles.clear();
    //     _sharedFiles.addAll(value);
    //     print(_sharedFiles.map((f) => f.toMap()));

    //     // Tell the library that we are done processing the intent.
    //     ReceiveSharingIntent.instance.reset();
    //   });
    // });
  }

  @override
  void dispose() {
    _intentSub.cancel();
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
