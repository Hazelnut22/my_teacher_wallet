import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.colorNavBarBg,
      body: Center(
        child: Text("This is home screen"),
      ),
    );
  }
}