import 'package:dio/dio.dart' as dios;
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/models/book_infomation/book_infomation.dart';
import 'package:kexie_app/widgets/toast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../widgets/scan.dart';

class BookBorrowController extends GetxController{

  Rx<BookInfomation> bookInformation = BookInfomation(code: 0, result: false, msg: '', data: []).obs;
  final controller = ZoomDrawerController();
  var isColumn = false.obs;
  
  Future getBooks() async {
    try {
      final dio = AppNetwork.get().appDio;
      final response = await dio.get('/book/get_books');
      if (response.statusCode == 200) {
        bookInformation.value.data.clear();
        bookInformation.value = BookInfomation.fromJson(response.data);
        List<Data> originalData = List.from(bookInformation.value.data);
        // for (int i=0;i<5;i++) {
        //   bookInformation.value.data.addAll(originalData);
        // }
      } else {
        toastFailure(message: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '获取书籍信息失败',error: e.toString());
    }
  }

  Future<String> scanBookQrCode() async {
    BarcodeCapture result = await Get.to(Scan());
    String isbn = result.barcodes.first.rawValue.toString();
    return isbn;
  }

  Future addBooks(String isbn) async {
    try {
      final dio = AppNetwork.get().appDio;
      dios.FormData formData = dios.FormData.fromMap({
        'isbn': isbn
      });
      final response = await dio.post('/book/add_books',data: formData);
      if (response.data['code'] == 200) {
        await getBooks();
        toastSuccess(message: '添加成功');
      } else {
        toastFailure(message: response.data['msg']);
      }
    } on Exception catch (e) {
      toastFailure(message: '添加书籍失败',error: e.toString());
    }
  }

  @override
  void onInit() {
    getBooks();
    super.onInit();
  }

}