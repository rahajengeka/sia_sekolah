// lib/models/siswa.dart

class Siswa {
  final String id;
  final String nis;
  final String nama;
  final String kelas;
  final String jurusan;
  final String email; // TAMBAH INI!

  Siswa({
    required this.id,
    required this.nis,
    required this.nama,
    required this.kelas,
    required this.jurusan,
    required this.email,
  });

  // GANTI fromMap → fromJson
  factory Siswa.fromJson(Map<String, dynamic> json, String id) {
    return Siswa(
      id: id,
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
      kelas: json['kelas'] ?? '',
      jurusan: json['jurusan'] ?? '',
      email: json['email'] ?? '', // WAJIB ADA!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'jurusan': jurusan,
      'email': email,
    };
  }
}