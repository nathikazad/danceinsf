import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './screens/splash_screen.dart' as splash;
import 'package:dance_sf/screens/verify_screen.dart' as verify;
import 'screens/list_events_screen.dart' as list_events;
import './screens/add_event_screen.dart' as add_event;
import 'package:dance_sf/screens/view_event_screen.dart' as view_event;
import 'utils/app_storage.dart';
import 'screens/edit_event_screen.dart' as edit_event;
import 'screens/edit_event_instance_screen.dart' as edit_event_instance;
import 'screens/help_screen.dart' as help;
import 'package:dance_sf/utils/app_scaffold/app_scaffold.dart';
import 'controllers/log_controller.dart';
import 'package:dance_sf/models/event_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authProvider).state;

  return GoRouter(
    initialLocation: '/',
    // refreshListenable: ref.watch(authProvider),
    redirect: (context, state) async {
      await LogController.logNavigation("Routing to ${state.uri.path}");
      
      // If we're not on the home route, don't redirect
      if (state.uri.path != '/') {
        return null;
      }
      // await AppStorage.clearHomeRouteCount();
      // Only handle home route redirect
      final homeRouteCount = await AppStorage.getHomeRouteCount();
      if (homeRouteCount < 5) {
        await AppStorage.incrementHomeRouteCount();
        return '/';
      } else {
        return '/events';
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppScaffold(
          child: splash.SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const AppScaffold(
          child: list_events.EventsScreen(),
        ),
      ),
      GoRoute(
        path: '/add-event',
        builder: (context, state) => const AppScaffold(
          child: add_event.AddEventScreen(),
        ),
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final initialEvent = state.extra as EventInstance?;
          return AppScaffold(
            child: view_event.ViewEventScreen(
              eventInstanceId: eventId,
              initialEventInstance: initialEvent,
            ),
          );
        },
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final nextRoute = state.extra is Map ? (state.extra as Map)['nextRoute'] as String? : null;
          return AppScaffold(
            child: verify.VerifyScreen(nextRoute: nextRoute, extra: state.extra),
          );
        },
      ),
      GoRoute(
        path: '/edit-event/:eventId',
        builder: (context, state) => AppScaffold(
          child: edit_event.EditEventScreen(
            eventId: state.pathParameters['eventId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/edit-event-instance/:instanceId',
        builder: (context, state) => AppScaffold(
          child: edit_event_instance.EditEventInstanceScreen(
            eventInstanceId: state.pathParameters['instanceId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const AppScaffold(
          child: help.HelpScreen(),
        ),
      ),
    ],
  );
}); 