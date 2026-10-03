// lib/screens/guru/guru_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import '../pengumuman_screen.dart';
import 'pilih_kelas_input_nilai_screen.dart';

class GuruDashboard extends StatelessWidget {
  const GuruDashboard({super.key});

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
          "Apakah Anda yakin ingin keluar dari Portal Guru?",
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
                  (_) => false,
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Sesi telah berakhir, silakan login kembali.")),
      );
    }

    final firestore = Provider.of<FirestoreService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
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
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('guru').doc(user.uid).snapshots(),
                builder: (context, guruSnapshot) {
                  String nama = "Guru Pengajar";
                  String mapel = "Pengajar Akademik";
                  String nip = "-";

                  if (guruSnapshot.hasData && guruSnapshot.data!.exists) {
                    final data = guruSnapshot.data!.data()!;
                    nama = data['nama'] ?? "Guru Pengajar";
                    mapel = data['mapel'] ?? "Pengajar Akademik";
                    nip = data['nip'] ?? "-";
                  }

                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: firestore.streamJadwalGuru(user.uid),
                    builder: (context, jadwalSnapshot) {
                      final allJadwal = jadwalSnapshot.data ?? [];
                      final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                      final today = hariList[DateTime.now().weekday - 1];

                      final todayJadwal = allJadwal
                          .where((j) => j['hari'] == today)
                          .toList()
                        ..sort((a, b) => (a['jamMulai'] as String).compareTo(b['jamMulai']));

                      final uniqueClasses = allJadwal
                          .map((j) => "${j['kelas'] ?? ''} ${j['jurusan'] ?? ''}".trim())
                          .where((c) => c.isNotEmpty)
                          .toSet();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. TOP APP BAR (Branding, Role Badge, Date, Logout)
                          _buildTopBar(context, isDark, cardColor, borderColor, textColor),

                          const SizedBox(height: 20),

                          // 2. HERO TEACHER BANNER
                          _buildHeroBanner(context, nama, mapel, nip, isDark),

                          const SizedBox(height: 24),

                          // 3. RESPONSIVE KPI STATS ROW
                          _buildKpiSection(
                            context,
                            isDark,
                            cardColor,
                            borderColor,
                            todayJadwalCount: todayJadwal.length,
                            totalKelasCount: uniqueClasses.length,
                            totalJadwalSemua: allJadwal.length,
                            mapel: mapel,
                          ),

                          const SizedBox(height: 28),

                          // 4. MAIN ACTION CARDS (GRID)
                          Text(
                            "Menu Layanan Guru",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildMenuGrid(context, user.uid, isDark),

                          const SizedBox(height: 32),

                          // 5. LOWER SECTION: RESPONSIVE SCHEDULE & QUICK WIDGETS
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 850;

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Schedule Timeline (Flex 3)
                                    Expanded(
                                      flex: 3,
                                      child: _buildScheduleColumn(
                                        context,
                                        user.uid,
                                        today,
                                        todayJadwal,
                                        isDark,
                                        cardColor,
                                        borderColor,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Right: Academic Notice & Guidelines (Flex 2)
                                    Expanded(
                                      flex: 2,
                                      child: _buildRightWidgetPanel(context, isDark, cardColor, borderColor),
                                    ),
                                  ],
                                );
                              }

                              // Narrow / Mobile Layout
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildScheduleColumn(
                                    context,
                                    user.uid,
                                    today,
                                    todayJadwal,
                                    isDark,
                                    cardColor,
                                    borderColor,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildRightWidgetPanel(context, isDark, cardColor, borderColor),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. TOP APP BAR ---
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
                      "Portal Guru & Tenaga Pendidik",
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

  // --- 2. HERO BANNER ---
  Widget _buildHeroBanner(
    BuildContext context,
    String nama,
    String mapel,
    String nip,
    bool isDark,
  ) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : "G",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 18),
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
                        "Guru Aktif",
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
                  nama,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Mata Pelajaran: $mapel • NIP: $nip",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. KPI STATS SECTION ---
  Widget _buildKpiSection(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color borderColor, {
    required int todayJadwalCount,
    required int totalKelasCount,
    required int totalJadwalSemua,
    required String mapel,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        final items = [
          _buildStatCard(
            title: "Mengajar Hari Ini",
            value: "$todayJadwalCount Sesi",
            sub: "Jadwal tatap muka",
            icon: Icons.calendar_today_rounded,
            color: AppColors.primaryLight,
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          _buildStatCard(
            title: "Kelas Diampu",
            value: "$totalKelasCount Kelas",
            sub: "Total rombel terdaftar",
            icon: Icons.class_outlined,
            color: AppColors.success,
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          _buildStatCard(
            title: "Total Jam Mingguan",
            value: "$totalJadwalSemua Jam",
            sub: "Senin s/d Sabtu",
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          _buildStatCard(
            title: "Bidang Studi",
            value: mapel.length > 14 ? "${mapel.substring(0, 12)}.." : mapel,
            sub: "Mata pelajaran utama",
            icon: Icons.menu_book_rounded,
            color: const Color(0xFF7C3AED),
            cardColor: cardColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ];

        if (isWide) {
          return Row(
            children: items.map((card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: card,
              ),
            )).toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: items,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. MENU GRID ---
  Widget _buildMenuGrid(BuildContext context, String uid, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        final cards = [
          _menuActionCard(
            context: context,
            title: "Input & Kelola Nilai",
            desc: "Pilih kelas & masukkan nilai harian, UTS, serta UAS",
            icon: Icons.edit_note_rounded,
            color: AppColors.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PilihKelasInputNilaiScreen()),
            ),
            isDark: isDark,
          ),
          _menuActionCard(
            context: context,
            title: "Jadwal Mengajar Lengkap",
            desc: "Lihat susunan jadwal mengajar kelas mingguan",
            icon: Icons.calendar_month_outlined,
            color: AppColors.primaryLight,
            onTap: () => _showFullJadwal(context, uid, isDark),
            isDark: isDark,
          ),
          _menuActionCard(
            context: context,
            title: "Papan Pengumuman",
            desc: "Informasi dan surat edaran resmi dari pihak sekolah",
            icon: Icons.campaign_outlined,
            color: const Color(0xFF7C3AED),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PengumumanScreen()),
            ),
            isDark: isDark,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards.map((c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: c,
              ),
            )).toList(),
          );
        }

        return Column(
          children: cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: c,
          )).toList(),
        );
      },
    );
  }

  Widget _menuActionCard({
    required BuildContext context,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: subtextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subtextColor),
          ],
        ),
      ),
    );
  }

  // --- 5. SCHEDULE COLUMN (LEFT) ---
  Widget _buildScheduleColumn(
    BuildContext context,
    String uid,
    String today,
    List<Map<String, dynamic>> todayJadwal,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Jadwal Mengajar Hari Ini",
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
              onPressed: () => _showFullJadwal(context, uid, isDark),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Semua Jadwal",
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

        if (todayJadwal.isEmpty)
          Container(
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
                  "Tidak ada jadwal mengajar hari ini ($today)",
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gunakan waktu luang untuk evaluasi nilai atau menyusun modul ajar.",
                  style: GoogleFonts.plusJakartaSans(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayJadwal.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final j = todayJadwal[i];
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
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Kelas ${j['kelas']} ${j['jurusan']}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (j['ruangan'] != null && j['ruangan'].toString().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Ruang ${j['ruangan']}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PilihKelasInputNilaiScreen()),
                        );
                      },
                      child: Text(
                        "Beri Nilai",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // --- 6. RIGHT WIDGET PANEL ---
  Widget _buildRightWidgetPanel(
    BuildContext context,
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
          "Pusat Panduan Akademik",
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
                    child: const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Standar Penilaian Kurikulum",
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
                "Nilai akhir rapor dihitung otomatis dari rata-rata Tugas Harian (30%), UTS (30%), dan UAS (40%). Pastikan semua komponen terisi sebelum batas penutupan semester.",
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
                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    "KKM Standar Kelulusan: 75.0",
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
                  const Icon(Icons.sync_rounded, size: 16, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Text(
                    "Sinkronisasi Rapor: Real-time Cloud",
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PilihKelasInputNilaiScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: Text(
                    "Buka Form Input Nilai",
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

  // --- FULL JADWAL MODAL / DIALOG ---
  void _showFullJadwal(BuildContext context, String uid, bool isDark) {
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Jadwal Mengajar Lengkap (Senin - Sabtu)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Provider.of<FirestoreService>(context, listen: false).streamJadwalGuru(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "Belum ada jadwal mengajar terdaftar di sistem.",
                            style: GoogleFonts.plusJakartaSans(color: subtextColor),
                          ),
                        );
                      }

                      final jadwal = snapshot.data!;
                      final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: hariList.length,
                        itemBuilder: (context, index) {
                          final hari = hariList[index];
                          final jadwalHari = jadwal.where((j) => j['hari'] == hari).toList()
                            ..sort((a, b) => (a['jamMulai'] as String).compareTo(b['jamMulai']));

                          if (jadwalHari.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      hari,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...jadwalHari.map((j) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${j['jamMulai']} - ${j['jamSelesai']}",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            j['mataPelajaran'] ?? '',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: textColor,
                                            ),
                                          ),
                                          Text(
                                            "Kelas ${j['kelas']} ${j['jurusan']}${j['ruangan'] != null ? ' • R. ${j['ruangan']}' : ''}",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
