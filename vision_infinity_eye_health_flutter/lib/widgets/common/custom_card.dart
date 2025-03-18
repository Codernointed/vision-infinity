import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surface,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow:
                hasShadow
                    ? [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
