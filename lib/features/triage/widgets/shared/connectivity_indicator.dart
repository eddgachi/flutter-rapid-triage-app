import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/sync_controller.dart';

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: syncState.isConnected
            ? AppColors.secondaryContainer.withOpacity(0.3)
            : AppColors.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            syncState.isSyncing
                ? Icons.sync
                : syncState.isConnected
                ? Icons.cloud_done
                : Icons.cloud_off,
            size: 18,
            color: syncState.isSyncing
                ? AppColors.primary
                : syncState.isConnected
                ? AppColors.onSecondaryContainer
                : AppColors.error,
          ),
          if (syncState.isSyncing) ...{
            const SizedBox(width: 4),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          },
          const SizedBox(width: 4),
          Text(
            syncState.isSyncing
                ? 'Syncing...'
                : syncState.isConnected
                ? '${syncState.syncedCount} Synced'
                : 'Offline',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: syncState.isConnected
                  ? AppColors.onSecondaryContainer
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// A sync indicator that can be tapped to trigger a manual sync.
class SyncButton extends ConsumerWidget {
  final double size;

  const SyncButton({super.key, this.size = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);

    return GestureDetector(
      onTap: syncState.isSyncing
          ? null
          : () async {
              await ref.read(syncControllerProvider.notifier).syncNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      syncState.isConnected
                          ? 'Sync completed: ${syncState.syncedCount} synced, ${syncState.failedCount} failed'
                          : 'No internet connection',
                    ),
                    backgroundColor: syncState.isConnected
                        ? AppColors.primary
                        : AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
      child: Tooltip(
        message: syncState.isSyncing
            ? 'Syncing...'
            : 'Tap to sync\n${syncState.syncedCount} synced | ${syncState.failedCount} failed',
        child: Icon(
          syncState.isSyncing
              ? Icons.sync
              : syncState.isConnected
              ? Icons.cloud_sync
              : Icons.cloud_off,
          size: size,
          color: syncState.isSyncing
              ? AppColors.primary
              : syncState.isConnected
              ? AppColors.onSurfaceVariant
              : AppColors.error,
        ),
      ),
    );
  }
}

/// A banner shown at the top when offline.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    if (syncState.isConnected) return const SizedBox.shrink();

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
}
