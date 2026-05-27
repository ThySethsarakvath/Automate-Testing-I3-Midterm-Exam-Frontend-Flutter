import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User?   _user;
  String? _token;
  bool    _isLoading = false;
  String? _error;

  User?   get user      => _user;
  String? get token     => _token;
  bool    get isLoading => _isLoading;
  String? get error     => _error;
  bool    get isLoggedIn => _token != null;
  AuthService get authService => _authService;

  // Called on app start to restore session
  Future<void> init() async {
    _user  = await _authService.getStoredUser();
    _token = await _authService.getToken();
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null; // Clear previous errors
    try {
      final result = await _authService.register(
        username: username, email: email, password: password,
      );
      _setLoading(false);

      if (result['success']) {
        _user  = User.fromJson(result['data']['user']);
        _token = result['data']['accessToken'];
        _error = null;
        notifyListeners();
        return true;
      }

      _error = _formatError(result['message']);
      notifyListeners();
      return false;
    } catch (e) {
      _setLoading(false);
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final result = await _authService.login(email: email, password: password);
    _setLoading(false);

    if (result['success']) {
      _user  = User.fromJson(result['data']['user']);
      _token = result['data']['accessToken'];
      _error = null;
      notifyListeners();
      return true;
    }

    _error = _formatError(result['message']);
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user  = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Flatten NestJS error messages (can be array or string)
  String _formatError(dynamic message) {
    if (message is List) return message.join('\n');
    return message?.toString() ?? 'Something went wrong';
  }
}