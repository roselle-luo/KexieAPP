import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/widgets/loading_view.dart';
import '../../widgets/toast.dart';

class SendPostController extends GetxController {

  final contentController = TextEditingController();
  final imagePicker = ImagePicker();
  var contentIsNotBlank = false.obs;
  var textNum = 0.obs;
  var images = <XFile>[].obs;
  var upLoading = false.obs;
  var isEmojiVisible = false.obs;


  void toggleEmojiPicker() {
    isEmojiVisible.value = !isEmojiVisible.value;
  }


  void pickImage() async {
    if (images.length < 9) {
      final pickedFile = await imagePicker.pickMultiImage();
      images.addAll(pickedFile);
    } else {
      toastFailure(
          error: '\n一次最多上传9张图片捏',
          message: '图片已达到上限',
          toastGravity: ToastGravity.TOP);
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> imagesPaths = [];
    try {
      final multipartFiles = await Future.wait(
        images.map((image) async {
          return MultipartFile.fromFile(image.path, filename: image.name);
        }).toList(),
      );
      final formData = FormData.fromMap({
        'images': multipartFiles,
      });
      final dio = AppNetwork.get().appDio;
      final response = await dio.post('/forum/upload_images', data: formData);
      if (response.data['code'] == 200) {
        imagesPaths.addAll((response.data['data'] as List).map((e) => e.toString()).toList());
        return imagesPaths;
      } else {
        toastFailure(message: response.data['msg']);
        return imagesPaths;
      }
    } on Exception catch (e) {
      toastFailure(message: e.toString());
      return imagesPaths;
    }
  }

  Future<void> uploadPost(BuildContext context, {int? parentId}) async {
    List<String> imgUrls = [];
    LoadingView.show(context, text: "正在上传中...");
    try {
      final dio = AppNetwork.get().appDio;
      String content = contentController.text.toString();
      if (images.isNotEmpty) {
        imgUrls = await uploadImages();
        if (imgUrls.isEmpty) {
          toastFailure(message: '上传图片失败');
          return;
        }
      }
      Map<String,dynamic> data = {
        "images": imgUrls,
        "text": content,
        "parent_id": parentId,
      };
      final response = await dio.post('/forum/upload_post', data: data);
      if (response.data['code'] == 200) {
        clearAll();
        toastSuccess(message: "上传成功", toastGravity: ToastGravity.CENTER);
      } else {
        print(response.data['msg']);
        toastFailure(message: response.data['msg'], toastGravity: ToastGravity.CENTER);
      }
    } on Exception catch (e) {
      print(e.toString());
      toastFailure(message: '上传失败：', error: e, toastGravity: ToastGravity.CENTER);
    } finally {
      LoadingView.hide(context);
    }
  }

  void clearAll() {
    contentController.clear();
    images.clear();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    contentController.addListener(() {
      textNum.value = contentController.value.text.length;
      contentIsNotBlank.value = contentController.text.trim().isNotEmpty;
    });
  }
}
