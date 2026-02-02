import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/ui/widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    // This switches between branches while preserving state
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        pageIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}