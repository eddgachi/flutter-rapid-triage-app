import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../dummy/dummy_data.dart';
import '../../widgets/shared/bottom_nav_bar.dart';

class SyncHistoryScreen extends StatelessWidget {
  const SyncHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsBento(),
                    const SizedBox(height: 24),
                    _buildActionBar(),
                    const SizedBox(height: 16),
                    ...DummyData.syncRecords.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SyncRecordCard(record: r),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEndOfHistory(),
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
          const Icon(Icons.cloud_sync, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatsBento() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Records',
                value: '124',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Synced',
                value: '118',
                color: AppColors.primary,
                bgColor: AppColors.primaryContainer,
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
                value: '4',
                color: AppColors.error,
                bgColor: AppColors.errorContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: '2',
                color: AppColors.onSurfaceVariant,
                bgColor: AppColors.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Recent Activity',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
            ),
            overflow: TextOverflow.ellipsis, // <-- prevent overflow
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Retry All Failed'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
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

  Widget _buildEndOfHistory() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'END OF HISTORY',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.outline,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
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
        color: bgColor ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bgColor != null ? color : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: bgColor != null && bgColor == AppColors.primaryContainer
                  ? AppColors.onPrimaryContainer
                  : bgColor == AppColors.errorContainer
                  ? AppColors.onErrorContainer
                  : AppColors.onSurfaceVariant,
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
                      bgColor != null && bgColor == AppColors.primaryContainer
                      ? AppColors.onPrimaryContainer
                      : bgColor == AppColors.errorContainer
                      ? AppColors.error
                      : AppColors.primary,
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
  final DummySyncRecord record;

  const _SyncRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: record.leftColor, width: 4)),
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
              color: record.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(record.icon, color: record.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.patientName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Triage ${record.triageLevel} \u2022 ${record.description}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.time,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.outline,
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
                  color: record.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: record.statusColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  record.status,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: record.statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  record.status == 'Sync Failed'
                      ? Icons.replay
                      : Icons.visibility,
                  size: 20,
                  color: record.status == 'Sync Failed'
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
