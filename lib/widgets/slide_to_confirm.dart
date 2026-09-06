import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SlideToConfirm extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  final bool isLoading;
  final double height;

  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.isLoading = false,
    this.height = 58,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SlideToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading && _isConfirmed) {
      // Reset if loading completed
      setState(() {
        _isConfirmed = false;
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - widget.height;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              if (_dragPosition > 0)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2 * (_dragPosition / maxDrag)),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Filled glowing progress track behind knob
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: widget.height + _dragPosition,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.25),
                        AppColors.primary.withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),

              // Center shimmer label
              Center(
                child: widget.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Executing on DEX...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          final progress = _dragPosition / (maxDrag > 0 ? maxDrag : 1);
                          final opacity = (1.0 - (progress * 1.5)).clamp(0.0, 1.0);

                          return Opacity(
                            opacity: opacity,
                            child: Padding(
                              padding: EdgeInsets.only(left: widget.height * 0.8, right: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: const [
                                            AppColors.textSecondary,
                                            Colors.white,
                                            AppColors.cyan,
                                            AppColors.textSecondary,
                                          ],
                                          stops: const [0.0, 0.45, 0.55, 1.0],
                                          transform: GradientRotation(_shimmerController.value * 6.28),
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        widget.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_double_arrow_right_rounded,
                                    size: 16,
                                    color: AppColors.cyan,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Draggable Slider Knob
              if (!widget.isLoading)
                Positioned(
                  left: _dragPosition,
                  top: 3,
                  bottom: 3,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragPosition = (_dragPosition + details.delta.dx)
                            .clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragPosition >= maxDrag * 0.78) {
                        // Success trigger! Snap to end
                        setState(() {
                          _dragPosition = maxDrag;
                          _isConfirmed = true;
                        });
                        widget.onConfirmed();
                      } else {
                        // Spring back to start
                        setState(() {
                          _dragPosition = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: widget.height - 6,
                      height: widget.height - 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.6),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _dragPosition >= maxDrag * 0.78
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
