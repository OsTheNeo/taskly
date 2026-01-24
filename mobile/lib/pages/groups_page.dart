import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:radix_icons/radix_icons.dart';
import 'package:signals/signals_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/task_category.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/injection.dart';
import '../state/settings_state.dart' as settings;
import '../widgets/task_form.dart';
import '../widgets/ui/ui.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  // Data from Supabase
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _personalTasks = [];
  List<Map<String, dynamic>> _customCategories = [];

  bool _isLoadingGroups = true;
  bool _isLoadingTasks = true;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPersonalTasks(),
      _loadGroups(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadPersonalTasks() async {
    if (_currentUser == null) return;

    setState(() => _isLoadingTasks = true);
    try {
      final tasks = await _dataService.getTasks(_currentUser!.uid);
      setState(() {
        _personalTasks = tasks;
        _isLoadingTasks = false;
      });
    } catch (e) {
      debugPrint('[GroupsPage] Error loading tasks: $e');
      setState(() => _isLoadingTasks = false);
    }
  }

  Future<void> _loadGroups() async {
    if (_currentUser == null) return;

    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _dataService.getHouseholds(_currentUser!.uid);
      setState(() {
        _groups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      debugPrint('[GroupsPage] Error loading groups: $e');
      setState(() => _isLoadingGroups = false);
    }
  }

  Future<void> _loadCategories() async {
    if (_currentUser == null) return;

    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _dataService.getCategories(_currentUser!.uid);
      setState(() {
        _customCategories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('[GroupsPage] Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
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
            const Tab(text: 'Categorias'),
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

    if (_isLoadingTasks) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return RefreshIndicator(
      onRefresh: _loadPersonalTasks,
      child: ListView.builder(
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
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, bool isDark) {
    final isGoal = task['task_type'] == 'goal';
    final categoryId = task['color'] as String? ?? 'personal';
    final category = PredefinedCategories.getById(categoryId);
    final accentColor = category.accentColor;

    String recurrenceLabel = 'Una vez';
    switch (task['recurrence']) {
      case 'daily':
        recurrenceLabel = 'Diario';
        break;
      case 'weekly':
        recurrenceLabel = 'Semanal';
        break;
      case 'biweekly':
        recurrenceLabel = 'Quincenal';
        break;
      case 'monthly':
        recurrenceLabel = 'Mensual';
        break;
    }

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
                      recurrenceLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                    if (isGoal && task['has_progress'] == true) ...[
                      const SizedBox(width: 12),
                      Icon(
                        RadixIcons.Target,
                        size: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(task['progress_target'] as num?)?.toInt() ?? 1} ${task['progress_unit'] ?? 'min'}',
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

    if (_isLoadingGroups) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomPadding,
        ),
        children: [
          // My groups
          if (_groups.isNotEmpty)
            ..._groups.map((membership) {
              final group = membership['household'] as Map<String, dynamic>?;
              if (group == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGroupCard(group, membership['role'] as String?, isDark, l10n),
              );
            }),

          if (_groups.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  'No perteneces a ningun grupo',
                  style: TextStyle(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),

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
      ),
    );
  }

  Widget _buildCategoriesTab(bool isDark, S l10n) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Watch((context) {
      final localCustomCats = settings.customCategories.value;
      return RefreshIndicator(
        onRefresh: _loadCategories,
        child: ListView(
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
              child: _buildCategoryCard(cat, isDark, false, null),
            )),

            // Custom categories from Supabase
            if (_customCategories.isNotEmpty || localCustomCats.isNotEmpty) ...[
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
              // Supabase categories
              ..._customCategories.map((catData) {
                final cat = TaskCategory(
                  id: catData['id'] as String,
                  name: catData['name'] as String,
                  icon: CategoryIcons.icons[catData['icon']] ?? RadixIcons.Star,
                  accentColor: CategoryColors.fromHex(catData['color'] as String?) ?? AppColors.primary,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryCard(cat, isDark, true, catData['id'] as String),
                );
              }),
              // Local categories (for offline support)
              ...localCustomCats.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCategoryCard(cat, isDark, true, null),
              )),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCategoryCard(TaskCategory category, bool isDark, bool canDelete, String? supabaseId) {
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
              onTap: () => _deleteCategory(category.id, supabaseId),
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

  Future<void> _deleteCategory(String localId, String? supabaseId) async {
    if (supabaseId != null) {
      // Delete from Supabase
      final success = await _dataService.deleteCategory(supabaseId);
      if (success) {
        await _loadCategories();
      }
    } else {
      // Delete local
      settings.deleteCategory(localId);
    }
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
        onSave: (category, iconKey, colorHex) async {
          if (_currentUser != null) {
            // Save to Supabase
            await _dataService.createCategory(
              visitorId: _currentUser!.uid,
              name: category.name,
              icon: iconKey,
              color: colorHex,
            );
            await _loadCategories();
          } else {
            // Save locally
            settings.addCategory(category);
          }
        },
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, String? role, bool isDark, S l10n) {
    final iconColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final bgColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final inviteCode = group['invite_code'] as String? ?? '';

    return AppCard(
      onTap: () => _showGroupDetail(context, group, role, l10n),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group['name'] as String? ?? 'Grupo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    if (role == 'owner')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Codigo: $inviteCode',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
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
    final inviteCode = group['invite_code'] as String? ?? group['id'] as String;

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
              data: 'taskly://group/$inviteCode',
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
            group['name'] as String? ?? 'Grupo',
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
                  inviteCode,
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

  Future<void> _handleTaskAction(String action, Map<String, dynamic> task) async {
    if (action == 'delete') {
      final success = await _dataService.deleteTask(task['id'] as String);
      if (success) {
        await _loadPersonalTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea eliminada')),
          );
        }
      }
    } else if (action == 'edit') {
      _showEditTaskSheet(context, task);
    }
  }

  void _showEditTaskSheet(BuildContext context, Map<String, dynamic> task) {
    final l10n = S.of(context)!;
    AppBottomSheet.show(
      context: context,
      title: 'Editar tarea',
      child: TaskForm(
        initialData: TaskFormData(
          title: task['title'] as String,
          description: task['description'] as String?,
          isGoal: task['task_type'] == 'goal',
          targetValue: (task['progress_target'] as num?)?.toInt(),
          targetUnit: task['progress_unit'] as String?,
          category: PredefinedCategories.getById(task['color'] as String? ?? 'personal'),
          recurrence: _parseRecurrence(task['recurrence'] as String?),
        ),
        onSave: (data) async {
          if (_currentUser == null) return;

          await _dataService.updateTask(
            taskId: task['id'] as String,
            title: data.title,
            description: data.description,
          );

          await _loadPersonalTasks();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarea actualizada')),
            );
          }
        },
      ),
    );
  }

  RecurrenceType _parseRecurrence(String? value) {
    switch (value) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'biweekly':
        return RecurrenceType.biweekly;
      case 'monthly':
        return RecurrenceType.monthly;
      case 'custom':
        return RecurrenceType.custom;
      default:
        return RecurrenceType.none;
    }
  }

  void _showGroupDetail(BuildContext context, Map<String, dynamic> group, String? role, S l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final bgColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    AppBottomSheet.show(
      context: context,
      title: group['name'] as String? ?? 'Grupo',
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
          if (role != null)
            Text(
              'Tu rol: ${role == 'owner' ? 'Administrador' : 'Miembro'}',
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
        onSave: (data) async {
          if (_currentUser == null) return;

          await _dataService.createTask(
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

          await _loadPersonalTasks();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarea creada')),
            );
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

  void _showCreateGroupSheet(BuildContext context, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: l10n.createGroup,
      child: _CreateGroupForm(
        onSave: (name, description) async {
          if (_currentUser == null) return;

          final group = await _dataService.createHousehold(
            visitorId: _currentUser!.uid,
            name: name,
            description: description,
          );

          if (group != null) {
            await _loadGroups();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grupo creado')),
              );
            }
          }
        },
      ),
    );
  }

  void _showJoinGroupSheet(BuildContext context, S l10n) {
    AppBottomSheet.show(
      context: context,
      title: l10n.joinGroup,
      child: _JoinGroupForm(
        onJoin: (inviteCode) async {
          if (_currentUser == null) return;

          final group = await _dataService.joinHousehold(
            visitorId: _currentUser!.uid,
            inviteCode: inviteCode,
          );

          if (group != null) {
            await _loadGroups();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Te uniste a "${group['name']}"')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Codigo de invitacion no valido'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _CreateGroupForm extends StatefulWidget {
  final Function(String name, String? description) onSave;

  const _CreateGroupForm({required this.onSave});

  @override
  State<_CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<_CreateGroupForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
        const SizedBox(height: 16),
        AppInput(
          label: 'Descripcion (opcional)',
          placeholder: 'Describe el grupo...',
          controller: _descriptionController,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: l10n.createGroup,
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: () async {
            if (_nameController.text.isEmpty) return;

            setState(() => _isLoading = true);

            await widget.onSave(
              _nameController.text,
              _descriptionController.text.isEmpty ? null : _descriptionController.text,
            );

            if (mounted) {
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
  bool _isLoading = false;

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
                'o ingresa el codigo',
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
          isLoading: _isLoading,
          onPressed: () async {
            if (_codeController.text.isEmpty) return;

            setState(() => _isLoading = true);

            await widget.onJoin(_codeController.text.trim());

            if (mounted) {
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
                  final inviteCode = value.replaceFirst('taskly://group/', '');
                  _handleQrCode(context, inviteCode);
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

  void _handleQrCode(BuildContext context, String inviteCode) {
    Navigator.pop(context);
    widget.onJoin(inviteCode);
  }
}

class _AddCategorySheet extends StatefulWidget {
  final bool isDark;
  final Function(TaskCategory, String iconKey, String colorHex) onSave;

  const _AddCategorySheet({required this.isDark, required this.onSave});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 1;
  int _selectedIconIndex = 0;
  bool _isLoading = false;

  final List<String> _iconKeys = CategoryIcons.icons.keys.toList();
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
                  'Nueva categoria',
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
                      _nameController.text.isEmpty ? 'Mi categoria' : _nameController.text,
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
                hintText: 'Nombre de la categoria',
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
              label: 'Crear categoria',
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: _nameController.text.isEmpty
                  ? null
                  : () async {
                      setState(() => _isLoading = true);

                      final newCategory = TaskCategory(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: _nameController.text,
                        icon: _availableIcons[_selectedIconIndex],
                        accentColor: CategoryColors.accentColors[_selectedColorIndex],
                      );

                      final iconKey = _iconKeys[_selectedIconIndex];
                      final colorHex = CategoryColors.toHex(CategoryColors.accentColors[_selectedColorIndex]);

                      await widget.onSave(newCategory, iconKey, colorHex);

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
