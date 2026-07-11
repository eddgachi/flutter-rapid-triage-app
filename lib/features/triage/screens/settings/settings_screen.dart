import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../widgets/shared/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Settings',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfile(),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Organization',
                      children: [
                        _SettingTile(
                          icon: Icons.local_hospital,
                          title: 'Assigned Hospital',
                          subtitle: 'Central Metropolitan Trauma Center',
                          trailing: Icons.chevron_right,
                        ),
                        const _SettingDivider(),
                        _SettingTile(
                          icon: Icons.badge,
                          title: 'System Access Permissions',
                          subtitle: 'Level 3 Admin Access',
                          trailing: Icons.lock,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Preferences',
                      children: [
                        _SettingToggle(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          value: false,
                          onChanged: (_) {},
                        ),
                        const _SettingDivider(),
                        _SettingTile(
                          icon: Icons.language,
                          title: 'System Language',
                          subtitle: 'English (US)',
                          trailing: Icons.expand_more,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Hardware Integrations',
                      children: [
                        _SettingToggle(
                          icon: Icons.location_on,
                          title: 'GPS Tracking',
                          value: true,
                          onChanged: (_) {},
                        ),
                        const _SettingDivider(),
                        _SettingToggle(
                          icon: Icons.nfc,
                          title: 'NFC Bracelet Scanning',
                          value: true,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Data & Synchronization',
                      children: [
                        _SettingToggle(
                          icon: Icons.sync,
                          title: 'Background Auto-sync',
                          value: true,
                          onChanged: (_) {},
                        ),
                        const _SettingDivider(),
                        _SettingToggle(
                          icon: Icons.wifi,
                          title: 'Sync over WiFi only',
                          value: false,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Device Storage',
                      children: [
                        _SettingTile(
                          icon: Icons.download,
                          title: 'Export Offline Logs (.csv)',
                          trailing: Icons.arrow_outward,
                        ),
                        const _SettingDivider(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 56,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_sweep,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Clear Local Cache',
                                  style: AppTypography.textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ),
                              Text(
                                '124 MB',
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.errorContainer,
                          foregroundColor: AppColors.onErrorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'RapidTriage Emergency Protocol Suite',
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          Text(
                            'Version 4.12.0 (Build 8829)',
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/about'),
                        child: Text(
                          'About RapidTriage',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 3),
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
          const Icon(Icons.cloud_sync, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed,
            ),
            child: const Icon(Icons.person, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'James Wilson',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Senior Lead Paramedic',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Badge #PR-4492',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Icon(trailing, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.outlineVariant,
    );
  }
}
