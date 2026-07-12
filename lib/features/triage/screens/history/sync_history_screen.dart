import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/history_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/sync_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/bottom_nav_bar.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/connectivity_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncHistoryScreen extends ConsumerWidget {
  const SyncHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);
    final records = historyState.records;

    // Calculate stats
    final total = records.length;
    final synced = records
        .where((r) => r.syncStatus == SyncStatus.synced)
        .length;
    final failed = records
        .where((r) => r.syncStatus == SyncStatus.failed)
        .length;
    final pending = records
        .where((r) => r.syncStatus == SyncStatus.pending)
        .length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsBento(
                      total: total,
                      synced: synced,
                      failed: failed,
                      pending: pending,
                      context: context,
                    ),
                    const SizedBox(height: 24),
                    _buildActionBar(ref, context),
                    const SizedBox(height: 16),
                    if (historyState.loading)
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
                                Icons.history,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No sync history',
                                style: AppTypography.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Patient records will appear here once they are created.',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
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
                          child: _SyncRecordCard(record: record),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildEndOfHistory(context),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Icon(Icons.emergency, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'RapidTriage',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await ref.read(syncControllerProvider.notifier).syncNow();
              ref.invalidate(historyControllerProvider);
              if (context.mounted) {
                final s = ref.read(syncControllerProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.isConnected
                          ? 'Sync: ${s.syncedCount} succeeded, ${s.failedCount} failed'
                          : 'No internet connection',
                    ),
                    backgroundColor: s.isConnected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const ConnectivityIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBento({
    required int total,
    required int synced,
    required int failed,
    required int pending,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Records',
                value: total.toString(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Synced',
                value: synced.toString(),
                color: Theme.of(context).colorScheme.primary,
                bgColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Failed',
                value: failed.toString(),
                color: Theme.of(context).colorScheme.error,
                bgColor: Theme.of(context).colorScheme.errorContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: pending.toString(),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                bgColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBar(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Recent Activity',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            ref.read(historyControllerProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Refresh'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildEndOfHistory(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'END OF HISTORY',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bgColor != null
              ? color
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color:
                  bgColor != null &&
                      bgColor == Theme.of(context).colorScheme.primaryContainer
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : bgColor == Theme.of(context).colorScheme.errorContainer
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color:
                      bgColor != null &&
                          bgColor ==
                              Theme.of(context).colorScheme.primaryContainer
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : bgColor == Theme.of(context).colorScheme.errorContainer
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              if (label == 'Synced') const Icon(Icons.check_circle, size: 20),
              if (label == 'Failed') const Icon(Icons.error, size: 20),
              if (label == 'Pending') const Icon(Icons.pending, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncRecordCard extends StatelessWidget {
  final TriageRecord record;

  const _SyncRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(record.priority);
    final isSynced = record.syncStatus == SyncStatus.synced;
    final isFailed = record.syncStatus == SyncStatus.failed;
    final statusLabel = record.syncStatus.name.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSynced
                  ? Icons.cloud_done
                  : isFailed
                  ? Icons.cloud_off
                  : Icons.cloud_sync,
              color: isSynced
                  ? Theme.of(context).colorScheme.primary
                  : isFailed
                  ? Theme.of(context).colorScheme.error
                  : AppColors.failed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.patient.name,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getPriorityLabel(record.priority)} \u2022 ${record.chiefComplaint}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(record.createdAt),
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSynced
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : isFailed
                      ? Theme.of(context).colorScheme.error.withOpacity(0.15)
                      : AppColors.failed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: isSynced
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : isFailed
                        ? Theme.of(context).colorScheme.error.withOpacity(0.2)
                        : AppColors.failed.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: isSynced
                        ? Theme.of(context).colorScheme.primary
                        : isFailed
                        ? Theme.of(context).colorScheme.error
                        : AppColors.failed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  isFailed ? Icons.replay : Icons.visibility,
                  size: 20,
                  color: isFailed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: isFailed
                    ? () {
                        // TODO: Implement retry sync
                      }
                    : () {
                        // TODO: Navigate to patient details
                      },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
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
        return 'P1 - Critical';
      case 2:
        return 'P2 - Urgent';
      case 3:
        return 'P3 - Delayed';
      case 4:
        return 'P4 - Expectant';
      case 5:
        return 'P5 - Minor';
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
