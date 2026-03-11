import 'package:async_dispatch/camera/camera.dart';
import 'package:async_dispatch/intro/intro.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _goRouter = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: IntroStoryPage.route,
      routes: [
        GoRoute(
          path: IntroStoryPage.route,
          name: IntroStoryPage.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: IntroStoryPage.pageBuilder(context, state),
          ),
        ),
        GoRoute(
          path: CameraActionPage.route,
          name: CameraActionPage.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: CameraActionPage.pageBuilder(context, state),
          ),
        ),
      ],
    );
  }
  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;
}
