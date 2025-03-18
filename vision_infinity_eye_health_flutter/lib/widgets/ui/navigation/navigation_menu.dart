import 'package:flutter/material.dart';

class NavigationMenuItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;
  final List<NavigationMenuItem>? children;

  const NavigationMenuItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isActive = false,
    this.children,
  });
}

class NavigationMenu extends StatelessWidget {
  final List<NavigationMenuItem> items;
  final bool isVertical;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final Color? backgroundColor;
  final bool showDividers;

  const NavigationMenu({
    super.key,
    required this.items,
    this.isVertical = false,
    this.padding,
    this.spacing = 4.0,
    this.backgroundColor,
    this.showDividers = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildMenuItem(NavigationMenuItem item) {
      return InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                item.isActive
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 20,
                  color:
                      item.isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            item.isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                        fontWeight: item.isActive ? FontWeight.w600 : null,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.children != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
            ],
          ),
        ),
      );
    }

    final menuItems = items.map((item) => buildMenuItem(item)).toList();

    if (isVertical) {
      return Container(
        padding: padding,
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < menuItems.length; i++) ...[
              menuItems[i],
              if (showDividers && i < menuItems.length - 1)
                Divider(
                  height: spacing * 2,
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: padding,
      color: backgroundColor,
      child: Row(
        children: [
          for (int i = 0; i < menuItems.length; i++) ...[
            Flexible(child: menuItems[i]),
            if (i < menuItems.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}
