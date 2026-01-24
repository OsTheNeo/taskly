import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:radix_icons/radix_icons.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../l10n/app_localizations.dart';
import '../models/task_category.dart';
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
  bool _isLoading = true;
  String? _error;

  // Search and filter
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  bool _showCompletedOnly = false;
  bool _showPendingOnly = false;
  final _searchController = TextEditingController();

  // Group tasks summary
  final int _groupTasksTotal = 0;
  final int _groupTasksCompleted = 0;

  // Filtered tasks
  List<Map<String, dynamic>> get _filteredTasks {
    var result = _tasks;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((task) {
        final title = (task['title'] as String? ?? '').toLowerCase();
        return title.contains(_searchQuery.toLowerCase());
      }).toList();
    }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firebaseUid = _currentUser!.uid;

      // Cargar tareas y completados en paralelo
      final results = await Future.wait([
        _dataService.getTasks(firebaseUid),
        _dataService.getTodayCompletions(firebaseUid),
      ]);

      final tasks = results[0];
      final completions = results[1];

      // Mapear completados por task_id
      final completionsMap = <String, Map<String, dynamic>>{};
      for (final c in completions) {
        completionsMap[c['task_id']] = c;
      }

      setState(() {
        _tasks = tasks;
        _completions = completionsMap;
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
                  // Date badge
                  Container(
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
                          '${DateTime.now().day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          _getMonthName(DateTime.now().month),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                RadixIcons.Cross_Circled,
                                size: 48,
                                color: AppColors.destructive,
                              ),
                              const SizedBox(height: 12),
                              Text(_error!),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Reintentar',
                                onPressed: _loadTasks,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTasks,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Progress Card
                                _buildProgressCard(isDark, l10n),
                                const SizedBox(height: 20),

                                // Group Tasks Shortcut
                                _buildGroupTasksShortcut(isDark, l10n),
                                const SizedBox(height: 20),

                                // Search bar
                                _buildSearchBar(isDark),
                                const SizedBox(height: 12),

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
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              RadixIcons.Plus,
                                              size: 14,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Nueva',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.onPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Tasks List
                                if (_filteredTasks.isEmpty)
                                  Container(
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
                                        Icon(
                                          _searchQuery.isNotEmpty || _selectedCategoryFilter != null
                                              ? RadixIcons.Magnifying_Glass
                                              : RadixIcons.Checkbox,
                                          size: 48,
                                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedCategoryFilter != null
                                              ? 'No hay resultados'
                                              : 'No tienes tareas',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedCategoryFilter != null
                                              ? 'Prueba con otros filtros'
                                              : 'Crea tu primera tarea para comenzar',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: TextStyle(
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar tareas...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          prefixIcon: Icon(
            RadixIcons.Magnifying_Glass,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            size: 18,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(
                    RadixIcons.Cross_2,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    size: 16,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
          ),
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
    final accentColor = Theme.of(context).colorScheme.primary;

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
                        RadixIcons.Target,
                        '$goalsCompleted/$goalsCount',
                        'Metas',
                        isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        RadixIcons.Checkbox,
                        '$tasksCompleted/${tasksOnly.length}',
                        'Tareas',
                        isDark,
                      ),
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

  Widget _buildMetricItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
              child: Icon(
                RadixIcons.Person,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                size: 22,
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
            Icon(
              RadixIcons.Chevron_Right,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              size: 20,
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
        child: const Icon(RadixIcons.Trash, color: AppColors.destructive),
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
                      ? Icon(RadixIcons.Check, size: 14, color: Theme.of(context).colorScheme.onPrimary)
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
                              Icon(category.icon, size: 12, color: accentColor),
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
          onPressed: () => widget.onSave(_value),
        ),
      ],
    );
  }
}
