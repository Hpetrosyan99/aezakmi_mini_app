import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';

part 'login_page_state.g.dart';

@injectable
class LoginPageState = _LoginPageStateBase with _$LoginPageState;

abstract class _LoginPageStateBase with Store {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  String? emailError;

  @observable
  String? passwordError;

  @observable
  bool loading = false;

  @observable
  String? authError;

  @computed
  bool get isValid => emailError == null && passwordError == null && email.isNotEmpty && password.isNotEmpty;

  @action
  void setEmail(String value) {
    email = value;
    validateEmail();
  }

  @action
  void setPassword(String value) {
    password = value;
    validatePassword();
  }

  @action
  bool validateEmail() {
    if (email.isEmpty) {
      emailError = 'Введите электронную почту';
      return false;
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Неверный формат почты';
      return false;
    }
    emailError = null;
    return true;
  }

  @action
  bool validatePassword() {
    if (password.isEmpty) {
      passwordError = 'Введите пароль';
      return false;
    }
    if (password.length < 8 || password.length > 16) {
      passwordError = 'Пароль должен быть 8–16 символов';
      return false;
    }
    passwordError = null;
    return true;
  }

  @action
  bool validateAll() {
    final e = validateEmail();
    final p = validatePassword();
    return e && p;
  }

  @action
  Future<bool> signIn() async {
    authError = null;
    if (!validateAll()) {
      return false;
    }
    loading = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    } catch (_) {
      authError = 'Неизвестная ошибка. Попробуйте позже';
      return false;
    } finally {
      loading = false;
    }
  }
}
