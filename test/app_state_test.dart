import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pam/models/grade.dart';
import 'package:uts_pam/services/app_state.dart';

void main() {
  test('IP dihitung dari bobot nilai dan jumlah SKS', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppState appState = AppState();
    await appState.init();

    await appState.saveGrade(
      const Grade(
        courseCode: 'IF-401',
        courseName: 'Pemrograman Aplikasi Mobile',
        sks: 3,
        score: 85, // A = 4
      ),
    );
    await appState.saveGrade(
      const Grade(
        courseCode: 'IF-302',
        courseName: 'Basis Data',
        sks: 2,
        score: 75, // B = 3
      ),
    );

    // (4 x 3 + 3 x 2) / 5 = 3.6
    expect(appState.gpa, closeTo(3.6, 0.001));
    expect(appState.gradedSks, 5);
    expect(appState.totalGradeCount, 2);
  });
}
