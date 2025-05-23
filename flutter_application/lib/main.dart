import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dance_sf/utils/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dance_sf/utils/session/session.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing Supabase');
  await Supabase.initialize(
    url: 'https://swsvvoysafsqsgtvpnqg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3c3Z2b3lzYWZzcXNndHZwbnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5Mzk1NzgsImV4cCI6MjA2MjUxNTU3OH0.Z3J3KaWt3zd55GSx2fvAZBzd0WRYDWxFzL-eA4X0l54',
  );

  // Get session ID from browser
  final sessionId = await getSessionId();

  if (!kDebugMode && kIsWeb && sessionId != null) {
    // Add log to Supabase
    try {
      await Supabase.instance.client.from('logs').insert({
        'text': 'App initialization started',
        'session_id': sessionId,
      });
      print('Flutter - Logged with session ID: $sessionId');
    } catch (e) {
      print('Failed to log to Supabase: $e');
    }
  }

  // Error handling for the app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  runApp(const ProviderScope(child: DanceApp()));
}

class DanceApp extends ConsumerStatefulWidget {
  const DanceApp({super.key});

  @override
  ConsumerState<DanceApp> createState() => _DanceAppState();
}

class _DanceAppState extends ConsumerState<DanceApp> with WidgetsBindingObserver {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initUniLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    if (!kIsWeb) {
      // Handle links that opened the app from a terminated state
      try {
        final initialUri = await AppLinks().getInitialLink();
        if (initialUri != null) {
          print('Initial URI: ${initialUri.toString()}');
          _handleIncomingLink(initialUri.toString(), true);
        }
      } catch (e) {
        print('Failed to get initial link: $e');
      }

      // Handle links that opened the app from a background state
      _linkSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print('Received URI: ${uri.toString()}');
          _handleIncomingLink(uri.toString(), false);
        }
      }, onError: (err) {
        print('Failed to receive link: $err');
      });
    } else {
      // For web platform, handle the initial URL
      final uri = Uri.base;
      print('Initial web URL: ${uri.toString()}');
      if (uri.path != '/') {
        _handleIncomingLink(uri.toString(), true);
      }
    }
  }

  void _handleIncomingLink(String link, bool initial) {
    print('handleIncomingLink: $link');
    final uri = Uri.parse(link);
    if (uri.host == 'wheredothey.dance' || uri.host == 'localhost') {
      // Clean up the URL by removing the hash fragment
      final cleanPath = uri.path.split('#')[0];
      print('cleanPath: $cleanPath');
      
      // Get router from provider
      final router = ref.read(routerProvider);
      
      router.push(cleanPath);

    }
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

    return MaterialApp.router(
      title: 'Dance in SF',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
    );
  }
}
