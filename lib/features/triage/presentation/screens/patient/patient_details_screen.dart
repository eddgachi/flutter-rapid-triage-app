import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../dummy/dummy_data.dart';
import '../../widgets/shared/priority_badge.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patients.first;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, patient),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewBento(patient),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    _buildClinicalNotes(),
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

  Widget _buildAppBar(BuildContext context, DummyPatient patient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name,
                    style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('ID: ${patient.id}',
                    style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PriorityBadge(label: patient.triageLevel, color: patient.triageColor),
          const SizedBox(width: 8),
          const Icon(Icons.cloud_sync, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildOverviewBento(DummyPatient patient) {
    return Column(
      children: [
        // Sync banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: AppColors.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Local Storage Only - Pending Sync',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    )),
              ),
              TextButton(
                onPressed: () {},
                child: Text('PUSH NOW',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Details cards
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                title: 'Symptoms',
                value: patient.symptoms,
                subtitle: 'SPO2: 88% | BP: 90/60',
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                title: 'Location',
                value: patient.location,
                subtitle: 'Lat: 40.7128 | Lon: -74.0060',
                color: AppColors.secondary,
                icon: Icons.location_on,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                title: 'NFC ID',
                value: patient.nfcId,
                subtitle: 'Validated ${patient.createdAt}',
                color: AppColors.primary,
                icon: Icons.contactless,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final events = DummyData.timelineEvents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppColors.onSurface, size: 20),
            const SizedBox(width: 8),
            Text('Triage Timeline',
                style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.onSurface)),
          ],
        ),
        const SizedBox(height: 16),
        ...events.map((e) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: e.dotColor,
                            border: Border.all(color: AppColors.background, width: 4),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: e.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.title,
                                    style: AppTypography.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: e.dotColor,
                                    )),
                                Text(e.time,
                                    style: AppTypography.textTheme.labelMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(e.description,
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildClinicalNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notes, color: AppColors.onSurface, size: 20),
            const SizedBox(width: 8),
            Text('Clinical Notes',
                style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.onSurface)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient presents with sharp trauma to the upper thoracic cavity. Significant bleeding controlled via pressure dressing. Breath sounds absent on the left side. Needle decompression performed at 12:42 PM with positive air release. Monitoring for tension pneumothorax recurrence.',
                style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 96,
                      height: 96,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.image, color: AppColors.outline),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync, size: 20),
                  label: const Text('Retry Sync'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData? icon;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1,
              )),
          const SizedBox(height: 4),
          if (icon != null) ...[
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(value,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ] else
            Text(value,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                )),
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              )),
        ],
      ),
    );
  }
}
