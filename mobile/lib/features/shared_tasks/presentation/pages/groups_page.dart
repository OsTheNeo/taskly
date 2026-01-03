import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:radix_icons/radix_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/settings/settings_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/task_category.dart';
import '../../../../shared/widgets/task_form.dart';
import '../../../../shared/widgets/ui/ui.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data
  final List<Map<String, dynamic>> _groups = [
    {
      'id': '1',
      'name': 'Casa',
      'members': 3,
      'tasks': 5,
      'icon': '🏠',
    },
  ];

  final List<Map<String, dynamic>> _personalTasks = [
    {'id': '1', 'title': 'Leer 30 minutos', 'recurrence': 'Diario', 'type': 'goal'},
    {'id': '2', 'title': 'Ejercicio', 'recurrence': 'Diario', 'type': 'goal'},
    {'id': '3', 'title': 'Meditar', 'recurrence': 'Diario', 'type': 'goal'},
    {'id': '4', 'title': 'Revisar correos', 'recurrence': 'Diario', 'type': 'task'},
  ];

  SettingsCubit get _settingsCubit => getIt<SettingsCubit>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          l10n.myTasks,
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showAddSheet(context, l10n),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                RadixIcons.Plus,
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                size: 20,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
          unselectedLabelColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          indicatorColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
          tabs: [
            Tab(text: l10n.personalTasks),
            Tab(text: l10n.groups),
            const Tab(text: 'Categorías'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(isDark, l10n),
          _buildGroupsTab(isDark, l10n),
          _buildCategoriesTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(bool isDark, S l10n) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    if (_personalTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPersonalTasks,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: l10n.createTask,
              size: AppButtonSize.sm,
              onPressed: () => _showAddSheet(context, l10n),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomPadding,
      ),
      itemCount: _personalTasks.length,
      itemBuilder: (context, index) {
        final task = _personalTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTaskItem(task, isDark),
        );
      },
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, bool isDark) {
    final isGoal = task['type'] == 'goal' || task['isGoal'] == true;
    final categoryId = task['categoryId'] as String? ?? 'personal';
    final category = PredefinedCategories.getById(categoryId);
    final accentColor = category.accentColor;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              isGoal ? RadixIcons.Target : category.icon,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      RadixIcons.Calendar,
                      size: 12,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task['recurrence'] as String? ?? 'Diario',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                    if (isGoal) ...[
                      const SizedBox(width: 12),
                      Icon(
                        RadixIcons.Target,
                        size: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task['target'] ?? 1} ${task['unit'] ?? 'min'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            onSelected: (value) => _handleTaskAction(value, task),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab(bool isDark, S l10n) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return ListView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomPadding,
      ),
      children: [
        // My groups
        ..._groups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGroupCard(group, isDark, l10n),
            )),

        const SizedBox(height: 16),

        // Create or join group
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 40,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.createOrJoinGroup,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.shareTasksWithOthers,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.createGroup,
                      size: AppButtonSize.sm,
                      onPressed: () => _showCreateGroupSheet(context, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: l10n.join,
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.outline,
                      onPressed: () => _showJoinGroupSheet(context, l10n),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(bool isDark, S l10n) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: _settingsCubit,
      builder: (context, settings) {
        return ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomPadding,
          ),
          children: [
            // Header with add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Predefinidas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddCategorySheet(context, isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          RadixIcons.Plus,
                          size: 14,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nueva',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Predefined categories
            ...PredefinedCategories.all.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCategoryCard(cat, isDark, false),
            )),

            if (settings.customCategories.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Personalizadas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              ...settings.customCategories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCategoryCard(cat, isDark, true),
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(TaskCategory category, bool isDark, bool canDelete) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category.icon,
              color: category.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: () => _settingsCubit.deleteCategory(category.id),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  RadixIcons.Trash,
                  size: 16,
                  color: AppColors.destructive,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AddCategorySheet(
        isDark: isDark,
        onSave: (category) {
          _settingsCubit.addCategory(category);
        },
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, bool isDark, S l10n) {
    final iconColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final bgColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return AppCard(
      onTap: () => _showGroupDetail(context, group, l10n),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Center(
              child: Icon(
                RadixIcons.Home,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.nMembers(group['members'] as int),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.nTasks(group['tasks'] as int),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              RadixIcons.Share_1,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            onPressed: () => _showQrCodeSheet(context, group, l10n),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  void _showQrCodeSheet(BuildContext context, Map<String, dynamic> group, S l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupCode = 'taskly://group/${group['id']}';

    AppBottomSheet.show(
      context: context,
      title: l10n.inviteMembers,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: groupCode,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            group['name'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shareThisCode,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.groupCode}: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                Text(
                  group['id'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTaskAction(String action, Map<String, dynamic> task) {
    final l10n = S.of(context)!;
    if (action == 'delete') {
      setState(() {
        _personalTasks.removeWhere((t) => t['id'] == task['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada')),
      );
    } else if (action == 'edit') {
      // Show edit sheet
      _showEditTaskSheet(context, task, l10n);
    }
  }

  void _showEditTaskSheet(BuildContext context, Map<String, dynamic> task, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: 'Editar tarea',
      child: _EditPersonalTaskForm(
        task: task,
        onSave: (updatedTask) {
          setState(() {
            final index = _personalTasks.indexWhere((t) => t['id'] == task['id']);
            if (index != -1) {
              _personalTasks[index] = updatedTask;
            }
          });
        },
      ),
    );
  }

  void _showGroupDetail(BuildContext context, Map<String, dynamic> group, S l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final bgColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    AppBottomSheet.show(
      context: context,
      title: group['name'] as String,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                RadixIcons.Home,
                size: 32,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${group['members']} miembros • ${group['tasks']} tareas',
            style: TextStyle(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: l10n.inviteMembers,
            fullWidth: true,
            icon: RadixIcons.Share_1,
            onPressed: () {
              Navigator.pop(context);
              _showQrCodeSheet(context, group, l10n);
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Ver tareas del grupo',
            fullWidth: true,
            variant: AppButtonVariant.outline,
            icon: RadixIcons.Checkbox,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: l10n.newTask,
      child: TaskForm(
        onSave: (data) {
          setState(() {
            _personalTasks.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'title': data.title,
              'recurrence': _getRecurrenceLabel(data.recurrence),
              'type': data.isGoal ? 'goal' : 'task',
              'isGoal': data.isGoal,
              'target': data.targetValue ?? 1,
              'unit': data.targetUnit ?? 'min',
              'categoryId': data.category?.id ?? 'personal',
              'isPersonal': data.isPersonal,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea creada')),
          );
        },
      ),
    );
  }

  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Diario';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.biweekly:
        return 'Quincenal';
      case RecurrenceType.monthly:
        return 'Mensual';
      case RecurrenceType.custom:
        return 'Personalizado';
      case RecurrenceType.none:
        return 'Una vez';
    }
  }

  void _showCreateGroupSheet(BuildContext context, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: l10n.createGroup,
      child: _CreateGroupForm(
        onSave: (group) {
          setState(() {
            _groups.add(group);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grupo creado')),
          );
        },
      ),
    );
  }

  void _showJoinGroupSheet(BuildContext context, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: l10n.joinGroup,
      child: _JoinGroupForm(
        onJoin: (groupId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Uniéndose al grupo: $groupId')),
          );
        },
      ),
    );
  }
}

class _CreateGroupForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _CreateGroupForm({required this.onSave});

  @override
  State<_CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<_CreateGroupForm> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          label: l10n.groupName,
          placeholder: l10n.groupNamePlaceholder,
          controller: _nameController,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: l10n.createGroup,
          fullWidth: true,
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': _nameController.text,
                'members': 1,
                'tasks': 0,
                'icon': '📋',
              });
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

class _JoinGroupForm extends StatefulWidget {
  final Function(String) onJoin;

  const _JoinGroupForm({required this.onJoin});

  @override
  State<_JoinGroupForm> createState() => _JoinGroupFormState();
}

class _JoinGroupFormState extends State<_JoinGroupForm> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Scan button
        GestureDetector(
          onTap: () => _openQrScanner(context, l10n),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  RadixIcons.Camera,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scanQrCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orContinueWithEmail.replaceAll('email', 'codigo'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppInput(
          label: l10n.invitationCode,
          placeholder: l10n.enterCode,
          controller: _codeController,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: l10n.join,
          fullWidth: true,
          onPressed: () {
            if (_codeController.text.isNotEmpty) {
              widget.onJoin(_codeController.text);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  void _openQrScanner(BuildContext context, S l10n) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QrScannerPage(
          l10n: l10n,
          onJoin: widget.onJoin,
        ),
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  final S l10n;
  final Function(String) onJoin;

  const _QrScannerPage({required this.l10n, required this.onJoin});

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.l10n.scanQrCode),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value != null && value.startsWith('taskly://group/')) {
                  _hasScanned = true;
                  final groupId = value.replaceFirst('taskly://group/', '');
                  _handleQrCode(context, groupId);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.l10n.pointCameraAtQr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQrCode(BuildContext context, String groupId) {
    Navigator.pop(context);
    widget.onJoin(groupId);
  }
}

class _EditPersonalTaskForm extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onSave;

  const _EditPersonalTaskForm({required this.task, required this.onSave});

  @override
  State<_EditPersonalTaskForm> createState() => _EditPersonalTaskFormState();
}

class _EditPersonalTaskFormState extends State<_EditPersonalTaskForm> {
  late TextEditingController _titleController;
  late String _recurrence;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title'] as String);
    _recurrence = _getRecurrenceValue(widget.task['recurrence'] as String);
  }

  String _getRecurrenceValue(String label) {
    switch (label) {
      case 'Diario': return 'daily';
      case 'Semanal': return 'weekly';
      case 'Mensual': return 'monthly';
      case 'Una vez': return 'once';
      default: return 'daily';
    }
  }

  String _getRecurrenceLabel(String value) {
    switch (value) {
      case 'daily': return 'Diario';
      case 'weekly': return 'Semanal';
      case 'monthly': return 'Mensual';
      case 'once': return 'Una vez';
      default: return value;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          label: l10n.title,
          placeholder: l10n.titlePlaceholder,
          controller: _titleController,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.frequency,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildRecurrenceChip(l10n.daily, 'daily', isDark),
                _buildRecurrenceChip(l10n.weekly, 'weekly', isDark),
                _buildRecurrenceChip(l10n.monthly, 'monthly', isDark),
                _buildRecurrenceChip(l10n.once, 'once', isDark),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Guardar cambios',
          fullWidth: true,
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave({
                ...widget.task,
                'title': _titleController.text,
                'recurrence': _getRecurrenceLabel(_recurrence),
              });
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecurrenceChip(String label, String value, bool isDark) {
    final isSelected = _recurrence == value;

    return GestureDetector(
      onTap: () => setState(() => _recurrence = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.secondaryDark : AppColors.secondary),
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.primaryForeground
                : (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final bool isDark;
  final Function(TaskCategory) onSave;

  const _AddCategorySheet({required this.isDark, required this.onSave});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 1;
  int _selectedIconIndex = 0;

  final List<IconData> _availableIcons = CategoryIcons.icons.values.toList();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = CategoryColors.accentColors[_selectedColorIndex];
    final selectedIcon = _availableIcons[_selectedIconIndex];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nueva categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    RadixIcons.Cross_2,
                    color: widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preview card
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selectedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(selectedIcon, color: selectedColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _nameController.text.isEmpty ? 'Mi categoría' : _nameController.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            Text(
              'Nombre',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Nombre de la categoría',
                hintStyle: TextStyle(
                  color: widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: widget.isDark ? AppColors.secondaryDark : AppColors.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Icon selection
            Text(
              'Icono',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_availableIcons.length, (index) {
                final icon = _availableIcons[index];
                final isSelected = _selectedIconIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.2)
                          : (widget.isDark ? AppColors.mutedDark : AppColors.muted),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected
                          ? selectedColor
                          : (widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Color selection
            Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(CategoryColors.accentColors.length, (index) {
                final color = CategoryColors.accentColors[index];
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: widget.isDark ? Colors.white : Colors.black,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            RadixIcons.Check,
                            size: 16,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Create button
            AppButton(
              label: 'Crear categoría',
              fullWidth: true,
              onPressed: _nameController.text.isEmpty
                  ? null
                  : () {
                      final newCategory = TaskCategory(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: _nameController.text,
                        icon: _availableIcons[_selectedIconIndex],
                        accentColor: CategoryColors.accentColors[_selectedColorIndex],
                      );
                      widget.onSave(newCategory);
                      Navigator.pop(context);
                    },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
