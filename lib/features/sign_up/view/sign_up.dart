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
import '../mobx/sign_up_state.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final state = SignUpState();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  Future<void> _onSignUpPressed() async {
    FocusScope.of(context).unfocus();
    final success = await state.signUp();
    if (success && mounted) {
      await router.pushAndPopAll(const GalleryRoute());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Observer(
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              GradientGlowText(text: LocaleKeys.loginPage_signUp.tr()),
              const Gap(20),
              GlassInputContainer(
                child: GlassTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  label: LocaleKeys.loginPage_name.tr(),
                  hint: LocaleKeys.loginPage_enterName.tr(),
                  errorText: state.nameError,
                  onChanged: state.setName,
                  textStyle: TextStyles.textFieldTextStyle,
                  hintStyle: TextStyles.textFieldTitleStyle,
                ),
              ),
              const Gap(20),
              GlassInputContainer(
                child: GlassTextField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  isEmail: true,
                  label: LocaleKeys.loginPage_email.tr(),
                  hint: LocaleKeys.loginPage_enterEmail.tr(),
                  errorText: state.emailError,
                  onChanged: state.setEmail,
                  textStyle: TextStyles.textFieldTextStyle,
                  hintStyle: TextStyles.textFieldTitleStyle,
                ),
              ),
              const Gap(20),
              GlassInputContainer(
                child: GlassTextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  obscureText: true,
                  label: LocaleKeys.loginPage_password.tr(),
                  hint: LocaleKeys.loginPage_passwordSymbols.tr(),
                  errorText: state.passwordError,
                  onChanged: state.setPassword,
                  textStyle: TextStyles.textFieldTextStyle,
                  hintStyle: TextStyles.textFieldTitleStyle,
                ),
              ),
              const Gap(20),
              GlassInputContainer(
                child: GlassTextField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  obscureText: true,
                  label: LocaleKeys.loginPage_confirmPassword.tr(),
                  hint: LocaleKeys.loginPage_passwordSymbols.tr(),
                  errorText: state.confirmPasswordError,
                  onChanged: state.setConfirmPassword,
                  textStyle: TextStyles.textFieldTextStyle,
                  hintStyle: TextStyles.textFieldTitleStyle,
                ),
              ),
              const Spacer(),
              Observer(
                builder: (context) {
                  return LoadingButton(
                    isLoading: state.loading,
                    onPressed: state.isValid && !state.loading ? _onSignUpPressed : null,
                    style: Theme.of(
                      context,
                    ).buttonStyle(buttonType: state.isValid ? ButtonTypes.PRIMARY : ButtonTypes.INACTIVE),
                    child: Text(
                      LocaleKeys.loginPage_register.tr(),
                      style: TextStyles.primaryButtonTextStyle.setColor(const Color(0xFF131313)),
                    ),
                  ).expandedHorizontally();
                },
              ),
              Gap(context.bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}
