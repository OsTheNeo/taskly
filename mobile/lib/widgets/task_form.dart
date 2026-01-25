import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/injection.dart';
import '../l10n/app_localizations.dart';
import '../models/task_category.dart';
import '../state/settings_state.dart' as settings;
import 'ui/ui.dart';

enum RecurrenceType { none, daily, weekly, biweekly, monthly, custom }

class TaskFormData {
  String title;
  String? description;
  bool isPersonal;
  bool isGoal;
  int? targetValue;
  String? targetUnit;
  RecurrenceType recurrence;
  List<int> selectedDays; // 0-6 for Mon-Sun
  TimeOfDay? reminderTime;
  bool reminderEnabled;
  TaskCategory? category;
  String? groupId;
  String? groupName;

  TaskFormData({
    this.title = '',
    this.description,
    this.isPersonal = true,
    this.isGoal = false,
    this.targetValue,
    this.targetUnit,
    this.recurrence = RecurrenceType.daily,
    this.selectedDays = const [],
    this.reminderTime,
    this.reminderEnabled = false,
    this.category,
    this.groupId,
    this.groupName,
  });
}

class TaskForm extends StatefulWidget {
  final TaskFormData? initialData;
  final ValueChanged<TaskFormData>? onSave;

  const TaskForm({
    super.key,
    this.initialData,
    this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TaskFormData _data;
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  bool _isFormValid = false;

  List<Map<String, dynamic>> _groups = [];
  bool _isLoadingGroups = false;

  DataService get _dataService => getIt<DataService>();
  AuthService get _authService => getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    _data = widget.initialData ?? TaskFormData();
    _data.category ??= PredefinedCategories.defaultCategory;
    _titleController.text = _data.title;
    _targetController.text = _data.targetValue?.toString() ?? '';
    _titleController.addListener(_validateForm);
    _validateForm();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _dataService.getHouseholds(user.uid);
      setState(() {
        _groups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroups = false);
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title + Category button
          _buildSectionLabel(l10n.title, isDark),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppInput(
                  placeholder: l10n.titlePlaceholder,
                  controller: _titleController,
                  onChanged: (v) => _data.title = v,
                ),
              ),
              const SizedBox(width: 12),
              _buildCategoryButton(isDark),
            ],
          ),
          const SizedBox(height: 20),

