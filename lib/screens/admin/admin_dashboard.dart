// lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'crud_siswa_screen.dart';
import 'crud_guru_screen.dart';
import 'jadwal_screen.dart';
import '../pengumuman_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Konfirmasi Logout",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar dari Portal Administrasi?",
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Batal",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              authProvider.logout(context);
            },
            child: Text(
              "Ya, Keluar",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.read<AuthProvider>();

    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP APP BAR & BRANDING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.primaryDark),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SMA BRAWIJAYA",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: textColor,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Super Administrator",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // LOGOUT BUTTON
                  IconButton(
                    onPressed: () => _confirmLogout(context, authProvider),
                    tooltip: "Logout",
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. HERO SUMMARY BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.primaryDark,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now()),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "T.A. 2025/2026",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Selamat Datang, Admin",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pusat kendali dan manajemen operasional akademik SMA Brawijaya Malang.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. STATISTIK REALTIME (KPI)
              Text(
                "Ringkasan Data Sekolah",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  final stat1 = _buildStatCard(
                    stream: _db.collection('siswa').snapshots(),
                    title: "Total Siswa",
                    icon: Icons.people_alt_rounded,
                    color: AppColors.info,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  );
                  final stat2 = _buildStatCard(
                    stream: _db.collection('guru').snapshots(),
                    title: "Total Guru",
                    icon: Icons.school_rounded,
                    color: AppColors.success,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  );
                  final stat3 = _buildStatCard(
                    stream: _db.collection('jadwal_pelajaran').snapshots(),
                    title: "Jadwal Aktif",
                    icon: Icons.event_note_rounded,
                    color: AppColors.warning,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  );
                  final stat4 = _buildStatCard(
                    stream: _db.collection('pengumuman').snapshots(),
                    title: "Pengumuman",
                    icon: Icons.campaign_rounded,
                    color: const Color(0xFF7C3AED),
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: stat1),
                        const SizedBox(width: 12),
                        Expanded(child: stat2),
                        const SizedBox(width: 12),
                        Expanded(child: stat3),
                        const SizedBox(width: 12),
                        Expanded(child: stat4),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: stat1),
                          const SizedBox(width: 12),
                          Expanded(child: stat2),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: stat3),
                          const SizedBox(width: 12),
                          Expanded(child: stat4),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 4. MENU MANAJEMEN UTAMA
              Text(
                "Menu Manajemen",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.35 : 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        title: "Data Siswa",
                        desc: "Kelola NIS, kelas & profil",
                        icon: Icons.badge_outlined,
                        accentColor: AppColors.info,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CrudSiswaScreen()),
                        ),
                      ),
                      _buildActionCard(
                        title: "Data Guru",
                        desc: "Atur NIP & penugasan mapel",
                        icon: Icons.co_present_outlined,
                        accentColor: AppColors.success,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CrudGuruScreen()),
                        ),
                      ),
                      _buildActionCard(
                        title: "Jadwal",
                        desc: "Alokasi jam & kelas",
                        icon: Icons.calendar_month_outlined,
                        accentColor: AppColors.warning,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JadwalScreen()),
                        ),
                      ),
                      _buildActionCard(
                        title: "Pengumuman",
                        desc: "Broadcast informasi",
                        icon: Icons.campaign_outlined,
                        accentColor: const Color(0xFF7C3AED),
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PengumumanScreen()),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 5. PENGUMUMAN TERAKHIR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pengumuman Terkini",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PengumumanScreen()),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Lihat Semua",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('pengumuman').orderBy('tanggal', descending: true).limit(2).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Center(
                        child: Text(
                          "Belum ada pengumuman yang dipublikasikan.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: subtextColor,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final judul = data['judul'] ?? "Pengumuman";
                      final isi = data['isi'] ?? "";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFF7C3AED),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    judul,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isi,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: subtextColor,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  // --- STAT CARD (CLEAN & METRIC-FOCUSED) ---
  Widget _buildStatCard({
    required Stream<QuerySnapshot> stream,
    required String title,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text(
                      "$count",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    );
                  },
                ),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ACTION CARD ---
  Widget _buildActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: subtextColor,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}