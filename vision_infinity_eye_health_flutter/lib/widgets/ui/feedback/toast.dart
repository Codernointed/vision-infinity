import 'package:flutter/material.dart';

enum ToastVariant { default_, destructive, success, warning, info }

class Toast extends StatelessWidget {
  final String title;
  final String? description;
  final ToastVariant variant;
  final VoidCallback? onClose;
  final Duration duration;
  final bool isVisible;

  const Toast({
    super.key,
    required this.title,
    this.description,
    this.variant = ToastVariant.default_,
    this.onClose,
    this.duration = const Duration(seconds: 3),
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColorScheme(theme);
    final iconData = _getIcon();

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (variant != ToastVariant.default_)
                Container(height: 4, color: colors.foreground),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (iconData != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          iconData,
                          color: colors.foreground,
                          size: 20,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.9,
                                ),
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
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ColorScheme _getColorScheme(ThemeData theme) {
    switch (variant) {
      case ToastVariant.destructive:
        return _ColorScheme(
          background: theme.colorScheme.error.withOpacity(0.1),
          border: theme.colorScheme.error.withOpacity(0.2),
          foreground: theme.colorScheme.error,
        );
      case ToastVariant.success:
        return _ColorScheme(
          background: Colors.green.withOpacity(0.1),
          border: Colors.green.withOpacity(0.2),
          foreground: Colors.green,
        );
      case ToastVariant.warning:
        return _ColorScheme(
          background: Colors.orange.withOpacity(0.1),
          border: Colors.orange.withOpacity(0.2),
          foreground: Colors.orange,
        );
      case ToastVariant.info:
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
      case ToastVariant.destructive:
        return Icons.error_outline;
      case ToastVariant.success:
        return Icons.check_circle_outline;
      case ToastVariant.warning:
        return Icons.warning_amber_outlined;
      case ToastVariant.info:
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

class ToastService {
  static OverlayEntry? _currentToast;
  static bool _isVisible = false;

  static void show(
    BuildContext context, {
    required String title,
    String? description,
    ToastVariant variant = ToastVariant.default_,
    VoidCallback? onClose,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentToast?.remove();
    _isVisible = true;

    _currentToast = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Toast(
                title: title,
                description: description,
                variant: variant,
                onClose: () {
                  _hide();
                  onClose?.call();
                },
                duration: duration,
                isVisible: _isVisible,
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_currentToast!);

    Future.delayed(duration, _hide);
  }

  static void _hide() {
    _isVisible = false;
    Future.delayed(const Duration(milliseconds: 200), () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }
}
