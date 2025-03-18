import 'package:flutter/material.dart';

class ModeToggle extends StatelessWidget {
  final bool isAdvancedMode;
  final ValueChanged<bool> onModeChanged;

  const ModeToggle({
    super.key,
    required this.isAdvancedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Animated selection indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left:
                isAdvancedMode ? MediaQuery.of(context).size.width / 2 - 16 : 4,
            right:
                isAdvancedMode ? 4 : MediaQuery.of(context).size.width / 2 - 16,
            top: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Mode buttons
          Row(
            children: [
              _ModeButton(
                text: 'Simple Mode',
                isSelected: !isAdvancedMode,
                onTap: () => onModeChanged(false),
              ),
              _ModeButton(
                text: 'Advanced Mode',
                isSelected: isAdvancedMode,
                onTap: () => onModeChanged(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.7,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodyMedium!.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
