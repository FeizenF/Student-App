import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'biodata_screen.dart';
import 'input_grade_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);

    final List<_QuickMenuItem> menuItems = <_QuickMenuItem>[
      _QuickMenuItem(
        icon: Icons.person_outline_rounded,
        title: 'Biodata',
        subtitle: 'Data mahasiswa',
        onTap: () => _openScreen(context, const BiodataScreen()),
      ),
      _QuickMenuItem(
        icon: Icons.menu_book_outlined,
        title: 'Mata Kuliah',
        subtitle: '${appState.totalCourseCount} mata kuliah',
        onTap: () => onNavigateTab(1),
      ),
      _QuickMenuItem(
        icon: Icons.edit_note_rounded,
        title: 'Input Nilai',
        subtitle: 'Tambah nilai',
        onTap: () => _openScreen(context, const InputGradeScreen()),
      ),
      _QuickMenuItem(
        icon: Icons.assessment_outlined,
        title: 'Daftar Nilai',
        subtitle: '${appState.totalGradeCount} nilai',
        onTap: () => onNavigateTab(2),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Buka profil',
            onPressed: () => onNavigateTab(3),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: <Widget>[
          _WelcomeCard(student: appState.student),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: StatCard(
                    label: 'Mata Kuliah',
                    value: '${appState.totalCourseCount}',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Nilai',
                    value: '${appState.totalGradeCount}',
                    icon: Icons.assessment_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'IP Sementara',
                    value: appState.gpaText,
                    icon: Icons.insights_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Menu Cepat'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 112,
            ),
            itemBuilder: (BuildContext context, int index) {
              final _QuickMenuItem item = menuItems[index];
              return _QuickMenuTile(item: item);
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Ringkasan Akademik'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: <Widget>[
                InfoRow(
                  icon: Icons.menu_book_outlined,
                  label: 'Total SKS mata kuliah',
                  value: '${appState.totalCourseSks} SKS',
                ),
                const Divider(height: 24),
                InfoRow(
                  icon: Icons.checklist_rounded,
                  label: 'SKS sudah dinilai',
                  value: '${appState.gradedSks} SKS',
                ),
                const Divider(height: 24),
                InfoRow(
                  icon: Icons.insights_outlined,
                  label: 'IP sementara',
                  value: appState.grades.isEmpty
                      ? 'Belum ada nilai'
                      : formatGpa(appState.gpa),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final String name =
        student.name.trim().isEmpty ? 'Mahasiswa' : student.name.trim();
    final String npm =
        student.npm.trim().isEmpty ? 'NPM belum diisi' : student.npm.trim();
    final String program = student.studyProgram.trim().isEmpty
        ? 'Program studi belum diisi'
        : student.studyProgram.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.navy, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Selamat datang,',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$npm  •  $program',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              student.initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMenuItem {
  const _QuickMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _QuickMenuTile extends StatelessWidget {
  const _QuickMenuTile({required this.item});

  final _QuickMenuItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 19, color: AppColors.primary),
          ),
          const Spacer(),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
