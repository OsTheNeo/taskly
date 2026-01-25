import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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

    try {
      final categories = await _dataService.getCategories(_currentUser!.uid);
      setState(() {
        _customCategories = categories;
      });
    } catch (e) {
      debugPrint('[GroupsPage] Error loading categories: $e');
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
          l10n.myTasks.toUpperCase(),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DuotoneIcon(
                DuotoneIcon.plus,
                size: 14,
                strokeColor: isDark ? Colors.black : Colors.white,
                fillColor: isDark ? Colors.black : Colors.white,
                accentColor: settings.accentColor,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFolderTab(
                  index: 0,
                  icon: DuotoneIcon.user,
                  label: l10n.personalTasks,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFolderTab(
                  index: 1,
                  icon: DuotoneIcon.users,
                  label: l10n.groups,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFolderTab(
                  index: 2,
                  icon: DuotoneIcon.layers,
                  label: 'Categorias',
                  isDark: isDark,
                ),
              ],
            ),
          ),
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

  Widget _buildFolderTab({
    required int index,
    required String icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _tabController.index == index;
    final accentColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? AppColors.secondaryDark : AppColors.secondary),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DuotoneIcon(
                icon,
                size: 16,
                strokeColor: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                fillColor: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                accentColor: accentColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
            DuotoneIcon(
              DuotoneIcon.clipboardCheck,
              size: 64,
              accentColor: settings.accentColor,
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
              iconName: DuotoneIcon.plus,
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
            child: Center(
              child: DuotoneIcon(
                isGoal ? DuotoneIcon.target : category.iconName,
                color: accentColor,
                accentColor: accentColor,
                size: 20,
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
                    DuotoneIcon(
                      DuotoneIcon.calendar,
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
                      DuotoneIcon(
                        DuotoneIcon.target,
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
            icon: DuotoneIcon(
              DuotoneIcon.sliders,
              size: 20,
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
                DuotoneIcon(
                  DuotoneIcon.userPlus,
                  size: 40,
                  accentColor: settings.accentColor,
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
                        iconName: DuotoneIcon.plus,
                        onPressed: () => _showCreateGroupSheet(context, l10n),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: l10n.join,
                        size: AppButtonSize.sm,
                        variant: AppButtonVariant.outline,
                        iconName: DuotoneIcon.userPlus,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DuotoneIcon(
                          DuotoneIcon.plus,
                          size: 12,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nueva',
                          style: TextStyle(
                            fontSize: 11,
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

            // Custom categories first (personalizadas arriba)
            if (_customCategories.isNotEmpty || localCustomCats.isNotEmpty) ...[
              Text(
                'Mis categorías',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              // Grid of custom categories
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  // Supabase categories
                  ..._customCategories.map((catData) {
                    final cat = TaskCategory(
                      id: catData['id'] as String,
                      name: catData['name'] as String,
                      iconName: CategoryIcons.fromString(catData['icon'] as String?),
                      accentColor: CategoryColors.fromHex(catData['color'] as String?) ?? AppColors.primary,
                    );
                    return _buildCategoryTile(cat, isDark, true, catData['id'] as String);
                  }),
                  // Local categories
                  ...localCustomCats.map((cat) => _buildCategoryTile(cat, isDark, true, null)),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Predefined categories (predefinidas abajo)
            Text(
              'Predefinidas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: PredefinedCategories.all.map((cat) =>
                _buildCategoryTile(cat, isDark, false, null)
              ).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryTile(TaskCategory category, bool isDark, bool canEdit, String? supabaseId) {
    return GestureDetector(
      onTap: canEdit ? () => _showEditCategorySheet(context, category, supabaseId, isDark) : null,
      onLongPress: canEdit ? () => _confirmDeleteCategory(category.id, supabaseId, isDark) : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: category.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: category.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DuotoneIcon(
              category.iconName,
              color: category.accentColor,
              accentColor: category.accentColor,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(String localId, String? supabaseId, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: Text(
          'Eliminar categoría',
          style: TextStyle(color: isDark ? AppColors.foregroundDark : AppColors.foreground),
        ),
        content: Text(
          '¿Estás seguro de eliminar esta categoría?',
          style: TextStyle(color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCategory(localId, supabaseId);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }

  void _showEditCategorySheet(BuildContext context, TaskCategory category, String? supabaseId, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditCategorySheet(
        isDark: isDark,
        category: category,
        supabaseId: supabaseId,
        onSave: (updatedCategory, iconKey, colorHex) async {
          if (supabaseId != null && _currentUser != null) {
            // Update in Supabase
            await _dataService.updateCategory(
              categoryId: supabaseId,
              name: updatedCategory.name,
              icon: iconKey,
              color: colorHex,
            );
            await _loadCategories();
          } else {
            // Update locally
            settings.updateCategory(updatedCategory);
          }
        },
        onDelete: () => _deleteCategory(category.id, supabaseId),
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
              child: DuotoneIcon(
                DuotoneIcon.home,
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
            icon: DuotoneIcon(
              DuotoneIcon.link,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            onPressed: () => _showQrCodeSheet(context, group, l10n),
          ),
          DuotoneIcon(
            DuotoneIcon.chevronRight,
            size: 20,
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
            SnackBar(
              content: const Text('Tarea eliminada'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 80,
                left: 16,
                right: 16,
              ),
            ),
          );
        }
      }
    } else if (action == 'edit') {
      _showEditTaskSheet(context, task);
    }
  }

  void _showEditTaskSheet(BuildContext context, Map<String, dynamic> task) {
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
              SnackBar(
                content: const Text('Tarea actualizada'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                  left: 16,
                  right: 16,
                ),
              ),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailPage(
          group: group,
          role: role,
          onGroupUpdated: _loadGroups,
        ),
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
              SnackBar(
                content: const Text('Tarea creada'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                  left: 16,
                  right: 16,
                ),
              ),
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
                SnackBar(
                  content: const Text('Grupo creado'),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    left: 16,
                    right: 16,
                  ),
                ),
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
                SnackBar(
                  content: Text('Te uniste a "${group['name']}"'),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    left: 16,
                    right: 16,
                  ),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Codigo de invitacion no valido'),
                  backgroundColor: AppColors.destructive,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    left: 16,
                    right: 16,
                  ),
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
          iconName: DuotoneIcon.plus,
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
                DuotoneIcon(
                  DuotoneIcon.camera,
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
          iconName: DuotoneIcon.userPlus,
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
  final List<String> _availableIcons = CategoryIcons.icons.values.toList();

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
                  icon: DuotoneIcon(
                    DuotoneIcon.x,
                    size: 20,
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
                      child: Center(
                        child: DuotoneIcon(selectedIcon, color: selectedColor, accentColor: selectedColor, size: 24),
                      ),
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
                    child: Center(
                      child: DuotoneIcon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? selectedColor
                            : (widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                        accentColor: isSelected ? selectedColor : null,
                      ),
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
                        ? DuotoneIcon(
                            DuotoneIcon.check,
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
                        iconName: _availableIcons[_selectedIconIndex],
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

// ============================================================================
// Group Detail Page
// ============================================================================

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> group;
  final String? role;
  final VoidCallback onGroupUpdated;

  const GroupDetailPage({
    super.key,
    required this.group,
    required this.role,
    required this.onGroupUpdated,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  bool get _isAdmin => widget.role == 'owner';

  String _selectedIcon = DuotoneIcon.home;
  Color _selectedColor = AppColors.primary;
  List<Map<String, dynamic>> _groupTasks = [];
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.group['icon'] as String? ?? DuotoneIcon.home;
    final colorHex = widget.group['color'] as String?;
    _selectedColor = colorHex != null
        ? CategoryColors.fromHex(colorHex) ?? AppColors.primary
        : AppColors.primary;
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);

    try {
      final householdId = widget.group['id'] as String?;
      if (householdId == null || _currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load group tasks from Supabase
      final tasks = await _dataService.getGroupTasks(
        householdId: householdId,
      );

      // Load group members
      final members = await _dataService.getHouseholdMembers(
        householdId: householdId,
      );

      setState(() {
        _groupTasks = tasks;
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[GroupDetailPage] Error loading group data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;
    final groupName = widget.group['name'] as String? ?? 'Grupo';
    final inviteCode = widget.group['invite_code'] as String? ?? '';
    final description = widget.group['description'] as String?;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: DuotoneIcon(
            DuotoneIcon.chevronLeft,
            size: 22,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          groupName.toUpperCase(),
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: DuotoneIcon(
                DuotoneIcon.gear,
                size: 22,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              onPressed: () => _showGroupSettings(isDark),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(isDark, l10n),
        backgroundColor: _selectedColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva tarea',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroupData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Group header card
            _buildGroupHeader(isDark, groupName, description, inviteCode),
            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(isDark, l10n),
            const SizedBox(height: 24),

            // Group tasks section
            _buildSectionHeader(isDark, 'Tareas del grupo', _groupTasks.length),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_groupTasks.isEmpty)
              _buildEmptyTasksState(isDark, l10n)
            else
              ..._groupTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildGroupTaskItem(task, isDark),
                  )),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(bool isDark, String name, String? description, String inviteCode) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _isAdmin ? () => _showIconSelector(isDark) : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: DuotoneIcon(
                          _selectedIcon,
                          size: 32,
                          accentColor: _selectedColor,
                        ),
                      ),
                      if (_isAdmin)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: DuotoneIcon(
                              DuotoneIcon.sliders,
                              size: 10,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isAdmin
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark ? AppColors.mutedDark : AppColors.muted),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isAdmin ? 'Administrador' : 'Miembro',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isAdmin
                              ? AppColors.primary
                              : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                DuotoneIcon(
                  DuotoneIcon.link,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Codigo de invitacion',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        inviteCode.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Copiar',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    // Copy to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Codigo copiado'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 80,
                          left: 16,
                          right: 16,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, S l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            isDark: isDark,
            icon: DuotoneIcon.userPlus,
            label: 'Invitar',
            onTap: () => _showInviteSheet(isDark, l10n),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            isDark: isDark,
            icon: DuotoneIcon.users,
            label: 'Miembros',
            onTap: () => _showMembersSheet(isDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            isDark: isDark,
            icon: DuotoneIcon.bell,
            label: _notificationsEnabled ? 'Notif. ON' : 'Notif. OFF',
            onTap: () {
              setState(() => _notificationsEnabled = !_notificationsEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_notificationsEnabled
                      ? 'Notificaciones activadas'
                      : 'Notificaciones desactivadas'),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                    left: 16,
                    right: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            DuotoneIcon(
              icon,
              size: 24,
              accentColor: _selectedColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.mutedDark : AppColors.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTasksState(bool isDark, S l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            DuotoneIcon(
              DuotoneIcon.clipboardCheck,
              size: 48,
              accentColor: _selectedColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin tareas en el grupo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Agrega tareas para que todos las vean',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTaskItem(Map<String, dynamic> task, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: DuotoneIcon(
                DuotoneIcon.clipboardCheck,
                size: 20,
                accentColor: _selectedColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task['title'] as String? ?? 'Tarea',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIconSelector(bool isDark) {
    final icons = [
      DuotoneIcon.home,
      DuotoneIcon.users,
      DuotoneIcon.heart,
      DuotoneIcon.star,
      DuotoneIcon.suitcase,
      DuotoneIcon.book,
      DuotoneIcon.sparkle,
      DuotoneIcon.feather,
      DuotoneIcon.camera,
      DuotoneIcon.leaf,
      DuotoneIcon.target,
      DuotoneIcon.clock,
    ];

    String tempIcon = _selectedIcon;
    Color tempColor = _selectedColor;

    AppBottomSheet.show(
      context: context,
      title: 'Personalizar grupo',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: tempColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: tempColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: DuotoneIcon(
                      tempIcon,
                      size: 36,
                      accentColor: tempColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icon label
              Text(
                'Icono',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),

              // Icon grid
              GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: icons.map((icon) {
                  final isSelected = icon == tempIcon;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => tempIcon = icon);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tempColor.withValues(alpha: 0.2)
                            : (isDark ? AppColors.mutedDark : AppColors.muted),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? tempColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: DuotoneIcon(
                          icon,
                          size: 24,
                          accentColor: isSelected ? tempColor : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Color label
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),

              // Color grid - squares with black border
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: CategoryColors.accentColors.map((color) {
                  final isSelected = color.toARGB32() == tempColor.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => tempColor = color);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white : Colors.black,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: DuotoneIcon(
                                DuotoneIcon.check,
                                size: 18,
                                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save button
              AppButton(
                label: 'Guardar cambios',
                fullWidth: true,
                iconName: DuotoneIcon.check,
                onPressed: () async {
                  Navigator.pop(context);

                  // Update local state
                  setState(() {
                    _selectedIcon = tempIcon;
                    _selectedColor = tempColor;
                  });

                  // Save to Supabase
                  final householdId = widget.group['id'] as String?;
                  if (householdId != null) {
                    await _dataService.updateHousehold(
                      householdId: householdId,
                      icon: tempIcon,
                      color: CategoryColors.toHex(tempColor),
                    );
                    widget.onGroupUpdated();
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  void _showGroupSettings(bool isDark) {
    AppBottomSheet.show(
      context: context,
      title: 'Configuracion del grupo',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingsItem(
            isDark: isDark,
            icon: DuotoneIcon.feather,
            label: 'Cambiar nombre',
            onTap: () {
              Navigator.pop(context);
              // TODO: Show rename dialog
            },
          ),
          _buildSettingsItem(
            isDark: isDark,
            icon: DuotoneIcon.layers,
            label: 'Cambiar icono y color',
            onTap: () {
              Navigator.pop(context);
              _showIconSelector(isDark);
            },
          ),
          _buildSettingsItem(
            isDark: isDark,
            icon: DuotoneIcon.userPlus,
            label: 'Gestionar administradores',
            onTap: () {
              Navigator.pop(context);
              _showManageAdminsSheet(isDark);
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            isDark: isDark,
            icon: DuotoneIcon.trash,
            label: 'Eliminar grupo',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show delete confirmation
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required bool isDark,
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.secondaryDark : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            DuotoneIcon(
              icon,
              size: 20,
              color: isDestructive
                  ? AppColors.destructive
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? AppColors.destructive
                      : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                ),
              ),
            ),
            DuotoneIcon(
              DuotoneIcon.chevronRight,
              size: 18,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(bool isDark, S l10n) {
    final inviteCode = widget.group['invite_code'] as String? ?? widget.group['id'] as String;

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
            l10n.shareThisCode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showMembersSheet(bool isDark) {
    AppBottomSheet.show(
      context: context,
      title: 'Miembros del grupo',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay miembros aun',
                style: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            )
          else
            ..._members.map((member) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                    child: Text(
                      (member['display_name'] as String? ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                  title: Text(
                    member['display_name'] as String? ?? 'Usuario',
                    style: TextStyle(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: member['role'] == 'owner'
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member['role'] == 'owner' ? 'Admin' : 'Miembro',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: member['role'] == 'owner'
                            ? AppColors.primary
                            : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showManageAdminsSheet(bool isDark) {
    AppBottomSheet.show(
      context: context,
      title: 'Gestionar administradores',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: settings.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: settings.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                DuotoneIcon(
                  DuotoneIcon.info,
                  size: 20,
                  accentColor: settings.accentColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los administradores pueden agregar tareas, invitar miembros y gestionar el grupo.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay miembros para promover',
                style: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            )
          else
            ..._members.where((m) => m['role'] != 'owner').map((member) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                    child: Text(
                      (member['display_name'] as String? ?? 'U')[0].toUpperCase(),
                    ),
                  ),
                  title: Text(member['display_name'] as String? ?? 'Usuario'),
                  trailing: AppButton(
                    label: 'Hacer admin',
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      // TODO: Implement promote to admin
                      Navigator.pop(context);
                    },
                  ),
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddTaskSheet(bool isDark, S l10n) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    bool isFormValid = false;

    AppBottomSheet.show(
      context: context,
      title: 'Nueva tarea del grupo',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    DuotoneIcon(
                      _selectedIcon,
                      size: 20,
                      accentColor: _selectedColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Esta tarea sera visible para todos los miembros de "${widget.group['name']}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title field
              Text(
                'Nombre de la tarea *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              AppInput(
                controller: titleController,
                placeholder: 'Ej: Limpiar la cocina',
                onChanged: (value) {
                  setModalState(() {
                    isFormValid = value.trim().isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description field (optional)
              Text(
                'Descripcion (opcional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              AppInput(
                controller: descController,
                placeholder: 'Detalles adicionales...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save button
              AppButton(
                label: 'Crear tarea',
                fullWidth: true,
                iconName: DuotoneIcon.plus,
                disabled: !isFormValid,
                onPressed: isFormValid
                    ? () async {
                        Navigator.pop(context);

                        if (_currentUser == null) return;

                        // Create task with household association
                        await _dataService.createTask(
                          visitorId: _currentUser!.uid,
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          taskType: 'task',
                          householdId: widget.group['id'] as String?,
                        );

                        await _loadGroupData();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tarea creada'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom + 80,
                                left: 16,
                                right: 16,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          );
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
}

class _EditCategorySheet extends StatefulWidget {
  final bool isDark;
  final TaskCategory category;
  final String? supabaseId;
  final Function(TaskCategory, String iconKey, String colorHex) onSave;
  final VoidCallback onDelete;

  const _EditCategorySheet({
    required this.isDark,
    required this.category,
    required this.supabaseId,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late TextEditingController _nameController;
  late int _selectedColorIndex;
  late int _selectedIconIndex;
  bool _isLoading = false;

  final List<String> _iconKeys = CategoryIcons.icons.keys.toList();
  final List<String> _availableIcons = CategoryIcons.icons.values.toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);

    // Find current icon index
    _selectedIconIndex = _availableIcons.indexOf(widget.category.iconName);
    if (_selectedIconIndex < 0) _selectedIconIndex = 0;

    // Find current color index
    _selectedColorIndex = CategoryColors.accentColors.indexWhere(
      (c) => c.toARGB32() == widget.category.accentColor.toARGB32(),
    );
    if (_selectedColorIndex < 0) _selectedColorIndex = 0;
  }

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
                  'Editar categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete();
                      },
                      icon: const DuotoneIcon(DuotoneIcon.trash, size: 20, color: AppColors.destructive),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: DuotoneIcon(
                        DuotoneIcon.x,
                        size: 20,
                        color: widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preview
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: selectedColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selectedColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DuotoneIcon(selectedIcon, color: selectedColor, accentColor: selectedColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      _nameController.text.isEmpty ? 'Nombre' : _nameController.text,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selectedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name field
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                filled: true,
                fillColor: widget.isDark ? AppColors.secondaryDark : AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Icon selection
            Text('Icono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_availableIcons.length, (index) {
                final icon = _availableIcons[index];
                final isSelected = _selectedIconIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor.withValues(alpha: 0.2) : (widget.isDark ? AppColors.mutedDark : AppColors.muted),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                    ),
                    child: Center(
                      child: DuotoneIcon(icon, size: 18, color: isSelected ? selectedColor : (widget.isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground), accentColor: isSelected ? selectedColor : null),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Color selection
            Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(CategoryColors.accentColors.length, (index) {
                final color = CategoryColors.accentColors[index];
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: widget.isDark ? Colors.white : Colors.black, width: 3) : null,
                    ),
                    child: isSelected ? Icon(Icons.check, size: 16, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Save button
            AppButton(
              label: 'Guardar cambios',
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: _nameController.text.isEmpty ? null : () async {
                setState(() => _isLoading = true);
                final updatedCategory = TaskCategory(
                  id: widget.category.id,
                  name: _nameController.text,
                  iconName: _availableIcons[_selectedIconIndex],
                  accentColor: CategoryColors.accentColors[_selectedColorIndex],
                );
                final iconKey = _iconKeys[_selectedIconIndex];
                final colorHex = CategoryColors.toHex(CategoryColors.accentColors[_selectedColorIndex]);
                await widget.onSave(updatedCategory, iconKey, colorHex);
                if (mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
