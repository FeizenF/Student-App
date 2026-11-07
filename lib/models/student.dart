class Student {
  final String name;
  final String npm;
  final String birthPlace;
  final DateTime? birthDate;
  final String gender;
  final String address;
  final String studyProgram;
  final String faculty;
  final String email;
  final String phone;

  const Student({
    this.name = '',
    this.npm = '',
    this.birthPlace = '',
    this.birthDate,
    this.gender = '',
    this.address = '',
    this.studyProgram = '',
    this.faculty = '',
    this.email = '',
    this.phone = '',
  });

  bool get isFilled => name.trim().isNotEmpty && npm.trim().isNotEmpty;

  /// Inisial nama untuk ditampilkan di avatar.
  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'npm': npm,
      'birthPlace': birthPlace,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'address': address,
      'studyProgram': studyProgram,
      'faculty': faculty,
      'email': email,
      'phone': phone,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    final String? rawBirthDate = json['birthDate'] as String?;

    return Student(
      name: json['name'] as String? ?? '',
      npm: json['npm'] as String? ?? '',
      birthPlace: json['birthPlace'] as String? ?? '',
      birthDate: rawBirthDate == null ? null : DateTime.tryParse(rawBirthDate),
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      studyProgram: json['studyProgram'] as String? ?? '',
      faculty: json['faculty'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}
