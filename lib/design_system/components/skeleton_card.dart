import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF404040) : const Color(0xFFEEEEEE);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: _ShimmerBox(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  animationValue: _animation.value,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerLine(
                        width: 40,
                        height: 8,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        animationValue: _animation.value,
                      ),
                      const SizedBox(height: 4),
                      _ShimmerLine(
                        width: double.infinity,
                        height: 8,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        animationValue: _animation.value,
                      ),
                      const SizedBox(height: 2),
                      _ShimmerLine(
                        width: 64,
                        height: 8,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        animationValue: _animation.value,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ShimmerLine(
                            width: 44,
                            height: 8,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            animationValue: _animation.value,
                          ),
                          _ShimmerLine(
                            width: 24,
                            height: 8,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            animationValue: _animation.value,
                          ),
                        ],
                      ),
                    ],
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

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.baseColor,
    required this.highlightColor,
    required this.animationValue,
  });

  final Color baseColor;
  final Color highlightColor;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: [
            (animationValue - 0.3).clamp(0.0, 1.0),
            animationValue.clamp(0.0, 1.0),
            (animationValue + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: ColoredBox(color: baseColor),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    required this.animationValue,
  });

  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: [
            (animationValue - 0.3).clamp(0.0, 1.0),
            animationValue.clamp(0.0, 1.0),
            (animationValue + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
