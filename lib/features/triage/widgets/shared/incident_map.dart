import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/theme/app_colors.dart';
import 'package:flutter_rapid_triage/core/theme/app_radius.dart';
import 'package:flutter_rapid_triage/core/theme/app_typography.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as ll;

/// A small live map, backed by OpenStreetMap (no API key needed), showing
/// the user's current position plus triage records that have a captured
/// location as priority-colored pins. Used both as the "nearby incidents"
/// overview on Home and as the single-incident locator on Patient Details.
class IncidentMapCard extends ConsumerStatefulWidget {
  const IncidentMapCard({
    super.key,
    required this.incidents,
    this.height = 220,
    this.focusRecordId,
    this.onIncidentTap,
    this.showCurrentLocation = true,
  });

  /// Records to plot. Only ones with a non-null [TriageRecord.location]
  /// are shown.
  final List<TriageRecord> incidents;
  final double height;

  /// When set, the map centers on this record instead of the user's
  /// current position, and only that record's pin is drawn — used on
  /// Patient Details to focus a single incident.
  final String? focusRecordId;

  final void Function(TriageRecord record)? onIncidentTap;
  final bool showCurrentLocation;

  @override
  ConsumerState<IncidentMapCard> createState() => _IncidentMapCardState();
}

class _IncidentMapCardState extends ConsumerState<IncidentMapCard> {
  static const _fallbackCenter = ll.LatLng(
    AppConstants.fallbackLatitude,
    AppConstants.fallbackLongitude,
  );

  ll.LatLng? _currentPosition;
  bool _resolvedLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _resolveCurrentPosition();
    } else {
      _resolvedLocation = true;
    }
  }

  Future<void> _resolveCurrentPosition() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final available = await locationService.isLocationAvailable();
      if (!available) return;

      final position = await locationService.getCurrentPositionWithTimeout(
        timeout: const Duration(seconds: 4),
      );
      if (mounted) {
        setState(() {
          _currentPosition = ll.LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {
      // Keep showing the map centered on incidents/fallback.
    } finally {
      if (mounted) setState(() => _resolvedLocation = true);
    }
  }

  List<TriageRecord> get _plottable {
    final withLocation = widget.incidents
        .where((r) => r.location != null)
        .toList();
    if (widget.focusRecordId == null) return withLocation;
    return withLocation.where((r) => r.id == widget.focusRecordId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final incidents = _plottable;

    final ll.LatLng center;
    if (widget.focusRecordId != null && incidents.isNotEmpty) {
      final loc = incidents.first.location!;
      center = ll.LatLng(loc.latitude, loc.longitude);
    } else {
      center = _currentPosition ?? _fallbackCenter;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_resolvedLocation)
              Container(color: scheme.surfaceContainerHighest)
            else
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: widget.focusRecordId != null ? 15 : 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_rapid_triage',
                  ),
                  MarkerLayer(
                    markers: [
                      if (widget.showCurrentLocation &&
                          _currentPosition != null)
                        Marker(
                          point: _currentPosition!,
                          width: 22,
                          height: 22,
                          child: _CurrentLocationDot(color: scheme.primary),
                        ),
                      for (final record in incidents)
                        Marker(
                          point: ll.LatLng(
                            record.location!.latitude,
                            record.location!.longitude,
                          ),
                          width: 36,
                          height: 36,
                          alignment: Alignment.topCenter,
                          child: _IncidentPin(
                            color: _priorityColor(record.priority, scheme),
                            onTap: widget.onIncidentTap == null
                                ? null
                                : () => widget.onIncidentTap!(record),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            // Attribution is required by the OSM tile usage policy.
            Positioned(
              right: 6,
              bottom: 4,
              child: Text(
                '© OpenStreetMap',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  fontSize: 9,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(int priority, ColorScheme scheme) {
    switch (priority) {
      case 1:
        return scheme.error;
      case 2:
        return AppColors.p2Urgent;
      case 3:
        return AppColors.p3Delayed;
      case 4:
        return scheme.inverseSurface;
      default:
        return scheme.primary;
    }
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.25),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}

class _IncidentPin extends StatelessWidget {
  const _IncidentPin({required this.color, this.onTap});

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_hospital,
              size: 12,
              color: Colors.white,
            ),
          ),
          CustomPaint(size: const Size(8, 5), painter: _PinTailPainter(color)),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2 - 4, 0)
      ..lineTo(size.width / 2 + 4, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
