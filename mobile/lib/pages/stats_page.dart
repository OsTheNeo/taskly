import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:radix_icons/radix_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/task_category.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/injection.dart';
import '../widgets/ui/ui.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _dataService.getCompletionStats(visitorId: _currentUser!.uid, days: 30),
        _dataService.getCompletionHistory(visitorId: _currentUser!.uid, days: 30),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _history = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[StatsPage] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          'Estadisticas',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak card
                    _buildStreakCard(isDark),
                    const SizedBox(height: 20),

                    // Weekly chart
                    _buildWeeklyChart(isDark),
                    const SizedBox(height: 24),

                    // Recent history
                    Text(
                      'Historial reciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                RadixIcons.Activity_Log,
                                size: 48,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay actividad reciente',
                                style: TextStyle(
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._buildHistoryList(isDark),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    final streak = _stats['current_streak'] ?? 0;
    final total = _stats['total_completions'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Streak indicator
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RadixIcons.Lightning_Bolt,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak == 1 ? 'dia de racha' : 'dias de racha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sigue asi para mantener tu racha',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatBadge(
                      RadixIcons.Checkbox,
                      '$total',
                      'completadas',
                      isDark,
                    ),
                    const SizedBox(width: 16),
                    _buildStatBadge(
                      RadixIcons.Calendar,
                      '30',
                      'dias',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    final byDate = (_stats['completions_by_date'] as Map<String, int>?) ?? {};
    final now = DateTime.now();
    final days = <DateTime>[];

    for (int i = 6; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }

    // Find max for scaling
    int maxCompletions = 1;
    for (final day in days) {
      final dateStr = day.toIso8601String().split('T')[0];
      final count = byDate[dateStr] ?? 0;
      if (count > maxCompletions) maxCompletions = count;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Esta semana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${byDate.values.fold(0, (a, b) => a + b)} tareas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final dateStr = day.toIso8601String().split('T')[0];
                final count = byDate[dateStr] ?? 0;
                final height = count == 0 ? 8.0 : (count / maxCompletions) * 80 + 20;
                final isToday = day.day == now.day && day.month == now.month;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (count > 0)
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: height,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? (isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.6))
                            : (isDark ? AppColors.mutedDark : AppColors.muted),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDayLabel(day),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                        color: isToday
                            ? AppColors.primary
                            : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) {
      return 'Hoy';
    }
    final weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return weekdays[date.weekday - 1];
  }

  List<Widget> _buildHistoryList(bool isDark) {
    // Agrupar por fecha
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in _history) {
      final date = item['completion_date'] as String;
      grouped.putIfAbsent(date, () => []).add(item);
    }

    final widgets = <Widget>[];

    grouped.forEach((date, items) {
      // Date header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),
      );

      // Items for this date
      for (final item in items) {
        final task = item['task'] as Map<String, dynamic>?;
        if (task == null) continue;

        final categoryId = task['color'] as String? ?? 'personal';
        final category = PredefinedCategories.getById(categoryId);
        final isGoal = task['task_type'] == 'goal';
        final status = item['status'] as String? ?? 'completed';
        final progressValue = item['progress_value'] as num?;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: category.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      status == 'completed'
                          ? RadixIcons.Check
                          : (status == 'partial' ? RadixIcons.Timer : RadixIcons.Cross_2),
                      color: category.accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] as String? ?? 'Tarea',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: category.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: category.accentColor,
                                ),
                              ),
                            ),
                            if (isGoal && progressValue != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${progressValue.toInt()} completado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'completed'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : (status == 'partial'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : AppColors.destructive.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status == 'completed'
                          ? 'Completada'
                          : (status == 'partial' ? 'Parcial' : 'Omitida'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: status == 'completed'
                            ? AppColors.success
                            : (status == 'partial' ? Colors.orange : AppColors.destructive),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    return widgets;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return 'Hoy';
      if (diff == 1) return 'Ayer';
      if (diff < 7) return 'Hace $diff dias';

      return DateFormat('d MMMM', 'es').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
