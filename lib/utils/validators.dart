/// Validasi nilai angka 0-100 yang dipakai pada form input dan edit nilai.
String? validateScore(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nilai wajib diisi.';
  }

  final double? parsed = parseScore(value);
  if (parsed == null) {
    return 'Masukkan angka yang valid.';
  }
  if (parsed < 0) {
    return 'Nilai tidak boleh kurang dari 0.';
  }
  if (parsed > 100) {
    return 'Nilai tidak boleh lebih dari 100.';
  }
  return null;
}

/// Mengubah teks menjadi angka. Koma juga diterima, misalnya "85,5".
double? parseScore(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

/// Sama seperti [parseScore], tetapi hanya mengembalikan nilai 0-100.
double? parseValidScore(String value) {
  final double? parsed = parseScore(value);
  if (parsed == null || parsed < 0 || parsed > 100) return null;
  return parsed;
}
