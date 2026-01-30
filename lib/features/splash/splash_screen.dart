import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/navigation/app_navigator.dart';
import '../../shared/widgets/custom_scaffold/custom_scaffold.dart';

@RoutePage()
class SplashPage extends HookWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      checkSession();
      return;
    });

    return CustomScaffold(body: Container());
  }

  Future<void> checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    await router.pushAndPopAll(const LoginRoute());
  }
}
