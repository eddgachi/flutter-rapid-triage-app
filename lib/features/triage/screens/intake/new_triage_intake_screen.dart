import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_radius.dart';
import 'package:flutter_rapid_triage/core/theme/app_spacing.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/intake_controller.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewTriageIntakeScreen extends ConsumerStatefulWidget {
  const NewTriageIntakeScreen({super.key});

  @override
  ConsumerState<NewTriageIntakeScreen> createState() =>
      _NewTriageIntakeScreenState();
}

class _NewTriageIntakeScreenState extends ConsumerState<NewTriageIntakeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  double _ageValue = 30;
  int? _selectedPriority;

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen for submission results
    ref.listenManual<IntakeState>(intakeControllerProvider, (previous, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient record saved successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final intakeState = ref.watch(intakeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'RapidTriage',
              showBack: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_sync,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.account_circle, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.lg,
                    AppSpacing.marginMobile,
                    120, // Extra space for sticky footer
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
                    ],
                  ),
                ),
              ),
            ),
            _buildStickyFooter(intakeState),
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
                'Full Name *',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
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
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error, width: 2),
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
            divisions: 100,
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
                  isSelected: _selectedGender == 'Male',
                  onTap: () => setState(() => _selectedGender = 'Male'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GenderButton(
                  icon: Icons.female,
                  label: 'Female',
                  isSelected: _selectedGender == 'Female',
                  onTap: () => setState(() => _selectedGender = 'Female'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GenderButton(
                  icon: Icons.question_mark,
                  label: 'Unknown',
                  isSelected: _selectedGender == 'Unknown',
                  onTap: () => setState(() => _selectedGender = 'Unknown'),
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
                'Chief Complaint *',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _conditionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter chief complaint';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Shortness of breath, chest pain...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error, width: 2),
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
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Observed trauma, vital signs, pupil response...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                  'Triage Priority *',
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
        const SizedBox(height: AppSpacing.md),
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
              ? AppColors.primaryFixed.withOpacity(0.2)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter(IntakeState intakeState) {
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
            onPressed: intakeState.isLoading
                ? null
                : () async {
                    // Validate form
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    // Validate priority
                    if (_selectedPriority == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a triage priority'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    // Get the controller
                    final controller = ref.read(
                      intakeControllerProvider.notifier,
                    );

                    // Submit the form
                    await controller.submit(
                      patientName: _nameController.text.trim(),
                      age: _ageValue.round(),
                      gender: _selectedGender,
                      chiefComplaint: _conditionController.text.trim(),
                      clinicalNotes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                      priority: _selectedPriority!,
                      status: '',
                    );
                  },
            icon: intakeState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              intakeState.isLoading ? "Saving..." : "Save Patient Record",
            ),
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
            width: isSelected ? 2 : 1,
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
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
