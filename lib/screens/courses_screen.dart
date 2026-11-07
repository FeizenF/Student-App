import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/grade.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final List<Course> courses = appState.courses;

    return Scaffold(
      appBar: AppBar(title: const Text('Mata Kuliah')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourse(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: courses.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Belum ada mata kuliah',
              message:
                  'Tambahkan mata kuliah terlebih dahulu untuk mulai menginput nilai.',
              action: SizedBox(
                width: 200,
                child: PrimaryButton(
                  label: 'Tambah Mata Kuliah',
                  icon: Icons.add_rounded,
                  onPressed: () => _showAddCourse(context),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              itemCount: courses.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CourseSummary(
                      courseCount: courses.length,
                      totalSks: appState.totalCourseSks,
                    ),
                  );
                }

                final Course course = courses[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CourseTile(
                    course: course,
                    grade: appState.gradeFor(course.code),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showAddCourse(BuildContext context) async {
    final AppState appState = AppStateScope.of(context);
    final Set<String> existingCodes = appState.courses
        .map((Course course) => course.code.toUpperCase())
        .toSet();

    final Course? course = await showDialog<Course>(
      context: context,
      builder: (_) => _AddCourseDialog(existingCodes: existingCodes),
    );

    if (course == null) return;
    await appState.addCourse(course);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mata kuliah ${course.name} berhasil ditambahkan.')),
    );
  }
}

class _CourseSummary extends StatelessWidget {
  const _CourseSummary({required this.courseCount, required this.totalSks});

  final int courseCount;
  final int totalSks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: SectionHeader(title: 'Daftar Mata Kuliah')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$courseCount MK • $totalSks SKS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
          ),
        ),
      ],
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, this.grade});

  final Course course;
  final Grade? grade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  'Kode: ${course.code}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${course.sks} SKS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                ),
              ),
              if (grade != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Nilai ${grade!.letter}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddCourseDialog extends StatefulWidget {
  const _AddCourseDialog({required this.existingCodes});

  final Set<String> existingCodes;

  @override
  State<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<_AddCourseDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  int _sks = 3;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final Course course = Course(
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      sks: _sks,
    );
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Tambah Mata Kuliah'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: <Widget>[
            TextFormField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kode Mata Kuliah',
                hintText: 'Contoh: IF-406',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kode mata kuliah wajib diisi.';
                }
                final String code = value.trim().toUpperCase();
                if (widget.existingCodes.contains(code)) {
                  return 'Kode mata kuliah sudah digunakan.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Mata Kuliah',
                hintText: 'Contoh: Kecerdasan Buatan',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama mata kuliah wajib diisi.';
                }
                return null;
              },
            ),
            DropdownButtonFormField<int>(
              initialValue: _sks,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Jumlah SKS',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
              items: List<DropdownMenuItem<int>>.generate(
                6,
                (int index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('${index + 1} SKS'),
                ),
              ),
              onChanged: (int? value) {
                if (value != null) setState(() => _sks = value);
              },
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
