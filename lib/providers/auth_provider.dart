import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _userId;
  String? _role;

  String? get userId => _userId;
  String? get role => _role;

  // LOGIN
  Future<bool> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _userId = user.uid;
        _role = await _authService.getRole(user.uid);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  // REGISTER SISWA (BARU!)
  Future<bool> registerSiswa({
    required String email,
    required String password,
    required String nis,
    required String nama,
    required String kelas,
    required String jurusan,
  }) async {
    try {
      final user = await _authService.registerSiswa(
        email: email,
        password: password,
        nis: nis,
        nama: nama,
        kelas: kelas,
        jurusan: jurusan,
      );

      if (user != null) {
        _userId = user.uid;
        _role = 'siswa';
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Register provider error: $e");
    }
    return false;
  }

  // LOGOUT
  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    _userId = null;
    _role = null;
    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}