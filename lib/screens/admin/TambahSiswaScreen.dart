// lib/screens/admin/tambah_siswa_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahSiswaScreen extends StatefulWidget {
  const TambahSiswaScreen({super.key});
  @override State<TambahSiswaScreen> createState() => _TambahSiswaScreenState();
}

class _TambahSiswaScreenState extends State<TambahSiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nis = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _kelas = TextEditingController();
  final _jurusan = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nama.dispose(); _nis.dispose(); _email.dispose(); _pass.dispose();
    _kelas.dispose(); _jurusan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Siswa Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nama, decoration: const InputDecoration(labelText: "Nama Lengkap"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _nis, decoration: const InputDecoration(labelText: "NIS"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"), validator: (v) => v!.contains('@') ? null : "Email tidak valid"),
              TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Password (min 6 karakter)"), validator: (v) => v!.length >= 6 ? null : "Min 6 karakter"),
              TextFormField(controller: _kelas, decoration: const InputDecoration(labelText: "Kelas (contoh: XII IPA 1)")),
              TextFormField(controller: _jurusan, decoration: const InputDecoration(labelText: "Jurusan (IPA/IPS/Bahasa)")),
              const SizedBox(height: 30),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _tambahSiswa,
                      child: const Text("TAMBAH SISWA"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tambahSiswa() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Buat akun di Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      final uid = cred.user!.uid;

      // 2. Simpan ke collection 'users'
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'siswa',
        'email': _email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Simpan ke collection 'siswa'
      await FirebaseFirestore.instance.collection('siswa').doc(uid).set({
        'id': uid,
        'nama': _nama.text.trim(),
        'nis': _nis.text.trim(),
        'email': _email.text.trim(),
        'kelas': _kelas.text.trim(),
        'jurusan': _jurusan.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Siswa berhasil ditambahkan!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // kembali ke dashboard admin
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }
}