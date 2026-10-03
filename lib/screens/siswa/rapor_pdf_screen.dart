// lib/screens/siswa/rapor_pdf_screen.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class RaporPdfScreen extends StatefulWidget {
  final String siswaId;
  final String namaSiswa;
  const RaporPdfScreen({super.key, required this.siswaId, required this.namaSiswa});

  @override
  State<RaporPdfScreen> createState() => _RaporPdfScreenState();
}

class _RaporPdfScreenState extends State<RaporPdfScreen> {
  bool _isGenerating = false;

  Future<void> _generatePdf() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    try {
      final firestore = Provider.of<FirestoreService>(context, listen: false);
      final nilaiList = await firestore.streamNilaiBySiswa(widget.siswaId).first;

      if (nilaiList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Belum ada data nilai untuk dicetak.")),
          );
          setState(() => _isGenerating = false);
        }
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header PDF
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text("SMA BRAWIJAYA", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text("LAPORAN HASIL BELAJAR SISWA", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 12),
                  pw.Divider(thickness: 1.5),
                  pw.SizedBox(height: 16),
                ],
              ),
            ),

            // Info Siswa
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Nama Siswa: ${widget.namaSiswa}", style: const pw.TextStyle(fontSize: 12)),
                pw.Text("Tanggal Cetak: ${DateTime.now().toString().substring(0, 10)}", style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 20),

            // Tabel Nilai
            pw.Table.fromTextArray(
              headers: ['Mata Pelajaran', 'Guru', 'Tugas', 'UTS', 'UAS', 'Akhir', 'Grade'],
              data: nilaiList.map((n) => [
                n.mataPelajaran,
                n.guruNama,
                n.tugas.toStringAsFixed(0),
                n.uts.toStringAsFixed(0),
                n.uas.toStringAsFixed(0),
                n.akhir.toStringAsFixed(1),
                n.predikat,
              ]).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1E3A8A)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 26,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
            ),

            pw.SizedBox(height: 40),

            // Tanda Tangan
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text("Mengetahui,", style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 50),
                  pw.Text("( Kepala Sekolah )", style: const pw.TextStyle(fontSize: 11)),
                  pw.Container(width: 120, child: pw.Divider()),
                ],
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "Rapor_${widget.namaSiswa.replaceAll(" ", "_")}.pdf")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/Rapor_${widget.namaSiswa.replaceAll(' ', '_')}.pdf");
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil mengunduh dokumen rapor.", style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Cetak Dokumen Rapor",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textColor,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visualisasi Dokumen (Formal Paper Look)
              Container(
                width: 260,
                height: 360,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_rounded, size: 18, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 3, width: double.infinity, color: const Color(0xFF0F172A)),
                    const SizedBox(height: 2),
                    Container(height: 1, width: double.infinity, color: const Color(0xFF64748B)),
                    const SizedBox(height: 16),

                    _buildLine(70),
                    const SizedBox(height: 6),
                    _buildLine(120),
                    const SizedBox(height: 16),
                    _buildLine(double.infinity),
                    const SizedBox(height: 6),
                    _buildLine(double.infinity),
                    const SizedBox(height: 6),
                    _buildLine(180),

                    const Spacer(),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 50,
                        height: 16,
                        color: const Color(0xFFF1F5F9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "Dokumen Siap Diekspor",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Rapor Akademik: ${widget.namaSiswa}",
                style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
              ),

              const SizedBox(height: 24),

              _isGenerating
                  ? Column(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                        const SizedBox(height: 12),
                        Text(
                          "Sedang membuat dokumen PDF...",
                          style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                        ),
                      ],
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                        onPressed: _generatePdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Unduh Dokumen PDF",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 16),
              if (!_isGenerating)
                Text(
                  "Format resmi A4 standar administrasi sekolah",
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subtextColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(double width) {
    return Container(
      height: 5,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}