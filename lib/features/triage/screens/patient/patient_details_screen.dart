import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_radius.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/patient_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/priority_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailsScreen> createState() =>
      _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load patient data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientControllerProvider.notifier).load(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientControllerProvider);
    final patient = patientState.patient;

    if (patientState.loading) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (patient == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: AppColors.outline),
                const SizedBox(height: 16),
                Text(
                  'Patient not found',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The patient record could not be loaded.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                    _buildTimeline(patient),
                    const SizedBox(height: 24),
                    _buildClinicalNotes(patient),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(patient),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TriageRecord patient) {
    final priorityColor = _getPriorityColor(patient.priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.patient.name,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${patient.id.substring(0, 8)}',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PriorityBadge(
            label: _getPriorityLabel(patient.priority),
            color: priorityColor,
          ),
          const SizedBox(width: 8),
          Icon(
            patient.syncStatus == SyncStatus.synced
                ? Icons.cloud_done
                : Icons.cloud_off,
            color: patient.syncStatus == SyncStatus.synced
                ? AppColors.primary
                : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBento(TriageRecord patient) {
    final priorityColor = _getPriorityColor(patient.priority);

    return Column(
      children: [
        // Sync banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: patient.syncStatus == SyncStatus.synced
                ? AppColors.primaryContainer
                : AppColors.errorContainer,
            border: Border.all(
              color: patient.syncStatus == SyncStatus.synced
                  ? AppColors.primary
                  : AppColors.error,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                patient.syncStatus == SyncStatus.synced
                    ? Icons.cloud_done
                    : Icons.wifi_off,
                color: patient.syncStatus == SyncStatus.synced
                    ? AppColors.primary
                    : AppColors.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  patient.syncStatus == SyncStatus.synced
                      ? 'Synced to Cloud'
                      : 'Local Storage Only - Pending Sync',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: patient.syncStatus == SyncStatus.synced
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
              ),
              if (patient.syncStatus != SyncStatus.synced)
                TextButton(
                  onPressed: () async {
                    final success = await ref
                        .read(patientControllerProvider.notifier)
                        .markSynced();
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Patient marked as synced'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'SYNC NOW',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                title: 'Priority',
                value: _getPriorityLabel(patient.priority),
                subtitle: 'Triage Level ${patient.priority}',
                color: priorityColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                title: 'Age & Gender',
                value: '${patient.patient.age ?? 'N/A'} yrs',
                subtitle: patient.patient.gender ?? 'Not specified',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                title: 'Status',
                value: patient.status.toUpperCase(),
                subtitle: _formatDate(patient.createdAt),
                color: AppColors.primary,
                icon: Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(TriageRecord patient) {
    // Create timeline events from patient data
    final events = [
      TimelineEvent(
        title: 'Patient Created',
        description: 'Initial triage record created',
        time: _formatTime(patient.createdAt),
        dotColor: AppColors.primary,
        cardColor: AppColors.surfaceContainerLow,
      ),
      if (patient.chiefComplaint.isNotEmpty)
        TimelineEvent(
          title: 'Chief Complaint Recorded',
          description: patient.chiefComplaint,
          time: _formatTime(patient.createdAt),
          dotColor: AppColors.secondary,
          cardColor: AppColors.surfaceContainerLow,
        ),
      if (patient.clinicalNotes != null && patient.clinicalNotes!.isNotEmpty)
        TimelineEvent(
          title: 'Clinical Notes Added',
          description: patient.clinicalNotes!,
          time: _formatTime(patient.createdAt),
          dotColor: AppColors.tertiary,
          cardColor: AppColors.surfaceContainerLow,
        ),
      TimelineEvent(
        title: 'Sync Status',
        description: patient.syncStatus == SyncStatus.synced
            ? 'Patient record synced to cloud'
            : 'Patient record pending sync',
        time: _formatTime(patient.createdAt),
        dotColor: patient.syncStatus == SyncStatus.synced
            ? AppColors.primary
            : AppColors.error,
        cardColor: patient.syncStatus == SyncStatus.synced
            ? AppColors.primaryContainer.withOpacity(0.1)
            : AppColors.errorContainer.withOpacity(0.1),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppColors.onSurface, size: 20),
            const SizedBox(width: 8),
            Text(
              'Triage Timeline',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...events.map(
          (e) => Padding(
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
                          border: Border.all(
                            color: AppColors.background,
                            width: 4,
                          ),
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
                              Text(
                                e.title,
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: e.dotColor,
                                    ),
                              ),
                              Text(
                                e.time,
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            e.description,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClinicalNotes(TriageRecord patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notes, color: AppColors.onSurface, size: 20),
            const SizedBox(width: 8),
            Text(
              'Clinical Notes',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
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
                patient.clinicalNotes ?? 'No clinical notes recorded.',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chief Complaint',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    patient.chiefComplaint,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(TriageRecord patient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
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
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
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
                  onPressed: patient.syncStatus == SyncStatus.synced
                      ? null
                      : () async {
                          final success = await ref
                              .read(patientControllerProvider.notifier)
                              .markSynced();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Patient synced successfully'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            setState(() {});
                          }
                        },
                  icon: const Icon(Icons.sync, size: 20),
                  label: Text(
                    patient.syncStatus == SyncStatus.synced
                        ? 'Synced'
                        : 'Retry Sync',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: patient.syncStatus == SyncStatus.synced
                        ? AppColors.primaryContainer
                        : AppColors.primary,
                    foregroundColor: patient.syncStatus == SyncStatus.synced
                        ? AppColors.primary
                        : AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Patient'),
                        content: const Text(
                          'Are you sure you want to delete this patient record? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final success = await ref
                          .read(patientControllerProvider.notifier)
                          .delete();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Patient deleted successfully'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        context.pop();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final String time;
  final Color dotColor;
  final Color cardColor;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.dotColor,
    required this.cardColor,
  });
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          if (icon != null) ...[
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              value,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
