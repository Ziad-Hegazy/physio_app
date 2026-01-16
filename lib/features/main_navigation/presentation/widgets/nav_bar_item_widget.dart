import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavBarItemWidget extends StatelessWidget {
  const NavBarItemWidget({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
    required this.color,
  });

  final bool isSelected;
  final Widget icon;
  final Widget selectedIcon;
  final void Function()? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(15.w),
            // width: 51.68.w,
            // height: 51.68.h,
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(26) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: isSelected ? selectedIcon : icon,
          ),
        ),
      ),
    );
  }
}