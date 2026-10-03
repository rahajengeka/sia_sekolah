// lib/screens/pengumuman_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  final FirestoreService _fs = FirestoreService();
  bool _isAdminUser = false;
  bool _isLoadingCheck = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _isAdminUser = doc.exists && doc.data()?['role'] == 'admin';
          _isLoadingCheck = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingCheck = false);
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
          "Papan Pengumuman Resmi",
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
      floatingActionButton: !_isLoadingCheck && _isAdminUser
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text(
                "Buat Pengumuman",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              onPressed: () => _showInputSheet(context, isDark),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.streamPengumuman(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          var docs = snapshot.data?.docs ?? [];
          final visible = docs.where((d) {
            final m = d.data() as Map<String, dynamic>;
            return m['isPublished'] == true || m['isPublished'] == null;
          }).toList();

          visible.sort((a, b) {
            try {
              final aDate = _parseDate((a.data() as Map)['tanggal']);
              final bDate = _parseDate((b.data() as Map)['tanggal']);
              return bDate.compareTo(aDate);
            } catch (_) {
              return 0;
            }
          });

          if (visible.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 52,
                    color: subtextColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Belum ada pengumuman",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Pengumuman akademik terbaru akan ditampilkan di sini.",
                    style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = visible[i];
              final data = doc.data() as Map<String, dynamic>;
              return _buildCard(doc.id, data, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(String id, Map<String, dynamic> data, bool isDark) {
    final date = _parseDate(data['tanggal']);
    final dateStr = DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(date);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['judul'] ?? 'Tanpa Judul',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAdminUser)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    tooltip: "Hapus Pengumuman",
                    onPressed: () => _confirmDelete(id),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          // Body Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              data['isi'] ?? '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  // --- FORM INPUT BOTTOM SHEET ---
  void _showInputSheet(BuildContext context, bool isDark) {
    final titleC = TextEditingController();
    final isiC = TextEditingController();
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Buat Pengumuman Baru",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleC,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Judul Pengumuman...",
                prefixIcon: Icon(Icons.title_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isiC,
              maxLines: 4,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Tulis isi pengumuman lengkap di sini...",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.trim().isNotEmpty && isiC.text.trim().isNotEmpty) {
                  _fs.addPengumuman(titleC.text.trim(), isiC.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Pengumuman berhasil dipublikasikan.",
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Judul dan isi pengumuman wajib diisi.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Publikasikan Pengumuman",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Hapus Pengumuman",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus pengumuman ini?",
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await _fs.deletePengumuman(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Pengumuman berhasil dihapus.", style: GoogleFonts.plusJakartaSans()),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text("Hapus", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}