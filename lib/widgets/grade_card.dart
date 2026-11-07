import 'package:flutter/material.dart';

import '../models/grade.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

/// Kartu nilai yang menampilkan nilai angka, nilai huruf, serta aksi edit/hapus.
class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.grade,
    required this.onEdit,
    required this.onDelete,
  });

  final Grade grade;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _letterColor {
    switch (grade.letter) {
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
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _letterColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grade.letter,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _letterColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  grade.courseName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '${grade.sks} SKS • ${grade.courseCode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                formatScore(grade.score),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Nilai',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: 'Opsi nilai',
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onSelected: (String value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (BuildContext context) {
              return const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Edit nilai'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Hapus nilai',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
