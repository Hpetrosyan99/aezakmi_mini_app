import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../injectable.dart';
import 'app_navigator.dart';

export 'app_router.gr.dart';

final router = getIt<AppNavigator>();

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(initial: true, path: '/', page: SplashRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(page: GalleryRoute.page),
    AutoRoute(page: DrawRoute.page),
  ];
}

@RoutePage()
class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.backgroundSurface);
  }
}
