import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Apple-style wheel time picker
class AppTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool use24HourFormat;

  const AppTimePicker({
    super.key,
    required this.initialTime,
    this.onTimeChanged,
    this.use24HourFormat = false,
  });

  @override
  State<AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedPeriod; // 0 = AM, 1 = PM

  @override
  void initState() {
    super.initState();
    _initializeTime();
  }

  void _initializeTime() {
    if (widget.use24HourFormat) {
      _selectedHour = widget.initialTime.hour;
      _selectedMinute = widget.initialTime.minute;
      _selectedPeriod = 0;
    } else {
      // Convert to 12-hour format
      final hour = widget.initialTime.hourOfPeriod;
      _selectedHour = hour == 0 ? 11 : hour - 1; // 0-indexed for 1-12
      _selectedMinute = widget.initialTime.minute;
      _selectedPeriod = widget.initialTime.hour >= 12 ? 1 : 0;
    }

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    int hour;
    if (widget.use24HourFormat) {
      hour = _selectedHour;
    } else {
      // Convert from 12-hour to 24-hour
      hour = _selectedHour + 1; // 1-12
      if (hour == 12) hour = 0;
      if (_selectedPeriod == 1) hour += 12;
      if (hour == 24) hour = 12;
    }

    final time = TimeOfDay(hour: hour, minute: _selectedMinute);
    widget.onTimeChanged?.call(time);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.secondaryDark.withValues(alpha: 0.8)
                    : AppColors.secondary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Wheels
          Row(
            children: [
              // Hour wheel
              Expanded(
                flex: widget.use24HourFormat ? 1 : 2,
                child: _buildWheel(
                  controller: _hourController,
                  itemCount: widget.use24HourFormat ? 24 : 12,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedHour = index);
                    _onTimeChanged();
                  },
                  itemBuilder: (index) {
                    final displayHour = widget.use24HourFormat
                        ? index
                        : index + 1;
                    return displayHour.toString().padLeft(2, '0');
                  },
                  isDark: isDark,
                ),
              ),
              // Separator
              _buildSeparator(isDark),
              // Minute wheel
              Expanded(
                flex: 2,
                child: _buildWheel(
                  controller: _minuteController,
                  itemCount: 60,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMinute = index);
                    _onTimeChanged();
                  },
                  itemBuilder: (index) => index.toString().padLeft(2, '0'),
                  isDark: isDark,
                ),
              ),
              // AM/PM wheel (only in 12-hour mode)
              if (!widget.use24HourFormat) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildPeriodWheel(isDark),
                ),
              ],
            ],
          ),
          // Gradient overlays for depth effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 70,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.cardDark : AppColors.card),
                      (isDark ? AppColors.cardDark : AppColors.card).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      (isDark ? AppColors.cardDark : AppColors.card),
                      (isDark ? AppColors.cardDark : AppColors.card).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
    required String Function(int) itemBuilder,
    required bool isDark,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      perspective: 0.003,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients &&
              controller.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: isSelected ? 24 : 20,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
              ),
              child: Text(itemBuilder(index)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodWheel(bool isDark) {
    final periods = ['AM', 'PM'];

    return ListWheelScrollView.useDelegate(
      controller: _periodController,
      itemExtent: 44,
      perspective: 0.003,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        HapticFeedback.selectionClick();
        setState(() => _selectedPeriod = index);
        _onTimeChanged();
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 2,
        builder: (context, index) {
          final isSelected = _periodController.hasClients &&
              _periodController.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: isSelected ? 22 : 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
              ),
              child: Text(periods[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
      ),
    );
  }
}

/// Shows an Apple-style time picker in a bottom sheet
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  bool use24HourFormat = false,
}) {
  TimeOfDay selectedTime = initialTime;

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    Text(
                      'Seleccionar hora',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, selectedTime),
                      child: Text(
                        'Listo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Time picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppTimePicker(
                  initialTime: initialTime,
                  use24HourFormat: use24HourFormat,
                  onTimeChanged: (time) => selectedTime = time,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

/// Apple-style date picker
class AppDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged;

  const AppDatePicker({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  late int _startYear;
  late int _endYear;

  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  void _initializeDate() {
    final now = DateTime.now();
    _startYear = widget.firstDate?.year ?? now.year - 10;
    _endYear = widget.lastDate?.year ?? now.year + 10;

    _selectedDay = widget.initialDate.day - 1;
    _selectedMonth = widget.initialDate.month - 1;
    _selectedYear = widget.initialDate.year - _startYear;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _onDateChanged() {
    final year = _startYear + _selectedYear;
    final month = _selectedMonth + 1;
    final maxDays = _daysInMonth(year, month);
    final day = (_selectedDay + 1).clamp(1, maxDays);

    final date = DateTime(year, month, day);
    widget.onDateChanged?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final year = _startYear + _selectedYear;
    final month = _selectedMonth + 1;
    final daysCount = _daysInMonth(year, month);

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.secondaryDark.withValues(alpha: 0.8)
                    : AppColors.secondary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Wheels
          Row(
            children: [
              // Day wheel
              Expanded(
                flex: 2,
                child: _buildWheel(
                  controller: _dayController,
                  itemCount: daysCount,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDay = index);
                    _onDateChanged();
                  },
                  itemBuilder: (index) => (index + 1).toString(),
                  isDark: isDark,
                ),
              ),
              // Month wheel
              Expanded(
                flex: 4,
                child: _buildWheel(
                  controller: _monthController,
                  itemCount: 12,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedMonth = index;
                      // Adjust day if needed
                      final maxDays = _daysInMonth(_startYear + _selectedYear, index + 1);
                      if (_selectedDay >= maxDays) {
                        _selectedDay = maxDays - 1;
                        _dayController.jumpToItem(_selectedDay);
                      }
                    });
                    _onDateChanged();
                  },
                  itemBuilder: (index) => _months[index],
                  isDark: isDark,
                ),
              ),
              // Year wheel
              Expanded(
                flex: 3,
                child: _buildWheel(
                  controller: _yearController,
                  itemCount: _endYear - _startYear + 1,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedYear = index;
                      // Adjust day if needed (for leap years)
                      final maxDays = _daysInMonth(_startYear + index, _selectedMonth + 1);
                      if (_selectedDay >= maxDays) {
                        _selectedDay = maxDays - 1;
                        _dayController.jumpToItem(_selectedDay);
                      }
                    });
                    _onDateChanged();
                  },
                  itemBuilder: (index) => (_startYear + index).toString(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          // Gradient overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 70,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.cardDark : AppColors.card),
                      (isDark ? AppColors.cardDark : AppColors.card).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      (isDark ? AppColors.cardDark : AppColors.card),
                      (isDark ? AppColors.cardDark : AppColors.card).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
    required String Function(int) itemBuilder,
    required bool isDark,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      perspective: 0.003,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = controller.hasClients &&
              controller.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: isSelected ? 20 : 17,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
              ),
              child: Text(itemBuilder(index)),
            ),
          );
        },
      ),
    );
  }
}

