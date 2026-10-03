// lib/models/nilai.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Nilai {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String guruId;
  final String guruNama;
  final String mataPelajaran;
  final double tugas;
  final double uts;
  final double uas;
  final double akhir;
  final String predikat;
  final String tanggal; // UBAH JADI STRING!

  Nilai({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.guruId,
    required this.guruNama,
    required this.mataPelajaran,
    required this.tugas,
    required this.uts,
    required this.uas,
    required this.akhir,
    required this.predikat,
    required this.tanggal,
  });

  factory Nilai.fromJson(Map<String, dynamic> json, String id) {
    final nilaiAkhir = (json['nilai'] as num?)?.toDouble() ?? 0.0;

    // TANGANI TANGGAL: BISA STRING ATAU TIMESTAMP (biar aman kalau ada data campur)
    String tanggalStr = '-';
    final rawTanggal = json['tanggal'];
    if (rawTanggal is String) {
      tanggalStr = rawTanggal;
    } else if (rawTanggal is Timestamp) {
      tanggalStr = rawTanggal.toDate().toString().split(' ').first; // 2025-11-27
    }

    return Nilai(
      id: id,
      siswaId: json['siswaId'] as String? ?? '',
      siswaNama: json['siswaNama'] as String? ?? '',
      guruId: json['guruId'] as String? ?? '',
      guruNama: json['guruNama'] as String? ?? '',
      mataPelajaran: json['mataPelajaran'] as String? ?? 'Tidak diketahui',
      tugas: (json['tugas'] as num?)?.toDouble() ?? 0,
      uts: (json['uts'] as num?)?.toDouble() ?? 0,
      uas: (json['uas'] as num?)?.toDouble() ?? 0,
      akhir: nilaiAkhir,
      predikat: _hitungPredikat(nilaiAkhir),
      tanggal: tanggalStr,
    );
  }

  static String _hitungPredikat(double nilai) {
    if (nilai >= 90) return 'A';
    if (nilai >= 80) return 'B';
    if (nilai >= 70) return 'C';
    if (nilai >= 60) return 'D';
    return 'E';
  }
}