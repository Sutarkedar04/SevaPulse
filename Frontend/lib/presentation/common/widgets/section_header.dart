// lib/presentation/common/widgets/section_header.dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    this.icon,
    this.onSeeAll,
    this.showSeeAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF3498db), size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ],
        ),
        if (showSeeAll && onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: Color(0xFF3498db),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}