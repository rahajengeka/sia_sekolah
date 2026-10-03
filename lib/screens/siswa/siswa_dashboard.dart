// lib/screens/siswa/siswa_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/siswa.dart';
import '../../theme/app_theme.dart';
import '../pengumuman_screen.dart';
import 'rapor_screen.dart';
import '../login_screen.dart';

// ==================== DASHBOARD SISWA ====================
class SiswaDashboard extends StatelessWidget {
  const SiswaDashboard({super.key});

  Future<Siswa?> _loadSiswa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('siswa')
        .doc(user.uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return Siswa.fromJson(doc.data()!, doc.id);
  }

  void _confirmLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Konfirmasi Logout",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar dari Portal Siswa?",
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
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Siswa?>(
        future: _loadSiswa(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              backgroundColor: bgColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      "Data profil siswa belum terdaftar.",
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: const Text("Kembali ke Login"),
                    ),
                  ],
                ),
              ),
            );
          }

          final siswa = snapshot.data!;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP APP BAR (Branding, Role Badge, Date, Logout)
                      _buildTopBar(context, isDark, cardColor, borderColor, textColor),

                      const SizedBox(height: 20),

                      // 2. HERO STUDENT CREDENTIAL & ACADEMIC STATS
                      _buildStudentHero(context, siswa, isDark),

                      const SizedBox(height: 28),

                      // 3. LAYANAN AKADEMIK (RESPONSIVE GRID)
                      Text(
                        "Layanan Akademik Siswa",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildAcademicGrid(context, siswa, isDark),

                      const SizedBox(height: 32),

                      // 4. LOWER SECTION: TODAY'S SCHEDULE & ACADEMIC NOTICE
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 850;

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Jadwal Hari Ini
                                Expanded(
                                  flex: 3,
                                  child: _buildTodayScheduleCard(
                                    context,
                                    siswa,
                                    isDark,
                                    cardColor,
                                    borderColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Right: Ringkasan & Informasi Kelulusan
                                Expanded(
                                  flex: 2,
                                  child: _buildAcademicNoticePanel(
                                    context,
                                    siswa,
                                    isDark,
                                    cardColor,
                                    borderColor,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTodayScheduleCard(
                                context,
                                siswa,
                                isDark,
                                cardColor,
                                borderColor,
                              ),
                              const SizedBox(height: 24),
                              _buildAcademicNoticePanel(
                                context,
                                siswa,
                                isDark,
                                cardColor,
                                borderColor,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 1. TOP BAR ---
  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
  ) {
    return Row(
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
                Icons.school_rounded,
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
                      "Portal Siswa Terpadu",
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

        // Date & Logout
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMM yyyy', 'id_ID').format(DateTime.now()),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _confirmLogout(context),
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
      ],
    );
  }

  // --- 2. STUDENT HERO BANNER & STATS ---
  Widget _buildStudentHero(BuildContext context, Siswa siswa, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('nilai')
          .where('siswaId', isEqualTo: siswa.id)
          .snapshots(),
      builder: (context, snapshot) {
        double avgScore = 0.0;
        int totalMapel = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          totalMapel = docs.length;
          final totalScore = docs.fold<double>(0.0, (acc, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return acc + ((data['nilai'] as num?)?.toDouble() ?? 0.0);
          });
          avgScore = totalScore / totalMapel;
        }

        final isLulus = avgScore >= 75.0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.primaryDark,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    child: Text(
                      siswa.nama.isNotEmpty ? siswa.nama[0].toUpperCase() : "S",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Tahun Ajaran 2024/2025 • Semester Genap",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Siswa Aktif",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          siswa.nama,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "NIS: ${siswa.nis} • Kelas: ${siswa.kelas} ${siswa.jurusan}",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.15), height: 1),
              const SizedBox(height: 16),

              // KPI Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildHeroStatItem(
                      label: "Rata-rata Nilai",
                      value: avgScore > 0 ? avgScore.toStringAsFixed(1) : "-",
                      badgeText: avgScore > 0 ? (isLulus ? "LULUS KKM" : "REMEDIAL") : "BELUM LENGKAP",
                      badgeColor: isLulus ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15)),
                  Expanded(
                    child: _buildHeroStatItem(
                      label: "Mata Pelajaran Dinilai",
                      value: "$totalMapel Mapel",
                      badgeText: "TERCATAT",
                      badgeColor: Colors.white24,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15)),
                  Expanded(
                    child: _buildHeroStatItem(
                      label: "Status Akademik",
                      value: isLulus ? "Memuaskan" : (avgScore > 0 ? "Perlu Remedial" : "Aktif"),
                      badgeText: "SEMESTER GENAP",
                      badgeColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroStatItem({
    required String label,
    required String value,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. ACADEMIC SERVICES GRID ---
  Widget _buildAcademicGrid(BuildContext context, Siswa siswa, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 1.25;

        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 5;
          childAspectRatio = 1.05;
        } else if (constraints.maxWidth >= 650) {
          crossAxisCount = 3;
          childAspectRatio = 1.15;
        }

        final items = [
          _buildMenuServiceCard(
            context: context,
            title: "Hasil Rapor",
            desc: "Cetak & unduh PDF",
            icon: Icons.assignment_turned_in_outlined,
            color: AppColors.info,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RaporScreen(
                    siswaId: siswa.id,
                    namaSiswa: siswa.nama,
                  ),
                ),
              );
            },
          ),
          _buildMenuServiceCard(
            context: context,
            title: "Grafik & Nilai",
            desc: "Analisis performa KKM",
            icon: Icons.bar_chart_rounded,
            color: AppColors.success,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GrafikNilaiScreen(siswaId: siswa.id),
                ),
              );
            },
          ),
          _buildMenuServiceCard(
            context: context,
            title: "Jadwal Pelajaran",
            desc: "Jadwal tatap muka",
            icon: Icons.calendar_month_outlined,
            color: AppColors.warning,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JadwalSiswaScreen(
                    kelas: siswa.kelas,
                    jurusan: siswa.jurusan,
                  ),
                ),
              );
            },
          ),
          _buildMenuServiceCard(
            context: context,
            title: "Pengumuman",
            desc: "Agenda & info sekolah",
            icon: Icons.campaign_outlined,
            color: const Color(0xFF7C3AED),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PengumumanScreen(),
                ),
              );
            },
          ),
          _buildMenuServiceCard(
            context: context,
            title: "Profil & Kartu",
            desc: "Data induk siswa",
            icon: Icons.badge_outlined,
            color: const Color(0xFF0D9488),
            isDark: isDark,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProfilSiswaDialog(siswa: siswa),
              );
            },
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: items,
        );
      },
    );
  }

  Widget _buildMenuServiceCard({
    required BuildContext context,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: subtextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. TODAY'S SCHEDULE CARD (LEFT) ---
  Widget _buildTodayScheduleCard(
    BuildContext context,
    Siswa siswa,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final today = hariList[DateTime.now().weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Jadwal Belajar Hari Ini",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    today,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JadwalSiswaScreen(
                      kelas: siswa.kelas,
                      jurusan: siswa.jurusan,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Semua Hari",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jadwal_pelajaran')
              .where('kelas', isEqualTo: siswa.kelas)
              .where('jurusan', isEqualTo: siswa.jurusan)
              .where('hari', isEqualTo: today)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 44,
                      color: subtextColor.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tidak ada jadwal pelajaran hari ini ($today)",
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Selamat beristirahat atau gunakan waktu untuk mengulang materi pelajaran.",
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            final jadwalList = docs.map((d) => d.data() as Map<String, dynamic>).toList()
              ..sort((a, b) => (a['jamMulai'] ?? '').compareTo(b['jamMulai'] ?? ''));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jadwalList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final j = jadwalList[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              j['jamMulai'] ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            Text(
                              j['jamSelesai'] ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j['mataPelajaran'] ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pengajar: ${j['guruNama'] ?? '-'}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (j['ruangan'] != null && j['ruangan'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "R. ${j['ruangan']}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- 5. ACADEMIC NOTICE PANEL (RIGHT) ---
  Widget _buildAcademicNoticePanel(
    BuildContext context,
    Siswa siswa,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pusat Panduan Akademik Siswa",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_outlined, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ketentuan Ketuntasan Belajar",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Nilai rapor diakumulasi dari seluruh penilaian guru. Siswa dengan nilai di bawah batas KKM (75.0) wajib menghubungi guru pengampu mata pelajaran untuk program remedial.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: subtextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    "Format Nilai: Kurikulum Merdeka",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    "Cetak Rapor: Resmi & Bertanda Tangan",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RaporScreen(
                          siswaId: siswa.id,
                          namaSiswa: siswa.nama,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: Text(
                    "Lihat Lembar Rapor Digital",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== GRAFIK NILAI SCREEN ====================
class GrafikNilaiScreen extends StatelessWidget {
  final String siswaId;
  const GrafikNilaiScreen({super.key, required this.siswaId});

  @override
  Widget build(BuildContext context) {
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
          "Statistik & Grafik Nilai",
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('nilai')
                .where('siswaId', isEqualTo: siswaId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 52, color: subtextColor.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada data nilai tercatat di sistem.",
                        style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              final List<Map<String, dynamic>> dataGrafik = docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                return {
                  'mapel': data['mataPelajaran'] ?? '?',
                  'nilai': (data['nilai'] as num?)?.toDouble() ?? 0.0,
                };
              }).toList();

              final totalScore = dataGrafik.fold<double>(0, (prev, item) => prev + (item['nilai'] as double));
              final avgScore = dataGrafik.isNotEmpty ? (totalScore / dataGrafik.length) : 0.0;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.primaryDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rata-rata Nilai Keseluruhan",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                avgScore.toStringAsFixed(1),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              avgScore >= 75 ? "Status: LULUS KKM" : "Status: PERLU BIMBINGAN",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bar Chart Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  String mapel = dataGrafik[group.x.toInt()]['mapel'];
                                  return BarTooltipItem(
                                    '$mapel\n${rod.toY.toStringAsFixed(0)}',
                                    GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    if (value.toInt() >= dataGrafik.length) return const SizedBox();
                                    String mapel = dataGrafik[value.toInt()]['mapel'].toString();
                                    String label = mapel.length > 5 ? mapel.substring(0, 5) : mapel;
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        label,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: subtextColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 25,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: subtextColor,
                                        fontSize: 11,
                                      ),
                                    );
                                  },
                                  reservedSize: 32,
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 25,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: borderColor,
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: dataGrafik.asMap().entries.map((e) {
                              final index = e.key;
                              final nilai = e.value['nilai'] as double;
                              final isLulus = nilai >= 75;

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: nilai,
                                    color: isLulus ? AppColors.primaryLight : AppColors.error,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(AppColors.primaryLight, "Tuntas (≥75)", textColor),
                        const SizedBox(width: 24),
                        _legendItem(AppColors.error, "Remedial (<75)", textColor),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==================== JADWAL SISWA SCREEN ====================
class JadwalSiswaScreen extends StatelessWidget {
  final String kelas;
  final String jurusan;
  const JadwalSiswaScreen({
    super.key,
    required this.kelas,
    required this.jurusan,
  });

  static const List<String> hariOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  Widget build(BuildContext context) {
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
          "Jadwal Kelas $kelas $jurusan",
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jadwal_pelajaran')
                .where('kelas', isEqualTo: kelas)
                .where('jurusan', isEqualTo: jurusan)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "Belum ada jadwal untuk kelas ini.",
                    style: GoogleFonts.plusJakartaSans(color: subtextColor),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              docs.sort((a, b) {
                final hariA = hariOrder.indexOf(a['hari'] ?? '');
                final hariB = hariOrder.indexOf(b['hari'] ?? '');
                if (hariA != hariB) return hariA.compareTo(hariB);
                return (a['jamMulai'] ?? '').compareTo(b['jamMulai'] ?? '');
              });

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                d['hari'] ?? '-',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              Text(
                                d['jamMulai'] ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['mataPelajaran'] ?? '-',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Guru Pengajar: ${d['guruNama'] ?? '-'}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: subtextColor,
                                ),
                              ),
                              if ((d['ruangan'] as String?)?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    "Ruang: ${d['ruangan']}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== PROFIL SISWA (DIGITAL ID CARD) ====================
class ProfilSiswaDialog extends StatelessWidget {
  final Siswa siswa;
  const ProfilSiswaDialog({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                child: Text(
                  siswa.nama.isNotEmpty ? siswa.nama[0].toUpperCase() : "S",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                siswa.nama,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Siswa Aktif Terdaftar",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 16),

              _infoRow(Icons.badge_outlined, "Nomor Induk Siswa (NIS)", siswa.nis, textColor, subtextColor),
              _infoRow(Icons.class_outlined, "Tingkat Kelas & Jurusan", "${siswa.kelas} ${siswa.jurusan}", textColor, subtextColor),
              _infoRow(Icons.email_outlined, "Alamat Email Terdaftar", siswa.email, textColor, subtextColor),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Tutup Kartu",
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: subtextColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subtextColor),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
