import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:radix_icons/radix_icons.dart';
import '../models/challenge.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/injection.dart';
import '../widgets/ui/ui.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with SingleTickerProviderStateMixin {
  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _myChallenges = [];
  List<Map<String, dynamic>> _availableChallenges = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _dataService.getChallenges(visitorId: _currentUser!.uid),
        _dataService.getAvailableChallenges(visitorId: _currentUser!.uid),
        _dataService.getChallengeStats(_currentUser!.uid),
      ]);

      setState(() {
        _myChallenges = results[0] as List<Map<String, dynamic>>;
        _availableChallenges = results[1] as List<Map<String, dynamic>>;
        _stats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ChallengesPage] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          'Retos',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              RadixIcons.Plus,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            onPressed: _showCreateChallengeSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Mis retos (${_myChallenges.length})'),
            Tab(text: 'Descubrir'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyChallenges(isDark),
                _buildDiscoverChallenges(isDark),
              ],
            ),
    );
  }

  Widget _buildMyChallenges(bool isDark) {
    if (_myChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RadixIcons.Rocket,
              size: 64,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes retos activos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea uno o unete a un reto existente',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              onPressed: _showCreateChallengeSheet,
              label: 'Crear reto',
              icon: RadixIcons.Plus,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats summary
          _buildStatsCard(isDark),
          const SizedBox(height: 20),

          // Active challenges
          ..._myChallenges.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChallengeCard(
                  challenge: c,
                  isDark: isDark,
                  onTap: () => _showChallengeDetail(c),
                ),
              )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${_stats['active_challenges'] ?? 0}',
            'Activos',
            RadixIcons.Rocket,
            isDark,
          ),
          _buildStatItem(
            '${_stats['challenges_won'] ?? 0}',
            'Ganados',
            RadixIcons.Rocket,
            isDark,
          ),
          _buildStatItem(
            '${_stats['total_points'] ?? 0}',
            'Puntos',
            RadixIcons.Star,
            isDark,
          ),
          _buildStatItem(
            '#${_stats['average_rank'] ?? '-'}',
            'Ranking',
            RadixIcons.Bar_Chart,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
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

  Widget _buildDiscoverChallenges(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Join by code
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    RadixIcons.Link_2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unirse con codigo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        'Ingresa el codigo del reto',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  onPressed: _showJoinByCodeSheet,
                  label: 'Unirse',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_availableChallenges.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      RadixIcons.Magnifying_Glass,
                      size: 48,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay retos disponibles',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              'Retos disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            ..._availableChallenges.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DiscoverChallengeCard(
                    challenge: c,
                    isDark: isDark,
                    onJoin: () => _joinChallenge(c['id']),
                  ),
                )),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _joinChallenge(String challengeId) async {
    if (_currentUser == null) return;

    final result = await _dataService.joinChallenge(
      visitorId: _currentUser!.uid,
      challengeId: challengeId,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has unido al reto')),
      );
      _loadData();
    }
  }

  void _showJoinByCodeSheet() {
    final codeController = TextEditingController();

    AppBottomSheet.show(
      context: context,
      title: 'Unirse con codigo',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInput(
            controller: codeController,
            label: 'Codigo del reto',
            placeholder: 'Ej: abc123',
          ),
          const SizedBox(height: 20),
          AppButton(
            onPressed: () async {
              if (codeController.text.isEmpty) return;

              final result = await _dataService.joinChallengeByCode(
                visitorId: _currentUser!.uid,
                inviteCode: codeController.text.trim(),
              );

              if (mounted) {
                Navigator.pop(context);
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Te has unido al reto')),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Codigo no valido')),
                  );
                }
              }
            },
            label: 'Unirse',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showCreateChallengeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateChallengeSheet(
        onCreated: () {
          _loadData();
        },
      ),
    );
  }

  void _showChallengeDetail(Map<String, dynamic> challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChallengeDetailPage(
          challenge: challenge,
          currentUserId: _currentUser!.uid,
        ),
      ),
    ).then((_) => _loadData());
  }
}

