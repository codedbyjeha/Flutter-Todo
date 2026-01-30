import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');
    if (userId != null) {
      _currentUser = await _dbHelper.getUserById(userId);
    }
    _setLoading(false);
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    final user = await _dbHelper.getUserByCredentials(username, password);
    if (user == null) {
      _errorMessage = 'Username atau password salah';
      _setLoading(false);
      return false;
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentUserId', user.id!);
    _setLoading(false);
    return true;
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    final exists = await _dbHelper.getUserByUsername(username);
    if (exists != null) {
      _errorMessage = 'Username sudah dipakai';
      _setLoading(false);
      return false;
    }
    await _dbHelper.insertUser(AppUser(username: username, password: password));
    _setLoading(false);
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
