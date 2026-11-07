const List<String> _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Format tanggal sederhana tanpa package tambahan, misalnya "12 Mei 2004".
String formatDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

/// Menampilkan nilai angka tanpa desimal yang tidak perlu.
String formatScore(double score) {
  if (score == score.roundToDouble()) return score.toStringAsFixed(0);
  return score.toStringAsFixed(1);
}

/// IP selalu ditampilkan dengan dua angka di belakang koma.
String formatGpa(double gpa) => gpa.toStringAsFixed(2);
