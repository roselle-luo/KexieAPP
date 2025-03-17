import 'package:dio/dio.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/widgets/toast.dart';

class BorrowAndReturn {

  Future<bool> borrowBook(String isbn,String planTime) async {
    FormData formData = FormData.fromMap({
      'isbn': isbn,
      'plan_borrow_time': planTime,
    });
    try {
      final dio = AppNetwork.get().appDio;
      print(isbn);
      Response response = await dio.post('/book/borrow',data: formData);
      print(response.data.toString());
      if (response.data['code'] == 200) {
        toastSuccess(message: response.data['msg']);
        return true;
      } else {
        toastFailure(message: response.data['msg']);
        return false;
      }
    } on Exception catch (e) {
      toastFailure(message: '借阅失败',error: e.toString());
      return false;
    }
  }

  Future<bool> returnBook(String isbn) async {
    FormData formData = FormData.fromMap({
      'isbn': isbn,
    });
    try {
      final dio = AppNetwork.get().appDio;
      final Response response = await dio.post('/book/return',data: formData);
      if (response.data['code'] == 200) {
        toastSuccess(message: response.data['msg']);
        return true;
      } else {
        toastFailure(message: response.data['msg']);
        return false;
      }
    } on Exception catch (e) {
      toastFailure(message: '归还失败',error: e.toString());
      return false;
    }
  }

  static final BorrowAndReturn _instance = BorrowAndReturn._internal();

  factory BorrowAndReturn() => _instance;

  BorrowAndReturn._internal();
}