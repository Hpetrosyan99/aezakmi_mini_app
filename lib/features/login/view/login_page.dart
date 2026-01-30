import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/button_settings.dart';
import '../../../core/extensions/elevated_button_extensions.dart';
import '../../../core/navigation/app_router.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../shared/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../shared/widgets/glass_input_container/glass_input_container.dart';
import '../../../shared/widgets/glass_text_field/glass_text_field.dart';
import '../../../shared/widgets/gradient_glow_text/gradient_glow_text.dart';
import '../../../shared/widgets/loading_button/loading_button.dart';
import '../mobx/login_page_state.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final state = LoginPageState();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final success = await state.signIn();
    if (success && mounted) {
      await router.pushAndPopAll(const GalleryRoute());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Observer(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                GradientGlowText(text: LocaleKeys.loginPage_login.tr()),
                const Gap(20),
                MutedScaleTap(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                  child: GlassInputContainer(
                    child: GlassTextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      isEmail: true,
                      label: LocaleKeys.loginPage_email.tr(),
                      hint: LocaleKeys.loginPage_enterEmail.tr(),
                      textStyle: TextStyles.textFieldTextStyle,
                      hintStyle: TextStyles.textFieldTitleStyle,
                      errorText: state.emailError,
                      onChanged: state.setEmail,
                    ),
                  ),
                ),

                const Gap(20),
                MutedScaleTap(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(passwordFocusNode);
                  },
                  child: GlassInputContainer(
                    child: GlassTextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: true,
                      label: LocaleKeys.loginPage_password.tr(),
                      hint: LocaleKeys.loginPage_enterPassword.tr(),
                      textStyle: TextStyles.textFieldTextStyle,
                      hintStyle: TextStyles.textFieldTitleStyle,
                      errorText: state.passwordError,
                      onChanged: state.setPassword,
                    ),
                  ),
                ),
                const Spacer(),
                LoadingButton(
                  isLoading: state.loading,
                  onPressed: state.isValid && !state.loading ? _submit : null,
                  style: Theme.of(context).buttonStyle(),
                  child: Text(LocaleKeys.loginPage_enter.tr(), style: TextStyles.primaryButtonTextStyle),
                ).expandedHorizontally(),
                const Gap(19),
                LoadingButton(
                  onPressed: () {
                    router.push(const SignUpRoute());
                  },
                  style: Theme.of(context).buttonStyle(buttonType: ButtonTypes.SECONDARY),
                  child: Text(
                    LocaleKeys.loginPage_signUp.tr(),
                    style: TextStyles.primaryButtonTextStyle.setColor(const Color(0xFF131313)),
                  ),
                ).expandedHorizontally(),
                Gap(context.bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
