import 'package:flutter/material.dart';

import '../models/grade.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_card.dart';
import '../widgets/section_header.dart';
import 'input_grade_screen.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final List<Grade> grades = appState.grades;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Nilai'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Input nilai',
            onPressed: () => _openInput(context),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: grades.isEmpty
          ? EmptyState(
              icon: Icons.assessment_outlined,
              title: 'Belum ada nilai',
              message:
                  'Tambahkan nilai mata kuliah untuk melihat daftar nilai dan IP sementara.',
              action: SizedBox(
                width: 200,
                child: PrimaryButton(
                  label: 'Input Nilai',
                  icon: Icons.add_rounded,
                  onPressed: () => _openInput(context),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: <Widget>[
                _GpaCard(appState: appState),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Nilai Mata Kuliah',
                  trailing: Text(
                    '${grades.length} nilai',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                ...grades.map((Grade grade) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GradeCard(
                      grade: grade,
                      onEdit: () => _editGrade(context, appState, grade),
                      onDelete: () => _deleteGrade(context, appState, grade),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  void _openInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const InputGradeScreen()),
    );
  }

  Future<void> _editGrade(
    BuildContext context,
    AppState appState,
    Grade grade,
  ) async {
    final double? score = await showDialog<double>(
      context: context,
      builder: (_) => _EditGradeDialog(grade: grade),
    );

    if (score == null) return;
    await appState.saveGrade(grade.copyWith(score: score));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nilai ${grade.courseName} berhasil diperbarui.')),
    );
  }

  Future<void> _deleteGrade(
    BuildContext context,
    AppState appState,
    Grade grade,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Nilai?'),
          content: Text(
            'Nilai ${grade.courseName} akan dihapus. '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await appState.deleteGrade(grade.courseCode);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nilai ${grade.courseName} telah dihapus.')),
    );
  }
}

class _GpaCard extends StatelessWidget {
  const _GpaCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.navy, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'IP Sementara',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  formatGpa(appState.gpa),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appState.totalGradeCount} mata kuliah • '
                  '${appState.gradedSks} SKS dinilai',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditGradeDialog extends StatefulWidget {
  const _EditGradeDialog({required this.grade});

  final Grade grade;

  @override
  State<_EditGradeDialog> createState() => _EditGradeDialogState();
}

class _EditGradeDialogState extends State<_EditGradeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: formatScore(widget.grade.score),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final double? score = parseScore(_scoreController.text);
    if (score == null) return;
    Navigator.of(context).pop(score);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Nilai'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.grade.courseName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _scoreController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nilai Angka',
                prefixIcon: Icon(Icons.numbers_rounded),
                suffixText: '/ 100',
              ),
              validator: validateScore,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
