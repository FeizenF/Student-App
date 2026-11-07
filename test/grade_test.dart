import 'package:flutter_test/flutter_test.dart';
import 'package:uts_pam/models/grade.dart';

void main() {
  group('nilai huruf', () {
    test('mengikuti rentang nilai yang ditentukan', () {
      expect(_grade(100).letter, 'A');
      expect(_grade(80).letter, 'A');
      expect(_grade(79).letter, 'B');
      expect(_grade(70).letter, 'B');
      expect(_grade(69).letter, 'C');
      expect(_grade(60).letter, 'C');
      expect(_grade(59).letter, 'D');
      expect(_grade(50).letter, 'D');
      expect(_grade(49).letter, 'E');
      expect(_grade(0).letter, 'E');
    });

    test('memiliki bobot yang benar', () {
      expect(_grade(85).weight, 4);
      expect(_grade(75).weight, 3);
      expect(_grade(65).weight, 2);
      expect(_grade(55).weight, 1);
      expect(_grade(45).weight, 0);
    });
  });
}

Grade _grade(double score) {
  return Grade(
    courseCode: 'IF-401',
    courseName: 'Pemrograman Aplikasi Mobile',
    sks: 3,
    score: score,
  );
}
