import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/global/global.dart';
import 'package:kexie_app/models/borrow_record/borrow_record.dart';
import 'package:kexie_app/widgets/toast.dart';

import '../borrow_and_return/borrow_and_return.dart';

class BookBorrowRecordController extends GetxController {
  RxList<Record> records = <Record>[].obs;
  BorrowAndReturn borrowAndReturn = BorrowAndReturn();
  var isReturning = false.obs;

  Future<void> getRecords(String studentId) async {
    try {
      final dio = AppNetwork.get().appDio;
      final response = await dio.get('/book/borrow_record',
          queryParameters: {'student_id': studentId});
      if (response.data['code'] == 200) {
        BorrowRecord borrowRecord = BorrowRecord.fromJson(response.data);
        records.value = borrowRecord.record.reversed.toList();
      } else {
        toastFailure(message: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '获取记录失败', error: e);
    }
  }

  String timeToString(String timeStamp) {
    DateTime time = DateTime.parse(timeStamp);
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
    return formattedTime;
  }

}
