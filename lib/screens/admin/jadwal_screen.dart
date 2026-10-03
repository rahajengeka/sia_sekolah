// lib/screens/admin/jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final FirestoreService _fs = FirestoreService();

  // Filter States
  String? filterHari;
  String? filterKelas;
  String? filterJurusan;

  // Form States (Temporary)
  String? selectedGuruId;
  String? selectedGuruNama;
  String? selectedMapel;

  final List<String> hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  final List<String> kelasList = ['10', '11', '12'];
  final List<String> jurusanList = ['IPA', 'IPS'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Kelola Jadwal Pelajaran",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: "Muat Ulang",
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
        label: Text(
          "Buat Jadwal",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        onPressed: () => _showForm(context),
      ),
      body: Column(
        children: [
          // 1. FILTER SECTION
          _buildFilterSection(isDark),

          // 2. TIMELINE LIST
          Expanded(child: _buildJadwalList(isDark)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Hari (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hariList.map((hari) {
                final isSelected = filterHari == hari;
                final primary = AppColors.primaryLight;
                final border = isSelected ? primary : (isDark ? AppColors.borderDark : AppColors.borderLight);
                final bg = isSelected ? primary.withOpacity(0.08) : cardColor;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => filterHari = isSelected ? null : hari),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border, width: isSelected ? 1.5 : 1),
                      ),
                      child: Text(
                        hari,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? primary : subtextColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Kelas & Jurusan
          Row(
            children: [
              _buildDropdownFilter("Semua Kelas", kelasList, filterKelas, (val) => setState(() => filterKelas = val), isDark),
              const SizedBox(width: 10),
              _buildDropdownFilter("Semua Jurusan", jurusanList, filterJurusan, (val) => setState(() => filterJurusan = val), isDark),
              if (filterKelas != null || filterJurusan != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                  tooltip: "Reset Filter",
                  onPressed: () => setState(() {
                    filterKelas = null;
                    filterJurusan = null;
                  }),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String hint, List<String> items, String? value, Function(String?) onChanged, bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor)),
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: subtextColor),
            dropdownColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textColor)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildJadwalList(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return StreamBuilder<QuerySnapshot>(
      stream: _fs.streamJadwal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        var docs = snapshot.data?.docs ?? [];

        if (filterHari != null) docs = docs.where((d) => d['hari'] == filterHari).toList();
        if (filterKelas != null) docs = docs.where((d) => d['kelas'] == filterKelas).toList();
        if (filterJurusan != null) docs = docs.where((d) => d['jurusan'] == filterJurusan).toList();

        docs.sort((a, b) {
          final dayA = hariList.indexOf(a['hari']);
          final dayB = hariList.indexOf(b['hari']);
          if (dayA != dayB) return dayA.compareTo(dayB);
          return (a['jamMulai'] as String).compareTo(b['jamMulai']);
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_outlined, size: 52, color: subtextColor.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada jadwal ditemukan.",
                  style: GoogleFonts.plusJakartaSans(color: subtextColor, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = docs[i];
            final String mapel = d['mataPelajaran'] ?? '-';
            final String jam = "${d['jamMulai']} - ${d['jamSelesai']}";
            final String kelasInfo = "Kelas ${d['kelas']} ${d['jurusan']}";
            final String hari = d['hari'] ?? '-';
            final String guruNama = d['guruNama'] ?? '-';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hari,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 13, color: subtextColor),
                              const SizedBox(width: 4),
                              Text(
                                jam,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, size: 18, color: subtextColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (v) {
                          if (v == 'edit') _showForm(context, id: d.id, data: d);
                          if (v == 'delete') _deleteJadwal(d.id);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18, color: AppColors.info),
                                const SizedBox(width: 8),
                                Text("Edit Jadwal", style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Text("Hapus", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mapel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kelasInfo,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.person_outline_rounded, size: 14, color: subtextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          guruNama,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (d['ruangan']?.toString().isNotEmpty == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "R. ${d['ruangan']}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showForm(BuildContext context, {String? id, QueryDocumentSnapshot? data}) {
    final isEdit = id != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? hari = data?['hari'];
    String? kelas = data?['kelas'];
    String? jurusan = data?['jurusan'];
    final jamMulaiC = TextEditingController(text: data?['jamMulai'] ?? '07:00');
    final jamSelesaiC = TextEditingController(text: data?['jamSelesai'] ?? '08:30');
    final ruanganC = TextEditingController(text: data?['ruangan'] ?? '');

    selectedGuruId = data?['guruId'];
    selectedGuruNama = data?['guruNama'];
    selectedMapel = data?['mataPelajaran'];

    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? "Edit Jadwal Pelajaran" : "Buat Jadwal Pelajaran",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: hari,
                    decoration: const InputDecoration(labelText: "Hari"),
                    items: hariList.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                    onChanged: (v) => setStateDialog(() => hari = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTimePicker(context, "Mulai", jamMulaiC)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTimePicker(context, "Selesai", jamSelesaiC)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: kelas,
                          decoration: const InputDecoration(labelText: "Kelas"),
                          items: kelasList.map((k) => DropdownMenuItem(value: k, child: Text("Kls $k"))).toList(),
                          onChanged: (v) => setStateDialog(() => kelas = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: jurusan,
                          decoration: const InputDecoration(labelText: "Jurusan"),
                          items: jurusanList.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                          onChanged: (v) => setStateDialog(() => jurusan = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Guru Dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: _fs.streamGuru(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final guruDocs = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedGuruId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Guru Pengajar"),
                        items: guruDocs.map((doc) {
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(
                              "${doc['nama']} (${doc['mapel'] ?? '-'})",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final guru = guruDocs.firstWhere((d) => d.id == val);
                          setStateDialog(() {
                            selectedGuruId = val;
                            selectedGuruNama = guru['nama'];
                            selectedMapel = guru['mapel'] ?? 'Belum diisi';
                          });
                        },
                      );
                    },
                  ),

                  if (selectedMapel != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.book_outlined, color: AppColors.primaryLight, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Mapel: $selectedMapel",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: ruanganC,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: "Ruangan (Opsional)",
                      prefixIcon: Icon(Icons.meeting_room_outlined, size: 19),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: subtextColor, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(120, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                if (hari == null || kelas == null || selectedGuruId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mohon lengkapi semua kolom jadwal!")),
                  );
                  return;
                }

                final dataBaru = {
                  'hari': hari,
                  'jamMulai': jamMulaiC.text,
                  'jamSelesai': jamSelesaiC.text,
                  'kelas': kelas,
                  'jurusan': jurusan,
                  'mataPelajaran': selectedMapel,
                  'guruId': selectedGuruId,
                  'guruNama': selectedGuruNama,
                  'ruangan': ruanganC.text.trim(),
                };

                try {
                  if (isEdit) {
                    await _fs.updateJadwal(id, dataBaru);
                  } else {
                    await _fs.addJadwal(dataBaru);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? "Jadwal berhasil diperbarui." : "Jadwal berhasil ditambahkan."),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: Text(
                isEdit ? "Simpan Perubahan" : "Buat Jadwal",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.access_time, size: 16),
      ),
      onTap: () async {
        TimeOfDay? t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.tryParse(controller.text.split(":")[0]) ?? 7,
            minute: int.tryParse(controller.text.split(":")[1]) ?? 0,
          ),
        );
        if (t != null) {
          final hour = t.hour.toString().padLeft(2, '0');
          final min = t.minute.toString().padLeft(2, '0');
          controller.text = "$hour:$min";
        }
      },
    );
  }

  void _deleteJadwal(String id) async {
    try {
      await _fs.deleteJadwal(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jadwal telah dihapus.", style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }
}