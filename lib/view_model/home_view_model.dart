import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/dashboard_stats.dart';

class HomeViewModel extends StateNotifier<AsyncValue<DashboardStats>> {
  HomeViewModel() : super(const AsyncValue.loading()) {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final stats = DashboardStats(
        activeProjects: 8,
        pendingExpenses: 2450.50,
        unreadMessages: 5,
        overdueTasks: 3,
      );

      state = AsyncValue.data(stats);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void refresh() {
    state = const AsyncValue.loading();
    _loadDashboardData();
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue<DashboardStats>>(
  (ref) => HomeViewModel(),
);
