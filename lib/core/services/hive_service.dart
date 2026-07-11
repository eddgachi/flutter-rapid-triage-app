import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class HiveService {
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      await Hive.openBox(AppConstants.authBox);
      await Hive.openBox(AppConstants.settingsBox);
      await Hive.openBox(AppConstants.triageBox);
    } catch (e) {
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  Future<void> clearBox(String name) async {
    await Hive.box(name).clear();
  }

  Future<void> deleteBox(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
