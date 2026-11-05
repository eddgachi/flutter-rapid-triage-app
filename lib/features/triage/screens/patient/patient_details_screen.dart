// lib/features/triage/screens/patient/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_decorations.dart';
import 'package:flutter_rapid_triage/core/theme/app_radius.dart';
import 'package:flutter_rapid_triage/core/theme/app_spacing.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/core/widgets/empty_state_widget.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/history_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/home_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/patient_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/queue_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/sync_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/patient.dart'
    as patient_model;
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/incident_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientControllerProvider.notifier).load(widget.patientId);
    });
  }

  void _goBack() {
    // Invalidate providers to refresh data when returning
    ref.invalidate(homeControllerProvider);
    ref.invalidate(queueControllerProvider);
    ref.invalidate(historyControllerProvider);
    context.go('/queue');
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientControllerProvider);
    final syncState = ref.watch(syncControllerProvider);
    final patient = patientState.patient;

    if (patientState.loading && patient == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
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
                const EmptyStateWidget(
                  icon: Icons.person_off,
                  title: 'Patient not found',
                  message: 'The patient record could not be loaded.',
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _goBack, child: const Text('Go Back')),
              ],
            ),
          ),
        ),
      );
    }

    final priorityColor = _getPriorityColor(context, patient.priority);
    final heroFg = _heroForeground(patient.priority);

    return Scaffold(
      backgroundColor: priorityColor,
      body: Column(
        children: [
          _buildHero(context, patient, priorityColor, heroFg),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Column(
                  children: [
                    if (!syncState.isConnected) _buildOfflineBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickStats(context, patient),
                            const SizedBox(height: 20),
                            _buildSyncStatusBanner(patient),
                            const SizedBox(height: 20),
                            _buildLocationSection(patient),
                            const SizedBox(height: 24),
                            _buildClinicalSection(patient),
                            const SizedBox(height: 24),
                            _buildTimeline(patient),
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
      ),
      bottomSheet: _buildStickyFooter(patient, patientState),
    );
  }

  // ==================== HERO ====================

  Widget _buildHero(
    BuildContext context,
    TriageRecord patient,
    Color priorityColor,
    Color fg,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            priorityColor,
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.18),
              priorityColor,
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeroIconButton(
                    icon: Icons.arrow_back,
                    foreground: fg,
                    onTap: _goBack,
                  ),
                  _HeroIconButton(
                    icon: Icons.edit,
                    foreground: fg,
                    onTap: () => _showEditDialog(patient),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Incident #${patient.id.length > 8 ? patient.id.substring(0, 8).toUpperCase() : patient.id.toUpperCase()}',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: fg.withValues(alpha: 0.75),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroChip(
                          icon: Icons.priority_high,
                          label: _getPriorityLabel(patient.priority),
                          foreground: fg,
                        ),
                        _HeroChip(
                          icon: Icons.cake_outlined,
                          label:
                              '${patient.patient.age ?? 'N/A'} • ${patient.patient.gender ?? 'Unknown'}',
                          foreground: fg,
                        ),
                        _HeroChip(
                          icon: Icons.schedule,
                          label: _formatTime(patient.createdAt),
                          foreground: fg,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode - Changes will sync when connected',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK STATS ====================

  Widget _buildQuickStats(BuildContext context, TriageRecord patient) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.flag_outlined,
            label: 'Status',
            value: patient.status.toUpperCase(),
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            icon: Icons.event_note_outlined,
            label: 'Logged',
            value: _formatDate(patient.createdAt),
            color: scheme.secondary,
          ),
        ),
      ],
    );
  }

  // ==================== SYNC STATUS ====================

  Widget _buildSyncStatusBanner(TriageRecord patient) {
    final scheme = Theme.of(context).colorScheme;

    if (patient.syncStatus == SyncStatus.synced) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(
          context,
          color: scheme.primaryContainer,
          borderColor: scheme.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_done, color: scheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Synced to Cloud',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Failed or pending
    final isFailed = patient.syncStatus == SyncStatus.failed;
    final isSyncing = patient.syncStatus == SyncStatus.syncing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(
        context,
        color: isFailed ? scheme.errorContainer : scheme.surfaceContainerLow,
        borderColor: isFailed
            ? scheme.error.withValues(alpha: 0.4)
            : isSyncing
            ? scheme.primary.withValues(alpha: 0.4)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFailed
                    ? Icons.error
                    : isSyncing
                    ? Icons.sync
                    : Icons.cloud_off,
                color: isFailed
                    ? scheme.error
                    : isSyncing
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFailed
                      ? 'Sync Failed'
                      : isSyncing
                      ? 'Syncing...'
                      : 'Local Storage Only',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isFailed
                        ? scheme.onErrorContainer
                        : scheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: isSyncing
                    ? null
                    : () async {
                        final controller = ref.read(
                          patientControllerProvider.notifier,
                        );
                        await controller.syncRecord();
                        // Invalidate other providers to reflect changes
                        ref.invalidate(homeControllerProvider);
                        ref.invalidate(queueControllerProvider);
                        ref.invalidate(historyControllerProvider);
                        setState(() {});
                      },
                child: Text(
                  isSyncing ? '...' : 'RETRY',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Show sync error reason if failed
          if (isFailed &&
              patient.syncError != null &&
              patient.syncError!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: scheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.syncError!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== LOCATION ====================

  Widget _buildLocationSection(TriageRecord patient) {
    final scheme = Theme.of(context).colorScheme;

    if (patient.location == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(
          context,
          color: scheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: scheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No location data captured',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final location = patient.location!;
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.location_on, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incident Location',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.open_in_new, color: scheme.primary),
                  onPressed: () async {
                    final uri = Uri.parse(googleMapsUrl);
                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Google Maps'),
                          ),
                        );
                      }
                    }
                  },
                  tooltip: 'Open in Google Maps',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          IncidentMapCard(
            incidents: [patient],
            focusRecordId: patient.id,
            height: 160,
            showCurrentLocation: false,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}'
              '${location.address != null ? ' • ${location.address}' : ''}',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CLINICAL ====================

  Widget _buildClinicalSection(TriageRecord patient) {
    final scheme = Theme.of(context).colorScheme;
    final priorityColor = _getPriorityColor(context, patient.priority);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_information_outlined,
              color: scheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Clinical Summary',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHIEF COMPLAINT',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                patient.chiefComplaint,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.flatCard(
            context,
            color: scheme.surfaceContainerLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CLINICAL NOTES',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                patient.clinicalNotes ?? 'No clinical notes recorded.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TIMELINE ====================

  Widget _buildTimeline(TriageRecord patient) {
    final scheme = Theme.of(context).colorScheme;
    final events = [
      TimelineEvent(
        title: 'Patient Created',
        description: 'Initial triage record created',
        time: _formatTime(patient.createdAt),
        dotColor: scheme.primary,
      ),
      if (patient.location != null)
        TimelineEvent(
          title: 'Location Captured',
          description:
              'GPS coordinates recorded at ${patient.location!.latitude.toStringAsFixed(4)}, ${patient.location!.longitude.toStringAsFixed(4)}',
          time: _formatTime(patient.createdAt),
          dotColor: scheme.secondary,
        ),
      TimelineEvent(
        title: 'Sync Status',
        description: _getSyncDescription(patient),
        time: _formatTime(patient.createdAt),
        dotColor: patient.syncStatus == SyncStatus.synced
            ? scheme.primary
            : patient.syncStatus == SyncStatus.failed
            ? scheme.error
            : scheme.onSurfaceVariant,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: scheme.onSurface, size: 20),
            const SizedBox(width: 8),
            Text(
              'Timeline',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...events.asMap().entries.map((entry) {
          final isLast = entry.key == events.length - 1;
          final e = entry.value;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.dotColor,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: scheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.title,
                              style: AppTypography.textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                            ),
                            Text(
                              e.time,
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(color: scheme.outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.description,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getSyncDescription(TriageRecord patient) {
    switch (patient.syncStatus) {
      case SyncStatus.synced:
        return 'Patient record synced to cloud';
      case SyncStatus.syncing:
        return 'Sync in progress...';
      case SyncStatus.failed:
        final error = patient.syncError;
        if (error != null && error.isNotEmpty) {
          return 'Sync failed: $error';
        }
        return 'Patient record failed to sync';
      case SyncStatus.pending:
        return 'Patient record pending sync';
    }
  }

  // ==================== FOOTER ====================

  Widget _buildStickyFooter(TriageRecord patient, PatientState patientState) {
    final scheme = Theme.of(context).colorScheme;
    final isSynced = patient.syncStatus == SyncStatus.synced;
    final isFailed = patient.syncStatus == SyncStatus.failed;
    final isSyncing = patient.syncStatus == SyncStatus.syncing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: AppDecorations.barShadow(context),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: (isSynced || patientState.loading || isSyncing)
                      ? null
                      : () async {
                          final controller = ref.read(
                            patientControllerProvider.notifier,
                          );
                          final success = await controller.syncRecord();

                          ref.invalidate(homeControllerProvider);
                          ref.invalidate(queueControllerProvider);
                          ref.invalidate(historyControllerProvider);

                          if (mounted) {
                            final updatedPatient = ref
                                .read(patientControllerProvider)
                                .patient;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Patient synced successfully'
                                      : 'Sync failed: ${updatedPatient?.syncError ?? "Unknown error"}',
                                ),
                                backgroundColor: success
                                    ? scheme.primary
                                    : scheme.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            setState(() {});
                          }
                        },
                  icon: patientState.loading || isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isSynced
                              ? Icons.check_circle
                              : isFailed
                              ? Icons.replay
                              : Icons.cloud_sync,
                          size: 20,
                        ),
                  label: Text(
                    patientState.loading || isSyncing
                        ? 'Syncing...'
                        : isSynced
                        ? 'Synced'
                        : isFailed
                        ? 'Retry Sync'
                        : 'Sync Now',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isSynced
                        ? scheme.primaryContainer
                        : isFailed
                        ? scheme.error
                        : scheme.primary,
                    foregroundColor: isSynced
                        ? scheme.onPrimaryContainer
                        : scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: patientState.isDeleting || patientState.loading
                    ? null
                    : () async {
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
                                  foregroundColor: scheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true && mounted) {
                          final success = await ref
                              .read(patientControllerProvider.notifier)
                              .delete();

                          ref.invalidate(homeControllerProvider);
                          ref.invalidate(queueControllerProvider);
                          ref.invalidate(historyControllerProvider);

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Patient deleted successfully',
                                  ),
                                  backgroundColor: scheme.primary,
                                ),
                              );
                              context.go('/queue');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Failed to delete patient',
                                  ),
                                  backgroundColor: scheme.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: patientState.isDeleting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.error,
                        ),
                      )
                    : const Icon(Icons.delete_outline, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(TriageRecord patient) {
    final nameController = TextEditingController(text: patient.patient.name);
    final complaintController = TextEditingController(
      text: patient.chiefComplaint,
    );
    final notesController = TextEditingController(
      text: patient.clinicalNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complaintController,
                decoration: const InputDecoration(labelText: 'Chief Complaint'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Clinical Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Patient name is required'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              final updated = patient.copyWith(
                patient: patient_model.Patient(
                  name: nameController.text.trim(),
                  age: patient.patient.age,
                  gender: patient.patient.gender,
                ),
                chiefComplaint: complaintController.text.trim(),
                clinicalNotes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );

              final controller = ref.read(patientControllerProvider.notifier);
              final success = await controller.update(updated);

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Patient record updated'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );

                ref.invalidate(homeControllerProvider);
                ref.invalidate(queueControllerProvider);
                ref.invalidate(historyControllerProvider);

                setState(() {});
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  Color _getPriorityColor(BuildContext context, int priority) {
    switch (priority) {
      case 1:
        return Theme.of(context).colorScheme.error;
      case 2:
        return AppColors.p2Urgent;
      case 3:
        return AppColors.p3Delayed;
      case 4:
        return Theme.of(context).colorScheme.inverseSurface;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// P3's priority color is a light gold — white text/icons on it would be
  /// unreadable, so that one case gets dark foreground instead.
  Color _heroForeground(int priority) {
    return priority == 3 ? Colors.black87 : Colors.white;
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

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.dotColor,
  });
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: foreground.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: foreground, size: 20),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: AppDecorations.flatCard(
        context,
        color: scheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