// ============================================================================
// Challenge Card Widget
// ============================================================================

class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final bool isDark;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.challenge,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = challenge['emoji'] as String? ?? '🏆';
    final title = challenge['title'] as String? ?? 'Reto';
    final status = challenge['status'] as String? ?? 'active';
    final targetValue = challenge['target_value'] as int? ?? 0;
    final endDate = DateTime.tryParse(challenge['end_date'] as String? ?? '');
    final participation = (challenge['my_participation'] as List?)?.firstOrNull
        as Map<String, dynamic>?;
    final currentScore = participation?['current_score'] as int? ?? 0;

    final progress = targetValue > 0 ? (currentScore / targetValue).clamp(0.0, 1.0) : 0.0;
    final daysLeft = endDate != null ? endDate.difference(DateTime.now()).inDays : 0;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentScore / $targetValue completados',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'active'
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysLeft > 0 ? '$daysLeft dias' : 'Hoy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status == 'active' ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Discover Challenge Card
// ============================================================================

class _DiscoverChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final bool isDark;
  final VoidCallback onJoin;

  const _DiscoverChallengeCard({
    required this.challenge,
    required this.isDark,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = challenge['emoji'] as String? ?? '🏆';
    final title = challenge['title'] as String? ?? 'Reto';
    final description = challenge['description'] as String?;
    final participants = (challenge['participants'] as List?)?.firstOrNull
        as Map<String, dynamic>?;
    final count = participants?['count'] as int? ?? 0;
    final creator = challenge['creator'] as Map<String, dynamic>?;
    final creatorName = creator?['display_name'] as String? ?? 'Usuario';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      RadixIcons.Person,
                      size: 12,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$count participantes',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'por $creatorName',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            onPressed: onJoin,
            label: 'Unirse',
            size: AppButtonSize.sm,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Create Challenge Sheet
// ============================================================================

class _CreateChallengeSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateChallengeSheet({required this.onCreated});

  @override
  State<_CreateChallengeSheet> createState() => _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<_CreateChallengeSheet> {
  AuthService get _authService => getIt<AuthService>();
  DataService get _dataService => getIt<DataService>();
  User? get _currentUser => _authService.currentUser;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedEmoji = '🏆';
  ChallengeType _selectedType = ChallengeType.completion;
  int _targetValue = 10;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isCreating = false;

  final List<String> _emojis = [
    '🏆',
    '🎯',
    '🔥',
    '⭐',
    '💪',
    '🚀',
    '🎖️',
    '👑',
    '💎',
    '🌟',
    '⚡',
    '🏅',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Crear reto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 20),

            // Emoji selector
            Text(
              'Icono',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark ? AppColors.mutedDark : AppColors.muted),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Title
            AppInput(
              controller: _titleController,
              label: 'Nombre del reto',
              placeholder: 'Ej: Semana productiva',
            ),
            const SizedBox(height: 12),

            // Description
            AppInput(
              controller: _descriptionController,
              label: 'Descripcion (opcional)',
              placeholder: 'Describe el reto...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Challenge type
            Text(
              'Tipo de reto',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ChallengeType.values.map((type) {
                final isSelected = type == _selectedType;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (isDark ? AppColors.mutedDark : AppColors.muted),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary)
                          : null,
                    ),
                    child: Text(
                      _getTypeName(type),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Target value
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Objetivo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_targetValue > 1) {
                                setState(() => _targetValue--);
                              }
                            },
                            icon: Icon(RadixIcons.Minus),
                          ),
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.mutedDark : AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_targetValue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _targetValue++),
                            icon: Icon(RadixIcons.Plus),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    'Inicio',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    'Fin',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create button
            AppButton(
              onPressed: _isCreating ? null : _createChallenge,
              label: _isCreating ? 'Creando...' : 'Crear reto',
              fullWidth: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.mutedDark : AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  RadixIcons.Calendar,
                  size: 16,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMM', 'es').format(date),
                  style: TextStyle(
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

  String _getTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.streak:
        return 'Racha';
      case ChallengeType.completion:
        return 'Completar';
      case ChallengeType.category:
        return 'Categoria';
      case ChallengeType.speed:
        return 'Velocidad';
      case ChallengeType.perfectDay:
        return 'Dia perfecto';
    }
  }

  Future<void> _createChallenge() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el reto')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final result = await _dataService.createChallenge(
        visitorId: _currentUser!.uid,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        emoji: _selectedEmoji,
        challengeType: _selectedType.name == 'perfectDay'
            ? 'perfect_day'
            : _selectedType.name,
        targetValue: _targetValue,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (result != null && mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reto creado exitosamente')),
        );
      }
    } catch (e) {
      debugPrint('[CreateChallenge] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el reto')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

// ============================================================================
// Challenge Detail Page
// ============================================================================

class _ChallengeDetailPage extends StatefulWidget {
  final Map<String, dynamic> challenge;
  final String currentUserId;

  const _ChallengeDetailPage({
    required this.challenge,
    required this.currentUserId,
  });

  @override
  State<_ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<_ChallengeDetailPage> {
  DataService get _dataService => getIt<DataService>();

  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      final result = await _dataService.getChallengeLeaderboard(
        widget.challenge['id'],
      );
      setState(() {
        _leaderboard = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ChallengeDetail] Error loading leaderboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = widget.challenge['emoji'] as String? ?? '🏆';
    final title = widget.challenge['title'] as String? ?? 'Reto';
    final description = widget.challenge['description'] as String?;
    final inviteCode = widget.challenge['invite_code'] as String?;
    final targetValue = widget.challenge['target_value'] as int? ?? 0;
    final endDate = DateTime.tryParse(widget.challenge['end_date'] as String? ?? '');
    final daysLeft = endDate != null ? endDate.difference(DateTime.now()).inDays : 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            RadixIcons.Arrow_Left,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (inviteCode != null)
            IconButton(
              icon: Icon(
                RadixIcons.Share_1,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              onPressed: () => _shareChallenge(inviteCode),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailStat('🎯', '$targetValue', 'Objetivo', isDark),
                _buildDetailStat('📅', '$daysLeft', 'Dias', isDark),
                _buildDetailStat('👥', '${_leaderboard.length}', 'Jugadores', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Invite code
            if (inviteCode != null)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Codigo para invitar',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inviteCode.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(RadixIcons.Copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Codigo copiado')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Leaderboard
            Text(
              'Clasificacion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_leaderboard.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Sin participantes aun',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
              )
            else
              ..._leaderboard.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                return _LeaderboardItem(
                  participant: participant,
                  index: index,
                  isCurrentUser: participant['user_id'] == widget.currentUserId,
                  isDark: isDark,
                  targetValue: targetValue,
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(
    String emoji,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
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

  void _shareChallenge(String code) {
    final message = 'Unete a mi reto en Taskly! Usa el codigo: ${code.toUpperCase()}';
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje copiado al portapapeles')),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final Map<String, dynamic> participant;
  final int index;
  final bool isCurrentUser;
  final bool isDark;
  final int targetValue;

  const _LeaderboardItem({
    required this.participant,
    required this.index,
    required this.isCurrentUser,
    required this.isDark,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = participant['display_name'] as String? ?? 'Usuario';
    final score = participant['current_score'] as int? ?? 0;
    final goalReached = participant['goal_reached'] as bool? ?? false;

    final medalEmoji = index == 0
        ? '🥇'
        : index == 1
            ? '🥈'
            : index == 2
                ? '🥉'
                : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.cardDark : AppColors.card),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              medalEmoji.isNotEmpty ? medalEmoji : '#${index + 1}',
              style: TextStyle(
                fontSize: medalEmoji.isNotEmpty ? 20 : 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
            child: Text(
              displayName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Tu',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$score / $targetValue completados',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (goalReached)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                RadixIcons.Check,
                color: AppColors.success,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
