import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

import '../../../injectable.dart';
import '../../../shared/stores/auth_store/auth_store.dart';

part 'sign_up_state.g.dart';

class SignUpState = _SignUpState with _$SignUpState;

abstract class _SignUpState with Store {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @observable
  String name = '';

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  String? nameError;

  @observable
  String? emailError;

  @observable
  String? passwordError;

  @observable
  String? confirmPasswordError;

  @observable
  bool loading = false;

  @computed
  bool get isValid =>
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  @action
  void setName(String value) {
    name = value;
    nameError = value.isEmpty ? 'Введите имя' : null;
  }

  @action
  void setEmail(String value) {
    email = value;

    if (value.isEmpty) {
      emailError = 'Введите электронную почту';
      return;
    }

    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    emailError = regex.hasMatch(value) ? null : 'Неверный формат почты';
  }

  @action
  void setPassword(String value) {
    password = value;

    if (value.isEmpty) {
      passwordError = 'Введите пароль';
      return;
    }

    if (value.length < 8 || value.length > 16) {
      passwordError = 'Пароль должен быть 8–16 символов';
      return;
    }

    passwordError = null;
    validateConfirmPassword();
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
    validateConfirmPassword();
  }

  @action
  void validateConfirmPassword() {
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Подтвердите пароль';
      return;
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Пароли не совпадают';
      return;
    }

    confirmPasswordError = null;
  }

  @action
  Future<bool> signUp() async {
    if (!isValid) {
      return false;
    }

    loading = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.updateDisplayName(name);
      final uid = credential.user!.uid;
      await getIt<AuthStore>().setAccessToken(uid);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emailError = 'Пользователь уже существует';
      } else {
        emailError = e.message ?? 'Ошибка регистрации';
      }
      return false;
    } finally {
      loading = false;
    }
  }
}
