import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final bool isDismissible;
  final double maxWidth;

  const CustomDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.onClose,
    this.isDismissible = true,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isDismissible)
                    IconButton(
                      onPressed: () {
                        if (onClose != null) {
                          onClose!();
                        }
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: content,
              ),
            ),
            if (actions != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      actions!
                          .map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: action,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    VoidCallback? onClose,
    bool isDismissible = true,
    double maxWidth = 400,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder:
          (context) => CustomDialog(
            title: title,
            content: content,
            actions: actions,
            onClose: onClose,
            isDismissible: isDismissible,
            maxWidth: maxWidth,
          ),
    );
  }
}
