import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/custom_logo_transparent_progress_indicator_widget.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/app_assets.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 35.0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = AppIcon(
      AppAssets.iconly.bold.profile,
      color: AppColors.black50,
      size: radius,
    );
    
    final Widget loadingIndicator = CustomLogoTransparentProgressIndicatorWidget();

    return CircleAvatar(
    radius: radius.w, 
    backgroundColor: AppColors.white,
    child: imageUrl == null ? CircleAvatar(
        radius: radius.w - 10.w, // Inner radius
        backgroundColor: AppColors.grey,
        child: placeholder,
      ) : CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius.w - 2.w, // Inner radius
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius.w - 2.w, // Inner radius
        backgroundColor: AppColors.grey,
        child: loadingIndicator,
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius.w - 2.w, // Inner radius
        backgroundColor: AppColors.grey,
        child: placeholder,
      ),
    ),
  );
  }
}