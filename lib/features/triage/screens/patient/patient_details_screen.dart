// lib/features/triage/screens/patient/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_radius.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/history_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/home_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/patient_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/queue_controller.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/sync_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/patient.dart'
    as patient_model;
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/widgets/shared/connectivity_indicator.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientControllerProvider.notifier).load(widget.patientId);
    });
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
                  onPressed: () {
                    // Invalidate providers to refresh data when returning
                    ref.invalidate(homeControllerProvider);
                    ref.invalidate(queueControllerProvider);
                    ref.invalidate(historyControllerProvider);
                    context.go('/queue'); // Fixed: Use go() instead of pop()
                  },
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
            _buildAppBar(context, patient, syncState),
            if (!syncState.isConnected) _buildOfflineBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  140,
                ), // Increased bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSyncStatusBanner(patient),
                    const SizedBox(height: 16),
                    _buildOverviewBento(patient),
                    const SizedBox(height: 24),
                    _buildLocationSection(patient),
                    const SizedBox(height: 24),
                    _buildTimeline(patient),
                    const SizedBox(height: 24),
                    _buildClinicalNotes(patient),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(patient, patientState),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.errorContainer,
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode - Changes will sync when connected',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    TriageRecord patient,
    SyncState syncState,
  ) {
    final priorityColor = _getPriorityColor(patient.priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 64,
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
          // Fixed back button - using context.pop() from go_router
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () {
              // Invalidate providers to refresh data when returning
              ref.invalidate(homeControllerProvider);
              ref.invalidate(queueControllerProvider);
              ref.invalidate(historyControllerProvider);
              // Use go_router's pop method
              context.go('/queue');
            },
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
                  'ID: ${patient.id.length > 8 ? patient.id.substring(0, 8) : patient.id}',
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
          // Connectivity indicator
          const ConnectivityIndicator(),
        ],
      ),
    );
  }

  Widget _buildSyncStatusBanner(TriageRecord patient) {
    if (patient.syncStatus == SyncStatus.synced) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_done, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Synced to Cloud',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
      decoration: BoxDecoration(
        color: isFailed
            ? AppColors.errorContainer
            : AppColors.surfaceContainerLow,
        border: Border.all(
          color: isFailed
              ? AppColors.error
              : isSyncing
              ? AppColors.primary
              : AppColors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
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
                    ? AppColors.error
                    : isSyncing
                    ? AppColors.primary
                    : AppColors.error,
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
                    color: isFailed ? AppColors.error : AppColors.onSurface,
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
                    color: AppColors.primary,
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
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.syncError!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
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

  Widget _buildOverviewBento(TriageRecord patient) {
    final priorityColor = _getPriorityColor(patient.priority);

    return Row(
      children: [
        Expanded(
          child: _DetailCard(
            title: 'Priority',
            value: _getPriorityLabel(patient.priority),
            subtitle: 'Triage Level P${patient.priority}',
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
    );
  }

  Widget _buildLocationSection(TriageRecord patient) {
    if (patient.location == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No location data captured',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Location Captured',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude: ${location.latitude.toStringAsFixed(6)}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longitude: ${location.longitude.toStringAsFixed(6)}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (location.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        location.address!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, color: AppColors.primary),
                onPressed: () {
                  // Open in Google Maps
                  // You can use url_launcher package here
                  // launchUrl(Uri.parse(googleMapsUrl));
                },
                tooltip: 'Open in Google Maps',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(TriageRecord patient) {
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
      if (patient.location != null)
        TimelineEvent(
          title: 'Location Captured',
          description:
              'GPS coordinates recorded at ${patient.location!.latitude.toStringAsFixed(4)}, ${patient.location!.longitude.toStringAsFixed(4)}',
          time: _formatTime(patient.createdAt),
          dotColor: AppColors.primary,
          cardColor: AppColors.surfaceContainerLow,
        ),
      TimelineEvent(
        title: 'Sync Status',
        description: _getSyncDescription(patient),
        time: _formatTime(patient.createdAt),
        dotColor: patient.syncStatus == SyncStatus.synced
            ? AppColors.primary
            : patient.syncStatus == SyncStatus.failed
            ? AppColors.error
            : AppColors.onSurfaceVariant,
        cardColor: patient.syncStatus == SyncStatus.synced
            ? AppColors.primaryContainer.withOpacity(0.1)
            : patient.syncStatus == SyncStatus.failed
            ? AppColors.errorContainer.withOpacity(0.1)
            : AppColors.surfaceContainerLow.withOpacity(0.1),
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
                  Expanded(
                    child: Text(
                      patient.chiefComplaint,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
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

  Widget _buildStickyFooter(TriageRecord patient, PatientState patientState) {
    final isSynced = patient.syncStatus == SyncStatus.synced;
    final isFailed = patient.syncStatus == SyncStatus.failed;
    final isSyncing = patient.syncStatus == SyncStatus.syncing;

    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Edit button - with improved styling
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: patientState.isDeleting || patientState.loading
                      ? null
                      : () => _showEditDialog(patient),
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text(''),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    side: const BorderSide(color: AppColors.outline),
                    foregroundColor: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Sync button - with improved styling and feedback
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: (isSynced || patientState.loading || isSyncing)
                      ? null
                      : () async {
                          final controller = ref.read(
                            patientControllerProvider.notifier,
                          );
                          final success = await controller.syncRecord();

                          // Invalidate providers to refresh
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
                                    ? AppColors.primary
                                    : AppColors.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            setState(() {});
                          }
                        },
                  icon: patientState.loading || isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isFailed ? Icons.replay : Icons.cloud_sync,
                          size: 20,
                        ),
                  label: Text(
                    patientState.loading || isSyncing
                        ? 'Syncing...'
                        : isSynced
                        ? 'Synced ✓'
                        : isFailed
                        ? 'Retry'
                        : 'Sync',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isSynced
                        ? AppColors.primaryContainer
                        : isFailed
                        ? AppColors.error
                        : AppColors.primary,
                    foregroundColor: isSynced
                        ? AppColors.primary
                        : AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: isSynced ? 0 : 2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Delete button - with improved styling
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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

                          if (shouldDelete == true && mounted) {
                            final success = await ref
                                .read(patientControllerProvider.notifier)
                                .delete();

                            // Invalidate providers to refresh
                            ref.invalidate(homeControllerProvider);
                            ref.invalidate(queueControllerProvider);
                            ref.invalidate(historyControllerProvider);

                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Patient deleted successfully',
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                // Navigate back to queue
                                context.go('/queue');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to delete patient'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  icon: patientState.isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Icon(Icons.delete, size: 20),
                  label: const Text(''),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complaintController,
                decoration: const InputDecoration(
                  labelText: 'Chief Complaint',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Clinical Notes',
                  border: OutlineInputBorder(),
                ),
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
                  const SnackBar(
                    content: Text('Patient name is required'),
                    backgroundColor: AppColors.error,
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
                  const SnackBar(
                    content: Text('Patient record updated'),
                    backgroundColor: AppColors.primary,
                  ),
                );

                // Invalidate to refresh
                ref.invalidate(homeControllerProvider);
                ref.invalidate(queueControllerProvider);
                ref.invalidate(historyControllerProvider);

                // Refresh the current view
                setState(() {});
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
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
          ] else ...[
            Text(
              value,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
