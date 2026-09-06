import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isPrimary = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isPrimary
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          const Color(0xFF232B3E),
                          const Color(0xFF141926),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: widget.isPrimary
                      ? const Color(0xFF818CF8).withOpacity(0.6)
                      : Colors.white.withOpacity(0.1),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? AppColors.primary.withOpacity(0.35)
                        : Colors.black.withOpacity(0.25),
                    blurRadius: widget.isPrimary ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.isPrimary ? Colors.white : AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isPrimary ? AppColors.primaryLight : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
