// lib/screens/guru/pilih_kelas_input_nilai_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'input_nilai_screen.dart';

class PilihKelasInputNilaiScreen extends StatelessWidget {
  const PilihKelasInputNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = Provider.of<FirestoreService>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Pilih Kelas Penilaian",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.streamJadwalGuru(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          // Hapus duplikat kelas
          final kelasSet = <String>{};
          final kelasList = <Map<String, dynamic>>[];

          for (var j in snapshot.data!) {
            final key = "${j['kelas']}-${j['jurusan']}-${j['mataPelajaran']}";
            if (kelasSet.add(key)) {
              kelasList.add(j);
            }
          }

          kelasList.sort((a, b) => a['kelas'].toString().compareTo(b['kelas'].toString()));

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: kelasList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final k = kelasList[i];
              return _buildClassCard(context, k, user, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> data, User user, bool isDark) {
    final String kelas = data['kelas']?.toString() ?? '-';
    final String jurusan = data['jurusan']?.toString() ?? '-';
    final String mapel = data['mataPelajaran']?.toString() ?? '-';

    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InputNilaiScreen(
                  kelas: kelas,
                  jurusan: jurusan,
                  mataPelajaran: mapel,
                  guruId: user.uid,
                  guruNama: user.displayName ?? "Guru",
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 1. Badge Kelas
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kelas,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      Text(
                        jurusan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Info Mapel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.edit_note_rounded, size: 14, color: subtextColor),
                          const SizedBox(width: 4),
                          Text(
                            "Ketuk untuk menginput nilai siswa",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: subtextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 52,
            color: subtextColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum Ada Jadwal Mengajar",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Anda belum ditugaskan di kelas manapun.",
            style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}