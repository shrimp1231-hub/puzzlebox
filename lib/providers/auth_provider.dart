import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthState.initial;
  UserProfile? _user;
  String? _errorMessage;

  AuthProvider(this._repository) {
    _init();
  }

  AuthState get state => _state;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> _init() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      _user = await _repository.getCurrentUser();
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.signInWithGoogle();
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
