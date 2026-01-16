import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import '../../../../core/presentation/widget/app_icon.dart';
import '../../../../core/utils/styles/app_colors.dart';
import '../../../../core/utils/config/routes.dart' as routes;
import '../../domain/navigation_tab.dart';
import '../cubit/navigation_cubit/navigation_cubit.dart';
import '../widgets/nav_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final allTabs = NavigationTab.values;
        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: state.index,
            children: state.pages,
          ),
          bottomNavigationBar: BlocConsumer<AppManagerCubit, AppManagerState>(
            listenWhen: (previous, current) =>
                previous.connectivityStatus != current.connectivityStatus,
            listener: (authcontext, authState) {
              if (authState.connectivityStatus == ConnectivityStatus.offline) {
                context.read<NavigationCubit>().changeTab(0);
                Navigator.popUntil(context, (route) {
                  return routes.Routes()
                          .isRouteHomeParent(route.settings.name) ||
                      route.settings.name == routes.Routes.mainScreen;
                });
              }
            },
            builder: (context, authState) {
              return authState.connectivityStatus == ConnectivityStatus.offline
                  ? const SizedBox.shrink()
                  : NavBar(
                      selectedIndex: state.index,
                      color: AppColors.teal,
                      navItems: List.generate(allTabs.length, (index) {
                        final tab = allTabs[index];
                        return NavItem(
                          icon: AppIcon(
                            tab.icon,
                            size:31.68,
                          ),
                          selectedIcon: AppIcon(
                            tab.selectedIcon,
                            color: AppColors.teal,
                            size: 31.68.w,
                          ),
                          onTap: authState.connectivityStatus ==
                                  ConnectivityStatus.offline
                              ? null
                              : () => context
                                  .read<NavigationCubit>()
                                  .changeTab(index),
                        );
                      }),
                    );
            },
          ),
        );
      },
    );
  }
}
