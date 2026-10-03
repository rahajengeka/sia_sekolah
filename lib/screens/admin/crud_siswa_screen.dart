// lib/screens/admin/crud_siswa_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../models/siswa.dart';
import '../../theme/app_theme.dart';

class CrudSiswaScreen extends StatefulWidget {
  const CrudSiswaScreen({super.key});
  @override
  State<CrudSiswaScreen> createState() => _CrudSiswaScreenState();
}

class _CrudSiswaScreenState extends State<CrudSiswaScreen> {
  final FirestoreService _fs = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedKelas;
  String? selectedJurusan;
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Kelola Data Siswa",
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
          "Tambah Siswa",
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
          // 1. FILTER & SEARCH SECTION
          _buildFilterSection(isDark),

          // 2. LIST SISWA
          Expanded(child: _buildListSiswa(isDark)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchC,
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Cari berdasarkan nama atau NIS...",
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: subtextColor),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchC.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Kelas 10", selectedKelas == "10", () => setState(() => selectedKelas = selectedKelas == "10" ? null : "10"), isDark),
                const SizedBox(width: 8),
                _buildFilterChip("Kelas 11", selectedKelas == "11", () => setState(() => selectedKelas = selectedKelas == "11" ? null : "11"), isDark),
                const SizedBox(width: 8),
                _buildFilterChip("Kelas 12", selectedKelas == "12", () => setState(() => selectedKelas = selectedKelas == "12" ? null : "12"), isDark),

                Container(height: 20, width: 1, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 10)),

                _buildFilterChip("IPA", selectedJurusan == "IPA", () => setState(() => selectedJurusan = selectedJurusan == "IPA" ? null : "IPA"), isDark),
                const SizedBox(width: 8),
                _buildFilterChip("IPS", selectedJurusan == "IPS", () => setState(() => selectedJurusan = selectedJurusan == "IPS" ? null : "IPS"), isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    final primary = AppColors.primaryLight;
    final borderColor = isSelected ? primary : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final bgColor = isSelected ? primary.withOpacity(0.08) : (isDark ? AppColors.cardDark : AppColors.surfaceLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildListSiswa(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return StreamBuilder<List<Siswa>>(
      stream: _fs.streamSiswa(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        var list = snapshot.data ?? [];

        if (selectedKelas != null) list = list.where((s) => s.kelas == selectedKelas).toList();
        if (selectedJurusan != null) list = list.where((s) => s.jurusan == selectedJurusan).toList();
        if (searchQuery.isNotEmpty) {
          list = list.where((s) =>
                  s.nama.toLowerCase().contains(searchQuery) ||
                  s.nis.toLowerCase().contains(searchQuery))
              .toList();
        }

        list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined, size: 52, color: subtextColor.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada data siswa ditemukan.",
                  style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final s = list[i];

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
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  child: Text(
                    s.nama.isNotEmpty ? s.nama[0].toUpperCase() : "?",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(
                  s.nama,
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
                          "NIS: ${s.nis}",
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Kelas ${s.kelas} ${s.jurusan}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: subtextColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val == 'edit') _showForm(context, siswa: s);
                    if (val == 'delete') _confirmDelete(context, s.id);
                  },
                  itemBuilder: (_) => [
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
                          Text("Hapus Siswa", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.error)),
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
    );
  }

  Future<String> _generateNIS(String kelas, String jurusan) async {
    final year = DateTime.now().year.toString().substring(2);
    final query = await FirebaseFirestore.instance
        .collection('siswa')
        .where('kelas', isEqualTo: kelas)
        .where('jurusan', isEqualTo: jurusan)
        .get();

    final count = (query.docs.length + 1).toString().padLeft(3, '0');
    return "$year$kelas$count";
  }

  void _showForm(BuildContext context, {Siswa? siswa}) async {
    final isEdit = siswa != null;
    final namaC = TextEditingController(text: siswa?.nama ?? '');
    final emailC = TextEditingController(text: siswa?.email ?? '');
    final passC = TextEditingController();

    String? kelas = siswa?.kelas;
    String? jurusan = siswa?.jurusan;
    String nis = siswa?.nis ?? "Pilih Kelas & Jurusan";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? "Edit Data Siswa" : "Tambah Siswa Baru",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaC,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: "Nama Lengkap Siswa",
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
                        labelText: "Email Akun Siswa",
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

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: kelas,
                          decoration: const InputDecoration(labelText: "Kelas"),
                          items: ["10", "11", "12"].map((k) => DropdownMenuItem(value: k, child: Text("Kls $k"))).toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              kelas = v;
                              jurusan = null;
                              nis = "...";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: jurusan,
                          decoration: const InputDecoration(labelText: "Jurusan"),
                          items: ["IPA", "IPS"].map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                          onChanged: kelas != null ? (v) async {
                            setStateDialog(() {
                              jurusan = v;
                              nis = "Menghitung...";
                            });
                            final newNis = await _generateNIS(kelas!, v!);
                            setStateDialog(() => nis = newNis);
                          } : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // NIS DISPLAY
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NOMOR INDUK SISWA (NIS)",
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: subtextColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                if (namaC.text.isEmpty || kelas == null || jurusan == null || (!isEdit && (emailC.text.isEmpty || passC.text.isEmpty))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mohon lengkapi semua kolom.")),
                  );
                  return;
                }

                try {
                  if (isEdit) {
                    await _fs.updateSiswa(siswa.id, {
                      'nama': namaC.text.trim(),
                      'kelas': kelas,
                      'jurusan': jurusan,
                      'nis': nis,
                    });
                  } else {
                    final cred = await _auth.createUserWithEmailAndPassword(
                      email: emailC.text.trim(),
                      password: passC.text,
                    );
                    final uid = cred.user!.uid;

                    final batch = FirebaseFirestore.instance.batch();

                    batch.set(FirebaseFirestore.instance.collection('users').doc(uid), {
                      'role': 'siswa',
                      'email': emailC.text.trim(),
                    });

                    batch.set(FirebaseFirestore.instance.collection('siswa').doc(uid), {
                      'id': uid,
                      'nis': nis,
                      'nama': namaC.text.trim(),
                      'email': emailC.text.trim(),
                      'kelas': kelas,
                      'jurusan': jurusan,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    await batch.commit();
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isEdit ? "Data siswa berhasil diperbarui." : "Siswa berhasil didaftarkan."),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ));
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
                isEdit ? "Simpan Perubahan" : "Daftarkan Siswa",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String siswaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Hapus Akun Siswa?",
          style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          "Akun siswa akan dihapus secara permanen dari sistem akademik.",
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('siswa').doc(siswaId).delete();
              await FirebaseFirestore.instance.collection('users').doc(siswaId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              "Hapus Permanen",
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}