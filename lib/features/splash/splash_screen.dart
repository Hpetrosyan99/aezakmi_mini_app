import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/navigation/app_navigator.dart';
import '../../injectable.dart';
import '../../shared/stores/auth_store/auth_store.dart';
import '../../shared/widgets/custom_scaffold/custom_scaffold.dart';

@RoutePage()
class SplashPage extends HookWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _checkSession();
      return null;
    }, const []);

    return CustomScaffold(body: Container());
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final authStore = getIt<AuthStore>();
    await authStore.getAccessToken();
    if (authStore.isLoggedIn) {
      await router.pushAndPopAll(const GalleryRoute());
    } else {
      await router.pushAndPopAll(const LoginRoute());
    }
  }
}
