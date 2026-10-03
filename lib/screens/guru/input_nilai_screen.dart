// lib/screens/guru/input_nilai_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../models/siswa.dart';
import '../../theme/app_theme.dart';

class InputNilaiScreen extends StatefulWidget {
  final String kelas;
  final String jurusan;
  final String mataPelajaran;
  final String guruId;
  final String guruNama;

  const InputNilaiScreen({
    super.key,
    required this.kelas,
    required this.jurusan,
    required this.mataPelajaran,
    required this.guruId,
    required this.guruNama,
  });

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  final _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Input Penilaian",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. HEADER INFO KELAS
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.primaryDark,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.mataPelajaran,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Kelas ${widget.kelas} ${widget.jurusan}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Pengajar: ${widget.guruNama}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // 2. SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
              decoration: InputDecoration(
                hintText: "Cari nama siswa...",
                prefixIcon: Icon(Icons.search, size: 20, color: subtextColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. DAFTAR SISWA
          Expanded(
            child: StreamBuilder<List<Siswa>>(
              stream: firestore.streamSiswaByKelas(widget.kelas, widget.jurusan),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: subtextColor.withOpacity(0.4)),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada siswa di kelas ini.",
                          style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                var list = snapshot.data!;
                if (searchQuery.isNotEmpty) {
                  list = list.where((s) => s.nama.toLowerCase().contains(searchQuery)).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final siswa = list[i];
                    return _buildSiswaCard(siswa, isDark, cardColor, borderColor, textColor, subtextColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(
    Siswa siswa,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
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
            siswa.nama.isNotEmpty ? siswa.nama[0].toUpperCase() : "?",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(
          siswa.nama,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
        ),
        subtitle: Text(
          "NIS: ${siswa.nis}",
          style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryLight),
              const SizedBox(width: 4),
              Text(
                "Input Nilai",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showInputDialog(siswa, isDark),
      ),
    );
  }

  // --- DIALOG INPUT NILAI ---
  void _showInputDialog(Siswa siswa, bool isDark) {
    final tugasC = TextEditingController();
    final utsC = TextEditingController();
    final uasC = TextEditingController();
    double finalScore = 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void calculate() {
              final t = double.tryParse(tugasC.text) ?? 0;
              final u1 = double.tryParse(utsC.text) ?? 0;
              final u2 = double.tryParse(uasC.text) ?? 0;
              setStateDialog(() {
                finalScore = (t * 0.3) + (u1 * 0.3) + (u2 * 0.4);
              });
            }

            final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
            final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Penilaian Siswa",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    siswa.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScoreField(tugasC, "Nilai Tugas (Bobot 30%)", calculate, isDark),
                    const SizedBox(height: 12),
                    _buildScoreField(utsC, "Nilai UTS (Bobot 30%)", calculate, isDark),
                    const SizedBox(height: 12),
                    _buildScoreField(uasC, "Nilai UAS (Bobot 40%)", calculate, isDark),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nilai Akhir (Kalkulasi):",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: subtextColor,
                          ),
                        ),
                        Text(
                          finalScore.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _getScoreColor(finalScore),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: GoogleFonts.plusJakartaSans(
                      color: subtextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(120, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (tugasC.text.isEmpty || utsC.text.isEmpty || uasC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Harap lengkapi semua komponen nilai!")),
                      );
                      return;
                    }

                    final tugas = double.tryParse(tugasC.text) ?? 0;
                    final uts = double.tryParse(utsC.text) ?? 0;
                    final uas = double.tryParse(uasC.text) ?? 0;
                    final nilaiBulat = finalScore.round();

                    await FirebaseFirestore.instance.collection('nilai').add({
                      'siswaId': siswa.id,
                      'siswaNama': siswa.nama,
                      'guruId': widget.guruId,
                      'guruNama': widget.guruNama,
                      'mataPelajaran': widget.mataPelajaran,
                      'kelas': widget.kelas,
                      'jurusan': widget.jurusan,
                      'tugas': tugas,
                      'uts': uts,
                      'uas': uas,
                      'nilai': nilaiBulat,
                      'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Nilai ${siswa.nama} berhasil disimpan."),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Simpan Nilai",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScoreField(
    TextEditingController c,
    String label,
    VoidCallback onChanged,
    bool isDark,
  ) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => onChanged(),
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }
}