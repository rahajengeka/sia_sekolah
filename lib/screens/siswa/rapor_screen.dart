// lib/screens/siswa/rapor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/nilai.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'rapor_pdf_screen.dart';

class RaporScreen extends StatelessWidget {
  final String siswaId;
  final String namaSiswa;

  const RaporScreen({super.key, required this.siswaId, required this.namaSiswa});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Laporan Hasil Studi",
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RaporPdfScreen(siswaId: siswaId, namaSiswa: namaSiswa),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
        label: Text(
          "Cetak Rapor PDF",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
      body: StreamBuilder<List<Nilai>>(
        stream: firestore.streamNilaiBySiswa(siswaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    "Gagal memuat data rapor.",
                    style: GoogleFonts.plusJakartaSans(color: subtextColor),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 52, color: subtextColor.withOpacity(0.4)),
                  const SizedBox(height: 14),
                  Text(
                    "Belum ada data nilai",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nilai akan tampil setelah guru menginput penilaian.",
                    style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final nilaiList = snapshot.data!;
          double totalNilai = 0;
          for (var n in nilaiList) {
            totalNilai += n.akhir;
          }
          final rataRata = nilaiList.isNotEmpty ? totalNilai / nilaiList.length : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. INSTITUTIONAL SUMMARY BANNER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.primaryDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lembar Hasil Penilaian",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                namaSiswa,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Semester Genap",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _buildStatItem("Mata Pelajaran", "${nilaiList.length}"),
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildStatItem("Rata-Rata Nilai", rataRata.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  "Rincian Hasil Studi",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. TABEL NILAI TERSTRUKTUR
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3.2),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.2),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        // HEADER ROW
                        TableRow(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9),
                          ),
                          children: [
                            _buildHeaderCell("Mata Pelajaran", Alignment.centerLeft),
                            _buildHeaderCell("Skor", Alignment.center),
                            _buildHeaderCell("Predikat", Alignment.center),
                          ],
                        ),
                        // DATA ROWS
                        ...nilaiList.asMap().entries.map((entry) {
                          final n = entry.value;

                          return TableRow(
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: borderColor, width: 0.8)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.mataPelajaran,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "T:${n.tugas.toInt()}  UTS:${n.uts.toInt()}  UAS:${n.uas.toInt()}",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                n.akhir.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              Center(child: _buildPredikatBadge(n.predikat)),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, Alignment align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: align,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPredikatBadge(String predikat) {
    Color color;
    switch (predikat) {
      case 'A':
        color = AppColors.success;
        break;
      case 'B':
        color = AppColors.info;
        break;
      case 'C':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.error;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          predikat,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}