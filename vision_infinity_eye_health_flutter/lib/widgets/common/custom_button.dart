import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined
                  ? Colors.transparent
                  : (backgroundColor ?? theme.colorScheme.primary),
          foregroundColor:
              isOutlined
                  ? theme.colorScheme.primary
                  : (textColor ?? Colors.white),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                isOutlined
                    ? BorderSide(color: theme.colorScheme.primary)
                    : BorderSide.none,
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined
                          ? theme.colorScheme.primary
                          : (textColor ?? Colors.white),
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            isOutlined
                                ? theme.colorScheme.primary
                                : (textColor ?? Colors.white),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
