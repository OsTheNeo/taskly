import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../l10n/app_localizations.dart';
import '../models/task_category.dart';
import '../state/settings_state.dart' as settings;
import '../widgets/ui/ui.dart';
import '../widgets/task_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  List<Map<String, dynamic>> _tasks = [];
  Map<String, Map<String, dynamic>> _completions = {}; // taskId -> completion
  List<Map<String, dynamic>> _myChallenges = []; // Challenges user is participating in
  bool _isLoading = true;
  String? _error;

  // Date selection
  DateTime _selectedDate = DateTime.now();

  // Filters
  String? _selectedCategoryFilter;
  bool _showCompletedOnly = false;
  bool _showPendingOnly = false;

  // Group tasks summary
  final int _groupTasksTotal = 0;
  final int _groupTasksCompleted = 0;

  // Filtered tasks
  List<Map<String, dynamic>> get _filteredTasks {
    var result = _tasks;

    // Category filter
    if (_selectedCategoryFilter != null) {
      result = result.where((task) {
        return task['color'] == _selectedCategoryFilter;
      }).toList();
    }

    // Status filter
    if (_showCompletedOnly) {
      result = result.where(_isTaskCompleted).toList();
    } else if (_showPendingOnly) {
      result = result.where((t) => !_isTaskCompleted(t)).toList();
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }


  Future<void> _loadTasks() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firebaseUid = _currentUser!.uid;

      // Cargar tareas, completados y retos en paralelo
      final results = await Future.wait([
        _dataService.getTasks(firebaseUid),
        _dataService.getTodayCompletions(firebaseUid),
        _dataService.getChallenges(visitorId: firebaseUid, activeOnly: true),
      ]);

      final tasks = results[0];
      final completions = results[1];
      final challenges = results[2];

      // Mapear completados por task_id
      final completionsMap = <String, Map<String, dynamic>>{};
      for (final c in completions) {
        completionsMap[c['task_id']] = c;
      }

      setState(() {
        _tasks = tasks;
        _completions = completionsMap;
        _myChallenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[HomePage] Error loading tasks: $e');
      setState(() {
        _error = 'Error al cargar tareas';
        _isLoading = false;
      });
    }
  }

  bool _isTaskCompleted(Map<String, dynamic> task) {
    final completion = _completions[task['id']];
    return completion != null && completion['status'] == 'completed';
  }

  int _getTaskProgress(Map<String, dynamic> task) {
    final completion = _completions[task['id']];
    if (completion == null) return 0;
    return (completion['progress_value'] as num?)?.toInt() ?? 0;
  }

  int get _completedCount => _tasks.where(_isTaskCompleted).length;
  double get _progressPercent => _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Avatar with user photo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      image: _currentUser?.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(_currentUser!.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _currentUser?.photoURL == null
                        ? Center(
                            child: Text(
                              _getUserInitials(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(l10n),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentUser?.displayName?.split(' ').first ?? 'Usuario',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date picker button
                  GestureDetector(
                    onTap: () => _showDatePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_selectedDate.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: settings.accentColor,
                            ),
                          ),
                          Text(
                            _getMonthName(_selectedDate.month),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Day selector strip
            _buildDayStrip(isDark),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DuotoneIcon(
                                DuotoneIcon.xmark,
                                size: 48,
                                color: AppColors.destructive,
                              ),
                              const SizedBox(height: 12),
                              Text(_error!),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Reintentar',
                                iconName: DuotoneIcon.refresh,
                                onPressed: _loadTasks,
                              ),
                            ],
                          ),
                        )
                      : _tasks.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : RefreshIndicator(
                              onRefresh: _loadTasks,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Progress Card - only show when there are tasks
                                    _buildProgressCard(isDark, l10n),
                                    const SizedBox(height: 20),

                                    // Challenges Section - show when user has challenges
                                    if (_myChallenges.isNotEmpty) ...[
                                      _buildChallengesSection(isDark),
                                      const SizedBox(height: 20),
                                    ],

                                    // Group Tasks Shortcut - only show when there are group tasks
                                    if (_groupTasksTotal > 0) ...[
                                      _buildGroupTasksShortcut(isDark, l10n),
                                      const SizedBox(height: 20),
                                    ],

                                    // Filter chips
                                    _buildFilterChips(isDark),
                                    const SizedBox(height: 20),

                                    // My Tasks Section
                                    Row(
                                      children: [
                                        Text(
                                          l10n.myTasks,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$_completedCount/${_tasks.length}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () => _showAddTaskSheet(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white : Colors.black,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DuotoneIcon(
                                                  DuotoneIcon.plus,
                                                  size: 12,
                                                  accentColor: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Nueva',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.black : Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Tasks List (filtered results)
                                    if (_filteredTasks.isEmpty)
                                      _buildFilteredEmptyState(isDark)
                                    else
                                      ..._filteredTasks.map((task) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _buildTaskCard(task, isDark),
                                      )),

                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state when filtered results are empty
  Widget _buildFilteredEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          DuotoneIcon(
            DuotoneIcon.sliders,
            size: 48,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prueba con otros filtros',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, S l10n) {
    final accentColor = settings.accentColor;

    // Empty state when no tasks at all - more engaging
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Illustration
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: DuotoneIcon(
                DuotoneIcon.rocket,
                size: 40,
                accentColor: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Comienza tu día productivo!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera tarea y empieza a construir hábitos positivos',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTip(
                  icon: DuotoneIcon.target,
                  text: 'Define metas claras y alcanzables',
                  isDark: isDark,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 10),
                _buildTip(
                  icon: DuotoneIcon.flame,
                  text: 'Mantén rachas para motivarte',
                  isDark: isDark,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 10),
                _buildTip(
                  icon: DuotoneIcon.users,
                  text: 'Comparte retos con amigos',
                  isDark: isDark,
                  accentColor: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Crear mi primera tarea',
              iconName: DuotoneIcon.plus,
              onPressed: () => _showAddTaskSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip({
    required String icon,
    required String text,
    required bool isDark,
    required Color accentColor,
  }) {
    return Row(
      children: [
        DuotoneIcon(
          icon,
          size: 18,
          accentColor: accentColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    // Get unique categories from tasks
    final categories = <TaskCategory>{};
    for (final task in _tasks) {
      final categoryId = task['color'] as String? ?? 'personal';
      categories.add(PredefinedCategories.getById(categoryId));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Status filters
          _buildFilterChip(
            label: 'Todas',
            iconName: DuotoneIcon.layers,
            isSelected: !_showCompletedOnly && !_showPendingOnly && _selectedCategoryFilter == null,
            onTap: () {
              setState(() {
                _showCompletedOnly = false;
                _showPendingOnly = false;
                _selectedCategoryFilter = null;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Pendientes',
            iconName: DuotoneIcon.clock,
            isSelected: _showPendingOnly,
            onTap: () {
              setState(() {
                _showPendingOnly = !_showPendingOnly;
                _showCompletedOnly = false;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Completadas',
            iconName: DuotoneIcon.check,
            isSelected: _showCompletedOnly,
            onTap: () {
              setState(() {
                _showCompletedOnly = !_showCompletedOnly;
                _showPendingOnly = false;
              });
            },
            isDark: isDark,
          ),
          // Category filters
          if (categories.length > 1) ...[
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 24,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            const SizedBox(width: 16),
            ...categories.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: cat.name,
                iconName: cat.iconName,
                isSelected: _selectedCategoryFilter == cat.id,
                color: cat.accentColor,
                onTap: () {
                  setState(() {
                    _selectedCategoryFilter =
                        _selectedCategoryFilter == cat.id ? null : cat.id;
                  });
                },
                isDark: isDark,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
    String? iconName,
  }) {
    final chipColor = color ?? (isDark ? AppColors.foregroundDark : AppColors.foreground);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor.withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null) ...[
              DuotoneIcon(
                iconName,
                size: 14,
                accentColor: chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark, S l10n) {
    final goals = _tasks.where((t) => t['task_type'] == 'goal').toList();
    final goalsCount = goals.length;
    final goalsCompleted = goals.where(_isTaskCompleted).length;
    final tasksOnly = _tasks.where((t) => t['task_type'] != 'goal').toList();
    final tasksCompleted = tasksOnly.where(_isTaskCompleted).length;
    final accentColor = settings.accentColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 42,
            lineWidth: 8,
            percent: _progressPercent,
            center: Text(
              '${(_progressPercent * 100).round()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            progressColor: accentColor,
            backgroundColor: accentColor.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.progressToday,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        DuotoneIcon.target,
                        '$goalsCompleted/$goalsCount',
                        'Metas',
                        isDark,
                        accentColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        DuotoneIcon.clipboardCheck,
                        '$tasksCompleted/${tasksOnly.length}',
                        'Tareas',
                        isDark,
                        accentColor,
                      ),
                    ),
                    if (_myChallenges.isNotEmpty) ...[
                      Container(
                        width: 1,
                        height: 32,
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          DuotoneIcon.rocket,
                          '${_myChallenges.length}',
                          'Retos',
                          isDark,
                          accentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String iconName, String value, String label, bool isDark, Color accentColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DuotoneIcon(
              iconName,
              size: 14,
              accentColor: accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesSection(bool isDark) {
    final accentColor = settings.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                DuotoneIcon(
                  DuotoneIcon.rocket,
                  size: 18,
                  accentColor: accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mis Retos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_myChallenges.length} activos',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _myChallenges.length,
            itemBuilder: (context, index) {
              final challenge = _myChallenges[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _myChallenges.length - 1 ? 12 : 0),
                child: _buildChallengeCard(challenge, isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, bool isDark) {
    final accentColor = settings.accentColor;
    final title = challenge['title'] as String? ?? 'Reto';
    final emoji = challenge['emoji'] as String? ?? DuotoneIcon.award;
    final targetValue = (challenge['target_value'] as num?)?.toInt() ?? 0;

    // Get participation data
    Map<String, dynamic>? participation;
    final rawParticipation = challenge['my_participation'];
    if (rawParticipation is List && rawParticipation.isNotEmpty) {
      participation = rawParticipation.first as Map<String, dynamic>?;
    } else if (rawParticipation is Map<String, dynamic>) {
      participation = rawParticipation;
    }

    final currentScore = (participation?['current_score'] as num?)?.toInt() ?? 0;
    final progress = targetValue > 0 ? (currentScore / targetValue).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        // Navigate to challenges page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ve a la pestaña "Retos" para más detalles'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: DuotoneIcon(
                      emoji,
                      size: 16,
                      accentColor: accentColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(accentColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTasksShortcut(bool isDark, S l10n) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usa la pestaña "Tareas" en el menú inferior'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DuotoneIcon(
                DuotoneIcon.users,
                size: 22,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.householdTasks,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.completedToday(_groupTasksCompleted, _groupTasksTotal),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            DuotoneIcon(
              DuotoneIcon.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isDark) {
    final isCompleted = _isTaskCompleted(task);
    final isGoal = task['task_type'] == 'goal';
    final hasProgress = task['has_progress'] == true;
    final progress = _getTaskProgress(task);
    final target = (task['progress_target'] as num?)?.toInt() ?? 1;
    final unit = task['progress_unit'] as String? ?? 'min';
    final themeAccent = Theme.of(context).colorScheme.primary;

    // Get category
    final categoryId = task['color'] as String? ?? 'personal';
    final category = PredefinedCategories.getById(categoryId);
    final accentColor = category.accentColor;

    return Dismissible(
      key: Key(task['id'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DuotoneIcon(DuotoneIcon.trash, size: 20, accentColor: AppColors.destructive),
      ),
      onDismissed: (_) => _deleteTask(task['id']),
      child: GestureDetector(
        onTap: () {
          if (isGoal && hasProgress && !isCompleted) {
            _showProgressSheet(context, task);
          } else {
            _toggleTaskCompletion(task);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? (isDark ? AppColors.borderDark : AppColors.border)
                  : accentColor.withValues(alpha: 0.3),
            ),
            boxShadow: !isCompleted
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Checkbox with accent color
              GestureDetector(
                onTap: () => _toggleTaskCompletion(task),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted ? themeAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted ? themeAccent : (isDark ? AppColors.borderDark : AppColors.border),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? DuotoneIcon(DuotoneIcon.check, size: 14, color: Theme.of(context).colorScheme.onPrimary)
                      : isGoal && hasProgress
                          ? Center(
                              child: Text(
                                '${((progress / target) * 100).round()}',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            )
                          : null,
                ),
              ),
              const SizedBox(width: 14),

              // Task Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground)
                                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                            ),
                          ),
                        ),
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DuotoneIcon(category.iconName, size: 12, color: isDark ? AppColors.foregroundDark : AppColors.foreground, accentColor: accentColor),
                              const SizedBox(width: 4),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isGoal && hasProgress && !isCompleted) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress / target,
                                backgroundColor: accentColor.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation(accentColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$progress/$target $unit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(Map<String, dynamic> task) async {
    if (_currentUser == null) return;

    final taskId = task['id'] as String;
    final isCurrentlyCompleted = _isTaskCompleted(task);

    try {
      if (isCurrentlyCompleted) {
        // Marcar como no completada (eliminar completion)
        // Por ahora, actualizamos el status a 'pending'
        await _dataService.completeTask(
          taskId: taskId,
          visitorId: _currentUser!.uid,
          status: 'pending',
        );
        setState(() {
          _completions.remove(taskId);
        });
      } else {
        // Marcar como completada
        final completion = await _dataService.completeTask(
          taskId: taskId,
          visitorId: _currentUser!.uid,
          status: 'completed',
        );
        if (completion != null) {
          setState(() {
            _completions[taskId] = completion;
          });
        }
      }
    } catch (e) {
      debugPrint('[HomePage] Error toggling completion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar tarea')),
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _dataService.deleteTask(taskId);
      setState(() {
        _tasks.removeWhere((t) => t['id'] == taskId);
        _completions.remove(taskId);
      });
    } catch (e) {
      debugPrint('[HomePage] Error deleting task: $e');
      // Recargar para recuperar el estado
      _loadTasks();
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    final l10n = S.of(context)!;
    AppBottomSheet.show(
      context: context,
      title: l10n.newTask,
      child: TaskForm(
        onSave: (data) async {
          if (_currentUser == null) return;

          final task = await _dataService.createTask(
            visitorId: _currentUser!.uid,
            title: data.title,
            description: data.description,
            taskType: data.isGoal ? 'goal' : 'task',
            hasProgress: data.isGoal,
            progressTarget: data.targetValue?.toDouble(),
            progressUnit: data.targetUnit,
            color: data.category?.id,
            recurrence: _mapRecurrence(data.recurrence),
            recurrenceDays: data.selectedDays.isNotEmpty ? data.selectedDays : null,
          );

          if (task != null) {
            await _loadTasks();
          }
        },
      ),
    );
  }

  String _mapRecurrence(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'once';
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.biweekly:
        return 'biweekly';
      case RecurrenceType.monthly:
        return 'monthly';
      case RecurrenceType.custom:
        return 'custom';
    }
  }

  void _showProgressSheet(BuildContext context, Map<String, dynamic> task) {
    final l10n = S.of(context)!;
    final currentProgress = _getTaskProgress(task);
    final target = (task['progress_target'] as num?)?.toInt() ?? 1;
    final unit = task['progress_unit'] as String? ?? 'min';

    AppBottomSheet.show(
      context: context,
      title: l10n.logProgress,
      child: ProgressForm(
        taskTitle: task['title'] as String,
        currentProgress: currentProgress,
        target: target,
        unit: unit,
        onSave: (value) async {
          Navigator.pop(context);

          if (_currentUser == null) return;

          final isComplete = value >= target;
          final completion = await _dataService.completeTask(
            taskId: task['id'] as String,
            visitorId: _currentUser!.uid,
            status: isComplete ? 'completed' : 'partial',
            progressValue: value.toDouble(),
          );

          if (completion != null) {
            setState(() {
              _completions[task['id']] = completion;
            });
          }
        },
      ),
    );
  }

  String _getUserInitials() {
    final name = _currentUser?.displayName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getGreeting(S l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    return days[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDayStrip(bool isDark) {
    final today = DateTime.now();
    // Generar 7 días: 3 antes, hoy, 3 después
    final days = List.generate(7, (i) => today.add(Duration(days: i - 3)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _loadTasksForDate(date);
            },
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? settings.accentColor
                    : (isDark ? AppColors.cardDark : AppColors.card),
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: settings.accentColor, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadTasksForDate(picked);
    }
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    // Por ahora recarga las tareas normales
    // TODO: Filtrar por fecha cuando el backend lo soporte
    await _loadTasks();
  }
}

class ProgressForm extends StatefulWidget {
  final String taskTitle;
  final int currentProgress;
  final int target;
  final String unit;
  final ValueChanged<int> onSave;

  const ProgressForm({
    super.key,
    required this.taskTitle,
    required this.currentProgress,
    required this.target,
    required this.unit,
    required this.onSave,
  });

  @override
  State<ProgressForm> createState() => _ProgressFormState();
}

class _ProgressFormState extends State<ProgressForm> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentProgress;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;
    final remaining = widget.target - _value;
    final percent = (_value / widget.target).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.taskTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 24),

        CircularPercentIndicator(
          radius: 55,
          lineWidth: 10,
          percent: percent,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_value',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Text(
                '/ ${widget.target} ${widget.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          progressColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
          backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
          circularStrokeCap: CircularStrokeCap.round,
        ),

        const SizedBox(height: 24),

        Text(
          l10n.addTime,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [5, 10, 15, 30].map((mins) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _value = (_value + mins).clamp(0, widget.target * 2);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '+$mins',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        if (remaining > 0)
          Text(
            l10n.remaining(remaining, widget.unit),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          )
        else
          Text(
            l10n.goalCompleted,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

        const SizedBox(height: 20),

        AppButton(
          label: l10n.save,
          fullWidth: true,
          iconName: DuotoneIcon.check,
          onPressed: () => widget.onSave(_value),
        ),
      ],
    );
  }
}
