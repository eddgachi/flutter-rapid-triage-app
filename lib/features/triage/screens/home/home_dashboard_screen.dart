import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../dummy/dummy_data.dart';
import '../../widgets/shared/bottom_nav_bar.dart';
import '../patient/patient_details_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.lg,
                  AppSpacing.marginMobile,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcome(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStatsGrid(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecentActivity(context),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      height: AppSpacing.touchTargetMin,
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
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RapidTriage',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                'City General Hospital',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_done,
                  size: 18,
                  color: AppColors.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Synced',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, John Doe',
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Emergency Triage Interface Active',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    label: 'Awaiting Sync',
                    value: '3',
                    icon: Icons.sync_problem,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DashboardCard(
                    label: 'Synced Today',
                    value: '12',
                    icon: Icons.check_circle,
                    iconColor: AppColors.secondary,
                    bgColor: AppColors.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DashboardCard(
              label: 'Critical Patients',
              value: '1',
              icon: Icons.warning_rounded,
              iconColor: AppColors.error,
              bgColor: AppColors.errorContainer,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.person_add,
                label: 'New Triage',
                color: AppColors.primary,
                textColor: AppColors.onPrimary,
                onTap: () => context.push('/intake'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.list_alt,
                label: 'View Queue',
                color: AppColors.surfaceContainerHighest,
                textColor: AppColors.onSurface,
                onTap: () => context.go('/queue'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.nfc,
                label: 'Scan NFC',
                color: AppColors.surfaceContainerHighest,
                textColor: AppColors.onSurface,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.sync,
                label: 'Sync Now',
                color: AppColors.secondaryContainer,
                textColor: AppColors.onSecondaryContainer,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = DummyData.recentActivity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: Text(
                'View All',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...activities.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ActivityCard(activity: a),
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool isFullWidth;

  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isFullWidth ? AppColors.error : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: isFullWidth
                  ? AppColors.onErrorContainer
                  : AppColors.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: isFullWidth ? AppColors.error : AppColors.primary,
                ),
              ),
              Icon(icon, size: 40, color: iconColor.withOpacity(0.2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: textColor),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final DummyActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PatientDetailsScreen())),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: activity.triageColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activity.patientName,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${activity.triageLevel} \u2022 ${activity.time}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      activity.syncStatus == 'cloud_off'
                          ? Icons.cloud_off
                          : Icons.cloud_done,
                      color: activity.syncColor,
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
}
