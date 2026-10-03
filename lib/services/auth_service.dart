import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // GET ROLE DARI COLLECTION users
  Future<String?> getRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc['role'] as String? : null;
    } catch (e) {
      print("Get role error: $e");
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() => _auth.signOut();

  // REGISTER SISWA (INI YANG BARU!)
  Future<User?> registerSiswa({
    required String email,
    required String password,
    required String nis,
    required String nama,
    required String kelas,
    required String jurusan,
  }) async {
    try {
      // 1. Buat user di Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      final uid = user.uid;

      // 2. Simpan role ke collection 'users'
      await _db.collection('users').doc(uid).set({
        'role': 'siswa',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Simpan data lengkap ke collection 'siswa'
      await _db.collection('siswa').doc(uid).set({
        'id': uid,
        'nis': nis,
        'nama': nama,
        'kelas': kelas,
        'jurusan': jurusan,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      print("Register siswa error: $e");
      rethrow;
    }
  }
}