class Grade {
  final String courseCode;
  final String courseName;
  final int sks;
  final double score;

  const Grade({
    required this.courseCode,
    required this.courseName,
    required this.sks,
    required this.score,
  });

  /// Nilai huruf ditentukan otomatis dari nilai angka.
  String get letter => letterForScore(score);

  /// Bobot nilai untuk perhitungan IP.
  int get weight => weightForLetter(letter);

  static String letterForScore(double score) {
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'E';
  }

  static int weightForLetter(String letter) {
    switch (letter) {
      case 'A':
        return 4;
      case 'B':
        return 3;
      case 'C':
        return 2;
      case 'D':
        return 1;
      default:
        return 0;
    }
  }

  Grade copyWith({double? score}) {
    return Grade(
      courseCode: courseCode,
      courseName: courseName,
      sks: sks,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseCode': courseCode,
      'courseName': courseName,
      'sks': sks,
      'score': score,
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      sks: (json['sks'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}
