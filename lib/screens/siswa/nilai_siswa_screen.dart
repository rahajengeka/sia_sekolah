// lib/screens/siswa/nilai_siswa_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class NilaiSiswaScreen extends StatelessWidget {
  final String siswaId;
  const NilaiSiswaScreen({super.key, required this.siswaId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Transkrip Penilaian",
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('nilai')
            .where('siswaId', isEqualTo: siswaId)
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan memuat data",
                style: GoogleFonts.plusJakartaSans(color: AppColors.error),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = snapshot.data!.docs[i].data();
              return _buildGradeCard(data, cardColor, borderColor, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(
    Map<String, dynamic> data,
    Color cardColor,
    Color borderColor,
    bool isDark,
  ) {
    final mataPelajaran = data['mataPelajaran'] ?? 'Mata Pelajaran';
    final guruNama = data['guruNama'] ?? '-';
    final nilaiAkhir = (data['nilai'] as num?)?.toInt() ?? 0;
    final tugas = (data['tugas'] as num?)?.toInt() ?? 0;
    final uts = (data['uts'] as num?)?.toInt() ?? 0;
    final uas = (data['uas'] as num?)?.toInt() ?? 0;

    String tanggalTampil = '-';
    if (data['tanggal'] != null) {
      try {
        final date = DateTime.parse(data['tanggal']);
        tanggalTampil = DateFormat('dd MMM yyyy', 'id_ID').format(date);
      } catch (_) {}
    }

    Color scoreColor;
    String statusText;
    if (nilaiAkhir >= 85) {
      scoreColor = AppColors.success;
      statusText = "Sangat Baik";
    } else if (nilaiAkhir >= 75) {
      scoreColor = AppColors.info;
      statusText = "Tuntas";
    } else {
      scoreColor = AppColors.error;
      statusText = "Remedial";
    }

    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mataPelajaran,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 13, color: subtextColor),
                        const SizedBox(width: 4),
                        Text(
                          guruNama,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    nilaiAkhir.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Divider(color: borderColor, thickness: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ),
                Text(
                  tanggalTampil,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreComponent("Tugas", tugas, textColor, subtextColor),
                _buildScoreComponent("UTS", uts, textColor, subtextColor),
                _buildScoreComponent("UAS", uas, textColor, subtextColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreComponent(String label, int score, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
        ),
        const SizedBox(height: 3),
        Text(
          score.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grade_outlined,
            size: 52,
            color: subtextColor.withOpacity(0.4),
          ),
          const SizedBox(height: 14),
          Text(
            "Belum Ada Data Penilaian",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Nilai dari pengajar akan muncul di sini.",
            style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}