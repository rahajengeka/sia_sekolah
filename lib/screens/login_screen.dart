// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin/admin_dashboard.dart';
import 'guru/guru_dashboard.dart';
import 'siswa/siswa_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _isObscure = true;
  String _selectedRole = '';

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _fillAccount(String role, String email, String password) {
    setState(() {
      _selectedRole = role;
      _email.text = email;
      _pass.text = password;
    });
  }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      _showSnack("Email dan kata sandi wajib diisi.", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _authService.login(_email.text.trim(), _pass.text);
      if (user == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        _showSnack("Login gagal. Pastikan email dan password sudah benar.", isError: true);
        return;
      }

      final role = await _authService.getRole(user.uid);
      if (!mounted) return;
      setState(() => _loading = false);

      if (role == null) {
        _showSnack("Role akun ini belum terdaftar di sistem.", isError: true);
        return;
      }

      Widget dashboard = role == 'admin'
          ? const AdminDashboard()
          : role == 'guru'
              ? const GuruDashboard()
              : const SiswaDashboard();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showSnack("Terjadi kesalahan: $e", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          if (isWide) {
            return Row(
              children: [
                // LEFT SIDE: Institutional Branding Showcase
                Expanded(
                  flex: 5,
                  child: _buildBrandingPanel(isDark),
                ),

                // RIGHT SIDE: Responsive Login Console
                Expanded(
                  flex: 6,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _buildLoginForm(isDark, isWide: true),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // MOBILE & TABLET PORTRAIT: Single Column Clean Centered Card
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    _buildMobileHeader(isDark),
                    const SizedBox(height: 24),
                    _buildLoginForm(isDark, isWide: false),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- BRANDING PANEL (FOR DESKTOP / WIDE SCREEN) ---
  Widget _buildBrandingPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFF172554), const Color(0xFF1E3A8A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Crest & School Name
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SMA BRAWIJAYA",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Sistem Informasi Akademik Terpadu",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center: Value Proposition & Feature Highlights
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Text(
                        "Portal Resmi Terverifikasi",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Platform Akademik\nDigital Unggul & Terintegrasi",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Mendukung pengelolaan administrasi, rekapitulasi penilaian kurikulum, jadwal pelajaran presisi, hingga penerbitan rapor digital secara efisien.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),

                // 3 Highlights
                _buildHighlightItem(
                  icon: Icons.shield_outlined,
                  title: "Akses Peran Khusus",
                  desc: "Hak akses terpisah & aman untuk Admin, Guru Pengajar, dan Siswa.",
                ),
                const SizedBox(height: 16),
                _buildHighlightItem(
                  icon: Icons.analytics_outlined,
                  title: "Statistik & Rapor Digital",
                  desc: "Pemantauan perkembangan belajar siswa dan unduh rapor PDF resmi.",
                ),
                const SizedBox(height: 16),
                _buildHighlightItem(
                  icon: Icons.cloud_sync_outlined,
                  title: "Sinkronisasi Realtime",
                  desc: "Database cloud terkoneksi langsung tanpa keterlambatan data.",
                ),
              ],
            ),
          ),

          // Bottom: Trust Badge
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(
                "T.A. 2024/2025 • Kurikulum Merdeka Terintegrasi",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white60,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- MOBILE HEADER ---
  Widget _buildMobileHeader(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.primaryDark,
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "SMA BRAWIJAYA",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Sistem Informasi Akademik Terpadu",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // --- MAIN LOGIN FORM ---
  Widget _buildLoginForm(bool isDark, {required bool isWide}) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: EdgeInsets.all(isWide ? 36 : 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Masuk ke Portal",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Silakan pilih akun demo atau masukkan kredensial Anda",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // DEMO ACCOUNT SELECTOR (QUICK ACCESS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PILIH AKUN CEPAT (DEMO)",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              if (_selectedRole.isNotEmpty)
                Text(
                  "Dipilih: ${_selectedRole.toUpperCase()}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildRoleButton(
                  label: "Admin",
                  roleKey: "admin",
                  email: "admin@gmail.com",
                  icon: Icons.shield_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleButton(
                  label: "Guru",
                  roleKey: "guru",
                  email: "guru@gmail.com",
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleButton(
                  label: "Siswa",
                  roleKey: "siswa",
                  email: "siswa@gmail.com",
                  icon: Icons.school_outlined,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // EMAIL INPUT
          Text(
            "Alamat Email",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_selectedRole.isNotEmpty) setState(() => _selectedRole = '');
            },
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textPrimary),
            decoration: InputDecoration(
              hintText: "nama@sekolah.sch.id",
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 19,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // PASSWORD INPUT
          Text(
            "Kata Sandi",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _pass,
            obscureText: _isObscure,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textPrimary),
            decoration: InputDecoration(
              hintText: "••••••••",
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 19,
                color: textSecondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 19,
                  color: textSecondary,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // SUBMIT BUTTON
          ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Masuk ke Sistem",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
          ),

          const SizedBox(height: 24),

          // CARD FOOTER
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                const SizedBox(width: 6),
                Text(
                  "SIA Terpadu • SMA Brawijaya Malang",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required String roleKey,
    required String email,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == roleKey;
    final primary = AppColors.primaryLight;
    final borderColor = isSelected
        ? primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final bgColor = isSelected
        ? primary.withOpacity(0.09)
        : (isDark ? Colors.transparent : const Color(0xFFF8FAFC));

    return InkWell(
      onTap: () => _fillAccount(roleKey, email, "123456"),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}