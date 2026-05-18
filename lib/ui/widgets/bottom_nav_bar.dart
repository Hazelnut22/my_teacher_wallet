
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.pageIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0.0,
      color: context.appColors.colorNavBarBg,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.colorNavBarBg,
            border: Border.all(color: context.appColors.colorGray, width: 0.5),
            borderRadius: BorderRadius.circular(16.0),
          ),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItems(
                onTap: () => onTap(0),
                icon: FontAwesomeIcons.house,
                isSelected: pageIndex == 0,
              ),
              NavItems(
                onTap: () => onTap(1),
                icon: FontAwesomeIcons.graduationCap,
                isSelected: pageIndex == 1,
              ),
              NavItems(
                onTap: () => onTap(2),
                icon: FontAwesomeIcons.dollarSign,
                isSelected: pageIndex == 2,
              ),
              NavItems(
                onTap: () => onTap(3),
                icon: FontAwesomeIcons.gear,
                isSelected: pageIndex == 3,
              ),
            ],
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
