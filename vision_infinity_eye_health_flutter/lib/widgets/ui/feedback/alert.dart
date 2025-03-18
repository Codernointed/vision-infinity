import 'package:flutter/material.dart';

enum AlertVariant { default_, destructive, success, warning, info }

class Alert extends StatelessWidget {
  final String title;
  final String? description;
  final AlertVariant variant;
  final VoidCallback? onClose;
  final Widget? icon;

  const Alert({
    super.key,
    required this.title,
    this.description,
    this.variant = AlertVariant.default_,
    this.onClose,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = _getColorScheme(theme);
    final iconData = _getIcon();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(padding: const EdgeInsets.only(right: 12), child: icon!)
          else if (iconData != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(iconData, color: colors.foreground, size: 20),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.foreground.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                size: 18,
                color: colors.foreground.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  _ColorScheme _getColorScheme(ThemeData theme) {
    switch (variant) {
      case AlertVariant.destructive:
        return _ColorScheme(
          background: theme.colorScheme.error.withOpacity(0.1),
          border: theme.colorScheme.error.withOpacity(0.2),
          foreground: theme.colorScheme.error,
        );
      case AlertVariant.success:
        return _ColorScheme(
          background: Colors.green.withOpacity(0.1),
          border: Colors.green.withOpacity(0.2),
          foreground: Colors.green,
        );
      case AlertVariant.warning:
        return _ColorScheme(
          background: Colors.orange.withOpacity(0.1),
          border: Colors.orange.withOpacity(0.2),
          foreground: Colors.orange,
        );
      case AlertVariant.info:
        return _ColorScheme(
          background: Colors.blue.withOpacity(0.1),
          border: Colors.blue.withOpacity(0.2),
          foreground: Colors.blue,
        );
      default:
        return _ColorScheme(
          background: theme.colorScheme.surface,
          border: theme.colorScheme.outline.withOpacity(0.2),
          foreground: theme.colorScheme.onSurface,
        );
    }
  }

  IconData? _getIcon() {
    switch (variant) {
      case AlertVariant.destructive:
        return Icons.error_outline;
      case AlertVariant.success:
        return Icons.check_circle_outline;
      case AlertVariant.warning:
        return Icons.warning_amber_outlined;
      case AlertVariant.info:
        return Icons.info_outline;
      default:
        return null;
    }
  }
}

class _ColorScheme {
  final Color background;
  final Color border;
  final Color foreground;

  const _ColorScheme({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
