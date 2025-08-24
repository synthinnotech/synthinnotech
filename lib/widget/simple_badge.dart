import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/main.dart';

class SimpleBadge extends StatelessWidget {
  const SimpleBadge({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: baseColor2.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: baseColor2.withAlpha(65),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: baseColor1,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
