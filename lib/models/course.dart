class Course {
  final String code;
  final String name;
  final int sks;

  const Course({
    required this.code,
    required this.name,
    required this.sks,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'sks': sks,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sks: (json['sks'] as num?)?.toInt() ?? 0,
    );
  }
}
