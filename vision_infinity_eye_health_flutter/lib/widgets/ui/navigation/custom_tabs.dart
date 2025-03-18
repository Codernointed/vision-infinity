import 'package:flutter/material.dart';

class TabItem {
  final String label;
  final Widget content;
  final IconData? icon;

  const TabItem({required this.label, required this.content, this.icon});
}

class CustomTabs extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final void Function(int)? onTabChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const CustomTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isScrollable = false,
    this.padding,
  });

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            padding: widget.padding,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            tabs:
                widget.tabs
                    .map(
                      (tab) => Tab(
                        text: tab.label,
                        icon: tab.icon != null ? Icon(tab.icon) : null,
                      ),
                    )
                    .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.content).toList(),
          ),
        ),
      ],
    );
  }
}
