import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../widgets/shared/bottom_nav_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  children: [
                    _buildLogoSection(context),
                    const SizedBox(height: 24),
                    _buildTechStack(context),
                    const SizedBox(height: 24),
                    _buildLegalSection(context),
                    const SizedBox(height: 32),
                    _buildFooter(context),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.cloud_sync,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
              ],
            ),
            child: Icon(
              Icons.emergency,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'RapidTriage',
            style: AppTypography.textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 2.4.0-Stable',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Emergency Response Systems Group',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clinical Decision Support Unit',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.memory,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'System Core',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TechCard(
                label: 'Framework',
                title: 'Flutter',
                subtitle: 'High-performance cross-platform rendering engine.',
                labelColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TechCard(
                label: 'State Management',
                title: 'Riverpod',
                subtitle: 'Compile-safe reactive data flow architecture.',
                labelColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TechCard(
                label: 'Local Storage',
                title: 'Hive',
                subtitle: 'NoSQL offline-first medical record persistence.',
                labelColor: AppColors.tertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TechCard(
                label: 'Navigation',
                title: 'GoRouter',
                subtitle: 'Declarative deep-linking and routing logic.',
                labelColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.gavel,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Compliance & Legal',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _LegalLink(icon: Icons.privacy_tip, label: 'Privacy Policy'),
        const SizedBox(height: 8),
        _LegalLink(icon: Icons.description, label: 'Terms of Service'),
        const SizedBox(height: 8),
        _LegalLink(icon: Icons.verified, label: 'Open Source Licenses'),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          '\u00a9 2024 Emergency Response Systems Group',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Designed for clinical environments.',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final Color labelColor;

  const _TechCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LegalLink({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
        ],
      ),
    );
  }
}
