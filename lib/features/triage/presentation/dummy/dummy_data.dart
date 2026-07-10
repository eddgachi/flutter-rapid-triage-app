import 'package:flutter/material.dart';

class DummyPatient {
  final String id;
  final String name;
  final String triageLevel;
  final Color triageColor;
  final String symptoms;
  final String location;
  final String nfcId;
  final String createdAt;
  final String syncStatus;
  final Color syncColor;

  const DummyPatient({
    required this.id,
    required this.name,
    required this.triageLevel,
    required this.triageColor,
    required this.symptoms,
    required this.location,
    required this.nfcId,
    required this.createdAt,
    required this.syncStatus,
    required this.syncColor,
  });
}

class DummyQueueItem {
  final String id;
  final String name;
  final String triageLevel;
  final Color triageColor;
  final String createdAt;
  final String syncStatus;
  final Color syncColor;

  const DummyQueueItem({
    required this.id,
    required this.name,
    required this.triageLevel,
    required this.triageColor,
    required this.createdAt,
    required this.syncStatus,
    required this.syncColor,
  });
}

class DummySyncRecord {
  final String id;
  final String patientName;
  final String triageLevel;
  final String description;
  final String time;
  final String status;
  final Color statusColor;
  final Color leftColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? databaseId;

  const DummySyncRecord({
    required this.id,
    required this.patientName,
    required this.triageLevel,
    required this.description,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.leftColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.databaseId,
  });
}

class DummyActivity {
  final String patientId;
  final String patientName;
  final String triageLevel;
  final Color triageColor;
  final String time;
  final String syncStatus;
  final Color syncColor;

  const DummyActivity({
    required this.patientId,
    required this.patientName,
    required this.triageLevel,
    required this.triageColor,
    required this.time,
    required this.syncStatus,
    required this.syncColor,
  });
}

class DummyTimelineEvent {
  final String title;
  final String time;
  final String description;
  final Color dotColor;
  final Color cardColor;

  const DummyTimelineEvent({
    required this.title,
    required this.time,
    required this.description,
    required this.dotColor,
    required this.cardColor,
  });
}

class DummyData {
  DummyData._();

  static const Color p1Color = Color(0xFFBA1A1A);
  static const Color p2Color = Color(0xFFFF8C00);
  static const Color p3Color = Color(0xFFFFD700);
  static const Color p4Color = Color(0xFF313034);
  static const Color p5Color = Color(0xFF0052CC);

  static const Color syncedColor = Color(0xFF2E7D32);
  static const Color pendingColor = Color(0xFFED6C02);
  static const Color failedColor = Color(0xFFBA1A1A);

  static const Color p1Bg = Color(0xFFFFDAD6);
  static const Color p2Bg = Color(0xFFFF8C00);
  static const Color p3Bg = Color(0xFF54A0FE);

  static List<DummyPatient> get patients => [
        const DummyPatient(
          id: '#492-AXB',
          name: 'Johnathan Doe',
          triageLevel: 'P1 - CRITICAL',
          triageColor: p1Color,
          symptoms: 'Respiratory Distress',
          location: 'Sector 7 - Ground Zero',
          nfcId: 'TAG-A42-990',
          createdAt: '12:30 PM',
          syncStatus: 'Synced',
          syncColor: syncedColor,
        ),
        const DummyPatient(
          id: '#493-BXC',
          name: 'Jane Smith',
          triageLevel: 'P3',
          triageColor: p3Color,
          symptoms: 'Minor Laceration',
          location: 'Sector 4 - Triage Tent',
          nfcId: 'TAG-B12-345',
          createdAt: '13:15 PM',
          syncStatus: 'Pending',
          syncColor: pendingColor,
        ),
        const DummyPatient(
          id: '#491-ABC',
          name: 'Unknown Male #402',
          triageLevel: 'P2',
          triageColor: p2Color,
          symptoms: 'Chest Trauma',
          location: 'Sector 7 - Ground Zero',
          nfcId: 'TAG-C78-901',
          createdAt: '14:35 PM',
          syncStatus: 'Synced',
          syncColor: syncedColor,
        ),
      ];

