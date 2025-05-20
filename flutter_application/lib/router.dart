
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import './auth.dart';
import './screens/splash_screen.dart' as splash;
import 'package:dance_sf/screens/verify_screen.dart' as verify;
import 'screens/list_events_screen.dart' as list_events;
import './screens/add_event_screen.dart' as add_event;
import './screens/view_event_screen.dart' as view_event;
import 'utils/local_storage.dart';
import 'screens/edit_event_screen.dart' as edit_event;
import 'screens/edit_event_instance_screen.dart' as edit_event_instance;

final routerProvider = Provider((ref) {
  // final authState = ref.watch(authProvider).state;

  return GoRouter(
    initialLocation: '/',
    // refreshListenable: ref.watch(authProvider),
    redirect: (context, state) async {
      // final isLoggedIn = authState.user != null;
      
      // final isAddEventRoute = state.uri.path == '/add-event';
      // final isVerifyRoute = state.uri.path == '/verify';
      // if (!isLoggedIn && isAddEventRoute) return '/verify';

      final isHomeRoute = state.uri.path == '/';
      if (isHomeRoute) {
        final homeRouteCount = await LocalStorage.getHomeRouteCount();
        if (homeRouteCount < 5) {
          await LocalStorage.incrementHomeRouteCount();
          return '/';
        } else {
          return '/events';
        }
      }

      // if (isVerifyRoute && isLoggedIn) {
      //   return '/';
      // }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const splash.SplashScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const list_events.EventsScreen(),
      ),
      GoRoute(
        path: '/add-event',
        builder: (context, state) => const add_event.AddEventScreen(),
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return view_event.ViewEventScreen(eventInstanceId: eventId);
        },
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final nextRoute = state.extra is Map ? (state.extra as Map)['nextRoute'] as String? : null;
          return verify.VerifyScreen(nextRoute: nextRoute, extra: state.extra);
        },
      ),
      GoRoute(
        path: '/edit-event/:eventId',
        builder: (context, state) => edit_event.EditEventScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/edit-event-instance/:instanceId',
        builder: (context, state) => edit_event_instance.EditEventInstanceScreen(
          eventInstanceId: state.pathParameters['instanceId']!,
        ),
      ),
    ],
  );
}); 