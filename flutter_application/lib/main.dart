import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
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
      await Supabase.instance.client
          .from('logs')
          .insert({
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


  runApp(
    const ProviderScope(
      child: DanceApp(),
    ),
  );
}

class DanceApp extends ConsumerWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Log app build
    getSessionId().then((sessionId) {
      Supabase.instance.client
          .from('logs')
          .insert({
            'text': 'MyApp build method called',
            'session_id': sessionId,
          });
    });

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

Future<String?> getSessionId() async {
  try {
    // Get session ID from browser's localStorage using new web APIs
    final storage = web.window.localStorage;
    final sessionId = storage.getItem('session');
    
    return sessionId;
  } catch (e) {
    print('Error getting session ID from browser: $e');
    // Fallback to a default session ID if browser call fails
    return 'default-session-id';
  }
}
