import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/course.dart';
import '../models/grade.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';
import 'courses_screen.dart';

class InputGradeScreen extends StatefulWidget {
  const InputGradeScreen({super.key});

  @override
  State<InputGradeScreen> createState() => _InputGradeScreenState();
}

class _InputGradeScreenState extends State<InputGradeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _scoreController = TextEditingController();

  Course? _selectedCourse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final List<Course> courses = AppStateScope.of(context).courses;
    if (_selectedCourse == null && courses.isNotEmpty) {
      _selectedCourse = courses.first;
      _prefillScore(_selectedCourse!);
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _prefillScore(Course course) {
    final Grade? grade = AppStateScope.of(context).gradeFor(course.code);
    _scoreController.text = grade == null ? '' : formatScore(grade.score);
  }

  double? get _parsedScore => parseValidScore(_scoreController.text);

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final Course? course = _selectedCourse;
    if (course == null) return;

    final double? score = parseScore(_scoreController.text);
    if (score == null) return;

    final Grade grade = Grade(
      courseCode: course.code,
      courseName: course.name,
      sks: course.sks,
      score: score,
    );

    final AppState appState = AppStateScope.of(context);
    await appState.saveGrade(grade);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nilai ${formatScore(score)} (${grade.letter}) untuk '
          '${course.name} berhasil disimpan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final List<Course> courses = appState.courses;
    final Course? selectedCourse = _selectedCourse;
    final Grade? existingGrade =
        selectedCourse == null ? null : appState.gradeFor(selectedCourse.code);

    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai')),
      body: courses.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Belum ada mata kuliah',
              message:
                  'Tambahkan mata kuliah terlebih dahulu sebelum menginput nilai.',
              action: SizedBox(
                width: 220,
                child: PrimaryButton(
                  label: 'Tambah Mata Kuliah',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CoursesScreen(),
                      ),
                    );
                  },
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: <Widget>[
                  _InfoBanner(),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Detail Nilai',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Course>(
                          initialValue: selectedCourse,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Mata Kuliah',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                          items: courses.map((Course course) {
                            return DropdownMenuItem<Course>(
                              value: course,
                              child: Text(
                                '${course.name} (${course.sks} SKS)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (Course? course) {
                            if (course == null) return;
                            setState(() {
                              _selectedCourse = course;
                              _prefillScore(course);
                            });
                          },
                          validator: (Course? value) => value == null
                              ? 'Mata kuliah wajib dipilih.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _scoreController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Nilai Angka',
                            hintText: 'Masukkan nilai 0 - 100',
                            prefixIcon: Icon(Icons.numbers_rounded),
                            suffixText: '/ 100',
                          ),
                          validator: validateScore,
                        ),
                        if (existingGrade != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            'Mata kuliah ini sudah memiliki nilai '
                            '${formatScore(existingGrade.score)} '
                            '(${existingGrade.letter}). Menyimpan akan '
                            'memperbarui nilai lama.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LetterPreview(score: _parsedScore),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Simpan Nilai',
                    icon: Icons.save_outlined,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nilai huruf ditentukan otomatis dan tidak dapat diisi manual.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nilai huruf dihitung otomatis dari nilai angka 0-100.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterPreview extends StatelessWidget {
  const _LetterPreview({required this.score});

  final double? score;

  String? get _letter => score == null ? null : Grade.letterForScore(score!);

  Color get _color {
    switch (_letter) {
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.accent;
      case 'C':
        return AppColors.warning;
      case 'D':
        return const Color(0xFFC2410C);
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? letter = _letter;
    final bool hasScore = score != null && letter != null;

    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (hasScore ? _color : AppColors.textSecondary)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              letter ?? '?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: hasScore ? _color : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Perkiraan Nilai Huruf',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  hasScore
                      ? 'Nilai ${formatScore(score!)} termasuk kategori '
                          '$letter dengan bobot '
                          '${Grade.weightForLetter(letter)}.'
                      : 'Masukkan nilai 0-100 untuk melihat nilai huruf.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
