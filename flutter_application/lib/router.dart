import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './auth.dart';
import './screens/splash_screen.dart';
import './screens/events_screen.dart';
import './screens/add_event_screen.dart';

final routerProvider = Provider((ref) {
  // final authState = ref.watch(authProvider).state;

  return GoRouter(
    initialLocation: '/events',
    // refreshListenable: ref.watch(authProvider),
    // redirect: (context, state) {
    //   final isLoggedIn = authState.user != null;
    //   final isSplashRoute = state.uri.path == '/';

    //   if (!isLoggedIn && !isSplashRoute) return '/';
    //   if (isLoggedIn && isSplashRoute) return '/events';
      
    //   return null;
    // },
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
    ],
  );
}); 