import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/loading_overlay_widget.dart';
import '../../../../core/presentation/widget/tile.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../../../core/utils/styles/widget_themes/buttons.dart';
import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../domain/entities/user_details.dart';
import '../cubit/user_profile_cubit.dart';
import '../widgets/profile_avatar.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    final authCubit = context.read<AppManagerCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: const Text(
            "Logout Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authCubit.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Select Color Scheme'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AppManagerCubit>().changeTheme(ThemeMode.system);
              },
              child: const Text('System Default'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AppManagerCubit>().changeTheme(ThemeMode.light);
              },
              child: const Text('Light'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AppManagerCubit>().changeTheme(ThemeMode.dark);
              },
              child: const Text('Dark'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppManagerCubit, AppManagerState, bool>(
      selector: (state) => state.isLoggingOut,
      builder: (context, isLoggingOut) {
        return LoadingOverlayWidget(
          isLoading: isLoggingOut,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleBarWidget(
                  title: 'User Settings',
                  subtitle: 'Configure your preferences',
                  isHeroEnabled: true,
                  heroTag: 'setting_title_bar',
                ),
                SizedBox(height: 30.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        context.read<UserProfileCubit>().fetchUserDetails(),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child:
                              BlocBuilder<UserProfileCubit, UserProfileState>(
                            builder: (context, state) {
                              switch (state.status) {
                                case UserProfileStatus.initial:
                                case UserProfileStatus.loading:
                                  return _buildShimmerLoading(context);
                                case UserProfileStatus.error:
                                  return _buildErrorState(
                                      context, state.errorMessage);
                                case UserProfileStatus.success:
                                  if (state.user == null) {
                                    return _buildErrorState(
                                        context, 'User data not found.');
                                  }
                                  return _buildSuccessContent(
                                    context,
                                    state.user!,
                                    isLoading: false,
                                  );
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final placeholderUser = UserDetails(
      id: '0',
      firstName: 'First',
      lastName: 'Last Name',
      userName: 'username',
      email: 'user@email.com',
      imageUrl: '',
      isTwoFactorEnabled: false,
      gender: null,
    );

    return Skeletonizer(
      containersColor: const Color.fromARGB(73, 158, 158, 158),
      child: _buildSuccessContent(context, placeholderUser, isLoading: true)
      );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message ?? 'An unknown error occurred.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () =>
                context.read<UserProfileCubit>().fetchUserDetails(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, UserDetails user,
      {bool isLoading = false}) {
    return Column(
      children: [
        _buildUserProfileCard(context, user, isLoading: isLoading),
        SizedBox(height: 15.h),
        _buildAppSettings(context),
      ],
    );
  }

  Widget _buildUserProfileCard(BuildContext context, UserDetails user,
      {bool isLoading = false}) {
    return Container(
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(23.r),
      ),
      child: Column(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              color: isLoading ? Colors.transparent : Color.alphaBlend(
                  AppColors.teal.withAlpha(38), AppColors.grey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.r))),
            ),
            child: Stack(
              children: [
                if (!isLoading)
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AppAssets.patternAndEffect.pattern,
                      fit: BoxFit.fill,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.grey.withAlpha(0), AppColors.grey],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 15.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileAvatar(imageUrl: user.imageUrl),
                      SizedBox(width: 20.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: AppTextStyles.header
                                .copyWith(color: AppColors.teal),
                          ),
                          Text('@${user.userName}', style: AppTextStyles.body),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {/* Navigate to edit profile screen */},
                        style: AppButtonThemes.iconButtonSmall.style,
                        icon:
                            AppIcon(AppAssets.iconly.bold.setting, size: 24.w),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Skeleton.keep(
            child: Padding(
              padding: EdgeInsets.only(right: 15.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: AppButtonThemes.textButton.style?.copyWith(
                      backgroundColor: WidgetStatePropertyAll(AppColors.red.withAlpha(39)),
                      foregroundColor: WidgetStateProperty.all(AppColors.red),
                    ),
                    child: Skeletonizer(
                      enabled: isLoading,
                      child: const Text('Logout')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    String getThemeModeText(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System Default';
      }
    }

    final state = context.watch<AppManagerCubit>().state;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(vertical:10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        children: [
          Tile(
            icon: Skeleton.shade(
              child: AppIcon(AppAssets.iconly.bold.colorSchemeSwitch,
                  color: AppColors.teal, size: 27.w),
            ),
            title: 'Color scheme',
            subTitle: getThemeModeText(state.themeMode),
            onTap: () => _showThemeDialog(context),
          ),
          Tile(
            icon: Skeleton.shade(
              child: AppIcon(AppAssets.iconly.bold.languageSwitch,
                  color: AppColors.teal, size: 27.w),
            ),
            title: 'Language',
            subTitle: 'English',
            onTap: () {},
          )
        ],
      ),
    );
  }
}
