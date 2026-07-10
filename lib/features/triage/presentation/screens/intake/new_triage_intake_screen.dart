import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../widgets/shared/custom_app_bar.dart';

class NewTriageIntakeScreen extends StatefulWidget {
  const NewTriageIntakeScreen({super.key});

  @override
  State<NewTriageIntakeScreen> createState() => _NewTriageIntakeScreenState();
}

class _NewTriageIntakeScreenState extends State<NewTriageIntakeScreen> {
  double _ageValue = 45;
  int? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'RapidTriage',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_sync,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Icon(Icons.account_circle, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.lg,
                  AppSpacing.marginMobile,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPatientInfoSection(),
                    const SizedBox(height: AppSpacing.md),
                    _buildClinicalSection(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPrioritySelection(),
                    const SizedBox(height: AppSpacing.md),
                    _buildDeploymentSection(),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Triage Intake',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Initialize patient record for rapid response.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Patient Info',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Name field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Name (Optional)',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Age slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Age',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _ageValue.round().toString(),
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _ageValue,
            min: 0,
            max: 100,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _ageValue = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Infant',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Adult',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Senior',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Gender
          Text(
            'Gender',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  icon: Icons.male,
                  label: 'Male',
                  isSelected: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GenderButton(
                  icon: Icons.female,
                  label: 'Female',
                  isSelected: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GenderButton(
                  icon: Icons.question_mark,
                  label: 'Unknown',
                  isSelected: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Clinical Presentation',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chief Complaint',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Shortness of breath, chest pain...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Notes / Symptoms',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Observed trauma, vital signs, pupil response...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notification_important,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Triage Priority',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              'REQUIRED',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPriorityCard(
          level: 'P1',
          title: 'Immediate',
          subtitle: 'Life-threatening / Emergent',
          color: AppColors.error,
          textColor: AppColors.error,
          showIcon: true,
          priority: 1,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPriorityCard(
          level: 'P2',
          title: 'Delayed',
          subtitle: 'Serious but stable',
          color: AppColors.p2Urgent,
          textColor: AppColors.p2Urgent,
          showIcon: false,
          priority: 2,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPriorityCard(
          level: 'P3',
          title: 'Minimal',
          subtitle: 'Minor injuries / Walking wounded',
          color: AppColors.p3Delayed,
          textColor: AppColors.onSurface,
          showIcon: false,
          priority: 3,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPriorityCard(
          level: 'P4',
          title: 'Expectant',
          subtitle: 'Palliative care required',
          color: AppColors.inverseSurface,
          textColor: AppColors.inverseOnSurface,
          showIcon: false,
          priority: 4,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPriorityCard(
          level: 'P5',
          title: 'Minor',
          subtitle: 'Discharge or non-urgent',
          color: AppColors.primary,
          textColor: AppColors.onPrimary,
          showIcon: false,
          priority: 5,
        ),
      ],
    );
  }

  Widget _buildPriorityCard({
    required String level,
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required bool showIcon,
    required int priority,
  }) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryFixed.withOpacity(0.3)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  level,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: level == 'P3' ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (showIcon) Icon(Icons.priority_high, color: color, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDeploymentSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Deployment Data',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Location',
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          Icon(
                            Icons.refresh,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '40.7128° N, 74.0060° W',
                        style: AppTypography.textTheme.titleMedium
                            ?.copyWith(color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: AppSpacing.touchTargetMin,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.nfc,
                          color: AppColors.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Scan NFC\nWristband',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.touchTargetMin,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text('Save Locally'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer.withOpacity(0.3)
              : AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
