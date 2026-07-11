import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/queue_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientQueueScreen extends ConsumerStatefulWidget {
  const PatientQueueScreen({super.key});

  @override
  ConsumerState<PatientQueueScreen> createState() => _PatientQueueScreenState();
}

class _PatientQueueScreenState extends ConsumerState<PatientQueueScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load queue data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queueControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(queueControllerProvider);
    final records = queueState.records;

    // Get pending count from the controller
    final pendingCount = ref
        .read(queueControllerProvider.notifier)
        .pendingCount();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    _buildQueueHeader(pendingCount),
                    const SizedBox(height: 8),
                    if (queueState.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (records.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppColors.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No patients in queue',
                                style: AppTypography.textTheme.headlineSmall
                                    ?.copyWith(color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Patient records will appear here once they are created.',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...records.map(
                        (record) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _QueueCard(record: record),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push('/intake'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'RapidTriage',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(Icons.cloud_sync, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          ref.read(queueControllerProvider.notifier).search(query);
        },
        decoration: InputDecoration(
          hintText: 'Search patient name or ID...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(queueControllerProvider.notifier).load();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isActive: true,
            onTap: () {
              ref.read(queueControllerProvider.notifier).load();
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Critical (P1)',
            isActive: false,
            onTap: () {
              ref.read(queueControllerProvider.notifier).filterPriority(1);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Urgent (P2)',
            isActive: false,
            onTap: () {
              ref.read(queueControllerProvider.notifier).filterPriority(2);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Delayed (P3)',
            isActive: false,
            onTap: () {
              ref.read(queueControllerProvider.notifier).filterPriority(3);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending Sync',
            isActive: false,
            onTap: () {
              ref.read(queueControllerProvider.notifier).loadPending();
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Synced',
            isActive: false,
            onTap: () {
              ref.read(queueControllerProvider.notifier).loadSynced();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueueHeader(int pendingCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Patient Queue',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$pendingCount Pending',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: isActive
                ? AppColors.onSecondaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final TriageRecord record;

  const _QueueCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(record.priority);
    final isSynced = record.syncStatus == SyncStatus.synced;

    return GestureDetector(
      onTap: () => context.go('/patient/${record.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.patient.name,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            _getPriorityLabel(record.priority),
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(
                                  color: record.priority == 3
                                      ? Colors.black
                                      : Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(record.createdAt),
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              isSynced ? Icons.check_circle : Icons.schedule,
                              size: 16,
                              color: isSynced
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSynced ? 'Synced' : 'Pending',
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(
                                    color: isSynced
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.p2Urgent;
      case 3:
        return AppColors.p3Delayed;
      case 4:
        return AppColors.inverseSurface;
      default:
        return AppColors.primary;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'P1';
      case 2:
        return 'P2';
      case 3:
        return 'P3';
      case 4:
        return 'P4';
      case 5:
        return 'P5';
      default:
        return 'P${priority.toString()}';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
