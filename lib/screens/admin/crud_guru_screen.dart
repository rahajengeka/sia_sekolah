// lib/screens/admin/crud_guru_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CrudGuruScreen extends StatefulWidget {
  const CrudGuruScreen({super.key});

  @override
  State<CrudGuruScreen> createState() => _CrudGuruScreenState();
}

class _CrudGuruScreenState extends State<CrudGuruScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _searchC = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchC.addListener(() {
      setState(() => searchQuery = _searchC.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Kelola Data Guru",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textColor,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white, size: 20),
        label: Text(
          "Tambah Guru",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        onPressed: () => _showForm(context),
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TextField(
              controller: _searchC,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Cari nama pengajar atau NIP...",
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: subtextColor),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => _searchC.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // 2. LIST GURU
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('guru').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                var docs = snapshot.data!.docs;

                if (searchQuery.isNotEmpty) {
                  docs = docs.where((d) =>
                      (d['nama'] as String?)?.toLowerCase().contains(searchQuery) == true ||
                      (d['nip'] as String?)?.contains(searchQuery) == true).toList();
                }

                docs.sort((a, b) => (a['nama'] as String).toLowerCase().compareTo((b['nama'] as String).toLowerCase()));

                if (docs.isEmpty) return _buildEmptyState(isDark);

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: docs.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final guruId = d.id;
                    final String nama = d['nama'] ?? '-';
                    final String inisial = nama.isNotEmpty ? nama[0].toUpperCase() : "G";
                    final String nip = d['nip'] ?? '-';
                    final String mapel = d['mapel'] ?? '-';

                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.success.withOpacity(0.1),
                          child: Text(
                            inisial,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "NIP: $nip",
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  mapel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded, size: 20, color: subtextColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (value) {
                            if (value == 'edit') _showForm(context, id: guruId, data: d);
                            if (value == 'delete') _confirmDelete(context, guruId);
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                                  const SizedBox(width: 8),
                                  Text("Edit Data", style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Text("Hapus Guru", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 52, color: subtextColor.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            "Data Guru Tidak Ditemukan",
            style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<String> _generateNIP() async {
    final year = DateTime.now().year.toString();
    final query = await _db.collection('guru').get();
    final count = (query.docs.length + 1).toString().padLeft(4, '0');
    return "$year$count";
  }

  void _showForm(BuildContext context, {String? id, QueryDocumentSnapshot? data}) async {
    final isEdit = id != null;
    final namaC = TextEditingController(text: data?['nama'] ?? '');
    final emailC = TextEditingController(text: data?['email'] ?? '');
    final passC = TextEditingController();
    final mapelC = TextEditingController(text: data?['mapel'] ?? '');
    String nip = data?['nip'] ?? await _generateNIP();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? "Edit Data Guru" : "Tambah Guru Pengajar",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaC,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap & Gelar",
                    prefixIcon: Icon(Icons.person_outline, size: 19),
                  ),
                ),
                const SizedBox(height: 12),
                if (!isEdit) ...[
                  TextField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: "Email Login",
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 19),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passC,
                    obscureText: true,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: "Kata Sandi",
                      prefixIcon: Icon(Icons.lock_outline, size: 19),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: mapelC,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: "Mata Pelajaran yang Diampu",
                    prefixIcon: Icon(Icons.book_outlined, size: 19),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: AppColors.success, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "NIP: $nip",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.plusJakartaSans(color: subtextColor, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(120, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                if (namaC.text.isEmpty || mapelC.text.isEmpty || (!isEdit && (emailC.text.isEmpty || passC.text.isEmpty))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lengkapi semua kolom formulir!")),
                  );
                  return;
                }

                try {
                  if (isEdit) {
                    await _db.collection('guru').doc(id).update({
                      'nama': namaC.text.trim(),
                      'mapel': mapelC.text.trim(),
                    });
                  } else {
                    final cred = await _auth.createUserWithEmailAndPassword(
                      email: emailC.text.trim(),
                      password: passC.text,
                    );
                    final uid = cred.user!.uid;

                    await _db.collection('users').doc(uid).set({'role': 'guru'});
                    await _db.collection('guru').doc(uid).set({
                      'nip': nip,
                      'nama': namaC.text.trim(),
                      'email': emailC.text.trim(),
                      'mapel': mapelC.text.trim(),
                    });
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? "Data guru berhasil diperbarui." : "Guru berhasil didaftarkan."),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: Text(
                isEdit ? "Simpan Perubahan" : "Daftarkan Guru",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String guruId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Hapus Guru?",
          style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          "Akun guru ini akan dinonaktifkan dari sistem pengajaran.",
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await _db.collection('guru').doc(guruId).delete();
                await _db.collection('users').doc(guruId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Data guru telah dihapus.", style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: Text("Hapus Permanen", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}