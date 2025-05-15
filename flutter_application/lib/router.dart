import 'package:flutter/material.dart';
import 'package:flutter_application/screens/verify_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './auth.dart';
import './screens/splash_screen.dart';
import 'screens/list_events_screen.dart';
import './screens/add_event_screen.dart';
import './screens/view_event_screen.dart';
import 'utils/local_storage.dart';

final routerProvider = Provider((ref) {
  // final authState = ref.watch(authProvider).state;

  return GoRouter(
    initialLocation: '/',
    // refreshListenable: ref.watch(authProvider),
    redirect: (context, state) async {
    //   final isLoggedIn = authState.user != null;
      final isHomeRoute = state.uri.path == '/';
    //   final isAddEventRoute = state.uri.path == '/add-event';
    //   final isVerifyRoute = state.uri.path == '/verify';
    //   if (!isLoggedIn && isAddEventRoute) return '/verify';

      if (isHomeRoute) {
        final homeRouteCount = await LocalStorage.getHomeRouteCount();
        print('homeRouteCount: $homeRouteCount');
        if (homeRouteCount < 5) {
          await LocalStorage.incrementHomeRouteCount();
          return '/';
        } else {
          return '/events';
        }
      }

    //   // if (isVerifyRoute && isLoggedIn) {
    //   //   return '/';
    //   // }
    //   return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/add-event',
        builder: (context, state) => const AddEventScreen(),
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return ViewEventScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final nextRoute = state.extra is Map ? (state.extra as Map)['nextRoute'] as String? : null;
          return VerifyScreen(nextRoute: nextRoute);
        },
      ),
    ],
  );
}); 