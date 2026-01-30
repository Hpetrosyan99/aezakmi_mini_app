import 'dart:async';

import 'package:auto_route/auto_route.dart';

import '../../injectable.dart';
import '../../shared/stores/auth_store/auth_store.dart';
import '../navigation/app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  const AuthGuard();

  @override
  Future<void> onNavigation(
      NavigationResolver resolver,
      StackRouter router,
      ) async {
    final authStore = getIt<AuthStore>();
    await authStore.getAccessToken();
    if (authStore.isLoggedIn) {
      resolver.next();
    } else {
      await router.replace(const LoginRoute());
    }
  }
}
