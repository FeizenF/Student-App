import 'package:flutter/material.dart';

/// Card dasar yang dipakai di seluruh aplikasi agar tampilan konsisten.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);

    return Card(
      color: color,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}
