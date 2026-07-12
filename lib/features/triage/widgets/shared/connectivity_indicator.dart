import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            ? Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.3)
            : Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.3),
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
                ? Theme.of(context).colorScheme.primary
                : syncState.isConnected
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Theme.of(context).colorScheme.error,
          ),
          if (syncState.isSyncing) ...{
            const SizedBox(width: 4),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
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
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.error,
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
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
              ? Theme.of(context).colorScheme.primary
              : syncState.isConnected
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.error,
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
}
