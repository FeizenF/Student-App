import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'biodata_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final Student student = appState.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: <Widget>[
          _ProfileHeader(student: student),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Informasi Mahasiswa'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: <Widget>[
                InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Program Studi',
                  value: _text(student.studyProgram),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Fakultas',
                  value: _text(student.faculty),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: _text(student.email),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Nomor HP',
                  value: _text(student.phone),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.location_city_outlined,
                  label: 'Tempat Lahir',
                  value: _text(student.birthPlace),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Tanggal Lahir',
                  value: student.birthDate == null
                      ? '-'
                      : formatDate(student.birthDate),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.wc_rounded,
                  label: 'Jenis Kelamin',
                  value: _text(student.gender),
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.home_outlined,
                  label: 'Alamat',
                  value: _text(student.address),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Edit Biodata',
            icon: Icons.edit_outlined,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BiodataScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, appState),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.30),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'StudentApp v1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _text(String value) => value.trim().isEmpty ? '-' : value.trim();

  Future<void> _confirmLogout(BuildContext context, AppState appState) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    appState.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final String name =
        student.name.trim().isEmpty ? 'Nama belum diisi' : student.name.trim();
    final String npm =
        student.npm.trim().isEmpty ? 'NPM belum diisi' : 'NPM ${student.npm}';
    final String program = student.studyProgram.trim().isEmpty
        ? 'Program studi belum diisi'
        : student.studyProgram.trim();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            child: Text(
              student.initials,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(npm, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              program,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
