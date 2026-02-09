import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.colorNavBarBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.appColors.colorSecondary,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text(
                  "Total",
                  style: context.appFonts.headlineMedium(),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}