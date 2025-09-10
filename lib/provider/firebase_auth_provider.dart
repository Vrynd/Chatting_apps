import 'package:chatting_app/models/profile.dart';
import 'package:chatting_app/services/firebase_auth_service.dart';
import 'package:chatting_app/static/firebase_auth_status.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  // Constructor
  final FirebaseAuthService _service;
  FirebaseAuthProvider(this._service);

  // State Status Pengguna
  String? _message;
  Profile? _profile;
  FirebaseAuthStatus _authStatus = FirebaseAuthStatus.unauthenticated;

  Profile? get profile => _profile;
  String? get message => _message;
  FirebaseAuthStatus get authStatus => _authStatus;

  // Membuat Akun
  Future createAccount(String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.creatingAccount;
      notifyListeners();

      await _service.createUser(email, password);

      _authStatus = FirebaseAuthStatus.accountCreated;
      _message = "Account successfully created. Please login now!";
    } catch (e) {
      _authStatus = FirebaseAuthStatus.error;
      _message = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Login Akun
  Future signInUser(String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.authenticating;
      notifyListeners();

      final result = await _service.signInUser(email, password);

      _profile = Profile(
        name: result.user?.displayName,
        email: result.user?.email,
        photoUrl: result.user?.photoURL,
      );

      _authStatus = FirebaseAuthStatus.authenticated;
      _message = "Login successfully. Welcome, ${_profile?.name}!";
    } catch (e) {
      _authStatus = FirebaseAuthStatus.error;
      _message = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // LogOut Akun
  Future signOutUser(String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.signingOut;
      notifyListeners();

      await _service.signOutUser();

      _authStatus = FirebaseAuthStatus.unauthenticated;
      _message = "Logout successfully.";
    } catch (e) {
      _authStatus = FirebaseAuthStatus.error;
      _message = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Update Profile
  Future updateProfile() async {
    final user = await _service.userChanges();
    _profile = Profile(
      name: user?.displayName,
      email: user?.email,
      photoUrl: user?.photoURL,
    );
    notifyListeners();
  }
}
