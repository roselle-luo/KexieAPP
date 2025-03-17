import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../internet/network.dart';
import '../../global/global.dart';
import '../../models/signRecords/signRecords.dart';
import '../../widgets/toast.dart';

class SignRecordController extends GetxController {
  RxList<String> terms = <String>[].obs;
  RxList<Data> records = <Data>[].obs;
  RxString selectedTerm = ''.obs;
  final ScrollController scrollController = ScrollController();

  String formatTerm(String term) {
    // 拆分输入字符串
    final parts = term.split('_');
    if (parts.length != 3) {
      throw ArgumentError('Invalid format. Expected format is "yyyy_yyyy_n"');
    }
    final startYear = parts[0];
    final endYear = parts[1];
    final semesterCode = int.tryParse(parts[2]);

    if (semesterCode == null || (semesterCode != 1 && semesterCode != 2)) {
      throw ArgumentError('Invalid semester code. Must be 1 (上学期) or 2 (下学期).');
    }
    // 格式化学期
    final semester = semesterCode == 1 ? '上学期' : '下学期';
    // 拼接最终结果
    return '$startYear-$endYear$semester';
  }

  getTerms() async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response =
          await dio.get('/api/record/term/${Global.user.value.studentId}');
      if (response.data['code'] == 0) {
        terms.value = List<String>.from(response.data['data']);
        selectedTerm.value = terms.first;
      } else {
        toastFailure(message: '获取学期失败', error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '获取学期失败', error: e.toString());
    }
  }

  getRecords({String? term}) async {
    dios.Dio dio = AppNetwork.get().kexieDio;
    try {
      dios.Response response = await dio
          .get('/api/record/${Global.user.value.studentId}/${term ?? ''}');
      if (response.data['code'] == 0) {
        SignRecords signRecords = SignRecords.fromJson(response.data);
        records.clear();
        records.addAll(signRecords.data);
        filterRecords();
      } else {
        toastFailure(message: '获取记录失败', error: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '获取记录失败', error: e.toString());
    }
  }

  Future<void> initRecordData() async {
    await getTerms();
    await getRecords();
  }

  void filterRecords() {
    records.removeWhere((record) {
      return record.status == '已签退' &&
          calculateTotalTime(record.start, record.end,record.status) < 0.05;
    });
  }

  void toTop() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  double calculateTotalTime(String start, String end,String status) {
    if (status == '被迫下线') {
      return 100;
    }
    DateTime startTime = DateTime.parse(start);
    DateTime endTime;
    if (end.isNotEmpty) {
      endTime =  DateTime.parse(end);
      Duration duration = endTime.difference(startTime);
      double totalTime = duration.inMinutes / 60;
      return double.parse(totalTime.toStringAsFixed(2));
    }
    return 100;
  }
}
