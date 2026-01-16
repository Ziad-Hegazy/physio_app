import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/presentation/widget/cached_network_image.dart';
import '../../../../core/presentation/widget/custom_logo_transparent_progress_indicator_widget.dart';
import '../../../../core/presentation/widget/tile_list_item.dart';
import '../../../../core/presentation/widget/title_bar_widget.dart';
import '../../../../core/utils/config/routes.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/styles/font.dart';
import '../../../../core/utils/styles/app_assets.dart';
import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../domain/entities/exercise_category.dart';
import '../cubit/exercise_category/exercise_category_cubit.dart';
import '../cubit/exercise_filter/exercise_filter_cubit.dart';
import '../model/exercise_description_screen_args.dart';

class ExercisesFilterScreen extends StatelessWidget {
  const ExercisesFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseFilterCubit = context.read<ExerciseFilterCubit>();

    return Scaffold(
      body: BlocProvider.value(
        value: exerciseFilterCubit,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0.h),
          child: MultiBlocListener(
            listeners: [
              BlocListener<ExerciseCategoryCubit, ExerciseCategoryState>(
                listenWhen: (prev, current) =>
                    prev.categories != current.categories &&
                    current.status == ExerciseCategoryStatus.loaded,
                listener: (context, categoryState) {
                  final categoryTitles = categoryState.categories
                      .where((c) => c.id != ExerciseCategory.favoritesId)
                      .map((c) => c.title)
                      .toList();

                  exerciseFilterCubit.updateExternalDependencies(
                    newAllCategories: categoryTitles,
                    isOffline: categoryState.isOffline,
                  );
                },
              ),
              BlocListener<AppManagerCubit, AppManagerState>(
                listener: (context, appState) {
                  final isOffline =
                      appState.connectivityStatus == ConnectivityStatus.offline;
                  final categoryState =
                      context.read<ExerciseCategoryCubit>().state;
                  final categoryTitles = categoryState.categories
                      .where((c) => c.id != ExerciseCategory.favoritesId)
                      .map((c) => c.title)
                      .toList();

                  exerciseFilterCubit.updateExternalDependencies(
                    newAllCategories: categoryTitles,
                    isOffline: isOffline,
                  );
                },
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AppManagerCubit, AppManagerState>(
              builder: (appManagerContext, appManagerState) {
                    return TitleBarWidget(
                      title: 'Exercises',
                      subtitle: 'Find your exercise',
                      isReturnButtonEnabled: true,
                      isHeroEnabled: true,
                      heroTag: appManagerState.connectivityStatus ==
                          ConnectivityStatus.online
                      ? 'exercise_title_bar'
                      : "no_internet_title_bar",
                    );
                  },
                ),
                BlocBuilder<ExerciseFilterCubit, ExerciseFilterState>(
                  buildWhen: (p, c) =>
                      p.displayCategories != c.displayCategories ||
                      p.activeFilters != c.activeFilters,
                  builder: (context, state) {
                    if (state.displayCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: state.displayCategories.map((category) {
                          final isSelected =
                              state.activeFilters.contains(category);
                          return Padding(
                            padding: EdgeInsets.only(right: 14.w),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style:
                                    AppTextStyles.secondaryTextButton.copyWith(
                                  color: isSelected
                                      ? AppColors.teal
                                      : AppColors.black,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  exerciseFilterCubit.toggleFilter(category),
                              selectedColor: AppColors.teal.withAlpha(39),
                              backgroundColor: AppColors.white,
                              checkmarkColor: AppColors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),
                SearchBar(
                  controller: exerciseFilterCubit.searchController,
                  autoFocus: exerciseFilterCubit.state.status ==
                      ExerciseFilterStatus.empty,
                  leading: AppIcon(AppAssets.iconly.bulk.search, size: 30.72),
                  hintText: 'Search',
                  onChanged: exerciseFilterCubit.onSearchChanged,
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: BlocConsumer<ExerciseFilterCubit, ExerciseFilterState>(
                    listener: (context, state) {
                      if (state.errorMessage != null &&
                          state.status == ExerciseFilterStatus.error) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                              content: Text(state.errorMessage!),
                              backgroundColor: Colors.red));
                      }
                    },
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: () => exerciseFilterCubit.refresh(),
                        child: Builder(
                          builder: (context) {
                            switch (state.status) {
                              case ExerciseFilterStatus.loading:
                              case ExerciseFilterStatus.initial:
                                return const Center(
                                    child:
                                        CustomLogoTransparentProgressIndicatorWidget());
                              case ExerciseFilterStatus.error:
                                return Center(
                                    child: Text(state.errorMessage ??
                                        'Failed to load exercises'));
                              case ExerciseFilterStatus.empty:
                                return const Center(
                                    child: Text('No exercises found.'));
                              case ExerciseFilterStatus.loaded:
                              case ExerciseFilterStatus.loadingMore:
                              case ExerciseFilterStatus.loadingMoreError:
                                if (state.exercises.isEmpty &&
                                    state.status ==
                                        ExerciseFilterStatus.loaded) {
                                  return const Center(
                                      child: Text(
                                          'No exercises found for the selected filters.',
                                          textAlign: TextAlign.center));
                                }
                                return ListView.builder(
                                  controller:
                                      exerciseFilterCubit.scrollController,
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  itemCount: state.exercises.length +
                                      (state.status ==
                                                  ExerciseFilterStatus
                                                      .loadingMore ||
                                              state.status ==
                                                  ExerciseFilterStatus
                                                      .loadingMoreError
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= state.exercises.length) {
                                      if (state.status ==
                                          ExerciseFilterStatus
                                              .loadingMoreError) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(state.errorMessage ??
                                                    'Failed to load more exercises.'),
                                                SizedBox(height: 8.h),
                                                TextButton(
                                                  onPressed: () =>
                                                      exerciseFilterCubit
                                                          .fetchNextPage(),
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return const Center(
                                          child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: SizedBox(
                                            width: 150,
                                            height: 150,
                                            child:
                                                CustomLogoTransparentProgressIndicatorWidget()),
                                      ));
                                    }
                                    final exercise = state.exercises[index];
                                    return TileListItem(
                                      index: index,
                                      length: state.exercises.length,
                                      onTap: () {
                                        final args =
                                            ExerciseDescriptionScreenArgs(
                                                exercise: exercise,
                                                exerciseFilterCubit:
                                                    exerciseFilterCubit);
                                        Navigator.of(context).pushNamed(
                                          Routes.exerciseDescription,
                                          arguments: args,
                                        );
                                      },
                                      icon: DynamicCachedImage(
                                        cacheKey:
                                            '${exercise.id}::${exercise.modelKey}::icon::SVG',
                                        imageUrl: exercise.iconUrl,
                                        fallbackAssetPath:
                                            exercise.localFallbackIconAsset,
                                        width: 35.66.w,
                                        height: 35.66.w,
                                        color: AppColors.teal,
                                      ),
                                      title: exercise.title,
                                      subTitle: exercise.subTitle,
                                      isFirst: index == 0,
                                      isEnd: index ==
                                              state.exercises.length - 1 &&
                                          state.status !=
                                              ExerciseFilterStatus.loadingMore,
                                      trailing: state.isOffline
                                          ? null
                                          : IconButton(
                                              onPressed: () =>
                                                  exerciseFilterCubit
                                                      .toggleFavorite(
                                                          exercise.id),
                                              icon: exercise.isFavorite
                                                  ? AppIcon(
                                                      AppAssets
                                                          .iconly.bold.heart,
                                                      color: AppColors.red,
                                                      size: 30.w)
                                                  : AppIcon(
                                                      AppAssets
                                                          .iconly.stroke.heart,
                                                      color: AppColors.black50,
                                                      size: 30.w),
                                            ),
                                    );
                                  },
                                );
                            }
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
