import 'package:flutter/material.dart';
import '../models/record.dart';
import '../utils/database_helper.dart';

class RecordProvider with ChangeNotifier {
  List<Record> _records = [];
  bool _isLoading = false;

  List<Record> get records => _records;
  bool get isLoading => _isLoading;

  int get totalCount => _records.length;

  Map<String, int> get categoryStats {
    Map<String, int> stats = {};
    for (var record in _records) {
      stats[record.category] = (stats[record.category] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await DatabaseHelper.instance.getRecords();
    } catch (e) {
      print('기록 로딩 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(Record record) async {
    try {
      await DatabaseHelper.instance.insertRecord(record);
      await loadRecords();
    } catch (e) {
      print('기록 추가 실패: $e');
      rethrow;
    }
  }

  Future<void> deleteRecord(int id) async {
    try {
      await DatabaseHelper.instance.deleteRecord(id);
      await loadRecords();
    } catch (e) {
      print('기록 삭제 실패: $e');
      rethrow;
    }
  }

  Future<void> updateRecord(Record record) async {
    try {
      await DatabaseHelper.instance.updateRecord(record);
      await loadRecords();
    } catch (e) {
      print('기록 수정 실패: $e');
      rethrow;
    }
  }
}