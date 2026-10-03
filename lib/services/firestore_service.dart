// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/siswa.dart';
import '../models/nilai.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== SISWA ====================
  Stream<List<Siswa>> streamSiswa() {
    return _db
        .collection('siswa')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Siswa.fromJson(d.data(), d.id)).toList(),
        );
  }

  Future<void> addSiswa(Map<String, dynamic> data) =>
      _db.collection('siswa').add(data);

  Future<void> updateSiswa(String id, Map<String, dynamic> data) =>
      _db.collection('siswa').doc(id).update(data);

  Future<void> deleteSiswa(String id) =>
      _db.collection('siswa').doc(id).delete();

  // ==================== GURU ====================
  Stream<QuerySnapshot> streamGuru() => _db.collection('guru').snapshots();

  Future<void> addGuru(Map<String, dynamic> data) =>
      _db.collection('guru').add(data);

  Future<void> updateGuru(String id, Map<String, dynamic> data) =>
      _db.collection('guru').doc(id).update(data);

  Future<void> deleteGuru(String id) => _db.collection('guru').doc(id).delete();

  // ==================== JADWAL PELAJARAN ====================
  Stream<QuerySnapshot> streamJadwal() =>
      _db.collection('jadwal_pelajaran').snapshots();

  Future<void> addJadwal(Map<String, dynamic> data) =>
      _db.collection('jadwal_pelajaran').add(data);

  Future<void> updateJadwal(String id, Map<String, dynamic> data) =>
      _db.collection('jadwal_pelajaran').doc(id).update(data);

  Future<void> deleteJadwal(String id) =>
      _db.collection('jadwal_pelajaran').doc(id).delete();

  // ==================== PENGUMUMAN ====================
  Stream<QuerySnapshot> streamPengumuman() {
    // Avoid combining where + orderBy here to prevent requiring a composite
    // index. Return raw snapshots and let the UI do filtering/sorting client-side.
    return _db.collection('pengumuman').snapshots();
  }

  Future<void> addPengumuman(String judul, String isi) async {
    await _db.collection('pengumuman').add({
      'judul': judul,
      'isi': isi,
      'tanggal': FieldValue.serverTimestamp(),
      'isPublished': true,
    });
  }

  Future<void> deletePengumuman(String id) =>
      _db.collection('pengumuman').doc(id).delete();

  // ==================== NILAI ====================
  Stream<List<Nilai>> streamNilaiBySiswa(String siswaId) {
    return _db
        .collection('nilai')
        .where('siswaId', isEqualTo: siswaId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Nilai.fromJson(d.data(), d.id)).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamJadwalGuru(String guruId) {
    return _db
        .collection('jadwal_pelajaran')
        .where('guruId', isEqualTo: guruId)
        .orderBy('hari')
        .orderBy('jamMulai')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // TAMBAH INI (SOLUSI ERROR)
  Stream<List<Siswa>> streamSiswaByKelas(String kelas, String jurusan) {
    return _db
        .collection('siswa')
        .where('kelas', isEqualTo: kelas)
        .where('jurusan', isEqualTo: jurusan)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Siswa.fromJson(d.data(), d.id)).toList(),
        );
  }

  Future<void> addNilai(Map<String, dynamic> data) =>
      _db.collection('nilai').add(data);

  Future<void> updateNilai(String id, Map<String, dynamic> data) =>
      _db.collection('nilai').doc(id).update(data);

  Future<void> deleteNilai(String id) =>
      _db.collection('nilai').doc(id).delete();
}