  static List<DummyQueueItem> get queue => [
        const DummyQueueItem(
          id: '1',
          name: 'John Doe',
          triageLevel: 'PRIORITY P1',
          triageColor: p1Color,
          createdAt: 'Created 14:22',
          syncStatus: 'Synced',
          syncColor: syncedColor,
        ),
        const DummyQueueItem(
          id: '2',
          name: 'Unknown Male #402',
          triageLevel: 'PRIORITY P2',
          triageColor: p2Color,
          createdAt: 'Created 14:35',
          syncStatus: 'Pending',
          syncColor: pendingColor,
        ),
        const DummyQueueItem(
          id: '3',
          name: 'Jane Smith',
          triageLevel: 'PRIORITY P3',
          triageColor: p3Color,
          createdAt: 'Created 14:40',
          syncStatus: 'Synced',
          syncColor: syncedColor,
        ),
        const DummyQueueItem(
          id: '4',
          name: 'Unknown Female #401',
          triageLevel: 'Expectant',
          triageColor: p4Color,
          createdAt: 'Created 14:10',
          syncStatus: 'Synced',
          syncColor: syncedColor,
        ),
      ];

  static List<DummyActivity> get recentActivity => [
        const DummyActivity(
          patientId: '#8294',
          patientName: 'Patient #8294',
          triageLevel: 'Triage P1',
          triageColor: p1Color,
          time: '14:02',
          syncStatus: 'cloud_off',
          syncColor: p1Color,
        ),
        const DummyActivity(
          patientId: '#8293',
          patientName: 'Patient #8293',
          triageLevel: 'Triage P3',
          triageColor: p3Color,
          time: '13:45',
          syncStatus: 'cloud_done',
          syncColor: syncedColor,
        ),
        const DummyActivity(
          patientId: '#8292',
          patientName: 'Patient #8292',
          triageLevel: 'Triage P2',
          triageColor: p2Color,
          time: '13:20',
          syncStatus: 'cloud_done',
          syncColor: syncedColor,
        ),
      ];

  static List<DummySyncRecord> get syncRecords => [
        const DummySyncRecord(
          id: '1',
          patientName: 'Johnathan Miller',
          triageLevel: 'P1',
          description: 'Critical Trauma',
          time: 'Today, 14:22 • Connection Timeout',
          status: 'Sync Failed',
          statusColor: failedColor,
          leftColor: failedColor,
          icon: Icons.sync_problem,
          iconBgColor: p1Bg,
          iconColor: failedColor,
        ),
        const DummySyncRecord(
          id: '2',
          patientName: 'Sarah Connor',
          triageLevel: 'P3',
          description: 'Minor Laceration',
          time: 'Today, 13:45 • Database ID: RT-4492',
          status: 'Synced',
          statusColor: syncedColor,
          leftColor: Color(0xFF0052CC),
          icon: Icons.done_all,
          iconBgColor: Color(0xFFDAE2FF),
          iconColor: Color(0xFF003D9B),
        ),
        const DummySyncRecord(
          id: '3',
          patientName: 'Unknown Male (Adult)',
          triageLevel: 'P2',
          description: 'Respiratory Distress',
          time: 'Today, 15:01 • Waiting for Network',
          status: 'Queued',
          statusColor: pendingColor,
          leftColor: Color(0xFF737685),
          icon: Icons.hourglass_empty,
          iconBgColor: Color(0xFFE5E1E7),
          iconColor: Color(0xFF434654),
        ),
        const DummySyncRecord(
          id: '4',
          patientName: 'Elena Rodriguez',
          triageLevel: 'P1',
          description: 'Cardiac Arrest',
          time: 'Yesterday, 23:58 • Invalid Metadata',
          status: 'Sync Failed',
          statusColor: failedColor,
          leftColor: failedColor,
          icon: Icons.priority_high,
          iconBgColor: p1Bg,
          iconColor: failedColor,
        ),
      ];

  static List<DummyTimelineEvent> get timelineEvents => [
        const DummyTimelineEvent(
          title: 'INITIAL ASSESSMENT',
          time: '12:30 PM',
          description:
              'Patient found unresponsive. Triage category set to P1 (Immediate). Airway secured manually.',
          dotColor: p1Color,
          cardColor: Color(0xFFEBE7EC),
        ),
        const DummyTimelineEvent(
          title: 'VITALS UPDATED',
          time: '12:38 PM',
          description: 'Pulse: 110 BPM | GCS: 8/15',
          dotColor: Color(0xFF005FAF),
          cardColor: Color(0xFFF1ECF2),
        ),
        const DummyTimelineEvent(
          title: 'TRANSPORT REQUESTED',
          time: '12:45 PM',
          description: 'Heli-Vac Unit 4 dispatched to Sector 7. ETA 8 minutes.',
          dotColor: Color(0xFF737685),
          cardColor: Color(0xFFF1ECF2),
        ),
      ];
}