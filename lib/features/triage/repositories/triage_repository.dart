import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/services/hive_service.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';

class TriageRepository {
  TriageRepository({required HiveService hiveService}) : _hive = hiveService;

  final HiveService _hive;

  Future<void> save(TriageRecord record) async {
    final box = _hive.getBox(AppConstants.triageBox);

    await box.put(record.id, record.toJson());
  }

  List<TriageRecord> getAll() {
    final box = _hive.getBox(AppConstants.triageBox);

    return box.values
        .map((e) => TriageRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TriageRecord? getById(String id) {
    final box = _hive.getBox(AppConstants.triageBox);

    final json = box.get(id);

    if (json == null) return null;

    return TriageRecord.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> delete(String id) async {
    final box = _hive.getBox(AppConstants.triageBox);

    await box.delete(id);
  }

  Future<void> update(TriageRecord record) async {
    final box = _hive.getBox(AppConstants.triageBox);

    await box.put(record.id, record.toJson());
  }
}