/// Shows an Apple-style date picker in a bottom sheet
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  DateTime selectedDate = initialDate;

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    Text(
                      'Seleccionar fecha',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, selectedDate),
                      child: Text(
                        'Listo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Date picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppDatePicker(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) => selectedDate = date,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

/// Combined date and time picker in Apple style
class AppDateTimePicker extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool use24HourFormat;
  final ValueChanged<DateTime>? onDateTimeChanged;

  const AppDateTimePicker({
    super.key,
    required this.initialDateTime,
    this.firstDate,
    this.lastDate,
    this.use24HourFormat = false,
    this.onDateTimeChanged,
  });

  @override
  State<AppDateTimePicker> createState() => _AppDateTimePickerState();
}

class _AppDateTimePickerState extends State<AppDateTimePicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDateTime);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    widget.onDateTimeChanged?.call(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.secondaryDark : AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
            unselectedLabelColor: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Fecha'),
              Tab(text: 'Hora'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab content
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabController,
            children: [
              AppDatePicker(
                initialDate: _selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) {
                  _selectedDate = date;
                  _notifyChange();
                },
              ),
              AppTimePicker(
                initialTime: _selectedTime,
                use24HourFormat: widget.use24HourFormat,
                onTimeChanged: (time) {
                  _selectedTime = time;
                  _notifyChange();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows an Apple-style date and time picker in a bottom sheet
Future<DateTime?> showAppDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  bool use24HourFormat = false,
}) {
  DateTime selectedDateTime = initialDateTime;

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    Text(
                      'Fecha y hora',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, selectedDateTime),
                      child: Text(
                        'Listo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // DateTime picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: AppDateTimePicker(
                  initialDateTime: initialDateTime,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  use24HourFormat: use24HourFormat,
                  onDateTimeChanged: (dt) => selectedDateTime = dt,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
