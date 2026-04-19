import 'package:flutter/material.dart';

class TaskSkeletonList extends StatefulWidget {
  const TaskSkeletonList({super.key});

  @override
  State<TaskSkeletonList> createState() => _TaskSkeletonListState();
}

class _TaskSkeletonListState extends State<TaskSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _TaskSkeletonTile(
          animation: _pulse,
          titleWidthFactor: index.isEven ? 0.78 : 0.58,
          subtitleWidthFactor: index % 3 == 0 ? 0.42 : 0.32,
        );
      },
    );
  }
}

class _TaskSkeletonTile extends StatelessWidget {
  const _TaskSkeletonTile({
    required this.animation,
    required this.titleWidthFactor,
    required this.subtitleWidthFactor,
  });

  final Animation<double> animation;
  final double titleWidthFactor;
  final double subtitleWidthFactor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _SkeletonBox(
              animation: animation,
              width: 24,
              height: 24,
              radius: 6,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                        animation: animation,
                        width: constraints.maxWidth * titleWidthFactor,
                        height: 14,
                      ),
                      const SizedBox(height: 10),
                      _SkeletonBox(
                        animation: animation,
                        width: constraints.maxWidth * subtitleWidthFactor,
                        height: 12,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            _SkeletonBox(
              animation: animation,
              width: 28,
              height: 28,
              radius: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.animation,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
    final highlightColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.25,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(baseColor, highlightColor, animation.value),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: child,
        );
      },
      child: SizedBox(width: width, height: height),
    );
  }
}
