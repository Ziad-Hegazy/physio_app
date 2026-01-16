import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/styles/app_colors.dart';
import '../../utils/styles/font.dart';

class Tile extends StatefulWidget {
  const Tile(
      {super.key,
      required this.icon,
      required this.title,
      this.subTitle = '',
      required this.onTap,
      this.isFirst = false,
      this.isEnd = false,
      this.trailing});
  final bool isFirst;
  final bool isEnd;
  final Widget icon;
  final Widget? trailing;
  final String title;
  final String? subTitle;
  final void Function() onTap;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            widget.onTap();
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, widget.isFirst ? 20.h : 10.h, 20.w,
              widget.isEnd ? 20.h : 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 20.w,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.teal.withAlpha(39),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: widget.icon,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 0.h,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.header,
                      textHeightBehavior: TextHeightBehavior(
                          applyHeightToLastDescent: false,
                          applyHeightToFirstAscent: true),
                    ),
                    Text(
                      widget.subTitle!,
                      style: AppTextStyles.body,
                      textWidthBasis: TextWidthBasis.parent,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      textHeightBehavior: TextHeightBehavior(
                          applyHeightToLastDescent: true,
                          applyHeightToFirstAscent: false),
                    )
                  ],
                ),
              ),
              if (widget.trailing != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [widget.trailing!],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
