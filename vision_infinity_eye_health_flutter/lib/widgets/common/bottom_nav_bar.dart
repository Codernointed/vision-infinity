import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.remove_red_eye_outlined,
              color:
                  currentIndex == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
              color:
                  currentIndex == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color:
                  currentIndex == 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
