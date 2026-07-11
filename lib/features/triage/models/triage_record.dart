import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

import 'location.dart';
import 'patient.dart';

class TriageRecord {
  TriageRecord({
    String? id,
    required this.patient,
    required this.chiefComplaint,
    this.clinicalNotes,
    required this.priority,
    required this.status,
    this.location,
    this.nfcTag,
    required this.createdAt,
    required this.syncStatus,
    this.syncError,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final Patient patient;
  final String chiefComplaint;
  final String? clinicalNotes;
  final int priority;
  final String status;
  final TriageLocation? location;
  final String? nfcTag;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final String? syncError;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient.toJson(),
      'chiefComplaint': chiefComplaint,
      'clinicalNotes': clinicalNotes,
      'priority': priority,
      'status': status,
      'location': location?.toJson(),
      'nfcTag': nfcTag,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'syncError': syncError,
    };
  }

  factory TriageRecord.fromJson(Map<String, dynamic> json) {
    return TriageRecord(
      id: json['id'] as String,
      patient: Patient.fromJson(Map<String, dynamic>.from(json['patient'])),
      chiefComplaint: json['chiefComplaint'] as String,
      clinicalNotes: json['clinicalNotes'] as String?,
      priority: json['priority'] as int,
      status: json['status'] as String,
      location: json['location'] != null
          ? TriageLocation.fromJson(Map<String, dynamic>.from(json['location']))
          : null,
      nfcTag: json['nfcTag'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
      ),
      syncError: json['syncError'] as String?,
    );
  }

  TriageRecord copyWith({
    String? id,
    Patient? patient,
    String? chiefComplaint,
    String? clinicalNotes,
    int? priority,
    String? status,
    TriageLocation? location,
    String? nfcTag,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    String? syncError,
    Object? clearSyncError,
  }) {
    return TriageRecord(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      nfcTag: nfcTag ?? this.nfcTag,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
    );
  }
}
