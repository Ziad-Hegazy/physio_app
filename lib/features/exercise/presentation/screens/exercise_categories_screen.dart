import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/widget/cached_network_image.dart';
import '../../../../core/presentation/widget/custom_logo_transparent_progress_indicator_widget.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../domain/entities/exercise_category.dart';
import '../cubit/exercise_category/exercise_category_cubit.dart';
import '../model/exercise_filter_screen_args.dart';
import '../widgets/exercise_category_widget.dart';

class ExerciseCategoriesScreen extends StatelessWidget {
  const ExerciseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseCategoryCubit = context.read<ExerciseCategoryCubit>();
    return Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AppManagerCubit, AppManagerState>(
              builder: (appManagerContext, appManagerState) {
                return TitleBarWidget(
                  title: "Exercise",
                  subtitle: "Choose a category",
                  onActionButtonPressed: () {
                    final categoryTitles = exerciseCategoryCubit
                        .state.categories
                        .where((c) => c.id != ExerciseCategory.favoritesId)
                        .map((c) => c.title)
                        .toList();

                    final args = ExerciseFilterScreenArgs(
                      allCategoryTitles: categoryTitles,
                      isOffline: exerciseCategoryCubit.state.isOffline,
                      selectedCategory: null,
                      exerciseCategoryCubit: exerciseCategoryCubit,
                    );

                    Navigator.of(context)
                        .pushNamed(Routes.exerciseFilter, arguments: args);
                  },
                  actionButtonIconSvgAsset: AppAssets.iconly.bulk.search,
                  isHeroEnabled: true,
                  heroTag: appManagerState.connectivityStatus ==
                          ConnectivityStatus.online
                      ? 'exercise_title_bar'
                      : "no_internet_title_bar",
                );
              },
            ),
            BlocListener<AppManagerCubit, AppManagerState>(
              listenWhen: (previous, current) =>
                  current.authStatus != AuthStatus.guest &&
                  previous.connectivityStatus != current.connectivityStatus,
              listener: (context, state) async {
                if (state.connectivityStatus == ConnectivityStatus.offline) {
                  await context
                      .read<ExerciseCategoryCubit>()
                      .getCategories(forceRefresh: true, isOffline: true);
                } else {
                  await context
                      .read<ExerciseCategoryCubit>()
                      .getCategories(forceRefresh: true, isOffline: false);
                }
              },
              child: Expanded(
                child:
                    BlocBuilder<ExerciseCategoryCubit, ExerciseCategoryState>(
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<ExerciseCategoryCubit>()
                          .getCategories(
                              forceRefresh: true, isOffline: state.isOffline),
                      child: Builder(
                        builder: (context) {
                          switch (state.status) {
                            case ExerciseCategoryStatus.loading:
                            case ExerciseCategoryStatus.initial:
                              return const Center(
                                  child:
                                      CustomLogoTransparentProgressIndicatorWidget());
                            case ExerciseCategoryStatus.error:
                              return LayoutBuilder(
                                builder: (context, constraints) =>
                                    SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight),
                                    child: Center(
                                      child: Text(state.errorMessage ??
                                          'An error occurred'),
                                    ),
                                  ),
                                ),
                              );
                            case ExerciseCategoryStatus.loaded:
                              final List<ExerciseCategory> categories =
                                  state.categories;

                              final allRealCategoryTitles = categories
                                  .where((c) =>
                                      c.id != ExerciseCategory.favoritesId)
                                  .map((c) => c.title)
                                  .toList();

                              if (categories.isEmpty) {
                                return LayoutBuilder(
                                  builder: (context, constraints) =>
                                      SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight),
                                      child: const Center(
                                          child: Text('No categories found.')),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: EdgeInsets.only(top: 30.h),
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return Column(children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 20.h),
                                      child: ExerciseCategoryWidget(
                                        color: category.iconColor ??
                                            AppColors.purple,
                                        title: category.title,
                                        subtitle: category.subTitle,
                                        icon: DynamicCachedImage(
                                          cacheKey: '${category.id}::icon::SVG',
                                          imageUrl: category.iconUrl,
                                          fallbackAssetPath:
                                              category.localFallbackIconAsset,
                                          width: 46.66.w,
                                          height: 46.66.w,
                                          color: category.iconColor ??
                                              AppColors.purple,
                                        ),
                                        onTap: () {
                                          final args = ExerciseFilterScreenArgs(
                                            allCategoryTitles:
                                                allRealCategoryTitles,
                                            selectedCategory: category.title,
                                            isOffline: state.isOffline,
                                            exerciseCategoryCubit:
                                                exerciseCategoryCubit,
                                          );
                                          Navigator.of(context).pushNamed(
                                              Routes.exerciseFilter,
                                              arguments: args);
                                        },
                                      ),
                                    ),
                                    index == categories.length - 1
                                        ? SizedBox(
                                            height: 120,
                                          )
                                        : SizedBox.shrink()
                                  ]);
                                },
                              );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
