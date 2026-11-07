import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import '../models/grade.dart';
import '../models/student.dart';

/// Menyimpan seluruh data aplikasi dan menyimpannya ke SharedPreferences.
/// Dibuat sesederhana mungkin: satu ChangeNotifier untuk semua data.
class AppState extends ChangeNotifier {
  static const String _studentKey = 'student_data';
  static const String _coursesKey = 'courses_data';
  static const String _gradesKey = 'grades_data';

  Student _student = const Student();
  List<Course> _courses = <Course>[];
  List<Grade> _grades = <Grade>[];
  bool _isLoggedIn = false;

  Student get student => _student;
  List<Course> get courses => List<Course>.unmodifiable(_courses);
  List<Grade> get grades => List<Grade>.unmodifiable(_grades);
  bool get isLoggedIn => _isLoggedIn;

  int get totalCourseCount => _courses.length;

  int get totalCourseSks =>
      _courses.fold(0, (total, course) => total + course.sks);

  int get totalGradeCount => _grades.length;

  int get gradedSks =>
      _grades.fold(0, (total, grade) => total + grade.sks);

  double get weightedPoints => _grades.fold(
        0.0,
        (total, grade) => total + (grade.weight * grade.sks),
      );

  /// IP = total (bobot x SKS) / total SKS yang sudah dinilai.
  double get gpa => gradedSks == 0 ? 0 : weightedPoints / gradedSks;

  String get gpaText => _grades.isEmpty ? '—' : gpa.toStringAsFixed(2);

  /// Memuat data dari penyimpanan lokal saat aplikasi dibuka.
  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _student = _readStudent(prefs);
    _grades = _readGrades(prefs);

    if (prefs.containsKey(_coursesKey)) {
      _courses = _readCourses(prefs);
    } else {
      _courses = _defaultCourses();
      await _write(_coursesKey, _courses.map((course) => course.toJson()).toList());
    }

    notifyListeners();
  }

  Future<void> saveStudent(Student student) async {
    _student = student;
    notifyListeners();
    await _write(_studentKey, student.toJson());
  }

  Future<void> addCourse(Course course) async {
    _courses = <Course>[..._courses, course];
    notifyListeners();
    await _write(
      _coursesKey,
      _courses.map((item) => item.toJson()).toList(),
    );
  }

  /// Menyimpan nilai baru, atau memperbarui nilai jika mata kuliahnya sama.
  Future<void> saveGrade(Grade grade) async {
    final int index = _grades.indexWhere(
      (item) => item.courseCode == grade.courseCode,
    );

    if (index == -1) {
      _grades = <Grade>[..._grades, grade];
    } else {
      final List<Grade> updated = <Grade>[..._grades];
      updated[index] = grade;
      _grades = updated;
    }

    notifyListeners();
    await _write(_gradesKey, _grades.map((item) => item.toJson()).toList());
  }

  Future<void> deleteGrade(String courseCode) async {
    _grades = _grades
        .where((grade) => grade.courseCode != courseCode)
        .toList();
    notifyListeners();
    await _write(_gradesKey, _grades.map((item) => item.toJson()).toList());
  }

  Grade? gradeFor(String courseCode) {
    for (final Grade grade in _grades) {
      if (grade.courseCode == courseCode) return grade;
    }
    return null;
  }

  void markLoggedIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  Student _readStudent(SharedPreferences prefs) {
    final String? raw = prefs.getString(_studentKey);
    if (raw == null) return _defaultStudent();

    try {
      return Student.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return _defaultStudent();
    }
  }

  List<Course> _readCourses(SharedPreferences prefs) {
    final String? raw = prefs.getString(_coursesKey);
    if (raw == null) return <Course>[];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Course>[];
    }
  }

  List<Grade> _readGrades(SharedPreferences prefs) {
    final String? raw = prefs.getString(_gradesKey);
    if (raw == null) return <Grade>[];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Grade.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Grade>[];
    }
  }

  Future<void> _write(String key, Object value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  /// Data awal mata kuliah agar aplikasi tidak kosong saat pertama dibuka.
  List<Course> _defaultCourses() {
    return const <Course>[
      Course(code: 'IF-401', name: 'Pemrograman Aplikasi Mobile', sks: 3),
      Course(code: 'IF-302', name: 'Basis Data', sks: 3),
      Course(code: 'IF-303', name: 'Pemrograman Web', sks: 3),
      Course(code: 'IF-304', name: 'Rekayasa Perangkat Lunak', sks: 3),
      Course(code: 'IF-305', name: 'Desain Front End', sks: 2),
    ];
  }

  /// Biodata contoh. Bisa diubah kapan saja lewat form biodata.
  Student _defaultStudent() {
    return Student(
      name: 'Budi Santoso',
      npm: '2210512034',
      birthPlace: 'Jakarta',
      birthDate: DateTime(2004, 5, 12),
      gender: 'Laki-laki',
      address: 'Jl. Merdeka No. 10, Jakarta',
      studyProgram: 'Teknik Informatika',
      faculty: 'Fakultas Ilmu Komputer',
      email: 'budi.santoso@student.ac.id',
      phone: '081234567890',
    );
  }
}

/// Membuat AppState dapat diakses dari seluruh widget.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppStateScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan di widget tree.');
    return scope!.notifier!;
  }
}
