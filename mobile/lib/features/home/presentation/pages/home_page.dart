import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:radix_icons/radix_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/task_category.dart';
import '../../../../shared/widgets/ui/ui.dart';
import '../../../../shared/widgets/task_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService get _authService => getIt<AuthService>();
  User? get _currentUser => _authService.currentUser;

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Leer 30 minutos',
      'completed': false,
      'isGoal': true,
      'progress': 15,
      'target': 30,
      'unit': 'min',
      'categoryId': 'study',
      'accentColor': null,
    },
    {
      'id': '2',
      'title': 'Ejercicio',
      'completed': false,
      'isGoal': true,
      'progress': 0,
      'target': 45,
      'unit': 'min',
      'categoryId': 'fitness',
      'accentColor': null,
    },
    {
      'id': '3',
      'title': 'Meditar',
      'completed': true,
      'isGoal': false,
      'categoryId': 'mindfulness',
      'accentColor': null,
    },
    {
      'id': '4',
      'title': 'Revisar correos',
      'completed': false,
      'isGoal': false,
      'categoryId': 'work',
      'accentColor': null,
    },
  ];

  // Group tasks summary
  final int _groupTasksTotal = 5;
  final int _groupTasksCompleted = 2;

  int get _completedCount => _tasks.where((t) => t['completed'] == true).length;
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Card
                    _buildProgressCard(isDark, l10n),
                    const SizedBox(height: 20),

                    // Group Tasks Shortcut
                    _buildGroupTasksShortcut(isDark, l10n),
                    const SizedBox(height: 24),

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
                    ..._tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildTaskCard(task, isDark),
                    )),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark, S l10n) {
    final goalsCount = _tasks.where((t) => t['isGoal'] == true).length;
    final goalsCompleted = _tasks.where((t) => t['isGoal'] == true && t['completed'] == true).length;
    final tasksOnly = _tasks.where((t) => t['isGoal'] != true).length;
    final tasksCompleted = _tasks.where((t) => t['isGoal'] != true && t['completed'] == true).length;
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
                        '$tasksCompleted/$tasksOnly',
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
    final isCompleted = task['completed'] as bool;
    final isGoal = task['isGoal'] == true;
    final progress = task['progress'] as int? ?? 0;
    final target = task['target'] as int? ?? 1;
    final unit = task['unit'] as String? ?? '';
    final themeAccent = Theme.of(context).colorScheme.primary;

    // Get category
    final categoryId = task['categoryId'] as String? ?? 'personal';
    final category = PredefinedCategories.getById(categoryId);
    final customColor = task['accentColor'] as Color?;
    final accentColor = customColor ?? category.accentColor;

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
      onDismissed: (_) {
        setState(() {
          _tasks.removeWhere((t) => t['id'] == task['id']);
        });
      },
      child: GestureDetector(
        onTap: () {
          if (isGoal && !isCompleted) {
            _showProgressSheet(context, task);
          } else {
            setState(() {
              task['completed'] = !isCompleted;
            });
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
                onTap: () {
                  setState(() {
                    task['completed'] = !isCompleted;
                    if (isGoal && !isCompleted) {
                      task['progress'] = target;
                    }
                  });
                },
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
                      : isGoal
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
                    if (isGoal && !isCompleted) ...[
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

  void _showAddTaskSheet(BuildContext context) {
    final l10n = S.of(context)!;
    AppBottomSheet.show(
      context: context,
      title: l10n.newTask,
      child: TaskForm(
        onSave: (data) {
          setState(() {
            _tasks.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'title': data.title,
              'completed': false,
              'isGoal': data.isGoal,
              'progress': 0,
              'target': data.targetValue ?? 1,
              'unit': data.targetUnit ?? 'min',
              'categoryId': data.category?.id ?? 'personal',
              'accentColor': data.customAccentColor,
            });
          });
        },
      ),
    );
  }

  void _showProgressSheet(BuildContext context, Map<String, dynamic> task) {
    final l10n = S.of(context)!;
    AppBottomSheet.show(
      context: context,
      title: l10n.logProgress,
      child: ProgressForm(
        taskTitle: task['title'] as String,
        currentProgress: task['progress'] as int,
        target: task['target'] as int,
        unit: task['unit'] as String? ?? 'min',
        onSave: (value) {
          setState(() {
            task['progress'] = value;
            if (value >= (task['target'] as int)) {
              task['completed'] = true;
            }
          });
          Navigator.pop(context);
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
