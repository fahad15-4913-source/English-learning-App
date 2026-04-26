import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    FirebaseService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _userModel = await FirebaseService.getUserData(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signUp(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      _userModel = await FirebaseService.getUserData(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
