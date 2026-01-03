import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:radix_icons/radix_icons.dart';
import '../../core/services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../models/task_category.dart';
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
  Color? customAccentColor;

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
    this.customAccentColor,
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

  @override
  void initState() {
    super.initState();
    _data = widget.initialData ?? TaskFormData();
    _data.category ??= PredefinedCategories.defaultCategory;
    _titleController.text = _data.title;
    _targetController.text = _data.targetValue?.toString() ?? '';
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
          // Title
          AppInput(
            label: l10n.title,
            placeholder: l10n.titlePlaceholder,
            controller: _titleController,
            onChanged: (v) => _data.title = v,
          ),
          const SizedBox(height: 20),

          // Category
          _buildSectionLabel('Categoria', isDark),
          const SizedBox(height: 8),
          _buildCategorySelector(isDark),
          const SizedBox(height: 20),

          // Type: Personal or Group
          _buildSectionLabel(l10n.taskType, isDark),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTypeChip(
                  icon: RadixIcons.Person,
                  label: l10n.personal,
                  isSelected: _data.isPersonal,
                  onTap: () => setState(() => _data.isPersonal = true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeChip(
                  icon: RadixIcons.Backpack,
                  label: l10n.group,
                  isSelected: !_data.isPersonal,
                  onTap: () => setState(() => _data.isPersonal = false),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Is Goal with progress
          _buildToggleOption(
            icon: RadixIcons.Target,
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

          // Reminder
          _buildToggleOption(
            icon: RadixIcons.Bell,
            title: l10n.reminder,
            subtitle: _data.reminderTime != null
                ? l10n.atTime(_formatTime(_data.reminderTime!))
                : l10n.noReminder,
            value: _data.reminderEnabled,
            onChanged: (v) {
              setState(() {
                _data.reminderEnabled = v;
                if (v && _data.reminderTime == null) {
                  _showTimePicker();
                }
              });
            },
            isDark: isDark,
            trailing: _data.reminderEnabled
                ? IconButton(
                    icon: const Icon(RadixIcons.Clock, size: 18),
                    onPressed: _showTimePicker,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(height: 32),

          // Submit button
          AppButton(
            label: l10n.saveTask,
            fullWidth: true,
            icon: RadixIcons.Check,
            onPressed: _onSave,
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

  Widget _buildCategorySelector(bool isDark) {
    final categories = PredefinedCategories.all;
    final selectedCategory = _data.category ?? PredefinedCategories.defaultCategory;
    final accentColor = _data.customAccentColor ?? selectedCategory.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips in a wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = selectedCategory.id == cat.id;
            final displayColor = isSelected
                ? (_data.customAccentColor ?? cat.accentColor)
                : cat.accentColor;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _data.category = cat;
                  _data.customAccentColor = null; // Reset custom color when changing category
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? displayColor.withValues(alpha: 0.15)
                      : (isDark ? AppColors.secondaryDark : AppColors.secondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? displayColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected
                          ? displayColor
                          : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? displayColor
                            : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Color picker
        Row(
          children: [
            Text(
              'Color de acento',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showColorPicker(isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      RadixIcons.Chevron_Down,
                      size: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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

  void _showColorPicker(bool isDark) {
    final colors = CategoryColors.accentColors;
    final currentColor = _data.customAccentColor ?? _data.category?.accentColor ?? colors.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Selecciona un color',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(RadixIcons.Cross_2),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colors.map((color) {
                      final isSelected = currentColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _data.customAccentColor = color;
                          });
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  RadixIcons.Check,
                                  color: _getContrastColor(color),
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildTypeChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.secondaryDark : AppColors.secondary),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    Widget? trailing,
  }) {
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
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark ? AppColors.mutedDark : AppColors.muted),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value
                  ? AppColors.primary
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
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
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.primaryForeground,
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
                  ? AppColors.primary
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
                      ? AppColors.primary
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
    final time = await showTimePicker(
      context: context,
      initialTime: _data.reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
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

      final taskId = DateTime.now().millisecondsSinceEpoch;
      await notificationService.scheduleDailyNotification(
        id: taskId,
        title: l10n.reminder,
        body: _data.title,
        time: _data.reminderTime!,
        payload: 'task_$taskId',
      );
    }

    widget.onSave?.call(_data);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
