import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.pageIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: Platform.isAndroid ? 16 : 0,
      ),
      child: BottomAppBar(
        elevation: 0.0,
        color: context.appColors.colorNavBarBg,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.colorNavBarBg,
              border: Border.all(
                color: context.appColors.colorGray,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(
                16.0,
              ), 
            ),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItems(
                  onTap: () => onTap(0),
                  icon: Icons.home,
                  isSelected: pageIndex == 0,
                ),
                NavItems(
                  onTap: () => onTap(1),
                  icon: Icons.person_4,
                  isSelected: pageIndex == 1,
                ),
                NavItems(
                  onTap: () => onTap(2),
                  icon: Icons.attach_money,
                  isSelected: pageIndex == 2,
                ),
                NavItems(
                  onTap: () => onTap(3),
                  icon: Icons.settings,
                  isSelected: pageIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItems extends StatelessWidget {
  const NavItems({
    super.key,
    required this.onTap,
    required this.icon,
    required this.isSelected,
  });

  final Function()? onTap;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        splashColor: context.appColors.colorWhite,
        onTap: onTap,
        child: Icon(
          icon,
          color: isSelected
              ? context.appColors.colorPrimary
              : context.appColors.colorPrimaryText,
        ),
      ),
    );
  }
}