          // Type: Personal or Group
          _buildSectionLabel(l10n.taskType, isDark),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTypeChip(
                  iconName: DuotoneIcon.user,
                  label: l10n.personal,
                  isSelected: _data.isPersonal,
                  onTap: () => setState(() => _data.isPersonal = true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeChip(
                  iconName: DuotoneIcon.users,
                  label: l10n.group,
                  isSelected: !_data.isPersonal,
                  onTap: () => setState(() => _data.isPersonal = false),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // Group selector (when group is selected)
          if (!_data.isPersonal) ...[
            const SizedBox(height: 16),
            _buildGroupSelector(isDark),
          ],
          const SizedBox(height: 20),

          // Is Goal with progress
          _buildToggleOption(
            iconName: DuotoneIcon.target,
            title: l10n.goalWithProgress,
            subtitle: l10n.trackDailyProgress,
            value: _data.isGoal,
            onChanged: (v) => setState(() => _data.isGoal = v),
            isDark: isDark,
          ),

          if (_data.isGoal) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppInput(
                    label: l10n.dailyGoal,
                    placeholder: '30',
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _data.targetValue = int.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildUnitSelector(isDark, l10n),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Recurrence
          _buildSectionLabel(l10n.frequency, isDark),
          const SizedBox(height: 8),
          _buildRecurrenceSelector(isDark, l10n),

          if (_data.recurrence == RecurrenceType.weekly ||
              _data.recurrence == RecurrenceType.custom) ...[
            const SizedBox(height: 16),
            _buildDaySelector(isDark, l10n),
          ],
          const SizedBox(height: 20),

          // Reminder - tap anywhere to open time picker
          GestureDetector(
            onTap: _showTimePicker,
            child: _buildToggleOption(
              iconName: DuotoneIcon.bell,
              title: l10n.reminder,
              subtitle: _data.reminderTime != null
                  ? l10n.atTime(_formatTime(_data.reminderTime!))
                  : l10n.tapToSetTime,
              value: _data.reminderEnabled,
              onChanged: (v) {
                if (v) {
                  _showTimePicker();
                } else {
                  setState(() {
                    _data.reminderEnabled = false;
                    _data.reminderTime = null;
                  });
                }
              },
              isDark: isDark,
              trailing: _data.reminderEnabled
                  ? DuotoneIcon(DuotoneIcon.clock, size: 18, accentColor: settings.accentColor)
                  : null,
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          AppButton(
            label: l10n.saveTask,
            fullWidth: true,
            iconName: DuotoneIcon.check,
            onPressed: _isFormValid ? _onSave : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
      ),
    );
  }

  Widget _buildCategoryButton(bool isDark) {
    final selectedCategory = _data.category ?? PredefinedCategories.defaultCategory;
    final categoryColor = selectedCategory.accentColor;

    return GestureDetector(
      onTap: () => _showCategoryModal(isDark),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DuotoneIcon(
              selectedCategory.iconName,
              size: 20,
              accentColor: categoryColor,
            ),
            const SizedBox(width: 8),
            Text(
              selectedCategory.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 4),
            DuotoneIcon(
              DuotoneIcon.chevronDown,
              size: 14,
              color: categoryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryModal(bool isDark) {
    final categories = PredefinedCategories.all;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selecciona categoria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: DuotoneIcon(
                      DuotoneIcon.x,
                      size: 20,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: categories.map((cat) {
                  final isSelected = _data.category?.id == cat.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _data.category = cat;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: cat.accentColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? cat.accentColor
                              : cat.accentColor.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DuotoneIcon(
                            cat.iconName,
                            size: 28,
                            accentColor: cat.accentColor,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupSelector(bool isDark) {
    final accentColor = settings.accentColor;

    if (_isLoadingGroups) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.secondaryDark : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_groups.isEmpty)
          GestureDetector(
            onTap: () => _showCreateGroupDialog(isDark),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  DuotoneIcon(DuotoneIcon.plus, size: 20, accentColor: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No tienes grupos. Crea uno',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                  DuotoneIcon(DuotoneIcon.chevronRight, size: 16, accentColor: accentColor),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._groups.map((group) {
                final isSelected = _data.groupId == group['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _data.groupId = group['id'];
                      _data.groupName = group['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.15)
                          : (isDark ? AppColors.secondaryDark : AppColors.secondary),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DuotoneIcon(
                          DuotoneIcon.users,
                          size: 16,
                          accentColor: isSelected ? accentColor : null,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          group['name'] ?? 'Grupo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Create new group button
              GestureDetector(
                onTap: () => _showCreateGroupDialog(isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DuotoneIcon(DuotoneIcon.plus, size: 16, accentColor: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Nuevo',
                        style: TextStyle(
                          fontSize: 13,
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
      ],
    );
  }

  void _showCreateGroupDialog(bool isDark) {
    final controller = TextEditingController();
    final accentColor = settings.accentColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear grupo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: controller,
                label: 'Nombre del grupo',
                placeholder: 'Ej: Familia, Trabajo...',
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Crear grupo',
                fullWidth: true,
                iconName: DuotoneIcon.plus,
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  final user = _authService.currentUser;
                  if (user == null) return;

                  final result = await _dataService.createHousehold(
                    visitorId: user.uid,
                    name: controller.text.trim(),
                  );

                  if (result != null && mounted) {
                    Navigator.pop(ctx);
                    await _loadGroups();
                    setState(() {
                      _data.groupId = result['id'];
                      _data.groupName = result['name'];
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeChip({
    required String iconName,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final accentColor = settings.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.secondaryDark : AppColors.secondary),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DuotoneIcon(
              iconName,
              size: 20,
              accentColor: isSelected ? accentColor : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? accentColor
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String iconName,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    Widget? trailing,
  }) {
    final accentColor = settings.accentColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.secondaryDark : AppColors.secondary,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? accentColor.withValues(alpha: 0.1)
                  : (isDark ? AppColors.mutedDark : AppColors.muted),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Center(
              child: DuotoneIcon(
                iconName,
                size: 20,
                accentColor: value ? accentColor : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accentColor,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(bool isDark, S l10n) {
    final units = {
      'minutes': l10n.minutes,
      'hours': l10n.hours,
      'times': l10n.times,
      'pages': l10n.pages,
      'km': l10n.km,
      'glasses': l10n.glasses,
    };
    _data.targetUnit ??= 'minutes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(l10n.unit, isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.background,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isDark ? AppColors.inputDark : AppColors.input,
            ),
          ),
          child: DropdownButton<String>(
            value: _data.targetUnit,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppColors.cardDark : AppColors.card,
            items: units.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _data.targetUnit = v),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenceSelector(bool isDark, S l10n) {
    final accentColor = settings.accentColor;
    final options = [
      (RecurrenceType.daily, l10n.daily),
      (RecurrenceType.weekly, l10n.weekly),
      (RecurrenceType.biweekly, l10n.biweekly),
      (RecurrenceType.monthly, l10n.monthly),
      (RecurrenceType.custom, l10n.custom),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = _data.recurrence == opt.$1;
        return GestureDetector(
          onTap: () => setState(() => _data.recurrence = opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : (isDark ? AppColors.secondaryDark : AppColors.secondary),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              opt.$2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaySelector(bool isDark, S l10n) {
    final accentColor = settings.accentColor;
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(l10n.selectDays, isDark),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isSelected = _data.selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _data.selectedDays = List.from(_data.selectedDays)..remove(index);
                  } else {
                    _data.selectedDays = List.from(_data.selectedDays)..add(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor
                      : (isDark ? AppColors.secondaryDark : AppColors.secondary),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showTimePicker() async {
    final time = await showAppTimePicker(
      context: context,
      initialTime: _data.reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() {
        _data.reminderTime = time;
        _data.reminderEnabled = true;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> _onSave() async {
    final l10n = S.of(context)!;
    _data.title = _titleController.text;
    if (_data.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterTitle)),
      );
      return;
    }

    // Schedule notification if reminder is enabled
    if (_data.reminderEnabled && _data.reminderTime != null) {
      final notificationService = NotificationService();
      await notificationService.requestPermissions();

      final taskId = 'task_${DateTime.now().millisecondsSinceEpoch}';

      // Convert selectedDays (0-6 Mon-Sun as index) to weekday (1-7 Mon-Sun)
      List<int>? weekDays;
      if (_data.recurrence == RecurrenceType.weekly ||
          _data.recurrence == RecurrenceType.custom) {
        if (_data.selectedDays.isNotEmpty) {
          weekDays = _data.selectedDays.map((d) => d + 1).toList();
        }
      }

      await notificationService.scheduleTaskReminder(
        taskId: taskId,
        taskTitle: _data.title,
        reminderTime: _data.reminderTime!,
        weekDays: weekDays, // null means daily
      );
    }

    widget.onSave?.call(_data);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
