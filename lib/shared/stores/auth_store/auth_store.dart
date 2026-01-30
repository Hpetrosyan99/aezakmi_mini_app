import 'package:api/api.dart';
import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';

import '../../../core/utils/storage_utils.dart';
import '../../../injectable.dart';
import '../../state/loading_state/loading_state.dart';

part 'auth_store.g.dart';

@singleton
class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  final _userLoadingState = LoadingState()..startLoading();

  AuthStoreBase();

  @readonly
  UserResponseDto? _currentUser;
  @readonly
  String? _accessToken;
  @readonly
  bool _isUserLoaded = false;

  @computed
  bool get isLoggedIn => _accessToken != null;

  @computed
  bool get isUserLoading => _userLoadingState.isLoading;

  @action
  Future<void> getAccessToken() async {
    final token = await StorageUtils.getAccessToken();
    if (token != null) {
      await setAccessToken(token);
    }
  }

  @action
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await StorageUtils.setAccessToken(token);
  }

  Future<void> _cleanUserData() async {
    await StorageUtils.removeAccessToken();
  }

  Future<void> logout() async {
    await _cleanUserData();
    await resetDependencies();
  }
}
