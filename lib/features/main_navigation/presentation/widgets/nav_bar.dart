import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/styles/app_colors.dart';
import 'nav_bar_item_widget.dart';

class NavItem {
  NavItem({
    required this.icon,
    required this.selectedIcon,
    this.label,
    this.onTap,
  });
  final String? label;
  final Widget icon;
  final Widget selectedIcon;
  final void Function()? onTap;
}

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    this.selectedIndex = 0,
    required this.navItems,
    this.color = AppColors.teal,
  });
  final int selectedIndex;
  final Color color;
  final List<NavItem> navItems;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.grey.withAlpha(0), AppColors.grey],
              begin: Alignment.topCenter,
              end: Alignment(0.0,-0.4))),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 40.h,
              bottom: 32.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(200.r),
            ),
            padding: EdgeInsets.all(10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = index == selectedIndex;
                return NavBarItemWidget(
                  onTap: item.onTap,
                  isSelected: isSelected,
                  color: color,
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
